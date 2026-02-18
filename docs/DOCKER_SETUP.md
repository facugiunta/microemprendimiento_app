# 🐳 DOCKER SETUP - Guía Completa

## Estado Actual

Actualmente tienes configurado:
- ✅ Dockerfile en `backend/`
- ✅ docker-compose.yml
- ✅ Variables de entorno (.env)
- ✅ Scripts SQL de inicialización

## Arquitectura Docker

```
┌─────────────────────────────────────────────────┐
│         Docker Compose Network                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────┐  ┌──────────────┐            │
│  │  PostgreSQL  │  │    Redis     │            │
│  │  :5432       │  │   :6379      │            │
│  └──────────────┘  └──────────────┘            │
│       │                                         │
│  ┌────┴───────────────────┐                    │
│  │    Node.js Backend      │                    │
│  │    :3000                │                    │
│  └────┬────────────────────┘                    │
│       │                                         │
│  ┌────┴──────────────┐                         │
│  │  PgAdmin (UI)     │                         │
│  │  :5050            │                         │
│  └───────────────────┘                         │
│                                                  │
└─────────────────────────────────────────────────┘
```

## Instrucciones para Levantar el Proyecto

### Paso 1: Verificar Requisitos Previos

```bash
# Verificar Docker instalado
docker --version

# Verificar Docker Compose
docker-compose --version

# Verificar que los puertos estén disponibles
# 3000, 5432, 6379, 5050
```

### Paso 2: Verificar Variables de Entorno

El archivo `.env` debe estar en la raíz del proyecto. Verifica que contenga:

```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres_password_secure_123
POSTGRES_DB=microemprendimiento_db
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=admin
```

**Nota:** Cambia las contraseñas en producción.

### Paso 3: Construir los Contenedores

```bash
# Desde la raíz del proyecto
docker-compose build
```

**Salida esperada:**
```
Building backend ... done
PostgreSQL (pullado) ... done
Redis (pullado) ... done
PgAdmin (pullado) ... done
```

### Paso 4: Levantar los Servicios

```bash
# Desde la raíz del proyecto
docker-compose up -d
```

**Salida esperada:**
```
Creating microemprendimiento_db     ... done
Creating microemprendimiento_redis  ... done
Creating microemprendimiento_pgadmin ... done
Creating microemprendimiento_backend ... done
```

### Paso 5: Verificar que Todos los Servicios Estén Corriendo

```bash
docker ps
```

**Debe mostrar 4 contenedores:**
- microemprendimiento_backend
- microemprendimiento_db
- microemprendimiento_redis
- microemprendimiento_pgadmin

## Verificar Que Todo Funcione

### 1. Backend API

```bash
curl http://localhost:3000/api/health
```

**Respuesta esperada:**
```json
{
  "status": "OK",
  "message": "Servidor funcionando correctamente",
  "timestamp": "2026-02-17T..."
}
```

### 2. PostgreSQL

```bash
# A través de PgAdmin en navegador
# URL: http://localhost:5050
# Email: admin@example.com
# Password: admin
```

**O desde línea de comandos:**
```bash
docker exec microemprendimiento_db psql -U postgres -d microemprendimiento_db -c "\dt"
```

### 3. Redis

```bash
docker exec microemprendimiento_redis redis-cli ping
```

**Respuesta esperada:** `PONG`

### 4. Logs

```bash
# Ver logs del backend
docker logs microemprendimiento_backend

# Ver logs en tiempo real
docker logs -f microemprendimiento_backend

# Ver logs de otros servicios
docker logs microemprendimiento_db
docker logs microemprendimiento_redis
docker logs microemprendimiento_pgadmin
```

## URLs de Acceso

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| Backend API | http://localhost:3000 | - |
| Health Check | http://localhost:3000/api/health | - |
| PgAdmin | http://localhost:5050 | admin@example.com / admin |
| PostgreSQL | localhost:5432 | postgres / postgres_password_secure_123 |
| Redis | localhost:6379 | - |

## Detener los Servicios

```bash
# Detener sin eliminar volúmenes
docker-compose stop

# Detener y eliminar los contenedores (pero mantiene datos)
docker-compose down

# Detener y eliminar TODO (incluyendo datos)
docker-compose down -v
```

## Troubleshooting

### Problema: Puertos en uso

```bash
# Encontrar qué proceso está usando el puerto
lsof -i :3000
lsof -i :5432
lsof -i :6379
lsof -i :5050

# Matar proceso
kill -9 <PID>

# O cambiar los puertos en docker-compose.yml
```

### Problema: Backend no se conecta a BD

```bash
# Verificar logs del backend
docker logs microemprendimiento_backend

# Verificar que PostgreSQL esté sano
docker ps | grep postgres

# Recrear sin caché
docker-compose up --build --force-recreate
```

