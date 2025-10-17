-- ===================================================
-- DATOS DE PRUEBA - GUTIÉRREZ HNOS APP (UUIDs válidos)
-- ===================================================

-- Proveedores
INSERT INTO proveedores (id, nombre, contacto, observaciones, datos_personales, establecimiento, renspa, cuit) VALUES
('a5ad4a2d-3b2e-4b1c-8ca9-23c78e2f568f', 'Estancia La Esperanza', 'Tel: 3764-123456 - José Martínez', 'Proveedor confiable, buena calidad de animales', 'José Martínez - DNI 25.123.456', 'Campo sobre Ruta 14 km 15', 'ARG.11.001.234', '20-25123456-7'),
('40a1a12c-15b7-48e1-9e21-c0e3988e1da2', 'Campo San Miguel', 'Tel: 3764-789012 - Carlos Romero', 'Especialista en terneros de destete', 'Carlos Romero - DNI 18.987.654', 'Establecimiento San Miguel', 'ARG.11.002.567', '20-18987654-3'),
('537c790c-82d5-4713-9fa6-1bc76fa7734e', 'Los Algarrobos S.A.', 'Tel: 3764-345678 - Ana García', 'Empresa familiar, excelente trato', 'Ana García - DNI 22.345.678', 'Estancia Los Algarrobos', 'ARG.11.003.890', '30-12345678-9');

-- Transportadores
INSERT INTO transportadores (id, nombre, contacto, precio_km, observaciones) VALUES
('fca6f6f4-41b4-4b5d-9679-d48dcdb93f07', 'Transporte Chaco Norte', 'Tel: 3764-111222 - Pedro López', 85.50, 'Muy puntual, camiones en buen estado'),
('0b8e3e31-6902-44d6-955e-1c9d7a8d377c', 'Fletes Rurales SRL', 'Tel: 3764-333444 - Miguel Torres', 78.00, 'Precio competitivo, experiencia en ganado'),
('d74ec3e7-1a64-4541-864e-c2a95e165d5b', 'Logística del Campo', 'Tel: 3764-555666 - Ricardo Benítez', 92.75, 'Servicio premium, seguimiento GPS');

-- Compradores
INSERT INTO compradores (id, nombre, contacto, cuit, observaciones) VALUES
('fbec9d7c-2f1e-4b37-b342-fae9d2695b7d', 'Frigorífico Regional', 'Tel: 11-2234-5678 - Dpto. Compras', '30-68345678-2', 'Pago contra entrega, buen precio'),
('5a1b5bc8-c6ab-4308-8f82-d5a1ebd0d3c2', 'Mercado de Liniers - Juan Pérez', 'Tel: 11-4567-8901 - Juan Pérez', '20-12345678-9', 'Comprador habitual de remates'),
('b7b8e225-3077-49f2-8fd1-21474dc13cc0', 'Exportadora San Martín', 'Tel: 3764-987654 - Oficina Comercial', '30-87654321-5', 'Para exportación, precios internacionales');

-- Lotes
INSERT INTO lotes (id, nombre, color, numero, fecha_creacion, observaciones) VALUES
('e25868ac-1240-41f8-a8fa-56f5b3c59c87', 'Lote Esperanza Marzo 2024', 'Amarillo', 'ESP-001', '2024-03-15 10:30:00', 'Primer lote de La Esperanza, excelente calidad'),
('e97cbb3f-36fc-4ebc-9852-1b4013e8e7b1', 'Lote San Miguel Abril 2024', 'Verde', 'SMG-001', '2024-04-08 14:15:00', 'Terneros de destete, muy uniformes'),
('a7fdde36-97ac-498c-9402-c2e4c8a1b4e2', 'Lote Algarrobos Mayo 2024', 'Azul', 'ALG-001', '2024-05-20 09:45:00', 'Animales pesados, listos para venta');

-- Compras
INSERT INTO compras (id, fecha, proveedor_id, lugar_origen, transportador_id, precio_total, flag_peso_promedio, peso_promedio, observaciones) VALUES
('7c2ff845-139e-4cd4-a7ab-2d01b2d37973', '2024-03-15', 'a5ad4a2d-3b2e-4b1c-8ca9-23c78e2f568f', 'Estancia La Esperanza - Potrero Norte', 'fca6f6f4-41b4-4b5d-9679-d48dcdb93f07', 850000.00, true, 180.5, 'Compra exitosa, animales en excelente estado'),
('e944c7d7-7c99-4b57-90a1-2479e68d47a0', '2024-04-08', '40a1a12c-15b7-48e1-9e21-c0e3988e1da2', 'Campo San Miguel - Sector Sur', '0b8e3e31-6902-44d6-955e-1c9d7a8d377c', 720000.00, true, 165.0, 'Terneros de destete, muy parejos'),
('94bbdbe4-330d-4c01-9d89-c455ce4003cc', '2024-05-20', '537c790c-82d5-4713-9fa6-1bc76fa7734e', 'Los Algarrobos - Manga Principal', 'd74ec3e7-1a64-4541-864e-c2a95e165d5b', 960000.00, false, NULL, 'Pesaje individual, categorías mixtas');

