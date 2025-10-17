-- =====================================================
-- FASE 1: OPTIMIZACIONES SISTEMA GANADERO
-- Tablas para Calendario, Selección Avanzada y Movimientos
-- =====================================================

-- Tabla para eventos del calendario
CREATE TABLE eventos_calendario (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo VARCHAR(50) NOT NULL, -- 'celo', 'parto', 'servicio', 'vacuna', 'tratamiento', 'tarea'
  titulo VARCHAR(200) NOT NULL,
  descripcion TEXT,
  fecha_evento DATE NOT NULL,
  fecha_alerta DATE,
  animal_id UUID REFERENCES animales(id),
  usuario_id UUID REFERENCES auth.users(id),
  completado BOOLEAN DEFAULT FALSE,
  prioridad VARCHAR(20) DEFAULT 'media', -- 'alta', 'media', 'baja'
  color VARCHAR(7) DEFAULT '#3B82F6',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla para movimientos de animales
CREATE TABLE movimientos_animales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  animal_id UUID REFERENCES animales(id),
  tipo_movimiento VARCHAR(50) NOT NULL, -- 'llegada', 'partida', 'transferencia', 'venta', 'exportacion'
  origen VARCHAR(100),
  destino VARCHAR(100),
  fecha_movimiento DATE NOT NULL,
  motivo TEXT,
  precio DECIMAL(10,2),
  peso DECIMAL(8,2),
  documentos JSONB, -- Para almacenar referencias a documentos
  usuario_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla para filtros personalizados
CREATE TABLE filtros_personalizados (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES auth.users(id),
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  criterios JSONB NOT NULL, -- Almacena los criterios de filtrado
  publico BOOLEAN DEFAULT FALSE,
  favorito BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla para etiquetas de animales
CREATE TABLE etiquetas_animales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  animal_id UUID REFERENCES animales(id),
  etiqueta VARCHAR(50) NOT NULL,
  color VARCHAR(7) DEFAULT '#3B82F6',
  descripcion TEXT,
  usuario_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(animal_id, etiqueta)
);

-- Tabla para listas personalizadas de animales
CREATE TABLE listas_personalizadas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  usuario_id UUID REFERENCES auth.users(id),
  animales_ids UUID[] DEFAULT '{}',
  criterios_automaticos JSONB, -- Para listas dinámicas
  es_dinamica BOOLEAN DEFAULT FALSE,
  publico BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla para configuración del calendario
CREATE TABLE configuracion_calendario (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES auth.users(id),
  vista_predeterminada VARCHAR(20) DEFAULT 'mes', -- 'dia', 'semana', 'mes'
  alertas_activas BOOLEAN DEFAULT TRUE,
  dias_anticipacion_alerta INTEGER DEFAULT 7,
  colores_eventos JSONB DEFAULT '{}',
  notificaciones_email BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(usuario_id)
);

-- Tabla para trabajo diario/tareas programadas
CREATE TABLE trabajo_diario (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo VARCHAR(200) NOT NULL,
  descripcion TEXT,
  fecha_programada DATE NOT NULL,
  fecha_completado DATE,
  prioridad VARCHAR(20) DEFAULT 'media',
  categoria VARCHAR(50), -- 'ordeño', 'alimentacion', 'sanidad', 'reproduccion', 'mantenimiento'
  animal_id UUID REFERENCES animales(id),
  lote_id UUID REFERENCES lotes(id),
  usuario_asignado UUID REFERENCES auth.users(id),
  usuario_creador UUID REFERENCES auth.users(id),
  completado BOOLEAN DEFAULT FALSE,
  notas TEXT,
  tiempo_estimado INTEGER, -- en minutos
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla para historial de búsquedas
CREATE TABLE historial_busquedas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES auth.users(id),
  termino_busqueda VARCHAR(200) NOT NULL,
  tipo_busqueda VARCHAR(50), -- 'animal', 'lote', 'general'
  resultados_encontrados INTEGER DEFAULT 0,
  filtros_aplicados JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para optimizar consultas
CREATE INDEX idx_eventos_calendario_fecha ON eventos_calendario(fecha_evento);
CREATE INDEX idx_eventos_calendario_animal ON eventos_calendario(animal_id);
CREATE INDEX idx_eventos_calendario_usuario ON eventos_calendario(usuario_id);
CREATE INDEX idx_eventos_calendario_tipo ON eventos_calendario(tipo);

CREATE INDEX idx_movimientos_animales_fecha ON movimientos_animales(fecha_movimiento);
CREATE INDEX idx_movimientos_animales_animal ON movimientos_animales(animal_id);
CREATE INDEX idx_movimientos_animales_tipo ON movimientos_animales(tipo_movimiento);

CREATE INDEX idx_etiquetas_animales_animal ON etiquetas_animales(animal_id);
CREATE INDEX idx_etiquetas_animales_etiqueta ON etiquetas_animales(etiqueta);

CREATE INDEX idx_trabajo_diario_fecha ON trabajo_diario(fecha_programada);
CREATE INDEX idx_trabajo_diario_usuario ON trabajo_diario(usuario_asignado);
CREATE INDEX idx_trabajo_diario_completado ON trabajo_diario(completado);

-- Triggers para actualizar timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_eventos_calendario_updated_at BEFORE UPDATE ON eventos_calendario FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_filtros_personalizados_updated_at BEFORE UPDATE ON filtros_personalizados FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_listas_personalizadas_updated_at BEFORE UPDATE ON listas_personalizadas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_configuracion_calendario_updated_at BEFORE UPDATE ON configuracion_calendario FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_trabajo_diario_updated_at BEFORE UPDATE ON trabajo_diario FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insertar datos de ejemplo para configuración
INSERT INTO configuracion_calendario (usuario_id, vista_predeterminada, alertas_activas, dias_anticipacion_alerta)
SELECT id, 'mes', true, 7 FROM auth.users LIMIT 1;

-- Insertar algunos eventos de ejemplo
INSERT INTO eventos_calendario (tipo, titulo, descripcion, fecha_evento, fecha_alerta, prioridad, color)
VALUES 
  ('celo', 'Observación de Celo - Vaca #001', 'Revisar signos de celo en vaca lechera', CURRENT_DATE + INTERVAL '2 days', CURRENT_DATE + INTERVAL '1 day', 'alta', '#EF4444'),
  ('parto', 'Parto Estimado - Vaca #015', 'Fecha estimada de parto, preparar área de maternidad', CURRENT_DATE + INTERVAL '5 days', CURRENT_DATE + INTERVAL '3 days', 'alta', '#F59E0B'),
  ('vacuna', 'Vacunación Anual', 'Aplicar vacuna contra brucelosis', CURRENT_DATE + INTERVAL '7 days', CURRENT_DATE + INTERVAL '5 days', 'media', '#10B981');

-- Insertar trabajo diario de ejemplo
INSERT INTO trabajo_diario (titulo, descripcion, fecha_programada, prioridad, categoria, tiempo_estimado)
VALUES 
  ('Ordeño Matutino', 'Ordeño de vacas lecheras - turno mañana', CURRENT_DATE, 'alta', 'ordeño', 120),
  ('Revisión Sanitaria Semanal', 'Inspección general del estado de salud del ganado', CURRENT_DATE + INTERVAL '1 day', 'media', 'sanidad', 60),
  ('Alimentación Suplementaria', 'Suministro de concentrado a vacas en lactancia', CURRENT_DATE, 'alta', 'alimentacion', 45);

-- Comentarios para documentación
COMMENT ON TABLE eventos_calendario IS 'Almacena eventos programados del calendario ganadero';
COMMENT ON TABLE movimientos_animales IS 'Registra todos los movimientos de animales (llegadas, partidas, transferencias)';
COMMENT ON TABLE filtros_personalizados IS 'Filtros guardados por usuarios para búsquedas avanzadas';
COMMENT ON TABLE etiquetas_animales IS 'Sistema de etiquetado para categorizar animales';
COMMENT ON TABLE listas_personalizadas IS 'Listas personalizadas de animales creadas por usuarios';
COMMENT ON TABLE configuracion_calendario IS 'Configuración personalizada del calendario por usuario';
COMMENT ON TABLE trabajo_diario IS 'Tareas y trabajo programado diariamente';
COMMENT ON TABLE historial_busquedas IS 'Historial de búsquedas realizadas por usuarios';