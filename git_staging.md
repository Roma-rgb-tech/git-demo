# Git — Staging area and commits 


### ❓ Що таке commit і що він містить?

**Commit** — це незмінний знімок (**snapshot**) стану проекту в певний момент часу. Коли ти робиш коміт, Git зберігає не різницю між файлами, а повний стан всіх файлів.

Кожен коміт містить:
- **SHA-хеш** — унікальний ідентифікатор (наприклад: `a3f1c2d`)
- **Автор** — ім'я та email
- **Дата та час**
- **Повідомлення** — опис що було зроблено
- **Посилання на батьківський коміт** — утворює ланцюжок історії

```bash
git commit -m "feat: add login form"

git log --oneline
# a3f1c2d feat: add login form
# 9b2e4f1 fix: handle empty input
```

---

## Staging Area та стани файлів

---

### ❓ Що таке Staging Area і навіщо вона потрібна?


Staging area — це проміжна зона між вашим робочим каталогом (де ви редагуєте файли) та репозиторієм (де зберігається історія). Це місце, де ми формуємо наступний комміт, вибираючи лише ті зміни, які хочете зафіксувати. 

```bash
git add index.html          # додати файл у staging
git add .                   # додати всі змінені файли
git add -p style.css        # вибрати конкретні рядки з файлу

git diff --staged           # переглянути що піде у коміт
git restore --staged f.js   # прибрати з staging (зміни залишаться)
```

> **Три зони Git:**
> `Working Directory` → `Staging Area` → `Repository (.git)`

---

### ❓ Які стани може мати файл у Git?

Є два верхніх рівні:

| Рівень | Опис |
|---|---|
| **Untracked** | Git не знає про цей файл |
| **Tracked** | Git відстежує цей файл |

Tracked файли мають три підстани:

| Підстан | Опис |
|---|---|
| **Unmodified** | Файл не змінювався після останнього коміту |
| **Modified** | Файл змінено, але ще не доданий у staging |
| **Staged** | Зміни підготовлені до коміту |

```bash
git status

# Changes to be committed:        ← staged
#   modified: app.js

# Changes not staged for commit:  ← modified
#   modified: style.css

# Untracked files:                 ← untracked
#   notes.txt
```

---

### ❓ Яка різниця між untracked та modified?

**Untracked** — файл новий, Git ніколи не бачив його раніше. Він не входить ні в коміти, ні в `diff`. Git його просто ігнорує, доки ти не зробиш `git add`.

**Modified** — файл вже відомий Git (є в попередньому коміті), але ти його відредагував. Git бачить різницю і чекає що ти вирішиш: додати в staging чи скасувати зміни.

```bash
git restore file.txt   # скасувати зміни: modified → unmodified
git add file.txt       # і modified, і untracked → staged
```

---

### ❓ Що таке unmodified і коли файл у цьому стані?

**Unmodified** — це "чистий" стан. Файл tracked, але з моменту останнього коміту він **не змінювався**. Версія на диску і версія в репозиторії — однакові.

Саме про такі файли `git status` нічого не пише. Якщо всі файли в стані unmodified, ти побачиш:

```bash
git status
# nothing to commit, working tree clean
```

> Після успішного коміту всі staged файли автоматично переходять у стан **unmodified**.

---

### ❓ Повна схема переходів між станами

```
Untracked  ──git add──────────────────► Staged
                                           │
                                     git commit
                                           │
                                           ▼
Modified  ◄──(редагуєш файл)──────  Unmodified
   │
git add
   │
   ▼
Staged
```

---

## Практика

---

### ❓ Опиши повний цикл від зміни файлу до коміту

```bash
# 1. Редагуємо файл → він стає modified
echo "new feature" >> app.js

# 2. Перевіряємо стан
git status

# 3. Додаємо в staging → файл стає staged
git add app.js

# 4. Перевіряємо що піде в коміт
git diff --staged

# 5. Комітимо → файл стає unmodified
git commit -m "feat: add new feature"

# 6. Переглядаємо історію
git log --oneline
```

---

### ❓ Як скасувати зміни на різних етапах?

Залежить від того, на якому етапі знаходяться зміни:

```bash
# Файл modified (ще не в staging) → повернути до останнього коміту
git restore file.txt

# Файл staged → прибрати зі staging (зміни залишаться у файлі)
git restore --staged file.txt

# Скасувати останній коміт (зміни повернуться у working directory)
git reset --soft HEAD~1

# Скасувати коміт і знищити всі зміни повністю
git reset --hard HEAD~1
```

---

## Basics commands 

```bash
git status              # стан всіх файлів
git diff                # різниця: working directory vs staging
git diff --staged       # різниця: staging vs останній коміт
git log --oneline       # коротка історія комітів
git show <SHA>          # деталі конкретного коміту

git add .               # додати всі зміни в staging
git add -p              # вибрати конкретні рядки
git commit -m "msg"     # зробити коміт
git commit --amend      # виправити останній коміт

git restore <file>          # скасувати зміни у файлі
git restore --staged <file> # прибрати зі staging
git stash                   # тимчасово відкласти зміни
git stash pop               # повернути відкладені зміни
```
