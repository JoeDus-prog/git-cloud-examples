# Git Cloud Examples 🚀

Eine Sammlung von **praktischen Beispielen** für Git-Workflows, Cloud-Integration und DevOps-Best Practices. Ideal für Entwickler, die Git und Cloud-Tools effizient nutzen möchten.

---

## 📁 Struktur

```
git-cloud-examples/
├── README.md                    # Diese Datei
├── LICENSE                      # MIT-Lizenz
├── .gitignore                   # Git-Ausschlüsse
├── .github/
│   └── workflows/
│       └── ci.yml               # GitHub Actions CI
├── docs/
│   ├── git-best-practices.md    # Git-Tipps & Tricks
│   └── cloud-deployment.md      # Cloud-Deployment-Anleitung
└── examples/
    ├── git-basics/
    │   ├── rebase-vs-merge.sh    # Rebase vs. Merge Demo
    │   ├── interactive-rebase.sh # Interaktives Rebase
    │   └── git-hooks/            # Git-Hook-Beispiele
    │       ├── pre-commit        # Pre-Commit Hook
    │       └── pre-push          # Pre-Push Hook
    └── cloud/
        ├── github-actions/      # GitHub Actions Beispiele
        │   └── basic-workflow.yml
        └── aws/
            └── s3-deploy.sh     # AWS S3 Deployment Skript
```

---

## 🚀 Schnellstart

### 1. Repository klonen
```bash
git clone https://github.com/JoeDus-prog/git-cloud-examples.git
cd git-cloud-examples
```

### 2. Beispiele ausführen
```bash
# Git-Beispiele
chmod +x examples/git-basics/*.sh
./examples/git-basics/rebase-vs-merge.sh

# Cloud-Beispiele
chmod +x examples/cloud/aws/s3-deploy.sh
./examples/cloud/aws/s3-deploy.sh --help
```

---

## 📚 Dokumentation

| Datei | Beschreibung |
|-------|--------------|
| [docs/git-best-practices.md](docs/git-best-practices.md) | Git-Best Practices & Workflows |
| [docs/cloud-deployment.md](docs/cloud-deployment.md) | Cloud-Deployment-Anleitung |

---

## 🛠️ Beitragen

1. **Fork** das Repository
2. Erstelle einen **Feature-Branch** (`git checkout -b feature/neues-beispiel`)
3. Füge deine Änderungen hinzu
4. **Commit** mit klarer Nachricht (`git commit -m "feat: add neues beispiel"`)
5. **Push** und öffne einen **Pull Request**

---

## 📄 Lizenz

Dieses Projekt steht unter der [MIT-Lizenz](LICENSE).

---

## 🔗 Links

- [Git Dokumentation](https://git-scm.com/doc)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [AWS CLI Docs](https://docs.aws.amazon.com/cli/)
