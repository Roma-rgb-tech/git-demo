# Git Hooks та Pre-commit
---

## Що таке Git Hooks?

Git Hooks — це **скрипти, які автоматично запускаються** при певних подіях у git (commit, push, merge тощо). Дозволяють автоматизувати перевірки та дії без участі розробника.

Зберігаються у директорії `.git/hooks/` кожного репозиторію.

```bash
ls .git/hooks/
# applypatch-msg.sample  pre-commit.sample
# commit-msg.sample      pre-push.sample
# post-update.sample     prepare-commit-msg.sample
# ...
```

> Файли з розширенням `.sample` — приклади, вони не активні. Щоб активувати — прибери `.sample`.

---

## Типи Git Hooks

Хуки діляться на дві групи: **client-side** (локальні) та **server-side** (на сервері).

### Client-side хуки

| Хук | Коли запускається | Типове використання |
|---|---|---|
| `pre-commit` | Перед створенням коміту | Лінтинг, форматування, тести |
| `prepare-commit-msg` | Перед відкриттям редактора повідомлення | Автодоповнення повідомлення |
| `commit-msg` | Після введення повідомлення коміту | Перевірка формату повідомлення |
| `post-commit` | Після створення коміту | Сповіщення, логування |
| `pre-push` | Перед відправкою на remote | Запуск тестів, перевірки |
| `pre-rebase` | Перед rebase | Захист від небезпечного rebase |
| `post-merge` | Після merge | Встановлення залежностей |
| `post-checkout` | Після checkout | Очищення, підготовка середовища |

### Server-side хуки

| Хук | Коли запускається | Типове використання |
|---|---|---|
| `pre-receive` | До прийому push | Перевірка прав, валідація |
| `update` | Для кожної гілки при push | Захист гілок |
| `post-receive` | Після прийому push | CI/CD тригер, сповіщення |

---

## Як створити Git Hook вручну

### Приклад: простий pre-commit хук

```bash
# Перейти в директорію хуків
cd .git/hooks

# Створити файл
touch pre-commit

# Зробити виконуваним
chmod +x pre-commit
```

Вміст файлу `.git/hooks/pre-commit`:
```bash
#!/bin/bash

echo "Запуск pre-commit перевірок..."

# Перевірка: чи немає слова TODO в коді
if git diff --cached | grep -q "TODO"; then
  echo "❌ Знайдено TODO у змінах. Закоміть після виправлення."
  exit 1  # ненульовий exit code = заблокувати коміт
fi

echo "✅ Перевірки пройдено"
exit 0  # нульовий exit code = дозволити коміт
```

> **Важливо:** якщо хук повертає `exit 1` — коміт блокується. `exit 0` — коміт проходить.

### Приклад: commit-msg хук (перевірка формату)

```bash
#!/bin/bash
# .git/hooks/commit-msg

COMMIT_MSG=$(cat "$1")
PATTERN="^(feat|fix|docs|style|refactor|test|chore): .+"

if ! echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
  echo "❌ Невірний формат повідомлення коміту!"
  echo "   Очікується: feat: опис / fix: опис / docs: опис"
  echo "   Отримано:   $COMMIT_MSG"
  exit 1
fi

exit 0
```

### Приклад: pre-push хук (запуск тестів)

```bash
#!/bin/bash
# .git/hooks/pre-push

echo "Запуск тестів перед push..."

npm test

if [ $? -ne 0 ]; then
  echo "❌ Тести не пройшли. Push заблоковано."
  exit 1
fi

echo "✅ Тести пройшли"
exit 0
```

---

## Проблема з .git/hooks

`.git/` **не додається в репозиторій** — хуки не шеряться між розробниками автоматично.

**Рішення:**
1. Зберігати хуки у папці в репозиторії (наприклад `.githooks/`)
2. Налаштувати git використовувати цю папку:

```bash
git config core.hooksPath .githooks
```

Або використовувати **pre-commit framework** (дивись нижче).

---

## Що таке pre-commit framework?

`pre-commit` — це **інструмент для управління git hooks**, зокрема `pre-commit` хуком. Дозволяє:

- Описати всі перевірки в одному файлі `.pre-commit-config.yaml`
- Шерити конфігурацію між розробниками через git
- Використовувати готові хуки з відкритого реєстру
- Запускати хуки для різних мов (Python, JS, Go тощо) в ізольованих середовищах

### Встановлення

```bash
# через pip
pip install pre-commit

# через brew (macOS)
brew install pre-commit

# перевірити версію
pre-commit --version
```

### Налаштування: .pre-commit-config.yaml

Файл створюється в корені репозиторію:

```yaml
repos:
  # Базові перевірки від pre-commit
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace        # видалити пробіли в кінці рядків
      - id: end-of-file-fixer          # додати новий рядок в кінці файлу
      - id: check-yaml                 # перевірити синтаксис YAML
      - id: check-json                 # перевірити синтаксис JSON
      - id: check-merge-conflict       # знайти маркери merge конфліктів
      - id: detect-private-key         # знайти приватні ключі в коді
      - id: check-added-large-files    # заблокувати великі файли (>500KB)

  # Python: форматування і лінтинг
  - repo: https://github.com/psf/black
    rev: 23.12.0
    hooks:
      - id: black
        language_version: python3

  - repo: https://github.com/PyCQA/flake8
    rev: 7.0.0
    hooks:
      - id: flake8

  # JavaScript/TypeScript: ESLint
  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v8.56.0
    hooks:
      - id: eslint
        files: \.(js|ts|jsx|tsx)$
        additional_dependencies:
          - eslint@8.56.0

  # Terraform: форматування
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.86.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate

  # Shell: перевірка bash скриптів
  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.6
    hooks:
      - id: shellcheck
```

