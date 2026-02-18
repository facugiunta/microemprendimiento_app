# CI/CD Configuration

## Workflows

### 1. **CI Workflow (`ci.yml`)**
- Triggers: `push` y `pull_request` en ramas `main` y `develop`
- **Tests:** 
  - Instala dependencias
  - Ejecuta linter (ESLint)
  - Compila TypeScript
  - Corre tests (si existen)
- **Docker Build:** Construye imagen después de tests exitosos

### 2. **Deploy Workflow (`deploy.yml`)**
- Triggers: `push` en rama `main`
- Construye imagen Docker con tag del commit SHA
- Lista las variables de entorno necesarias
- Incluye comentarios para deploy a Docker Hub, AWS, Heroku, etc.

## Configurar Secrets (GitHub)

Para usar el workflow de deploy con Docker Hub:

1. Ve a **Settings → Secrets and variables → Actions**
2. Agrega estos secrets:
   - `DOCKER_USERNAME` - Tu usuario de Docker Hub
   - `DOCKER_PASSWORD` - Tu token de Docker Hub
   - `DOCKER_REGISTRY` - (opcional) registry personalizado

## Scripts npm disponibles

```bash
npm run build    # Compilar TypeScript
npm run dev      # Modo desarrollo con nodemon
npm run lint     # Ejecutar ESLint
npm test         # Ejecutar tests
npm start        # Ejecutar en producción
```

## Para agregar deploy automático

Descomenta las secciones en `deploy.yml` para:
- **Docker Hub Push**
- **AWS ECR**
- **Heroku Deploy**
- **DigitalOcean App Platform**

## Estado de Builds

Todos los workflows se ejecutan automáticamente. Puedes ver el status en:
- GitHub Actions tab → Workflows
- Badge en el README: `![CI/CD](https://github.com/tuuser/turepository/workflows/CI%2FCD%20Backend/badge.svg)`
