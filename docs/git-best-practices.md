# Git Best Practices 📖

Eine Sammlung von **Best Practices** für effizientes Arbeiten mit Git.

---

## 📌 Inhaltsverzeichnis

1. [Commit-Nachrichten](#commit-nachrichten)
2. [Branching-Strategien](#branching-strategien)
3. [Rebase vs. Merge](#rebase-vs-merge)
4. [Git-Hooks](#git-hooks)
5. [Workflows](#workflows)

---

## Commit-Nachrichten

### ✅ Gute Beispiele
```
feat: add user authentication
fix: resolve login redirect loop
docs: update README with setup instructions
refactor: extract user service from controller
chore: update dependencies
```

### ❌ Schlechte Beispiele
```
Fixed bug
Added feature
WIP
```

### 📝 Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Typen**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

## Branching-Strategien

### Git Flow
- `main` – Produktionscode
- `develop` – Entwicklungsbranch
- `feature/*` – Neue Features
- `release/*` – Release-Vorbereitung
- `hotfix/*` – Kritische Fixes

### GitHub Flow (einfacher)
- `main` – Immer deploybar
- `feature/*` – Neue Features (PR → main)

### Trunk-Based Development
- `main` – Alle Entwickler arbeiten direkt auf main
- Kurze Feature-Branches (< 1 Tag)

---

## Rebase vs. Merge

### Merge
```bash
git checkout main
git merge feature-branch
```
- **Vorteile**: Einfache Historie, keine Konflikte während der Arbeit
- **Nachteile**: Merge-Commits "verschmutzen" die Historie

### Rebase
```bash
git checkout feature-branch
git rebase main
```
- **Vorteile**: Lineare, saubere Historie
- **Nachteile**: Konflikte müssen während des Rebase gelöst werden
- **⚠️ Achtung**: Nicht auf öffentliche Branches rebasen!

### Empfehlung
- **Lokale Branches**: Rebase vor dem Merge
- **Public Branches**: Nur Merge

---

## Git-Hooks

### Client-Side Hooks
| Hook | Zweck |
|------|-------|
| `pre-commit` | Vor dem Commit ausführen (Tests, Linting) |
| `pre-push` | Vor dem Push ausführen |
| `post-merge` | Nach dem Merge ausführen |
| `post-checkout` | Nach dem Checkout ausführen |

### Beispiel: Pre-Commit Hook
```bash
#!/bin/sh

# Linting
if ! npm run lint; then
  echo "Linting failed - commit aborted"
  exit 1
fi

# Tests
if ! npm test; then
  echo "Tests failed - commit aborted"
  exit 1
fi
```

### Server-Side Hooks
| Hook | Zweck |
|------|-------|
| `pre-receive` | Vor dem Empfang von Pushes |
| `post-receive` | Nach dem Empfang von Pushes (z. B. Deployment) |

---

## Workflows

### Feature Entwicklung
```bash
# 1. Branch erstellen
git checkout -b feature/neue-funktion

# 2. Änderungen commiten
git add .
git commit -m "feat: neue funktion implementieren"

# 3. Mit main synchronisieren
git fetch origin
git rebase origin/main

# 4. Push & Pull Request
git push origin feature/neue-funktion
# → PR auf GitHub erstellen
```

### Bug Fix
```bash
# 1. Branch von main erstellen
git checkout main
git pull origin main
git checkout -b fix/login-bug

# 2. Bug fixen & commiten
git add .
git commit -m "fix: login redirect loop"

# 3. Push & PR
git push origin fix/login-bug
```

### Hotfix (Produktion)
```bash
# 1. Von main branchen
git checkout main
git pull origin main
git checkout -b hotfix/kritischer-fehler

# 2. Fix & commiten
git add .
git commit -m "fix: kritischer fehler in produktion"

# 3. Direkt nach main mergen
git checkout main
git merge hotfix/kritischer-fehler
git push origin main

# 4. Tag setzen
git tag -a v1.0.1 -m "Hotfix: kritischer fehler"
git push origin v1.0.1
```

---

## 🔗 Nützliche Links

- [Git Offizielle Dokumentation](https://git-scm.com/doc)
- [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