-- Animales
INSERT INTO animales (id, numero_caravana, color_caravana, fecha_ingreso, peso_ingreso, categoria, estado_fisico, proveedor_id, transportador_id, precio_compra, observaciones, estado) VALUES
-- Lote Esperanza
('5c3d2e8a-88ae-40d6-927b-c27b0a245fb2', '001', 'amarillo', '2024-03-15', 180.5, 'ternero', 'excelente', 'a5ad4a2d-3b2e-4b1c-8ca9-23c78e2f568f', 'fca6f6f4-41b4-4b5d-9679-d48dcdb93f07', 4.80, 'Ternero Holstein, muy buena conformación', 'en_campo'),
('bb17ca3c-fc02-4309-bd04-b10199b6e066', '002', 'amarillo', '2024-03-15', 180.5, 'ternero', 'excelente', 'a5ad4a2d-3b2e-4b1c-8ca9-23c78e2f568f', 'fca6f6f4-41b4-4b5d-9679-d48dcdb93f07', 4.80, 'Ternero cruza, buen desarrollo', 'en_campo'),
('940f05f7-83e4-4e7d-afea-7c8cf8fbb99d', '003', 'amarillo', '2024-03-15', 180.5, 'ternero', 'bueno', 'a5ad4a2d-3b2e-4b1c-8ca9-23c78e2f568f', 'fca6f6f4-41b4-4b5d-9679-d48dcdb93f07', 4.80, 'Ternero Angus, estructura sólida', 'en_campo'),
('c07ba2d8-1361-4472-99e3-54e066110188', '004', 'amarillo', '2024-03-15', 180.5, 'ternero', 'excelente', 'a5ad4a2d-3b2e-4b1c-8ca9-23c78e2f568f', 'fca6f6f4-41b4-4b5d-9679-d48dcdb93f07', 4.80, 'Ternero Hereford, muy prolijo', 'en_campo'),
('8f9322bb-54cb-4a11-b3ca-514632d99e32', '005', 'amarillo', '2024-03-15', 180.5, 'ternero', 'bueno', 'a5ad4a2d-3b2e-4b1c-8ca9-23c78e2f568f', 'fca6f6f4-41b4-4b5d-9679-d48dcdb93f07', 4.80, 'Ternero cruza, buen potencial', 'en_campo'),
-- Lote San Miguel
('01af09f7-f8bb-45a1-819c-53a6af38c82b', '101', 'verde', '2024-04-08', 165.0, 'ternero', 'excelente', '40a1a12c-15b7-48e1-9e21-c0e3988e1da2', '0b8e3e31-6902-44d6-955e-1c9d7a8d377c', 4.65, 'Ternero de destete temprano', 'en_campo'),
('fd4cf7ae-1da0-41ea-a95b-d723a44f6f31', '102', 'verde', '2024-04-08', 165.0, 'ternero', 'bueno', '40a1a12c-15b7-48e1-9e21-c0e3988e1da2', '0b8e3e31-6902-44d6-955e-1c9d7a8d377c', 4.65, 'Buen desarrollo muscular', 'en_campo'),
('a9210f2c-4b24-4c1c-b68a-2cb99f1beafd', '103', 'verde', '2024-04-08', 165.0, 'ternero', 'excelente', '40a1a12c-15b7-48e1-9e21-c0e3988e1da2', '0b8e3e31-6902-44d6-955e-1c9d7a8d377c', 4.65, 'Excelente conformación', 'en_campo'),
('a0e71759-9ef6-41a5-b6cf-9c1d8b5c4d4b', '104', 'verde', '2024-04-08', 165.0, 'ternero', 'bueno', '40a1a12c-15b7-48e1-9e21-c0e3988e1da2', '0b8e3e31-6902-44d6-955e-1c9d7a8d377c', 4.65, 'Animal parejo y sano', 'en_campo'),
-- Lote Algarrobos
('8ef5b763-63db-46cf-bf8d-c88118d1c441', '201', 'azul', '2024-05-20', 220.0, 'novillo', 'excelente', '537c790c-82d5-4713-9fa6-1bc76fa7734e', 'd74ec3e7-1a64-4541-864e-c2a95e165d5b', 5.20, 'Novillo pesado, listo para venta', 'en_campo'),
('7f57e990-624b-48d6-9eab-1d12caa5b2ae', '202', 'azul', '2024-05-20', 195.5, 'ternero', 'bueno', '537c790c-82d5-4713-9fa6-1bc76fa7734e', 'd74ec3e7-1a64-4541-864e-c2a95e165d5b', 5.10, 'Ternero grande, buen peso', 'en_campo'),
('d0662f08-62ae-4e12-839a-1e6af3ab2623', '203', 'azul', '2024-05-20', 210.5, 'novillo', 'excelente', '537c790c-82d5-4713-9fa6-1bc76fa7734e', 'd74ec3e7-1a64-4541-864e-c2a95e165d5b', 5.15, 'Novillo premium, excelente calidad', 'en_campo');

