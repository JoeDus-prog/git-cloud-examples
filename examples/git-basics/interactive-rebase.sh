#!/bin/bash

# =============================================================================
# Interactive Rebase - Demonstrationsskript
# 
# Dieses Skript zeigt, wie man mit `git rebase -i` Commits interaktiv
# bearbeiten kann (squash, edit, drop, etc.)
# 
# Verwendung:
#   1. Führe das Skript in einem Git-Repository aus
#   2. Das Skript erstellt Test-Commits und führt dich durch den Prozess
# =============================================================================

set -e

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    git branch -D interactive-rebase-demo > /dev/null 2>&1
    print_success "Test-Branch gelöscht"
}

trap cleanup EXIT

# =============================================================================
# HAUPTPROGRAMM
# =============================================================================

echo ""
print_header "Interactive Rebase Demo"
echo ""

# 1. Vorbereitung
print_header "Vorbereitung"

# Main Branch sicherstellen
git checkout main > /dev/null 2>&1 || git checkout master > /dev/null 2>&1
print_success "Auf main Branch"

# Test-Branch löschen falls vorhanden
git branch -D interactive-rebase-demo > /dev/null 2>&1

# Demo-Branch erstellen
git checkout -b interactive-rebase-demo > /dev/null 2>&1
print_success "Demo-Branch erstellt"

# Mehrere Commits erstellen
print_warning "Erstelle Test-Commits..."

echo "Commit 1 - Initial" > commit1.txt
git add commit1.txt
git commit -m "feat: initial commit" > /dev/null 2>&1

sleep 1

echo "Commit 2 - Add feature A" > commit2.txt
git add commit2.txt
git commit -m "feat: add feature A" > /dev/null 2>&1

sleep 1

echo "Commit 3 - Typo fix" > commit3.txt
git add commit3.txt
git commit -m "fix: typo in feature A" > /dev/null 2>&1

sleep 1

echo "Commit 4 - Add feature B" > commit4.txt
git add commit4.txt
git commit -m "feat: add feature B" > /dev/null 2>&1

sleep 1

echo "Commit 5 - Another typo" > commit5.txt
git add commit5.txt
git commit -m "fix: another typo" > /dev/null 2>&1

print_success "5 Test-Commits erstellt"

echo ""
print_header "Aktuelle Historie"
git log --oneline --decorate

# 2. Interactive Rebase erklären
print_header "Interactive Rebase (git rebase -i)"
echo ""

echo "Mit interaktivem Rebase kannst du:"
echo "  - Commits zusammenfassen (squash)"
echo "  - Commit-Nachrichten bearbeiten (reword)"
echo "  - Commits löschen (drop)"
echo "  - Commits bearbeiten (edit)"
echo "  - Commits neu ordnen"
echo ""

# 3. Beispiel: Commits squashen
print_header "Beispiel: Commits zusammenfassen (squash)"
echo ""

print_warning "Wir werden die letzten 4 Commits zu 2 zusammenfassen:"
echo "  - Commit 2 & 3 → 'feat: add feature A with fixes'"
echo "  - Commit 4 & 5 → 'feat: add feature B with fixes'"
echo ""

print_warning "Führe folgenden Befehl aus:"
echo "  git rebase -i HEAD~4"
echo ""
print_warning "Im Editor, der sich öffnet:"
echo "  1. Ersetze 'pick' bei Commit 3 mit 'squash' (oder 's')"
echo "  2. Ersetze 'pick' bei Commit 5 mit 'squash' (oder 's')"
echo "  3. Speichern und schließen"
echo ""

read -p "Drücke Enter, um den interaktiven Rebase zu starten..." 

# Rebase starten
git rebase -i HEAD~4

# Nach dem Rebase
print_success "Interaktiver Rebase abgeschlossen!"
echo ""
print_header "Neue Historie"
git log --oneline --decorate

# 4. Beispiel: Commit-Nachricht bearbeiten
print_header "Beispiel: Commit-Nachricht bearbeiten (reword)"
echo ""

print_warning "Jetzt bearbeiten wir die Nachricht des ersten Commits."
echo ""

print_warning "Führe folgenden Befehl aus:"
echo "  git rebase -i HEAD~3"
echo ""
print_warning "Im Editor:"
echo "  1. Ersetze 'pick' beim ersten Commit mit 'reword' (oder 'r')"
echo "  2. Speichern und schließen"
echo "  3. Im nächsten Editor die Nachricht bearbeiten"
echo ""

read -p "Drücke Enter, um den Rebase zu starten..." 

# Rebase starten
git rebase -i HEAD~3

print_success "Commit-Nachricht bearbeitet!"
echo ""
print_header "Aktualisierte Historie"
git log --oneline --decorate

# 5. Beispiel: Commit löschen
print_header "Beispiel: Commit löschen (drop)"
echo ""

print_warning "Jetzt löschen wir den letzten Commit."
echo ""

print_warning "Führe folgenden Befehl aus:"
echo "  git rebase -i HEAD~2"
echo ""
print_warning "Im Editor:"
echo "  1. Ersetze 'pick' beim letzten Commit mit 'drop' (oder 'd')"
echo "  2. Speichern und schließen"
echo ""

read -p "Drücke Enter, um den Rebase zu starten..." 

# Rebase starten
git rebase -i HEAD~2

print_success "Commit gelöscht!"
echo ""
print_header "Final Historie"
git log --oneline --decorate

# 6. Wichtige Hinweise
print_header "Wichtige Hinweise"
echo ""

print_warning "⚠ Interactive Rebase ändert die Commit-History!"
echo "   - Alle Commits nach dem Rebase-Punkt bekommen neue Hashes"
echo "   - Dies kann Probleme verursachen, wenn andere auf diesen Branches arbeiten"
echo ""

print_warning "✓ Tipps für sicheres Rebasen:"
echo "   - Nur auf lokalen Branches verwenden"
echo "   - Nicht auf main/master oder anderen geteilten Branches"
echo "   - Vor dem Rebase: git fetch & git pull"
echo "   - Nach dem Rebase: Force Push (git push -f) wenn bereits gepusht"
echo ""

print_warning "💡 Nützliche Befehle:"
echo "   - git rebase -i HEAD~N  # Letzte N Commits bearbeiten"
echo "   - git rebase -i <commit> # Ab einem bestimmten Commit"
echo "   - git rebase --abort    # Rebase abbrechen"
echo "   - git rebase --continue # Rebase fortsetzen"
echo "   - git rebase --skip     # Aktuellen Commit überspringen"
echo ""

echo ""
print_success "Demo abgeschlossen!"
