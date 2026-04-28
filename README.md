# SafeWalk

Aplicación móvil colaborativa que ayuda a los usuarios a identificar y evitar zonas potencialmente peligrosas durante sus desplazamientos a pie. Los usuarios pueden visualizar un mapa con puntos reportados, registrar sus caminatas con GPS y recibir notificaciones cuando se acercan a una zona insegura.

## Stack

| Capa     | Tecnología                                                  |
| -------- | ----------------------------------------------------------- |
| App      | Flutter (Dart) — MVVM con `provider` + `go_router`          |
| Mapa     | `flutter_map` + tiles OpenStreetMap                         |
| GPS      | `geolocator`                                                |
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
│   ├── config/      # baseUrl de la API
│   ├── router/      # go_router con redirección por auth
│   └── theme/       # tema visual
├── models/          # Usuario, Ubicacion, ZonaPeligrosa, Caminata, Notificacion
├── services/        # ApiClient, AuthService, GpsService, ...
├── viewmodels/      # ChangeNotifier por feature
└── views/           # auth/, home/, mapa/
```

Las vistas observan ViewModels vía `provider`; los ViewModels delegan E/S en services; los services hablan con la API o con sensores.

## Estructura del repo

```
.
├── lib/                    # Flutter app
├── backend/                # API Dart (shelf)
│   ├── bin/server.dart
│   ├── lib/
│   │   ├── routes/         # /auth/{register,login,me}
│   │   ├── repositories/
│   │   └── middleware/     # JWT
│   └── Dockerfile
├── db/init.sql             # Schema Postgres
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

> **Nota:** en emulador Android, `ApiConfig` usa `http://10.0.2.2:8080` (alias del host). En dispositivo físico hay que reemplazar la URL en `lib/core/config/api_config.dart` por la IP de la máquina en la LAN.

## Endpoints del backend

| Método | Path             | Descripción                                     |
| ------ | ---------------- | ----------------------------------------------- |
| GET    | `/healthz`       | Liveness                                        |
| POST   | `/auth/register` | `{nombre, email, password}` → `{usuario, token}` |
| POST   | `/auth/login`    | `{email, password}` → `{usuario, token}`         |
| GET    | `/auth/me`       | Requiere `Authorization: Bearer <jwt>`          |

Errores: `400` validación, `401` credenciales/token, `409` email duplicado.

Ejemplo:

```bash
curl -X POST http://localhost:8080/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"nombre":"Ana","email":"ana@safewalk.com","password":"miPassword123"}'
```

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

| ID    | Estado | Detalle                                                                |
| ----- | ------ | ---------------------------------------------------------------------- |
| RF01  | ✅     | Registro y login con persistencia en Postgres                           |
| RF02  | ⏳     | Modelo y endpoints listos, falta UI de edición de perfil                |
| RF03  | ✅     | Mapa OSM con ubicación actual del usuario                               |
| RF04  | ⏳     | Modelo `ZonaPeligrosa` y `MapaViewModel` preparados; falta endpoint+UI |
| RF05  | ⏳     | `NotificacionService` con stub                                          |
| RF06  | ⏳     | Pendiente                                                              |
| RF07  | ⏳     | `GpsService` listo (stream); falta persistencia de caminatas            |
| RF08  | ⏳     | Pendiente                                                              |
| RNF01 | ✅     | Flutter                                                                |
| RNF02 | ✅     | MVVM                                                                   |
| RNF03 | ✅     | GPS vía `geolocator`                                                   |
| RNF07 | ✅     | bcrypt + JWT + secure storage                                          |

## Tests

```bash
flutter test          # widget tests
```

## Comandos útiles

```bash
docker compose logs -f backend                              # logs del API
docker compose exec postgres psql -U safewalk -d safewalk   # consola SQL
docker compose down -v                                       # reset total (borra volumen)
```

## Licencia

Proyecto académico — uso individual.
