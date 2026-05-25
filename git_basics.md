# Git Internals — `.git` та `HEAD`

## Що таке `.git`?

**`.git`** — прихована папка в кореневій директорії репозиторію, яка містить **увесь Git-репозиторій**: всю історію комітів, гілки, теги, конфігурацію та об'єкти.

> ⚠️ Видалити `.git` = видалити весь репозиторій. Робоча директорія залишиться, але вся Git-історія зникне.

---

## Структура `.git`

```
.git/
├── HEAD                  ← вказує на поточну гілку або коміт
├── config                ← локальна конфігурація репозиторію
├── description           ← опис репозиторію (для GitWeb)
├── index                 ← staging area (індекс)
│
├── objects/              ← база даних об'єктів Git
│   ├── pack/             ← стиснуті об'єкти (packfiles)
│   ├── info/             ← метадані для pack
│   ├── ab/               ← об'єкти (перші 2 символи хешу)
│   └── ...               ← папки-хеші
│
├── refs/                 ← посилання (гілки, теги)
│   ├── heads/            ← локальні гілки
│   │   ├── main
│   │   └── feature/login
│   ├── remotes/          ← remote-гілки
│   │   └── origin/
│   │       └── main
│   └── tags/             ← теги
│
├── logs/                 ← журнал змін посилань (reflog)
│   ├── HEAD
│   └── refs/
│
└── hooks/                ← скрипти-хуки (pre-commit, post-merge...)
```

---

## Ключові файли та папки

### `HEAD`

**HEAD** — файл, який вказує, **де ти зараз** у репозиторії.

Зазвичай містить **symbolic ref** — посилання на поточну гілку:

```
ref: refs/heads/main
```

Це означає: "я на гілці `main`, а `main` вказує на останній коміт цієї гілки."

**Detached HEAD** — стан, коли HEAD вказує напряму на хеш коміту, а не на гілку:

```
a3f8c2d19b4e7f1c0d5e9b8a2f6e4c7d1b3a5f7e
```

> 💡 Detached HEAD виникає при `git checkout <commit-hash>`. Нові коміти не прив'язуються до гілки — вони "висять у повітрі".

---

### `objects/` — база даних об'єктів

Git зберігає **всі дані як об'єкти** у вигляді хешів SHA-1 (40 символів).

| Тип об'єкта | Що зберігає |
|-------------|-------------|
| **blob** | Вміст файлу (без імені) |
| **tree** | Структура директорії (імена файлів + посилання на blob) |
| **commit** | Коміт: автор, час, повідомлення + посилання на tree |
| **tag** | Анотований тег: посилання на коміт + метадані |

**Як зберігаються об'єкти:**

Хеш `a3f8c2d19b...` → зберігається у `objects/a3/f8c2d19b...`

```bash
# Подивитись тип об'єкта
git cat-file -t a3f8c2d

# Подивитись вміст об'єкта
git cat-file -p a3f8c2d
```

---

### `refs/` — посилання

Гілки і теги — це просто **текстові файли з хешем коміту**.

```bash
cat .git/refs/heads/main
# → a3f8c2d19b4e7f1c0d5e9b8a2f6e4c7d1b3a5f7e
```

| Шлях | Що зберігає |
|------|-------------|
| `refs/heads/main` | Хеш останнього коміту гілки `main` |
| `refs/remotes/origin/main` | Останній відомий стан remote-гілки |
| `refs/tags/v1.0.0` | Хеш тегу |

---

### `index` — staging area

**Index (індекс)** — бінарний файл, який представляє **staging area** (`git add`).

Він зберігає список файлів з їхніми хешами, які будуть включені в наступний коміт.

```
Working Directory → (git add) → Index → (git commit) → Objects
```

---

### `config` — конфігурація репозиторію

Локальні налаштування, які перевизначають глобальні (`~/.gitconfig`):

```ini
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false

[remote "origin"]
    url = https://github.com/user/repo.git
    fetch = +refs/heads/*:refs/remotes/origin/*

[branch "main"]
    remote = origin
    merge = refs/heads/main
```

---

### `logs/` — reflog

**Reflog** — журнал всіх змін HEAD та гілок. Зберігає навіть "втрачені" коміти.

```bash
# Переглянути reflog
git reflog

# Відновити "видалену" гілку через reflog
git checkout -b recovered-branch HEAD@{3}
```

---

### `hooks/` — Git-хуки

Скрипти, які запускаються автоматично при певних Git-подіях:

| Хук | Коли запускається |
|-----|-------------------|
| `pre-commit` | Перед кожним комітом |
| `commit-msg` | Для валідації повідомлення коміту |
| `post-commit` | Після коміту |
| `pre-push` | Перед `git push` |
| `post-merge` | Після `git merge` |

Щоб активувати хук — файл має бути **executable** (`chmod +x .git/hooks/pre-commit`).

---

## Як Git знаходить поточний коміт

```
HEAD
 ↓ (читає файл HEAD → "ref: refs/heads/main")
refs/heads/main
 ↓ (читає файл → SHA-1 хеш)
objects/a3/f8c2d...   ← commit object
 ↓ (містить посилання на tree)
objects/.../tree      ← tree object
 ↓ (містить посилання на blob-и)
objects/.../blob      ← вміст файлів
```

---

## Корисні команди для дослідження `.git`

```bash
# Подивитись куди вказує HEAD
cat .git/HEAD

# Хеш поточного коміту
git rev-parse HEAD

# Список всіх об'єктів
git cat-file --batch-all-objects --batch-check

# Граф комітів з хешами
git log --oneline --graph --all

# Що в staging area (index)
git ls-files --stage

# Інформація про конкретний об'єкт
git cat-file -p HEAD
```

---

## Підсумок

| Компонент | Роль |
|-----------|------|
| `HEAD` | Поточна позиція в репозиторії |
| `objects/` | Вся база даних Git (файли, дерева, коміти) |
| `refs/` | Гілки та теги як іменовані вказівники на коміти |
| `index` | Staging area — що увійде в наступний коміт |
| `config` | Локальні налаштування репозиторію |
| `logs/` | Reflog — журнал всіх змін (для відновлення) |
| `hooks/` | Автоматичні скрипти на Git-події |