-- Relación animal_lote
INSERT INTO animal_lote (id, animal_id, lote_id, fecha_asignacion, observaciones) VALUES
-- Lote Esperanza
('4aa508c3-87b2-45b3-b189-2073d5737bf7', '5c3d2e8a-88ae-40d6-927b-c27b0a245fb2', 'e25868ac-1240-41f8-a8fa-56f5b3c59c87', '2024-03-15 11:00:00', 'Asignación inicial al lote'),
('12e51541-7bc5-4966-9de8-11b4ff2c225b', 'bb17ca3c-fc02-4309-bd04-b10199b6e066', 'e25868ac-1240-41f8-a8fa-56f5b3c59c87', '2024-03-15 11:00:00', 'Asignación inicial al lote'),
('b40e5ea6-1991-48b7-81b6-6b16762f5e01', '940f05f7-83e4-4e7d-afea-7c8cf8fbb99d', 'e25868ac-1240-41f8-a8fa-56f5b3c59c87', '2024-03-15 11:00:00', 'Asignación inicial al lote'),
('af002231-28a8-42db-9179-ff03e9df2825', 'c07ba2d8-1361-4472-99e3-54e066110188', 'e25868ac-1240-41f8-a8fa-56f5b3c59c87', '2024-03-15 11:00:00', 'Asignación inicial al lote'),
('5d0e79b2-64ca-4445-92d7-1eabf4baecaa', '8f9322bb-54cb-4a11-b3ca-514632d99e32', 'e25868ac-1240-41f8-a8fa-56f5b3c59c87', '2024-03-15 11:00:00', 'Asignación inicial al lote'),
-- Lote San Miguel
('1a0f99d8-7791-4321-b06e-6fcf26e39f55', '01af09f7-f8bb-45a1-819c-53a6af38c82b', 'e97cbb3f-36fc-4ebc-9852-1b4013e8e7b1', '2024-04-08 14:30:00', 'Asignación inicial al lote'),
('08ab5b46-0951-41fd-846e-446b79f26417', 'fd4cf7ae-1da0-41ea-a95b-d723a44f6f31', 'e97cbb3f-36fc-4ebc-9852-1b4013e8e7b1', '2024-04-08 14:30:00', 'Asignación inicial al lote'),
('019998fa-d1cf-4c3e-9539-47fd4d181488', 'a9210f2c-4b24-4c1c-b68a-2cb99f1beafd', 'e97cbb3f-36fc-4ebc-9852-1b4013e8e7b1', '2024-04-08 14:30:00', 'Asignación inicial al lote'),
('6d7c4b12-7888-4bd1-89a8-6dcb03a4be1e', 'a0e71759-9ef6-41a5-b6cf-9c1d8b5c4d4b', 'e97cbb3f-36fc-4ebc-9852-1b4013e8e7b1', '2024-04-08 14:30:00', 'Asignación inicial al lote'),
-- Lote Algarrobos
('b7f2b82c-638e-4441-b87c-e8a3d6873cbb', '8ef5b763-63db-46cf-bf8d-c88118d1c441', 'a7fdde36-97ac-498c-9402-c2e4c8a1b4e2', '2024-05-20 10:15:00', 'Asignación inicial al lote'),
('1a9b0a5c-9985-43c5-bb19-7c8c95b32150', '7f57e990-624b-48d6-9eab-1d12caa5b2ae', 'a7fdde36-97ac-498c-9402-c2e4c8a1b4e2', '2024-05-20 10:15:00', 'Asignación inicial al lote'),
('d8a01cd5-70da-4b5e-b6b3-e589f3f463e5', 'd0662f08-62ae-4e12-839a-1e6af3ab2623', 'a7fdde36-97ac-498c-9402-c2e4c8a1b4e2', '2024-05-20 10:15:00', 'Asignación inicial al lote');

