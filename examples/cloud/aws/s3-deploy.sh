#!/bin/bash

# =============================================================================
# AWS S3 Deployment Skript
# 
# Dieses Skript deployt Dateien zu einem AWS S3 Bucket.
# Es unterstützt:
#   - Sync von lokalen Dateien zu S3
#   - CloudFront Cache Invalidation
#   - Verschiedene AWS Profile
#   - Dry-Run Modus
# 
# Verwendung:
#   ./s3-deploy.sh [OPTIONS]
# 
# Optionen:
#   -b, --bucket BUCKET     S3 Bucket Name (erforderlich)
#   -s, --source SOURCE     Quellenverzeichnis (Standard: ./dist)
#   -r, --region REGION     AWS Region (Standard: eu-central-1)
#   -p, --profile PROFILE   AWS CLI Profil (Standard: default)
#   -d, --dry-run           Dry-Run Modus (kein tatsächliches Deployment)
#   -c, --cloudfront DIST   CloudFront Distribution ID für Invalidation
#   -h, --help              Hilfe anzeigen
# 
# Beispiele:
#   ./s3-deploy.sh --bucket my-app-bucket --source ./build
#   ./s3-deploy.sh -b my-app-bucket -s ./dist -r us-east-1
#   ./s3-deploy.sh -b my-app-bucket --dry-run
# =============================================================================

set -euo pipefail

# =============================================================================
# VARIABLEN & STANDARDWERTE
# =============================================================================

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Standardwerte
BUCKET=""
SOURCE="./dist"
REGION="eu-central-1"
PROFILE="default"
DRY_RUN=false
CLOUDFRONT_DISTRIBUTION_ID=""

# =============================================================================
# HILFSFUNKTIONEN
# =============================================================================

print_error() {
    echo -e "${RED}✗ $1${NC}" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

usage() {
    cat <<EOF
Verwendung: $0 [OPTIONS]

Optionen:
  -b, --bucket BUCKET       S3 Bucket Name (erforderlich)
  -s, --source SOURCE       Quellenverzeichnis (Standard: ./dist)
  -r, --region REGION       AWS Region (Standard: eu-central-1)
  -p, --profile PROFILE     AWS CLI Profil (Standard: default)
  -d, --dry-run             Dry-Run Modus (kein tatsächliches Deployment)
  -c, --cloudfront DIST     CloudFront Distribution ID für Invalidation
  -h, --help                Hilfe anzeigen

Beispiele:
  $0 --bucket my-app-bucket --source ./build
  $0 -b my-app-bucket -s ./dist -r us-east-1
  $0 -b my-app-bucket --dry-run

Umgebungvariablen:
  AWS_ACCESS_KEY_ID          AWS Access Key
  AWS_SECRET_ACCESS_KEY     AWS Secret Key
  AWS_SESSION_TOKEN         AWS Session Token (für temporäre Credentials)
EOF
}

# =============================================================================
# ARGUMENTE PARSEN
# =============================================================================

# Optionen parsen
while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--bucket)
            BUCKET="$2"
            shift 2
            ;;
        -s|--source)
            SOURCE="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -p|--profile)
            PROFILE="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -c|--cloudfront)
            CLOUDFRONT_DISTRIBUTION_ID="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unbekannte Option: $1"
            usage
            exit 1
            ;;
    esac
done

# =============================================================================
# VALIDIERUNG
# =============================================================================

# Überprüfen ob Bucket angegeben wurde
if [ -z "$BUCKET" ]; then
    print_error "Bucket Name ist erforderlich"
    usage
    exit 1
fi

# Überprüfen ob Quellenverzeichnis existiert
if [ ! -d "$SOURCE" ]; then
    print_error "Quellenverzeichnis '$SOURCE' existiert nicht"
    exit 1
fi

# Überprüfen ob AWS CLI installiert ist
if ! command -v aws > /dev/null 2>&1; then
    print_error "AWS CLI ist nicht installiert"
    print_info "Installation: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# =============================================================================
# AWS KONFIGURATION
# =============================================================================

print_header "AWS Konfiguration"

# AWS Profil verwenden
export AWS_DEFAULT_REGION="$REGION"
export AWS_DEFAULT_PROFILE="$PROFILE"

