# 🚀 QUICK START - Levantar el Proyecto en 5 Minutos

## Requisitos Previos
- Docker instalado
- Docker Compose instalado
- Puertos libres: 3000, 5432, 6379, 5050

## Comando Único para Levantar TODO

```bash
# Desde la carpeta raíz del proyecto
docker-compose up -d
```

## Verificar que Funcione

```bash
# Esperar 10 segundos a que PostgreSQL esté listo, luego:
curl http://localhost:3000/api/health
```

Deberías ver:
```json
{
  "status": "OK",
  "message": "Servidor funcionando correctamente",
  "timestamp": "2026-02-17T..."
}
```

## Acceder a los Servicios

| Sistema | URL |
|---------|-----|
| **Backend API** | http://localhost:3000 |
| **PgAdmin** | http://localhost:5050 |
| **PostgreSQL** | localhost:5432 |
| **Redis** | localhost:6379 |

## Credenciales

| Sistema | Usuario | Contraseña |
|---------|---------|-----------|
| PgAdmin | admin@example.com | admin |
| PostgreSQL | postgres | postgres_password_secure_123 |

## Ver Logs (Debugging)

```bash
# Backend
docker logs -f microemprendimiento_backend

# PostgreSQL
docker logs -f microemprendimiento_db

# Redis
docker logs -f microemprendimiento_redis

# Ver todos
docker logs -f $(docker ps -q)
```

## Detener Servicios

```bash
# Detener
docker-compose stop

# Reiniciar
docker-compose start

# Apagar todo
docker-compose down
```

## Comandos Rápidos Útiles

```bash
# ¿Está todo corriendo?
docker ps

# ¿Hay errores?
docker logs microemprendimiento_backend

# Entrar a BD
docker exec -it microemprendimiento_db psql -U postgres -d microemprendimiento_db

# Ejecutar comando en backend
docker exec microemprendimiento_backend npm run build

# Ver consumo de recursos
docker stats
```

## If Something Goes Wrong

```bash
# Reconstruir desde cero
docker-compose down
docker system prune -a
docker-compose up -d --build

# Ver qué proceso usa puerto
lsof -i :3000  # cambiar puerto según sea necesario
```

---

**¡Listo! Tu aplicación está corriendo.** 🎉  
Ir a [DOCKER_SETUP.md](DOCKER_SETUP.md) para más detalles.
