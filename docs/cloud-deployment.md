# Cloud Deployment Guide 🚀

Anleitung für **Deployment in verschiedene Cloud-Umgebungen** mit Git-Integration.

---

## 📌 Inhaltsverzeichnis

1. [GitHub Actions](#github-actions)
2. [AWS Deployment](#aws-deployment)
3. [Docker & Container](#docker--container)
4. [Best Practices](#best-practices)

---

## GitHub Actions

### Grundlagen
GitHub Actions ermöglicht **CI/CD direkt in deinem Repository**.

### Beispiel: Node.js Deployment
```yaml
name: Node.js CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm install
      - run: npm test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm install
      - run: npm run build
      - run: echo "Deployment hier einrichten"
```

### Wichtige Actions
| Action | Zweck |
|--------|-------|
| `actions/checkout@v4` | Repository auschecken |
| `actions/setup-node@v4` | Node.js einrichten |
| `actions/setup-python@v4` | Python einrichten |
| `aws-actions/configure-aws-credentials@v4` | AWS Credentials konfigurieren |

---

## AWS Deployment

### AWS S3 Deployment
Einfaches Deployment von statischen Websites auf **Amazon S3**.

#### Voraussetzungen
- AWS Account
- AWS CLI installiert (`aws configure`)
- S3 Bucket erstellt

#### Skript: `examples/cloud/aws/s3-deploy.sh`
```bash
#!/bin/bash

# AWS S3 Deployment Skript
# Verwendung: ./s3-deploy.sh <bucket-name> <source-dir>

set -e

if [ $# -ne 2 ]; then
  echo "Verwendung: $0 <bucket-name> <source-dir>"
  exit 1
fi

BUCKET=$1
SOURCE_DIR=$2

# Sync mit S3
aws s3 sync "$SOURCE_DIR" "s3://$BUCKET" \
  --delete \
  --exclude ".git/*" \
  --exclude ".github/*" \
  --exclude "*.md"

# CloudFront Cache invalidieren (optional)
if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
  aws cloudfront create-invalidation \
    --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" \
    --paths "/*"
fi

echo "Deployment nach s3://$BUCKET erfolgreich!"
```

### AWS Lambda Deployment
```yaml
# .github/workflows/deploy-lambda.yml
name: Deploy Lambda

on:
  push:
    branches: [main]
    paths:
      - 'lambda/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-central-1
      
      - name: Deploy Lambda Function
        run: |
          cd lambda
          zip -r function.zip .
          aws lambda update-function-code \
            --function-name my-function \
            --zip-file fileb://function.zip
```

---

## Docker & Container

### Dockerfile Beispiel
```dockerfile
# examples/docker/Dockerfile
FROM node:20-alpine

WORKDIR /app

# Abhängigkeiten kopieren
COPY package*.json ./
RUN npm install

# Source Code kopieren
COPY . .

# Build
RUN npm run build

# Port freigeben
EXPOSE 3000

# Startbefehl
CMD ["npm", "start"]
```

### Docker Compose
```yaml
# examples/docker/docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped

  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=secret
      - POSTGRES_DB=mydb
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Deployment mit Docker
```bash
# Build
docker build -t my-app:latest .

# Run
docker run -d -p 3000:3000 --name my-app my-app:latest

# Mit Docker Compose
docker-compose up -d
```

---

## Best Practices

### 1. **Environment Variables**
- **Niemals** Secrets im Code speichern
- **GitHub Secrets** nutzen:
  ```yaml
  env:
    DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
  ```
- **`.env` Dateien** in `.gitignore` eintragen

### 2. **Infrastructure as Code**
- **Terraform** für AWS/Azure/GCP
- **Pulumi** als Alternative
- **CloudFormation** für AWS

### 3. **Rollback-Strategie**
- **Tags** für Releases nutzen:
  ```bash
  git tag -a v1.0.0 -m "Release v1.0.0"
  git push origin v1.0.0
  ```
- **Deployment-Historie** in CI/CD speichern
- **Blue-Green Deployment** für Zero-Downtime

### 4. **Monitoring**
- **Health Checks** einrichten
- **Logging** (ELK Stack, CloudWatch)
- **Alerts** für Fehler konfigurieren

---

## 🔗 Nützliche Links

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [AWS CLI Docs](https://docs.aws.amazon.com/cli/)
- [Docker Dokumentation](https://docs.docker.com/)
- [Terraform Docs](https://developer.hashicorp.com/terraform/docs)
