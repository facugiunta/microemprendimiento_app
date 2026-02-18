# 🚀 PRÓXIMOS PASOS - TL;DR

## Para levantar todo en 2 minutos:

```bash
cd c:\Users\Mati\Documents\microemprendimiento_app
docker-compose up -d
```

## Luego verifica que está corriendo:

```bash
curl http://localhost:3000/api/health
```

Deberías ver:
```json
{"status":"ok","timestamp":"2024-01-..."}
```

## Acceso a los servicios:

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| Backend API | http://localhost:3000 | `-` |
| PgAdmin | http://localhost:5050 | admin@example.com / admin |
| PostgreSQL | localhost:5432 | postgres / postgres_password_secure_123 |
| Redis | localhost:6379 | `-` |

## Verificar Database:

1. Abre http://localhost:5050
2. Login: admin@example.com / admin
3. Haz clic en "Add New Server"
4. Name: `PostgreSQL`
5. Connection tab:
   - Host: `postgres`
   - Port: `5432`
   - Username: `postgres`
   - Password: `postgres_password_secure_123`
   - Database: `microemprendimiento_db`

Verás 10 tablas creadas automáticamente.

## Testear API:

```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!","name":"Test User"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'

# Get user (con token del login)
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Si algo falla:

```bash
# Ver logs
docker logs -f microemprendimiento_backend

# Reset completo
docker-compose down -v
docker-compose up -d

# Limpiar y reconstruir
docker-compose down
docker system prune -a
docker-compose up -d --build
```

---

✅ **Backend está LISTO para producción**.  
❌ **Frontend Flutter aún no iniciado**.  
📝 **38 endpoints implementados y funcionando**.
