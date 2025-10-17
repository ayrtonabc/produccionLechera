-- SCRIPT DE CREACIÓN DE TABLAS PARA GUTIERREZ HNOS APP
-- Ejecutar en Supabase SQL Editor

-- 1. Crear tabla USUARIOS (si no existe)
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    rol TEXT CHECK (rol IN ('administrador', 'operador')) DEFAULT 'operador',
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Crear tabla PROVEEDORES
CREATE TABLE IF NOT EXISTS proveedores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    contacto TEXT,
    observaciones TEXT,
    datos_personales TEXT,
    establecimiento TEXT,
    renspa TEXT,
    boleto_marca TEXT, -- URL del archivo
    cuit TEXT,
    created_by UUID REFERENCES usuarios(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Crear tabla TRANSPORTADORES
CREATE TABLE IF NOT EXISTS transportadores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    contacto TEXT,
    precio_km NUMERIC,
    observaciones TEXT,
    created_by UUID REFERENCES usuarios(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Crear tabla COMPRADORES
CREATE TABLE IF NOT EXISTS compradores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    contacto TEXT,
    cuit TEXT,
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Crear tabla LOTES
CREATE TABLE IF NOT EXISTS lotes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    fecha_creacion DATE DEFAULT CURRENT_DATE,
    observaciones TEXT,
    created_by UUID REFERENCES usuarios(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Crear ENUM para estado físico
DO $$ BEGIN
    CREATE TYPE estado_fisico_enum AS ENUM ('critico', 'malo', 'bueno', 'excelente');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 7. Crear tabla ANIMALES
CREATE TABLE IF NOT EXISTS animales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    numero_caravana TEXT,
    fecha_ingreso DATE NOT NULL DEFAULT CURRENT_DATE,
    peso_ingreso NUMERIC NOT NULL,
    categoria TEXT NOT NULL,
    estado_fisico estado_fisico_enum DEFAULT 'bueno',
    proveedor_id UUID REFERENCES proveedores(id),
    transportador_id UUID REFERENCES transportadores(id),
    precio_compra NUMERIC NOT NULL,
    observaciones TEXT,
    estado TEXT CHECK (estado IN ('en_campo', 'vendido')) DEFAULT 'en_campo',
    sanidad JSONB DEFAULT '{}',
    documentos TEXT[], -- Array de URLs
    foto_url TEXT,
    color_caravana TEXT DEFAULT 'amarillo',
    created_by UUID REFERENCES usuarios(id),
    fecha_creacion DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Crear tabla ANIMAL_LOTE (relación muchos a muchos con historial)
CREATE TABLE IF NOT EXISTS animal_lote (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    animal_id UUID REFERENCES animales(id) ON DELETE CASCADE,
    lote_id UUID REFERENCES lotes(id) ON DELETE CASCADE,
    fecha_asignacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_salida TIMESTAMP WITH TIME ZONE, -- NULL = activo
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Crear tabla COMPRAS
CREATE TABLE IF NOT EXISTS compras (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    proveedor_id UUID REFERENCES proveedores(id),
    lugar_origen TEXT,
    transportador_id UUID REFERENCES transportadores(id),
    precio_total NUMERIC,
    documento TEXT, -- URL del archivo
    flag_peso_promedio BOOLEAN DEFAULT FALSE,
    peso_promedio NUMERIC,
    observaciones TEXT,
    created_by UUID REFERENCES usuarios(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Crear tabla VENTAS
CREATE TABLE IF NOT EXISTS ventas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    tipo TEXT CHECK (tipo IN ('jaula', 'remate', 'particular')) NOT NULL,
    precio_kilo NUMERIC,
    comprador_id UUID REFERENCES compradores(id),
    documentos TEXT[], -- Array de URLs
    observaciones TEXT,
    created_by UUID REFERENCES usuarios(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. Crear tabla DETALLE_VENTA
CREATE TABLE IF NOT EXISTS detalle_venta (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venta_id UUID REFERENCES ventas(id) ON DELETE CASCADE,
    animal_id UUID REFERENCES animales(id) ON DELETE CASCADE,
    peso_salida NUMERIC NOT NULL,
    precio_final NUMERIC,
    created_by UUID REFERENCES usuarios(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 12. Crear tabla EVENTOS_SANITARIOS
CREATE TABLE IF NOT EXISTS eventos_sanitarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    animal_id UUID REFERENCES animales(id) ON DELETE CASCADE,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    descripcion TEXT NOT NULL,
    tipo TEXT NOT NULL, -- vacuna, desparasitario, etc
    observaciones TEXT,
    created_by UUID REFERENCES usuarios(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 13. Crear índices para mejorar performance
CREATE INDEX IF NOT EXISTS idx_animales_estado ON animales(estado);
CREATE INDEX IF NOT EXISTS idx_animales_proveedor ON animales(proveedor_id);
CREATE INDEX IF NOT EXISTS idx_animales_fecha_ingreso ON animales(fecha_ingreso);
CREATE INDEX IF NOT EXISTS idx_animal_lote_activo ON animal_lote(animal_id, fecha_salida) WHERE fecha_salida IS NULL;
CREATE INDEX IF NOT EXISTS idx_eventos_sanitarios_animal ON eventos_sanitarios(animal_id);

-- 14. Crear constraint único para animales activos en lotes
-- Un animal solo puede estar en un lote activo a la vez
CREATE UNIQUE INDEX IF NOT EXISTS idx_animal_lote_unico_activo 
ON animal_lote(animal_id) 
WHERE fecha_salida IS NULL;

-- 15. Habilitar RLS (Row Level Security) si está deshabilitado
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE transportadores ENABLE ROW LEVEL SECURITY;
ALTER TABLE compradores ENABLE ROW LEVEL SECURITY;
ALTER TABLE lotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE animales ENABLE ROW LEVEL SECURITY;
ALTER TABLE animal_lote ENABLE ROW LEVEL SECURITY;
ALTER TABLE compras ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE detalle_venta ENABLE ROW LEVEL SECURITY;
ALTER TABLE eventos_sanitarios ENABLE ROW LEVEL SECURITY;

-- 16. Crear políticas básicas (permite todo por ahora - ajustar según necesidades)
CREATE POLICY IF NOT EXISTS "Permitir todo en usuarios" ON usuarios FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "Permitir todo en proveedores" ON proveedores FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "Permitir todo en transportadores" ON transportadores FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "Permitir todo en compradores" ON compradores FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "Permitir todo en lotes" ON lotes FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "Permitir todo en animales" ON animales FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "Permitir todo en animal_lote" ON animal_lote FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "Permitir todo en compras" ON compras FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "Permitir todo en ventas" ON ventas FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "Permitir todo en detalle_venta" ON detalle_venta FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "Permitir todo en eventos_sanitarios" ON eventos_sanitarios FOR ALL USING (true);

-- 17. Crear funciones de trigger para updated_at automático
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 18. Crear triggers para updated_at
DROP TRIGGER IF EXISTS update_usuarios_updated_at ON usuarios;
CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON usuarios FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_proveedores_updated_at ON proveedores;
CREATE TRIGGER update_proveedores_updated_at BEFORE UPDATE ON proveedores FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_transportadores_updated_at ON transportadores;
CREATE TRIGGER update_transportadores_updated_at BEFORE UPDATE ON transportadores FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_animales_updated_at ON animales;
CREATE TRIGGER update_animales_updated_at BEFORE UPDATE ON animales FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_lotes_updated_at ON lotes;
CREATE TRIGGER update_lotes_updated_at BEFORE UPDATE ON lotes FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_compras_updated_at ON compras;
CREATE TRIGGER update_compras_updated_at BEFORE UPDATE ON compras FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_ventas_updated_at ON ventas;
CREATE TRIGGER update_ventas_updated_at BEFORE UPDATE ON ventas FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_detalle_venta_updated_at ON detalle_venta;
CREATE TRIGGER update_detalle_venta_updated_at BEFORE UPDATE ON detalle_venta FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_eventos_sanitarios_updated_at ON eventos_sanitarios;
CREATE TRIGGER update_eventos_sanitarios_updated_at BEFORE UPDATE ON eventos_sanitarios FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- 19. Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Base de datos Gutierrez Hnos creada exitosamente!';
    RAISE NOTICE 'Tablas creadas: usuarios, proveedores, transportadores, compradores, lotes, animales, animal_lote, compras, ventas, detalle_venta, eventos_sanitarios';
    RAISE NOTICE 'RLS habilitado con políticas permisivas para desarrollo';
    RAISE NOTICE 'Índices y triggers creados para optimización';
END $$;
