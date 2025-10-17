-- Crear tabla de trabajo diario si no existe
CREATE TABLE IF NOT EXISTS public.trabajo_diario (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    fecha_programada DATE NOT NULL,
    fecha_completado DATE,
    prioridad VARCHAR(20) DEFAULT 'media' CHECK (prioridad IN ('baja', 'media', 'alta', 'urgente')),
    categoria VARCHAR(50) CHECK (categoria IN ('ordeño', 'alimentacion', 'sanidad', 'reproduccion', 'mantenimiento', 'general')),
    animal_id UUID REFERENCES animales(id) ON DELETE SET NULL,
    lote_id UUID REFERENCES lotes(id) ON DELETE SET NULL,
    usuario_asignado UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    usuario_creador UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    completado BOOLEAN DEFAULT FALSE,
    notas TEXT,
    tiempo_estimado INTEGER, -- en minutos
    tiempo_real INTEGER, -- tiempo real empleado en minutos
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_trabajo_diario_fecha_programada ON public.trabajo_diario(fecha_programada);
CREATE INDEX IF NOT EXISTS idx_trabajo_diario_usuario_asignado ON public.trabajo_diario(usuario_asignado);
CREATE INDEX IF NOT EXISTS idx_trabajo_diario_completado ON public.trabajo_diario(completado);
CREATE INDEX IF NOT EXISTS idx_trabajo_diario_categoria ON public.trabajo_diario(categoria);
CREATE INDEX IF NOT EXISTS idx_trabajo_diario_prioridad ON public.trabajo_diario(prioridad);

-- RLS (Row Level Security)
ALTER TABLE public.trabajo_diario ENABLE ROW LEVEL SECURITY;

-- Política para que los usuarios vean las tareas asignadas a ellos o creadas por ellos
DROP POLICY IF EXISTS "Users can view assigned or created tasks" ON public.trabajo_diario;
CREATE POLICY "Users can view assigned or created tasks" ON public.trabajo_diario
    FOR SELECT USING (
        auth.uid() = usuario_asignado OR 
        auth.uid() = usuario_creador OR
        auth.uid() IN (
            SELECT id FROM auth.users WHERE raw_user_meta_data->>'rol' = 'administrador'
        )
    );

-- Política para que los usuarios puedan actualizar tareas asignadas a ellos
DROP POLICY IF EXISTS "Users can update assigned tasks" ON public.trabajo_diario;
CREATE POLICY "Users can update assigned tasks" ON public.trabajo_diario
    FOR UPDATE USING (
        auth.uid() = usuario_asignado OR 
        auth.uid() = usuario_creador OR
        auth.uid() IN (
            SELECT id FROM auth.users WHERE raw_user_meta_data->>'rol' = 'administrador'
        )
    );

-- Política para crear tareas
DROP POLICY IF EXISTS "Users can create tasks" ON public.trabajo_diario;
CREATE POLICY "Users can create tasks" ON public.trabajo_diario
    FOR INSERT WITH CHECK (
        auth.uid() = usuario_creador OR
        auth.uid() IN (
            SELECT id FROM auth.users WHERE raw_user_meta_data->>'rol' = 'administrador'
        )
    );

-- Política para eliminar tareas (solo creador o admin)
DROP POLICY IF EXISTS "Users can delete their created tasks" ON public.trabajo_diario;
CREATE POLICY "Users can delete their created tasks" ON public.trabajo_diario
    FOR DELETE USING (
        auth.uid() = usuario_creador OR
        auth.uid() IN (
            SELECT id FROM auth.users WHERE raw_user_meta_data->>'rol' = 'administrador'
        )
    );

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para actualizar updated_at
DROP TRIGGER IF EXISTS update_trabajo_diario_updated_at ON public.trabajo_diario;
CREATE TRIGGER update_trabajo_diario_updated_at
    BEFORE UPDATE ON public.trabajo_diario
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();