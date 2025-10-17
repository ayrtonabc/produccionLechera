-- SOLUCIÓN SIMPLE: Proceso manual de 2 pasos para crear usuarios
-- ============================================================

-- PASO 1: Crear usuario en Auth (Dashboard)
-- ============================================================
-- 1. Ve a: Dashboard > Authentication > Users > Add user
-- 2. Email: tu@email.com
-- 3. Password: tu_password
-- 4. ✅ Auto Confirm User
-- 5. Create user
-- 6. COPIA EL UUID que aparece en la columna ID

-- PASO 2: Ejecutar este INSERT (reemplaza el UUID)
-- ============================================================

INSERT INTO public.usuarios (id, nombre, rol, activo)
VALUES (
  'PEGA-AQUI-EL-UUID-COPIADO',  -- 👈 Reemplaza con el UUID de Auth
  'Administrador Principal',     -- 👈 Cambia el nombre
  'administrador',               -- 👈 'administrador' o 'operador'
  true
)
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  rol = EXCLUDED.rol,
  activo = EXCLUDED.activo,
  updated_at = NOW();

-- Verificar que se creó correctamente
SELECT 
  u.id,
  u.nombre,
  u.rol,
  u.activo,
  au.email,
  u.created_at
FROM public.usuarios u
JOIN auth.users au ON u.id = au.id
ORDER BY u.created_at DESC;

-- ============================================================
-- CREAR MÚLTIPLES USUARIOS
-- ============================================================
-- Si necesitas crear varios, copia este bloque y cambia los valores:

/*
INSERT INTO public.usuarios (id, nombre, rol, activo) VALUES
  ('uuid-usuario-1', 'Juan Pérez', 'administrador', true),
  ('uuid-usuario-2', 'María García', 'operador', true),
  ('uuid-usuario-3', 'Carlos López', 'operador', true)
ON CONFLICT (id) DO NOTHING;
*/
