-- EXTENSIÓN DEL SISTEMA PARA PRODUCCIÓN LECHERA
-- Script completo para adaptar la base de datos existente
-- Ejecutar en Supabase SQL Editor

-- =====================================================
-- 1. EXTENSIÓN DE TABLA ANIMALES PARA PRODUCCIÓN LECHERA
-- =====================================================

-- Agregar campos específicos para producción lechera
ALTER TABLE animales 
ADD COLUMN IF NOT EXISTS estado_reproductivo TEXT CHECK (estado_reproductivo IN ('lactancia', 'seca', 'prenada', 'vacia')) DEFAULT 'vacia',
ADD COLUMN IF NOT EXISTS fecha_ultimo_parto DATE,
ADD COLUMN IF NOT EXISTS dias_lactancia INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS numero_lactancia INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS fecha_ultimo_servicio DATE,
ADD COLUMN IF NOT EXISTS control_antibioticos JSONB DEFAULT '[]',
ADD COLUMN IF NOT EXISTS produccion_promedio_30d NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS fecha_secado_programado DATE,
ADD COLUMN IF NOT EXISTS fecha_parto_estimado DATE;

-- Crear índices para optimizar consultas de campos lecheros
CREATE INDEX IF NOT EXISTS idx_animales_estado_reproductivo ON animales(estado_reproductivo);
CREATE INDEX IF NOT EXISTS idx_animales_dias_lactancia ON animales(dias_lactancia);
CREATE INDEX IF NOT EXISTS idx_animales_fecha_ultimo_parto ON animales(fecha_ultimo_parto);
CREATE INDEX IF NOT EXISTS idx_animales_produccion_promedio ON animales(produccion_promedio_30d);

-- =====================================================
-- 2. TABLA PRODUCCION_LECHE
-- =====================================================

