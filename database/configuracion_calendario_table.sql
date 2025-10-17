-- Crear tabla de configuración de calendario si no existe
CREATE TABLE IF NOT EXISTS public.configuracion_calendario (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vista_predeterminada VARCHAR(20) DEFAULT 'mensual' CHECK (vista_predeterminada IN ('diaria', 'semanal', 'mensual')),
    hora_inicio_jornada TIME DEFAULT '08:00',
    hora_fin_jornada TIME DEFAULT '18:00',
    dias_laborables TEXT[] DEFAULT ARRAY['lunes', 'martes', 'miercoles', 'jueves', 'viernes'],
    alertas_activas BOOLEAN DEFAULT true,
    tiempo_anticipacion_alertas INTEGER DEFAULT 24,
    mostrar_eventos_reproductivos BOOLEAN DEFAULT true,
    mostrar_eventos_salud BOOLEAN DEFAULT true,
    mostrar_eventos_nutricion BOOLEAN DEFAULT true,
    mostrar_eventos_manejo BOOLEAN DEFAULT true,
    color_eventos_reproductivos VARCHAR(7) DEFAULT '#ec4899',
    color_eventos_salud VARCHAR(7) DEFAULT '#ef4444',
    color_eventos_nutricion VARCHAR(7) DEFAULT '#22c55e',
    color_eventos_manejo VARCHAR(7) DEFAULT '#3b82f6',
    notificaciones_email BOOLEAN DEFAULT false,
    notificaciones_push BOOLEAN DEFAULT true,
    formato_hora VARCHAR(3) DEFAULT '24h' CHECK (formato_hora IN ('12h', '24h')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(usuario_id)
);

-- Índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_configuracion_calendario_usuario_id ON public.configuracion_calendario(usuario_id);

-- RLS (Row Level Security)
ALTER TABLE public.configuracion_calendario ENABLE ROW LEVEL SECURITY;

-- Política para que los usuarios solo vean su propia configuración
DROP POLICY IF EXISTS "Users can view their own calendar config" ON public.configuracion_calendario;
CREATE POLICY "Users can view their own calendar config" ON public.configuracion_calendario
    FOR SELECT USING (auth.uid() = usuario_id);

-- Política para que los usuarios puedan actualizar su propia configuración
DROP POLICY IF EXISTS "Users can update their own calendar config" ON public.configuracion_calendario;
CREATE POLICY "Users can update their own calendar config" ON public.configuracion_calendario
    FOR UPDATE USING (auth.uid() = usuario_id);

-- Política para crear configuración (solo el propio usuario)
DROP POLICY IF EXISTS "Users can create their own calendar config" ON public.configuracion_calendario;
CREATE POLICY "Users can create their own calendar config" ON public.configuracion_calendario
    FOR INSERT WITH CHECK (auth.uid() = usuario_id);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para actualizar updated_at
DROP TRIGGER IF EXISTS update_configuracion_calendario_updated_at ON public.configuracion_calendario;
CREATE TRIGGER update_configuracion_calendario_updated_at
    BEFORE UPDATE ON public.configuracion_calendario
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();