-- Eventos sanitarios
INSERT INTO eventos_sanitarios (id, animal_id, fecha, tipo, descripcion) VALUES
('c1f1bffd-77db-4327-b95c-6806a2c90cf1', '5c3d2e8a-88ae-40d6-927b-c27b0a245fb2', '2024-03-20', 'vacuna', 'Vacuna antiaftosa - Dosis completa'),
('a37ce8fa-2f09-4f0c-9ff2-6cb0e17e2d13', 'bb17ca3c-fc02-4309-bd04-b10199b6e066', '2024-03-20', 'vacuna', 'Vacuna antiaftosa - Dosis completa'),
('e92ac2c5-73b6-4fa8-8246-c4e66d2e011d', '01af09f7-f8bb-45a1-819c-53a6af38c82b', '2024-04-15', 'desparasitario', 'Ivermectina inyectable - Control de parásitos'),
('6a9dcb6f-68ba-4423-a277-c5c66467e4f2', '8ef5b763-63db-46cf-bf8d-c88118d1c441', '2024-05-25', 'vacuna', 'Refuerzo antiaftosa + IBR-DVB'),
('78c1d144-c7f6-4d68-9f49-b9a1e4b0ad9a', '7f57e990-624b-48d6-9eab-1d12caa5b2ae', '2024-05-25', 'desparasitario', 'Doramectina pour-on - Tratamiento preventivo');

-- ===================================================
-- DATOS DE PRUEBA INSERTADOS EXITOSAMENTE
-- ===================================================

-- PESADAS para animales del Lote Esperanza
INSERT INTO pesadas (id, animal_id, fecha_pesada, peso, observaciones)
VALUES
('61cf98f7-50e5-41e4-a43d-cdb4c4f5ae8e', '5c3d2e8a-88ae-40d6-927b-c27b0a245fb2', '2024-03-15', 180.5, 'Peso inicial al ingreso'),
('5d7cdb98-3a2d-43c0-8b50-56bce0f0a57a', '5c3d2e8a-88ae-40d6-927b-c27b0a245fb2', '2024-04-15', 200.0, 'Primer control mensual'),
('3eeb89c0-fb47-4e16-995f-bdfda40f6e3e', 'bb17ca3c-fc02-4309-bd04-b10199b6e066', '2024-03-15', 180.5, 'Peso inicial'),
('a6ad58c1-49c6-4ee4-9021-b7f3ab03e2e5', 'bb17ca3c-fc02-4309-bd04-b10199b6e066', '2024-04-15', 196.3, 'Primer control'),
('7f1a418b-6b1c-4563-aab6-2c343c14b1bc', '940f05f7-83e4-4e7d-afea-7c8cf8fbb99d', '2024-03-15', 180.5, 'Ingreso'),
('c3f8f20d-5c11-4c32-9e81-5fbe2f26d3c2', '940f05f7-83e4-4e7d-afea-7c8cf8fbb99d', '2024-04-15', 189.7, 'Revisión mensual'),

-- PESADAS para animales del Lote San Miguel
('15b07f4e-c34e-4f7b-9478-8662db232f1a', '01af09f7-f8bb-45a1-819c-53a6af38c82b', '2024-04-08', 165.0, 'Ingreso'),
('a408fb6e-3f63-4e51-901d-893f468f4a8c', '01af09f7-f8bb-45a1-819c-53a6af38c82b', '2024-05-08', 178.0, 'Primer control'),
('8b4e39ea-c195-4a8e-9dbb-fbeebf0e0e52', 'fd4cf7ae-1da0-41ea-a95b-d723a44f6f31', '2024-04-08', 165.0, 'Ingreso'),
('dfbe158b-7bc8-4f37-b7f1-4ec2d39e62df', 'fd4cf7ae-1da0-41ea-a95b-d723a44f6f31', '2024-05-08', 172.4, 'Primer control'),

-- PESADAS para animales del Lote Algarrobos
('57e8a365-f6c0-4e60-9406-85a0e251c1f0', '8ef5b763-63db-46cf-bf8d-c88118d1c441', '2024-05-20', 220.0, 'Ingreso'),
('4d91a07f-63d2-48c2-902c-dfa0ad9c290d', '8ef5b763-63db-46cf-bf8d-c88118d1c441', '2024-06-20', 234.5, 'Control 1 mes'),
('ab4be013-d04c-44c7-b9e1-11b3b237d123', '7f57e990-624b-48d6-9eab-1d12caa5b2ae', '2024-05-20', 195.5, 'Ingreso'),
('aa0b8e1f-bd03-4f2a-8c0a-9f20cf6f438b', '7f57e990-624b-48d6-9eab-1d12caa5b2ae', '2024-06-20', 210.0, 'Control 1 mes');