# Überprüfen ob AWS Credentials verfügbar sind
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    print_error "AWS Credentials nicht gefunden oder ungültig"
    print_info "Konfiguriere AWS CLI mit: aws configure"
    print_info "Oder setze Umgebungsvariablen:"
    print_info "  AWS_ACCESS_KEY_ID"
    print_info "  AWS_SECRET_ACCESS_KEY"
    exit 1
fi

# Aktuellen AWS Benutzer anzeigen
AWS_USER=$(aws sts get-caller-identity --query "UserId" --output text 2>/dev/null)
AWS_ACCOUNT=$(aws sts get-caller-identity --query "Account" --output text 2>/dev/null)
print_success "AWS Benutzer: $AWS_USER"
print_success "AWS Account: $AWS_ACCOUNT"
print_success "Region: $REGION"
print_success "Profil: $PROFILE"

# =============================================================================
# DEPLOYMENT VORBEREITEN
# =============================================================================

print_header "Deployment Vorbereitung"

# Dry-Run Modus anzeigen
if [ "$DRY_RUN" = true ]; then
    print_warning "DRY-RUN Modus aktiviert - kein tatsächliches Deployment"
fi

# Zu deployende Dateien anzeigen
print_info "Quellenverzeichnis: $SOURCE"
print_info "Ziel-Bucket: s3://$BUCKET"

# Dateien im Quellenverzeichnis auflisten
print_info "Dateien zum Deployment:"
find "$SOURCE" -type f | while read -r file; do
    echo "  - $file"
done

# =============================================================================
# S3 SYNC
# =============================================================================

print_header "S3 Sync"

SYNC_COMMAND="aws s3 sync \
  $SOURCE s3://$BUCKET \
  --region $REGION \
  --delete \
  --exclude '.git/*' \
  --exclude '.github/*' \
  --exclude '*.md' \
  --exclude '.DS_Store' \
  --exclude '*.log' \
  --cache-control 'max-age=31536000,public' \
  --acl public-read"

if [ "$DRY_RUN" = true ]; then
    print_info "Würde ausführen: $SYNC_COMMAND"
    print_success "Dry-Run: S3 Sync erfolgreich simuliert"
else
    print_info "Führe S3 Sync aus..."
    
    # Sync ausführen
    if eval "$SYNC_COMMAND"; then
        print_success "S3 Sync erfolgreich"
    else
        print_error "S3 Sync fehlgeschlagen"
        exit 1
    fi
fi

# =============================================================================
# CLOUDFRONT CACHE INVALIDATION
# =============================================================================

if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    print_header "CloudFront Cache Invalidation"
    
    INVALIDATION_COMMAND="aws cloudfront create-invalidation \
      --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
      --paths '/*'"
    
    if [ "$DRY_RUN" = true ]; then
        print_info "Würde ausführen: $INVALIDATION_COMMAND"
        print_success "Dry-Run: CloudFront Invalidation erfolgreich simuliert"
    else
        print_info "Führe CloudFront Invalidation aus..."
        
        if eval "$INVALIDATION_COMMAND"; then
            print_success "CloudFront Cache Invalidierung erfolgreich"
        else
            print_error "CloudFront Cache Invalidierung fehlgeschlagen"
            exit 1
        fi
    fi
else
    print_info "Keine CloudFront Distribution ID angegeben - überspringe Cache Invalidation"
fi

# =============================================================================
# DEPLOYMENT ZUSAMMENFASSUNG
# =============================================================================

print_header "Deployment Zusammenfassung"

echo ""
print_success "Deployment abgeschlossen!"
echo ""

if [ "$DRY_RUN" = false ]; then
    print_info "Deployed zu: https://$BUCKET.s3.$REGION.amazonaws.com"
    
    if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
        print_info "CloudFront Distribution: $CLOUDFRONT_DISTRIBUTION_ID"
        print_info "Cache wird in ~5-10 Minuten invalidiert"
    fi
else
    print_warning "Dry-Run Modus - kein tatsächliches Deployment durchgeführt"
fi

echo ""
print_info "Deployment-Informationen:"
print_info "  Bucket: $BUCKET"
print_info "  Region: $REGION"
print_info "  Quellenverzeichnis: $SOURCE"
print_info "  AWS Profil: $PROFILE"

if [ "$DRY_RUN" = true ]; then
    print_info "  Modus: Dry-Run"
fi

exit 0
