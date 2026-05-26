# SafeWalk — Guion de presentación

Documento base para exponer el sistema. Cada sección lista los puntos a tocar; el orador desarrolla con ejemplos y demo en vivo.

---

## 1. ¿Qué es SafeWalk?

- Aplicación móvil **colaborativa** que ayuda a las personas a caminar de forma segura por la ciudad.
- Los usuarios **reportan** zonas peligrosas y la app **calcula rutas** que las evitan.
- Backend propio (datos de usuarios y zonas) + capas open-source (OSM, OSRM, Nominatim).
- Demo en vivo: registro → ubicación → buscar destino → ruta segura visible.

---

## 2. Problema que resuelve

- Caminar por una ciudad desconocida (turismo) o en horas inseguras (locales) implica **información asimétrica**: Google Maps optimiza por distancia/tiempo, no por riesgo.
- Las advertencias hoy circulan por **WhatsApp, redes y boca a boca** — no son consultables al momento de elegir un camino.
- Falta un **canal único, geolocalizado y comunitario** para que los reportes lleguen al peatón en el momento de decidir.

---

## 3. Casos de uso

### Turismo
- Turista llega a una ciudad nueva, no conoce barrios, idioma o costumbres.
- Quiere caminar entre el hotel y los puntos turísticos por el camino más **seguro**, no el más corto.
- SafeWalk muestra zonas reportadas por **locales** y propone una ruta que las esquiva.

### Ciudades grandes
- Residentes que se mueven a horas atípicas (vuelta del trabajo nocturno, salidas, etc.).
- Estudiantes que recorren a pie tramos largos hacia la facultad.
- Padres que quieren saber qué cuadras evita el trayecto escolar de sus hijos.

### Casos derivados
- Recorridos para **runners** y ciclistas urbanos.
- Apoyo a campañas municipales de **iluminación / arreglo de veredas** con datos reales.

---

## 4. Demo (5 min)

1. **Login** → entra directo al mapa.
2. **Header flotante** + avatar con la inicial del usuario.
3. **Zonas peligrosas** ya visibles (círculos rojos sobre Montevideo).
4. **Buscar destino** ("Pocitos") → seleccionar resultado.
5. **Trazar ruta segura** → polilínea verde que esquiva las zonas; en gris, las rutas descartadas.
6. **Long-press** en un punto del mapa → reportar nueva zona → aparece círculo rojo nuevo y se persiste.
7. **Perfil** → ver datos, ir a **Configuración**.

---

## 5. Stack tecnológico

| Capa       | Tecnología                                  | Por qué                                            |
| ---------- | ------------------------------------------- | -------------------------------------------------- |
| App        | Flutter (Dart) — MVVM con `provider`        | Un solo codebase para Android/iOS/web/desktop      |
| Mapa       | `flutter_map` + tiles OpenStreetMap         | Open-source, sin costos por uso                    |
| GPS        | `geolocator`                                | API uniforme entre plataformas                     |
| Ruteo      | OSRM público (perfil `foot`)                | Rutas alternativas peatonales gratis               |
| Geocoding  | Nominatim (OSM)                             | Búsqueda de direcciones gratis                     |
| Backend    | Dart (`shelf` + `shelf_router`)             | Mismo lenguaje que el cliente, deploy simple       |
| Auth       | bcrypt + JWT (HS256)                        | Estándar, sin dependencias externas                |
| BD         | PostgreSQL 16                               | Confiable, soporta extensiones espaciales (PostGIS)|
| Infra      | Docker Compose                              | "Una sola línea" para levantar todo en cualquier máquina |

---

## 6. Arquitectura

```
┌──────────────┐  HTTP/JSON  ┌──────────────┐   SQL   ┌────────────┐
│ Flutter app  │ ──────────► │ Backend Dart │ ──────► │ PostgreSQL │
│ (MVVM)       │ ◄────────── │ (shelf)      │ ◄────── │            │
└──────┬───────┘  JWT header └──────────────┘         └────────────┘
       │
       ├─ OSRM público   (ruteo)
       └─ Nominatim       (geocoding)
```

