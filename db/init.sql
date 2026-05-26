CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE usuarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  foto_perfil TEXT,
  tipo_cuenta TEXT NOT NULL DEFAULT 'gratuita',
  fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_usuarios_email ON usuarios (email);

CREATE TABLE IF NOT EXISTS zonas_peligrosas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  categoria TEXT NOT NULL DEFAULT 'general',
  lat DOUBLE PRECISION NOT NULL,
  lon DOUBLE PRECISION NOT NULL,
  radio_m INTEGER NOT NULL DEFAULT 75,
  reportada_por UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  fecha_reporte TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_zonas_latlon ON zonas_peligrosas (lat, lon);

INSERT INTO zonas_peligrosas (nombre, descripcion, categoria, lat, lon, radio_m) VALUES
  ('Plaza Seregni - poca iluminación', 'Zona con baja iluminación durante la noche', 'iluminacion', -34.8978, -56.1700, 120),
  ('Bajada del Buceo', 'Reportes de asaltos en horas nocturnas', 'asaltos', -34.9082, -56.1430, 100),
  ('Cordón sur peatonal', 'Vandalismo recurrente', 'vandalismo', -34.9095, -56.1830, 80),
  ('Parque Rodó borde sur', 'Zona oscura, evitar de noche', 'iluminacion', -34.9180, -56.1670, 150);
