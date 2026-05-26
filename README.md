# SafeWalk

Aplicación móvil colaborativa que ayuda a los usuarios a identificar y evitar zonas potencialmente peligrosas durante sus desplazamientos a pie. Los usuarios pueden visualizar un mapa con puntos reportados, registrar sus caminatas con GPS y recibir notificaciones cuando se acercan a una zona insegura.

## Stack

| Capa     | Tecnología                                                  |
| -------- | ----------------------------------------------------------- |
| App      | Flutter (Dart) — MVVM con `provider` + `go_router`          |
| Mapa     | `flutter_map` + tiles OpenStreetMap                         |
| GPS      | `geolocator`                                                |
| Ruteo    | OSRM público (`router.project-osrm.org`, perfil `foot`)     |
| Geocoding| Nominatim (`nominatim.openstreetmap.org`)                   |
| Backend  | Dart (`shelf` + `shelf_router`)                             |
| Auth     | bcrypt (hashing) + JWT (HS256)                              |
| BD       | PostgreSQL 16                                               |
| Infra    | Docker Compose                                              |

## Arquitectura

```
┌──────────────┐      HTTP/JSON      ┌──────────────┐      SQL      ┌────────────┐
│ Flutter app  │ ──────────────────► │ Backend Dart │ ────────────► │ PostgreSQL │
│ (MVVM)       │ ◄────────────────── │ (shelf)      │ ◄──────────── │            │
└──────────────┘   JWT en header     └──────────────┘               └────────────┘
        │
        └─ flutter_secure_storage (JWT)
        └─ geolocator (GPS)
        └─ flutter_map (tiles OSM)
```

### MVVM en la app

```
lib/
├── core/
│   ├── config/      # baseUrl de la API (override por --dart-define)
│   ├── router/      # go_router con redirección por auth
│   └── theme/       # tema visual
├── models/          # Usuario, Ubicacion, ZonaPeligrosa, Caminata, Notificacion
├── services/        # ApiClient, AuthService, GpsService,
│                    # ZonaPeligrosaService, RuteoService, GeocodingService
├── viewmodels/      # ChangeNotifier por feature
└── views/           # auth/, home/, mapa/ (con widgets/ para sheets y diálogos)
```

Las vistas observan ViewModels vía `provider`; los ViewModels delegan E/S en services; los services hablan con la API o con sensores.

## Estructura del repo

```
.
├── lib/                    # Flutter app
│   ├── core/               # config, router, theme
│   ├── models/             # Usuario, Ubicacion, ZonaPeligrosa, ...
│   ├── services/           # ApiClient, AuthService, GpsService,
│   │                       # ZonaPeligrosaService, RuteoService, GeocodingService
│   ├── viewmodels/
│   └── views/
│       ├── auth/
│       ├── home/
│       └── mapa/
│           └── widgets/    # BuscarDestinoSheet, ReportarZonaDialog
├── backend/                # API Dart (shelf)
│   ├── bin/server.dart
│   ├── lib/
│   │   ├── routes/         # auth_routes.dart, zona_routes.dart
│   │   ├── repositories/   # usuario_repository.dart, zona_repository.dart
│   │   └── middleware/     # JWT
│   └── Dockerfile
├── db/init.sql             # Schema Postgres (usuarios, zonas_peligrosas + seeds)
├── docker-compose.yml
└── .env.example
```

## Requisitos

- Docker + Docker Compose
- Flutter SDK ≥ 3.11.4 (con Dart 3.5+)
- Para móvil: Android Studio (emulador) o un dispositivo físico

## Puesta en marcha

### 1. Backend + base de datos

```bash
cp .env.example .env
docker compose up -d --build
```

Esto levanta:
- `postgres` en `localhost:5432` (init.sql se aplica la primera vez)
- `backend` en `localhost:8080`

Verificación rápida:

```bash
curl http://localhost:8080/healthz
# {"status":"ok"}
```

### 2. App Flutter

```bash
flutter pub get
flutter run
```

> **Nota:** en emulador Android, `ApiConfig` usa `http://10.0.2.2:8080` (alias del host). En iOS simulator / desktop usa `localhost`. Para dispositivo físico, pasar la IP de la LAN por `--dart-define`:
>
> ```bash
> flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8080
> ```

## Endpoints del backend

| Método | Path             | Auth | Descripción                                                                |
| ------ | ---------------- | ---- | -------------------------------------------------------------------------- |
| GET    | `/healthz`       | —    | Liveness                                                                   |
| POST   | `/auth/register` | —    | `{nombre, email, password}` → `{usuario, token}`                            |
| POST   | `/auth/login`    | —    | `{email, password}` → `{usuario, token}`                                    |
| GET    | `/auth/me`       | JWT  | Devuelve el usuario asociado al token                                       |
| GET    | `/zonas`         | —    | Lista todas las zonas peligrosas con `lat`, `lon`, `radioMetros`, categoría |
| POST   | `/zonas`         | JWT  | `{nombre, descripcion?, categoria, lat, lon, radioMetros}` → `{zona}`       |

Errores: `400` validación, `401` credenciales/token, `409` email duplicado.

