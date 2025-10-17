# 🔧 Configuración de Base de Datos - Gutierrez Hnos App

## ⚠️ Error: "Could not find a relationship between 'animales' and 'compras'"

Este error indica que las tablas de la base de datos no existen o no están configuradas correctamente en Supabase.

## 🛠️ Solución: Ejecutar Scripts SQL

### Paso 1: Crear las Tablas

1. **Abrir Supabase Dashboard**
   - Ve a [supabase.com](https://supabase.com)
   - Ingresa a tu proyecto
   - Ve a la sección **SQL Editor**

2. **Ejecutar Script de Creación**
   - Copia todo el contenido del archivo `database/create_tables.sql`
   - Pégalo en el SQL Editor de Supabase
   - Haz clic en **RUN** para ejecutar

3. **Verificar Creación**
   - Ve a **Table Editor** en Supabase
   - Deberías ver todas las tablas creadas:
     - `animales`
     - `proveedores`
     - `transportadores`
     - `lotes`
     - `animal_lote`
     - `compradores`
     - `compras`
     - `ventas`
     - `detalle_venta`
     - `eventos_sanitarios`
     - `usuarios`

### Paso 2: Insertar Datos de Prueba (Opcional)

1. **Ejecutar Script de Datos**
   - Copia todo el contenido del archivo `database/insert_test_data.sql`
   - Pégalo en el SQL Editor de Supabase
   - Haz clic en **RUN** para ejecutar

2. **Verificar Datos**
   - Ve a **Table Editor** 
   - Abre la tabla `animales`
   - Deberías ver 12 animales de prueba
   - Abre la tabla `lotes`
   - Deberías ver 3 lotes de prueba

## 🔍 Verificar en la Aplicación

1. **Refrescar la Aplicación**
   - Vuelve a la aplicación web
   - Navega a la sección **Animales**
   - El componente de debug debería mostrar:
     - ✅ Conexión a Supabase: Exitosa
     - ✅ Todas las tablas con conteos correctos

2. **Probar Funcionalidades**
   - Deberías ver la lista de animales
   - Los filtros deberían funcionar
   - El modal de lotes debería mostrar los lotes creados

## 📊 Datos de Prueba Incluidos

Si ejecutaste el script de datos de prueba, tendrás:

- **12 Animales**: Terneros, terneras y novillos
- **3 Lotes**: Primavera 2024, Verano 2024, y Especial Export
- **3 Proveedores**: Estancia La Pampa, Campo Los Alamos, Hacienda San Miguel
- **2 Transportadores**: Transportes Rurales SA, Logística Ganadera
- **6 Eventos Sanitarios**: Vacunaciones y tratamientos
- **3 Compras**: Registros de compras de animales

## 🚨 Problemas Comunes

### 1. Error de Permisos (RLS)
Si ves errores de permisos, los scripts ya configuran políticas permisivas. Si persiste:
```sql
-- Ejecutar en SQL Editor para deshabilitar RLS temporalmente
ALTER TABLE animales DISABLE ROW LEVEL SECURITY;
ALTER TABLE lotes DISABLE ROW LEVEL SECURITY;
ALTER TABLE proveedores DISABLE ROW LEVEL SECURITY;
```

### 2. Tablas ya Existen
Si ves errores de "tabla ya existe", es normal. Los scripts usan `CREATE TABLE IF NOT EXISTS`.

### 3. Error de UUID
Si hay problemas con UUIDs:
```sql
-- Ejecutar primero para habilitar extensión UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

## 🔄 Reiniciar Datos de Prueba

Para limpiar y reiniciar los datos de prueba:

```sql
-- Limpiar datos de prueba (mantiene estructura)
DELETE FROM eventos_sanitarios;
DELETE FROM animal_lote;
DELETE FROM detalle_venta;
DELETE FROM ventas;
DELETE FROM compras;
DELETE FROM animales;
DELETE FROM lotes;
DELETE FROM transportadores;
DELETE FROM compradores;
DELETE FROM proveedores;
DELETE FROM usuarios;
```

Luego ejecuta nuevamente el script `insert_test_data.sql`.

## ✅ Verificación Final

Una vez ejecutados los scripts:

1. ✅ La aplicación debería cargar sin errores
2. ✅ La sección Animales debería mostrar la lista
3. ✅ Los filtros deberían funcionar
4. ✅ Los modales de lotes y animales deberían abrir
5. ✅ El componente de debug debería mostrar todo en verde

---

## 📞 Soporte

Si continúas teniendo problemas:

1. Verifica que el archivo `.env` tenga las credenciales correctas de Supabase
2. Asegúrate de que el proyecto de Supabase esté activo
3. Revisa la consola del navegador para más detalles del error
4. Verifica que las políticas RLS permitan el acceso a las tablas