### Активація pre-commit у репозиторії

```bash
# Встановити хуки в .git/hooks/
pre-commit install

# Тепер при кожному git commit — автоматично запускаються перевірки
```

---

## Основні команди pre-commit

```bash
# Встановити хуки
pre-commit install

# Встановити хук для commit-msg
pre-commit install --hook-type commit-msg

# Запустити всі хуки вручну на всіх файлах
pre-commit run --all-files

# Запустити конкретний хук
pre-commit run black --all-files
pre-commit run trailing-whitespace

# Запустити на змінених файлах (staged)
pre-commit run

# Оновити версії хуків до останніх
pre-commit autoupdate

# Пропустити хуки для одного коміту (не зловживати!)
git commit --no-verify -m "fix: швидке виправлення"

# Очистити кеш pre-commit
pre-commit clean
```

---

## Приклад: повний робочий процес

### 1. Ініціалізація в проєкті

```bash
# Встановити pre-commit
pip install pre-commit

# Створити конфіг
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: detect-private-key
EOF

# Активувати
pre-commit install

# Додати конфіг в git
git add .pre-commit-config.yaml
git commit -m "chore: add pre-commit config"
```

### 2. Що відбувається при git commit

```bash
$ git add main.py
$ git commit -m "feat: add new feature"

[INFO] Initializing environment for https://github.com/psf/black.
Trim Trailing Whitespace.............................Passed
Fix End of Files.....................................Passed
Check Yaml...........................................Passed
black................................................Failed
- hook id: black
- files were modified by this hook

reformatted main.py

# black автоматично виправив форматування
# потрібно знову зробити git add і git commit
$ git add main.py
$ git commit -m "feat: add new feature"
# тепер всі перевірки пройшли ✅
```

---

## Власний локальний хук у pre-commit

```yaml
repos:
  - repo: local                          # локальний хук, не з реєстру
    hooks:
      - id: run-unit-tests
        name: Run unit tests
        entry: python -m pytest tests/unit -q
        language: python
        pass_filenames: false            # не передавати імена файлів
        always_run: false                # запускати тільки якщо є зміни

      - id: check-env-file
        name: Check .env not committed
        entry: bash -c 'git diff --cached --name-only | grep -q "^\.env$" && echo "❌ Не комітити .env!" && exit 1 || exit 0'
        language: system
        pass_filenames: false
```

---

## Корисні готові хуки

### pre-commit-hooks (офіційні)
```yaml
- repo: https://github.com/pre-commit/pre-commit-hooks
  rev: v4.5.0
  hooks:
    - id: check-added-large-files    # блокувати файли > 500KB
    - id: check-case-conflict        # конфлікти імен на case-insensitive ФС
    - id: check-merge-conflict       # маркери <<<< ====
    - id: detect-private-key         # приватні RSA/SSH ключі
    - id: no-commit-to-branch        # заборонити коміт в main/master
      args: ['--branch', 'main', '--branch', 'master']
```

### Безпека: detect-secrets
```yaml
- repo: https://github.com/Yelp/detect-secrets
  rev: v1.4.0
  hooks:
    - id: detect-secrets             # знаходить паролі, токени, API ключі
      args: ['--baseline', '.secrets.baseline']
```

### commitlint (перевірка формату коміту)
```yaml
- repo: https://github.com/alessandrojcm/commitlint-pre-commit-hook
  rev: v9.13.0
  hooks:
    - id: commitlint
      stages: [commit-msg]
      additional_dependencies: ['@commitlint/config-conventional']
```

---

## Порівняння: ручні хуки vs pre-commit framework

| | Ручні хуки (.git/hooks) | pre-commit framework |
|---|---|---|
| Шеринг між командою | Ні (не в git) | Так (.pre-commit-config.yaml в репо) |
| Готові хуки | Писати самому | Тисячі готових |
| Ізоляція середовища | Ні | Так (virtualenv для кожного хука) |
| Простота налаштування | Просто | Трохи складніше |
| Мультимовність | Ручно | Вбудована |
| Версіонування хуків | Ні | Так (rev у конфігу) |

---

## Типова конфігурація для DevOps проєкту

```yaml
# .pre-commit-config.yaml для DevOps/IaC репозиторію

repos:
  # Загальні перевірки
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
        args: ['--allow-multiple-documents']
      - id: check-json
      - id: detect-private-key
      - id: check-merge-conflict
      - id: no-commit-to-branch
        args: ['--branch', 'main']

  # Terraform
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.86.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
        args: ['--output-file', 'README.md']

  # Ansible
  - repo: https://github.com/ansible/ansible-lint
    rev: v6.22.2
    hooks:
      - id: ansible-lint

  # Shell скрипти
  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.6
    hooks:
      - id: shellcheck

  # Docker
  - repo: https://github.com/hadolint/hadolint
    rev: v2.12.0
    hooks:
      - id: hadolint            # лінтинг Dockerfile
        args: ['--ignore', 'DL3008']

  # Secrets detection
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
```

---

## Підсумок

```
Git Hooks
├── Вбудований механізм git
├── Зберігаються в .git/hooks/
├── Не шеряться в репозиторії (потребує core.hooksPath)
└── Типи: pre-commit, commit-msg, pre-push, post-merge...

pre-commit framework
├── Інструмент для управління хуками
├── Конфіг: .pre-commit-config.yaml (в git)
├── Тисячі готових хуків з реєстру
└── Ізольоване виконання, версіонування

Типовий workflow
├── pip install pre-commit
├── Створити .pre-commit-config.yaml
├── pre-commit install
└── При git commit → хуки запускаються автоматично
```

---

*Конспект охоплює: git hooks (типи, приклади), pre-commit framework (встановлення, конфігурація, команди), порівняння підходів.*