### Problema: Base de datos vacía (sin tablas)

```bash
# Verificar si los scripts SQL se ejecutaron
docker exec microemprendimiento_db psql -U postgres -d microemprendimiento_db -c "\dt"

# Si no hay tablas, ejecutarlas manualmente
docker exec -i microemprendimiento_db psql -U postgres -d microemprendimiento_db < ./backend/db/init.sql
docker exec -i microemprendimiento_db psql -U postgres -d microemprendimiento_db < ./backend/db/sales.sql
docker exec -i microemprendimiento_db psql -U postgres -d microemprendimiento_db < ./backend/db/purchases.sql
```

### Problema: Cambios en código no se reflejan

El docker-compose tiene volúmenes que ayudan al desarrollo iterativo:
- `./backend:/app` - sincroniza código
- `/app/node_modules` - evita conflictos

```bash
# Reconstruir si instalaste nuevos packages
docker-compose up --build

# O desde dentro del contenedor
docker exec microemprendimiento_backend npm install
```

## Flujo de Desarrollo

### Durante desarrollo:

```bash
# 1. Levantar servicios una sola vez
docker-compose up -d

# 2. Editar código en tu editor
# Los cambios se sincronizan automáticamente

# 3. Ver logs
docker logs -f microemprendimiento_backend

# 4. Instalar nuevos packages
docker exec microemprendimiento_backend npm install

# 5. Compilar TypeScript (si es necesario)
docker exec microemprendimiento_backend npm run build
```

### Para producción:

```bash
# 1. Actualizar variables de entorno con valores seguros
# 2. Cambiar NODE_ENV a "production"
# 3. Usar contraseñas fuertes para PostgreSQL
# 4. Usar secrets en lugar de .env
# 5. Hacer build multi-stage (ya está en el Dockerfile)
```

## Backups y Persistencia

### Datos persistentes

Los datos están almacenados en volúmenes Docker:
- `postgres_data` - Base de datos PostgreSQL
- `redis_data` - Caché Redis

```bash
# Listar volúmenes
docker volume ls

# Ver detalles de un volumen
docker volume inspect microemprendimiento_postgres_data

# Backup de BD
docker exec microemprendimiento_db pg_dump -U postgres microemprendimiento_db > backup.sql

# Restore de BD
docker exec -i microemprendimiento_db psql -U postgres microemprendimiento_db < backup.sql
```

## Configuración en .env

### Desarrollo
```env
NODE_ENV=development
JWT_ACCESS_SECRET=dev_secret_not_secure
JWT_REFRESH_SECRET=dev_secret_not_secure
```

### Producción
```env
NODE_ENV=production
JWT_ACCESS_SECRET=generar_con_openssl_rand_-base64_32
JWT_REFRESH_SECRET=generar_con_openssl_rand_-base64_32
POSTGRES_PASSWORD=usar_contraseña_fuerte
```

Generar secrets seguros:
```bash
openssl rand -base64 32
```

## Conectar desde Otras Aplicaciones

### Desde Flutter (en mismo Docker network)
```
postgresql://postgres:password@postgres:5432/microemprendimiento_db
```

### Desde PgAdmin en navegador
1. Ir a http://localhost:5050
2. Login: admin@example.com / admin
3. Register Server:
   - Hostname: postgres
   - Port: 5432
   - Username: postgres
   - Password: (la del .env)

### Desde herramientas locales
```
Host: localhost
Port: 5432
Username: postgres
Password: (la del .env)
Database: microemprendimiento_db
```

## Comandos Útiles

```bash
# Ver estado de todos los servicios
docker-compose ps

# Ejecutar comando en contenedor
docker exec microemprendimiento_backend npm run build

# Entrar a shell del contenedor
docker exec -it microemprendimiento_backend sh

# Entrar a PostgreSQL
docker exec -it microemprendimiento_db psql -U postgres

# Ver consumo de recursos
docker stats

# Actualizar imagen (si hay cambios en Dockerfile)
docker-compose up --build

# Limpiar todo (cuidado!)
docker system prune -a
```

## Próximos Pasos

Una vez que tengas Docker funcionando:

1. **Test la API** - Registrar usuario, login, crear productos, etc.
2. **Conecta la UI** - Desde PgAdmin para ver datos
3. **Conecta desde Flutter** - Implementar pantalla de login
4. **Implementar sincronización** - SQLite local
5. **Pasar a producción** - Cambiar variables de entorno

---

**Si algo no funciona, verifica:**
- ✅ Docker está corriendo
- ✅ Puertos disponibles (3000, 5432, 6379, 5050)
- ✅ .env en la carpeta raíz
- ✅ Dockerfile en backend/
- ✅ docker-compose.yml en raíz
- ✅ Backend compiló sin errores: `npm run build`
