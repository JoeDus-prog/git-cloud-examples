#!/bin/bash

# =============================================================================
# Git Rebase vs. Merge - Demonstrationsskript
# 
# Dieses Skript zeigt den Unterschied zwischen `git merge` und `git rebase`
# an einem praktischen Beispiel.
# 
# Verwendung:
#   1. Führe das Skript in einem Git-Repository aus
#   2. Das Skript erstellt Test-Branches und zeigt die Unterschiede
# =============================================================================

set -e

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hilfsfunktion für farbige Ausgabe
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Überprüfen ob wir in einem Git-Repository sind
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    print_error "Dies ist kein Git-Repository!"
    echo "Bitte führe das Skript in einem Git-Repository aus."
    exit 1
fi

# Aktuellen Branch speichern
CURRENT_BRANCH=$(git branch --show-current)

# Aufräumen am Ende
cleanup() {
    print_header "Aufräumen"
    git checkout "$CURRENT_BRANCH" > /dev/null 2>&1
    git branch -D merge-demo > /dev/null 2>&1
    git branch -D rebase-demo > /dev/null 2>&1
    git branch -D feature > /dev/null 2>&1
    print_success "Test-Branches gelöscht"
}

# Bei Abbruch aufräumen
trap cleanup EXIT

# =============================================================================
# HAUPTPROGRAMM
# =============================================================================

echo ""
print_header "Git Rebase vs. Merge Demo"
echo ""

# 1. Vorbereitung
print_header "Vorbereitung"

# Main Branch sicherstellen
git checkout main > /dev/null 2>&1 || git checkout master > /dev/null 2>&1
print_success "Auf main Branch"

# Test-Branches löschen falls vorhanden
git branch -D merge-demo > /dev/null 2>&1
git branch -D rebase-demo > /dev/null 2>&1
git branch -D feature > /dev/null 2>&1

# Feature Branch erstellen
print_warning "Erstelle Feature-Branch..."
git checkout -b feature > /dev/null 2>&1

# Commits auf feature erstellen
echo "Feature Commit 1" > feature1.txt
git add feature1.txt
git commit -m "feat: add feature commit 1" > /dev/null 2>&1

sleep 1

echo "Feature Commit 2" > feature2.txt
git add feature2.txt
git commit -m "feat: add feature commit 2" > /dev/null 2>&1

print_success "Feature-Branch mit 2 Commits erstellt"

# Zurück zu main
git checkout main > /dev/null 2>&1

# Commits auf main erstellen (simuliert andere Entwickler)
echo "Main Commit 1" > main1.txt
git add main1.txt
git commit -m "feat: add main commit 1" > /dev/null 2>&1

sleep 1

echo "Main Commit 2" > main2.txt
git add main2.txt
git commit -m "feat: add main commit 2" > /dev/null 2>&1

print_success "Main-Branch mit 2 neuen Commits aktualisiert"

echo ""
print_header "Aktueller Zustand"
git log --oneline --graph --all --decorate

# 2. MERGE Demo
print_header "MERGE Demo"
echo ""

# Merge-Branch von feature erstellen
git checkout -b merge-demo feature > /dev/null 2>&1
print_warning "Führe MERGE durch..."

git merge main --no-edit > /dev/null 2>&1

print_success "Merge abgeschlossen"
echo ""
print_header "Merge Ergebnis - Historie"
git log --oneline --graph --decorate merge-demo

MERGE_COMMITS=$(git rev-list --count merge-demo)
print_warning "Anzahl Commits nach Merge: $MERGE_COMMITS"

# Merge-Commit anzeigen
MERGE_COMMIT=$(git log --oneline merge-demo | grep "Merge branch" | head -1 | awk '{print $1}')
if [ -n "$MERGE_COMMIT" ]; then
    print_warning "Merge-Commit: $MERGE_COMMIT"
fi

echo ""

# 3. REBASE Demo
print_header "REBASE Demo"
echo ""

# Rebase-Branch von feature erstellen
git checkout -b rebase-demo feature > /dev/null 2>&1
print_warning "Führe REBASE durch..."

git rebase main > /dev/null 2>&1

print_success "Rebase abgeschlossen"
echo ""
print_header "Rebase Ergebnis - Historie"
git log --oneline --graph --decorate rebase-demo

REBASE_COMMITS=$(git rev-list --count rebase-demo)
print_warning "Anzahl Commits nach Rebase: $REBASE_COMMITS"

# 4. Vergleich
print_header "Vergleich"
echo ""

echo "MERGE:"
echo "  - Erstellt einen Merge-Commit"
echo "  - Behält die ursprüngliche Historie bei"
echo "  - Historie kann 'verschmutzt' wirken"
echo "  - Einfacher, keine Konfliktlösung während des Prozesses"
echo ""

echo "REBASE:"
echo "  - Kein Merge-Commit"
echo "  - Lineare, saubere Historie"
echo "  - Commits werden neu erstellt (andere Hashes!)"
echo "  - Konflikte müssen während des Rebase gelöst werden"
echo ""

# 5. Wichtige Hinweise
print_header "Wichtige Hinweise"
echo ""
print_warning "⚠ Rebase NIE auf öffentliche Branches anwenden!"
echo "   - Rebase ändert die Commit-History"
echo "   - Andere Entwickler hätten dann Probleme"
echo ""
print_warning "✓ Rebase ist ideal für lokale Branches vor dem Merge"
echo "   - Saubere Historie"
echo "   - Keine unnötigen Merge-Commits"
echo ""

# 6. Interaktive Entscheidung
print_header "Interaktive Entscheidung"
echo ""

read -p "Möchtest du die Unterschiede im Detail sehen? (j/n): " answer

if [ "$answer" = "j" ] || [ "$answer" = "J" ]; then
    echo ""
    print_header "Detaillierter Vergleich"
    
    echo ""
    print_header "Merge-Branch Historie"
    git log --oneline --graph --decorate merge-demo
    
    echo ""
    print_header "Rebase-Branch Historie"
    git log --oneline --graph --decorate rebase-demo
    
    echo ""
    print_header "Unterschiede in den Commits"
    echo "Merge-Branch Commits:"
    git log --oneline merge-demo | head -5
    
    echo ""
    echo "Rebase-Branch Commits:"
    git log --oneline rebase-demo | head -5
fi

echo ""
print_success "Demo abgeschlossen!"
echo ""
print_warning "Hinweis: Die Test-Branches werden automatisch gelöscht."