Ejemplos:

```bash
# Registrar usuario
curl -X POST http://localhost:8080/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"nombre":"Ana","email":"ana@safewalk.com","password":"miPassword123"}'

# Listar zonas
curl http://localhost:8080/zonas

# Reportar zona (requiere JWT del login/register)
curl -X POST http://localhost:8080/zonas \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"nombre":"Esquina mal iluminada","categoria":"iluminacion","lat":-34.9,"lon":-56.16,"radioMetros":80}'
```

## Esquema de base de datos

```sql
usuarios          (id UUID, nombre, email UNIQUE, password_hash, foto_perfil,
                   tipo_cuenta, fecha_creacion)

zonas_peligrosas  (id UUID, nombre, descripcion, categoria, lat, lon, radio_m,
                   reportada_por UUID → usuarios(id), fecha_reporte)
```

`init.sql` inserta 4 zonas seed en Montevideo (Plaza Seregni, Bajada del Buceo, Cordón sur, Parque Rodó) para que la demo de ruta segura tenga zonas que evitar.

## Ruta segura

El cliente arma la ruta combinando tres servicios:

1. **Geocoding** — `GeocodingService` consulta Nominatim filtrando por Uruguay; el usuario elige el destino desde un bottom sheet con sugerencias.
2. **Ruteo** — `RuteoService` pide al OSRM público varias rutas alternativas a pie entre origen y destino (`alternatives=true`, geometría GeoJSON).
3. **Selector seguro** — `seleccionarRutaSegura()` cuenta cuántos puntos de cada polilínea caen dentro del radio de alguna `ZonaPeligrosa` (usando `Geolocator.distanceBetween`) y elige la ruta con menos intrusiones; en empate, la más corta.

La ruta elegida se dibuja en verde sobre el mapa, las descartadas quedan en gris tenue, y las zonas se renderizan como círculos rojos semitransparentes (`CircleLayer` con `useRadiusInMeter: true`). Un long-press sobre el mapa abre un diálogo para reportar una nueva zona (`POST /zonas`).

> ⚠️ El OSRM público (`router.project-osrm.org`) y Nominatim son apropiados para demo, **no para producción** (rate limit, sin SLA). En producción hay que self-hostear OSRM y respetar la política de uso de Nominatim.

## Seguridad

- Las contraseñas se almacenan como hash **bcrypt** (cost 10). Nunca se guardan en claro ni viajan al cliente después del registro.
- La autenticación usa **JWT HS256** con expiración de 7 días. El secreto se inyecta vía variable de entorno `JWT_SECRET`.
- En el cliente, el JWT se guarda en `flutter_secure_storage` (Keychain en iOS, EncryptedSharedPreferences en Android).
- En desarrollo, el tráfico es HTTP plano. Para producción se debe poner un reverse proxy con TLS (no incluido en este compose).

## Variables de entorno

Definidas en `.env` (ver `.env.example`):

| Variable            | Descripción                          |
| ------------------- | ------------------------------------ |
| `POSTGRES_DB`       | Nombre de la base                    |
| `POSTGRES_USER`     | Usuario de la base                   |
| `POSTGRES_PASSWORD` | Password de la base                  |
| `JWT_SECRET`        | Secreto para firmar tokens (rotable) |

## Requisitos cubiertos

| ID    | Estado | Detalle                                                                          |
| ----- | ------ | -------------------------------------------------------------------------------- |
| RF01  | ✅     | Registro y login con persistencia en Postgres                                     |
| RF02  | ⏳     | Modelo y endpoints listos, falta UI de edición de perfil                          |
| RF03  | ✅     | Mapa OSM con ubicación actual del usuario                                         |
| RF04  | ✅     | Tabla `zonas_peligrosas` + `GET/POST /zonas` + render como círculos en el mapa + diálogo de reporte por long-press |
| RF05  | ⏳     | `NotificacionService` con stub                                                    |
| RF06  | ✅     | Ruta segura: Nominatim para destino, OSRM para alternativas, selector por intrusiones, polilínea verde sobre el mapa |
| RF07  | ⏳     | `GpsService` listo (stream); falta persistencia de caminatas                      |
| RF08  | ⏳     | Pendiente                                                                        |
| RNF01 | ✅     | Flutter                                                                          |
| RNF02 | ✅     | MVVM                                                                             |
| RNF03 | ✅     | GPS vía `geolocator`                                                             |
| RNF07 | ✅     | bcrypt + JWT + secure storage                                                    |

## Tests

```bash
flutter test          # widget tests
```

Cobertura actual: 1 widget test (`test/widget_test.dart`) que verifica que el login renderice. Sin tests de unidad para servicios/viewmodels ni tests de backend. Candidatos prioritarios: `seleccionarRutaSegura`, `ZonaPeligrosa.fromJson`, validaciones de `POST /zonas`.

## Comandos útiles

```bash
docker compose logs -f backend                              # logs del API
docker compose exec postgres psql -U safewalk -d safewalk   # consola SQL
docker compose down -v                                       # reset total (borra volumen)
```

## Licencia

Proyecto académico — uso individual.