### MVVM en la app
- **Views**: widgets Flutter, sólo UI.
- **ViewModels**: `ChangeNotifier` con la lógica de pantalla.
- **Services**: HTTP, GPS, ruteo, geocoding — todo lo I/O.
- **Models**: `Usuario`, `Ubicacion`, `ZonaPeligrosa`, `RutaCandidata`.

### Backend (capas)
- **Routes** → reciben HTTP, validan, devuelven JSON.
- **Repositories** → SQL contra Postgres.
- **Middleware** → `requireAuth()` (JWT) e inyección de `usuarioId`.

---

## 7. Modelo de negocio

### Capa gratuita
- Visualización del mapa con zonas reportadas.
- Reportar zonas peligrosas.
- Una ruta segura por trayecto.

### Capa **SafeWalk +** (suscripción mensual)
- **Múltiples rutas alternativas** ordenadas por seguridad/distancia/tiempo.
- **Rutas turísticas curadas** (recorridos seguros entre puntos de interés).
- **Optimización por preferencias**: "evitar avenidas", "preferir zonas iluminadas", "evitar cruces peligrosos".
- **Modo offline** del mapa de la ciudad seleccionada (útil para turistas sin datos).
- **Alertas en tiempo real** de zonas nuevas mientras se camina.
- **Historial de caminatas** con estadísticas.

### Recompensa por reportes
- Los usuarios que **reportan zonas validadas por la comunidad** obtienen suscripción mensual.
- Sistema de **karma comunitario**: confiabilidad del reporte (votos positivos) → más recompensa.
- Combate el incentivo a reportes falsos y construye la base de datos sin costo directo.

### Ingresos
1. **Suscripción individual** mensual/anual (SafeWalk+).
2. **Convenios con municipios y turismo** — datasets agregados de zonas evitadas para informar políticas públicas (iluminación, presencia policial, mantenimiento de veredas).
3. **API B2B** — hoteles, agencias de turismo y plataformas de delivery pueden consumir rutas seguras vía API.
4. **Financiamiento inicial**: rondas de inversión semilla, programas de innovación urbana, fondos de transporte sostenible.

---

## 8. Por qué la suscripción tiene sentido

- **Turismo**: un turista paga sin dudar **3-5 USD** por una semana si garantiza moverse seguro en una ciudad desconocida. Es menos que un taxi.
- **Residentes**: 2-3 USD/mes equivale a un café, y se ahorra "vueltas" innecesarias para esquivar zonas.
- **Diferencial vs. Google Maps**: ellos optimizan por **tiempo**; nosotros por **seguridad percibida + comunidad**.
- **Network effect**: cuantos más usuarios reportan, mejores rutas → más usuarios pagan → ciclo virtuoso.

---

## 9. Hoja de ruta (post-demo)

| Fase | Entregable                                                       |
| ---- | ---------------------------------------------------------------- |
| MVP  | Lo que vimos hoy: auth, zonas, ruta segura, reporte por long-press |
| v0.2 | Sistema de votos y validación comunitaria de zonas                |
| v0.3 | Suscripción + múltiples rutas alternativas                        |
| v0.4 | Rutas turísticas curadas para Montevideo, BA, Madrid              |
| v0.5 | Notificaciones push de proximidad                                 |
| v1.0 | API B2B y dashboard para municipios                               |

---

## Anexos para la presentación

- **Capturas**: login, mapa con zonas, ruta trazada, panel de perfil, configuración.
- **Demo de respaldo**: video de 60 s grabado por si falla el wifi.
- **Pricing comparativo**: Google Maps (gratis pero sin seguridad), Waze (autos), Citymapper (transporte) — ninguno cubre el peatón con foco en seguridad.