CREATE TABLE IF NOT EXISTS produccion_leche (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    animal_id UUID REFERENCES animales(id) ON DELETE CASCADE,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    litros_am NUMERIC NOT NULL DEFAULT 0,
    litros_pm NUMERIC NOT NULL DEFAULT 0,
    total_litros NUMERIC GENERATED ALWAYS AS (litros_am + litros_pm) STORED,
    calidad_grasa NUMERIC,
    calidad_proteina NUMERIC,
    observaciones TEXT,
    created_by UUID REFERENCES usuarios(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para optimizar consultas de producción
CREATE INDEX IF NOT EXISTS idx_produccion_leche_animal_fecha ON produccion_leche(animal_id, fecha DESC);
CREATE INDEX IF NOT EXISTS idx_produccion_leche_fecha ON produccion_leche(fecha DESC);
CREATE INDEX IF NOT EXISTS idx_produccion_leche_total ON produccion_leche(total_litros DESC);

-- Constraint único para evitar duplicados por animal y fecha
CREATE UNIQUE INDEX IF NOT EXISTS idx_produccion_leche_unico 
ON produccion_leche(animal_id, fecha);

-- Habilitar RLS para produccion_leche
ALTER TABLE produccion_leche ENABLE ROW LEVEL SECURITY;

-- Crear política para produccion_leche
DROP POLICY IF EXISTS "Permitir todo en produccion_leche" ON produccion_leche;
CREATE POLICY "Permitir todo en produccion_leche" ON produccion_leche FOR ALL USING (true);

-- =====================================================
-- 3. TABLA TAREAS
-- =====================================================

CREATE TABLE IF NOT EXISTS tareas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    titulo TEXT NOT NULL,
    descripcion TEXT,
    animal_id UUID REFERENCES animales(id) ON DELETE SET NULL,
    lote_id UUID REFERENCES lotes(id) ON DELETE SET NULL,
    fecha_programada DATE NOT NULL,
    prioridad TEXT CHECK (prioridad IN ('baja', 'media', 'alta', 'critica')) DEFAULT 'media',
    estado TEXT CHECK (estado IN ('pendiente', 'en_progreso', 'completada', 'cancelada')) DEFAULT 'pendiente',
    asignado_a UUID REFERENCES usuarios(id),
    completada_por UUID REFERENCES usuarios(id),
    fecha_completada TIMESTAMP WITH TIME ZONE,
    notas_completacion TEXT,
    created_by UUID REFERENCES usuarios(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para optimizar consultas de tareas
CREATE INDEX IF NOT EXISTS idx_tareas_estado ON tareas(estado);
CREATE INDEX IF NOT EXISTS idx_tareas_fecha_programada ON tareas(fecha_programada);
CREATE INDEX IF NOT EXISTS idx_tareas_asignado_a ON tareas(asignado_a);
CREATE INDEX IF NOT EXISTS idx_tareas_animal_id ON tareas(animal_id);
CREATE INDEX IF NOT EXISTS idx_tareas_prioridad ON tareas(prioridad);

-- Habilitar RLS para tareas
ALTER TABLE tareas ENABLE ROW LEVEL SECURITY;

-- Crear política para tareas
DROP POLICY IF EXISTS "Permitir todo en tareas" ON tareas;
CREATE POLICY "Permitir todo en tareas" ON tareas FOR ALL USING (true);

-- =====================================================
-- 4. FUNCIONES AUTOMÁTICAS Y TRIGGERS
-- =====================================================

-- Función para calcular producción promedio de los últimos 30 días
CREATE OR REPLACE FUNCTION calcular_produccion_promedio_30d(animal_uuid UUID)
RETURNS NUMERIC AS $$
DECLARE
    promedio NUMERIC;
BEGIN
    SELECT AVG(total_litros) INTO promedio
    FROM produccion_leche 
    WHERE animal_id = animal_uuid 
    AND fecha >= CURRENT_DATE - INTERVAL '30 days';
    
    RETURN COALESCE(promedio, 0);
END;
$$ LANGUAGE plpgsql;

-- Función para calcular días de lactancia automáticamente
CREATE OR REPLACE FUNCTION calcular_dias_lactancia(animal_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
    dias INTEGER;
    fecha_parto DATE;
BEGIN
    SELECT fecha_ultimo_parto INTO fecha_parto
    FROM animales 
    WHERE id = animal_uuid;
    
    IF fecha_parto IS NOT NULL THEN
        dias := CURRENT_DATE - fecha_parto;
        RETURN GREATEST(dias, 0);
    ELSE
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar producción promedio automáticamente
CREATE OR REPLACE FUNCTION actualizar_produccion_promedio()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE animales 
    SET produccion_promedio_30d = calcular_produccion_promedio_30d(NEW.animal_id)
    WHERE id = NEW.animal_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para producción promedio
DROP TRIGGER IF EXISTS trigger_actualizar_produccion_promedio ON produccion_leche;
CREATE TRIGGER trigger_actualizar_produccion_promedio
    AFTER INSERT OR UPDATE ON produccion_leche
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_produccion_promedio();

-- Trigger para actualizar días de lactancia automáticamente
CREATE OR REPLACE FUNCTION actualizar_dias_lactancia()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_ultimo_parto IS NOT NULL AND NEW.estado_reproductivo = 'lactancia' THEN
        NEW.dias_lactancia := calcular_dias_lactancia(NEW.id);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para días de lactancia
DROP TRIGGER IF EXISTS trigger_actualizar_dias_lactancia ON animales;
CREATE TRIGGER trigger_actualizar_dias_lactancia
    BEFORE UPDATE ON animales
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_dias_lactancia();

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para updated_at en tareas
DROP TRIGGER IF EXISTS trigger_actualizar_updated_at_tareas ON tareas;
CREATE TRIGGER trigger_actualizar_updated_at_tareas
    BEFORE UPDATE ON tareas
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- =====================================================
-- 5. VISTAS ÚTILES PARA REPORTES
-- =====================================================

-- Vista para resumen de producción diaria
CREATE OR REPLACE VIEW vista_produccion_diaria AS
SELECT 
    pl.fecha,
    COUNT(pl.animal_id) as animales_ordeñados,
    SUM(pl.total_litros) as produccion_total,
    AVG(pl.total_litros) as promedio_por_animal,
    SUM(pl.litros_am) as total_am,
    SUM(pl.litros_pm) as total_pm
FROM produccion_leche pl
GROUP BY pl.fecha
ORDER BY pl.fecha DESC;

-- Vista para estado reproductivo del rodeo
CREATE OR REPLACE VIEW vista_estado_reproductivo AS
SELECT 
    estado_reproductivo,
    COUNT(*) as cantidad,
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()), 2) as porcentaje
FROM animales 
WHERE estado = 'en_campo'
GROUP BY estado_reproductivo;

-- Vista para animales en producción con métricas
CREATE OR REPLACE VIEW vista_animales_produccion AS
SELECT 
    a.id,
    a.numero_caravana,
    a.estado_reproductivo,
    a.dias_lactancia,
    a.numero_lactancia,
    a.produccion_promedio_30d,
    a.fecha_ultimo_parto,
    CASE 
        WHEN a.control_antibioticos::text != '[]' THEN true 
        ELSE false 
    END as tiene_antibioticos
FROM animales a
WHERE a.estado = 'en_campo' AND a.estado_reproductivo = 'lactancia'
ORDER BY a.produccion_promedio_30d DESC;

-- =====================================================
-- 6. DATOS DE PRUEBA PARA DESARROLLO
-- =====================================================

-- Actualizar algunos animales existentes con datos lecheros de prueba
UPDATE animales 
SET 
    estado_reproductivo = 'lactancia',
    fecha_ultimo_parto = CURRENT_DATE - INTERVAL '45 days',
    dias_lactancia = 45,
    numero_lactancia = 2,
    produccion_promedio_30d = 25.5
WHERE id IN (
    SELECT id FROM animales 
    WHERE estado = 'en_campo' 
    LIMIT 5
);

-- Insertar algunos registros de producción de prueba
INSERT INTO produccion_leche (animal_id, fecha, litros_am, litros_pm, created_by)
SELECT 
    a.id,
    CURRENT_DATE - INTERVAL '1 day',
    20 + (RANDOM() * 10)::NUMERIC(5,2),
    18 + (RANDOM() * 8)::NUMERIC(5,2),
    (SELECT id FROM usuarios LIMIT 1)
FROM animales a
WHERE a.estado_reproductivo = 'lactancia'
LIMIT 5;

-- Insertar algunas tareas de ejemplo
INSERT INTO tareas (titulo, descripcion, fecha_programada, prioridad, asignado_a, created_by)
VALUES 
    ('Revisión veterinaria mensual', 'Control reproductivo y sanitario del rodeo', CURRENT_DATE + INTERVAL '3 days', 'alta', 
     (SELECT id FROM usuarios LIMIT 1), (SELECT id FROM usuarios LIMIT 1)),
    ('Limpieza de sala de ordeñe', 'Desinfección completa de equipos', CURRENT_DATE + INTERVAL '1 day', 'media',
     (SELECT id FROM usuarios LIMIT 1), (SELECT id FROM usuarios LIMIT 1)),
    ('Control de calidad de leche', 'Análisis de grasa y proteína', CURRENT_DATE + INTERVAL '7 days', 'media',
     (SELECT id FROM usuarios LIMIT 1), (SELECT id FROM usuarios LIMIT 1));

-- =====================================================
-- 7. PERMISOS Y SEGURIDAD
-- =====================================================

-- Otorgar permisos básicos a los roles anon y authenticated
GRANT SELECT, INSERT, UPDATE, DELETE ON produccion_leche TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON tareas TO anon, authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Otorgar permisos para las vistas
GRANT SELECT ON vista_produccion_diaria TO anon, authenticated;
GRANT SELECT ON vista_estado_reproductivo TO anon, authenticated;
GRANT SELECT ON vista_animales_produccion TO anon, authenticated;

-- =====================================================
-- SCRIPT COMPLETADO
-- =====================================================

-- Verificar que todo se creó correctamente
SELECT 'Extensión de sistema lechero completada exitosamente' as resultado;

-- Mostrar resumen de tablas creadas/modificadas
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE tablename IN ('produccion_leche', 'tareas', 'animales')
ORDER BY tablename;