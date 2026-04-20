# Git Interactive Rebase (`rebase -i`)

## Зміст
1. [Що таке rebase -i](#що-таке-rebase--i)
2. [Базовий синтаксис](#базовий-синтаксис)
3. [Команди в редакторі](#команди-в-редакторі)
4. [Практичні приклади](#практичні-приклади)
5. [Конфлікти під час rebase](#конфлікти-під-час-rebase)
6. [Золоті правила](#золоті-правила)

---

## Що таке rebase -i

**Interactive rebase** — інструмент Git, що дозволяє переписати історію комітів: об'єднати, перейменувати, видалити, переставити або розбити коміти до того, як вони потраплять у спільну гілку.

```
Брудна історія під час розробки:     Чиста історія після rebase -i:

abc1234 fix typo                      a1b2c3d feat(auth): add OAuth2 login
def5678 fix typo again
ghi9012 WIP
jkl3456 feat(auth): add OAuth2 login
```

> 💡 `rebase -i` — це інструмент для **локальної** роботи. Переписуй лише ті коміти, які ще не запушені у спільну гілку.

---

## Базовий синтаксис

```bash
git rebase -i HEAD~N        # переписати останні N комітів
git rebase -i <commit-hash> # переписати коміти після вказаного хешу
git rebase -i main          # переписати всі коміти, яких немає в main
```

### Як відкривається редактор

```bash
git rebase -i HEAD~4
```

Git відкриє редактор (vim / nano / vscode) з таким вмістом:

```
pick a1b2c3d feat(auth): initial OAuth setup
pick b2c3d4e fix typo in auth
pick c3d4e5f WIP: still broken
pick d4e5f6g feat(auth): complete OAuth2 login

# Rebase e5f6g7h..d4e5f6g onto e5f6g7h (4 commands)
#
# Commands:
# p, pick   = use commit
# r, reword = use commit, but edit the commit message
# e, edit   = use commit, but stop for amending
# s, squash = use commit, meld into previous commit
# f, fixup  = like squash, but discard this commit's message
# d, drop   = remove commit
```

Коміти відображаються від **старого до нового** (зверху вниз).

---

## Команди в редакторі

| Команда | Скорочення | Що робить |
|---|---|---|
| `pick` | `p` | Залишити коміт без змін |
| `reword` | `r` | Залишити коміт, але змінити повідомлення |
| `edit` | `e` | Зупинитись на коміті для внесення змін у код |
| `squash` | `s` | Об'єднати з попереднім комітом, зберегти обидва повідомлення |
| `fixup` | `f` | Об'єднати з попереднім комітом, викинути це повідомлення |
| `drop` | `d` | Видалити коміт повністю |
| `exec` | `x` | Виконати shell-команду після коміту |

---

## Практичні приклади

### 1. Squash — об'єднати дрібні коміти в один

**Ситуація:** є 3 коміти, які логічно є однією фічею.

```bash
git rebase -i HEAD~3
```

```
# До:
pick a1b2c3d feat(auth): add login form
pick b2c3d4e fix typo in form
pick c3d4e5f fix another typo

# Після (змінюємо pick → squash або fixup):
pick a1b2c3d feat(auth): add login form
squash b2c3d4e fix typo in form
fixup c3d4e5f fix another typo
```

Git відкриє редактор для фінального повідомлення коміту. Результат — один чистий коміт.

---

### 2. Reword — перейменувати коміт

**Ситуація:** коміт названий "WIP" або не відповідає Conventional Commits.

```bash
git rebase -i HEAD~2
```

```
# Змінюємо pick → reword:
pick a1b2c3d feat: add button
reword b2c3d4e WIP
```

Git зупиниться і відкриє редактор — вводимо нове повідомлення:
```
fix(ui): correct button alignment on mobile
```

---

### 3. Drop — видалити коміт

**Ситуація:** закомітили debug-код або секрети (але ще не запушили!).

```bash
git rebase -i HEAD~3
```

```
# Змінюємо pick → drop (або просто видаляємо рядок):
pick a1b2c3d feat(api): add endpoint
drop b2c3d4e debug: console.log all requests   ← видалено
pick c3d4e5f test(api): add endpoint tests
```

---

### 4. Reorder — переставити коміти

**Ситуація:** треба змінити порядок комітів.

```
# До:
pick a1b2c3d chore: update deps
pick b2c3d4e feat(ui): add dark mode
pick c3d4e5f docs: update readme

# Після (просто міняємо рядки місцями):
pick b2c3d4e feat(ui): add dark mode
pick c3d4e5f docs: update readme
pick a1b2c3d chore: update deps
```

---

### 5. Edit — розбити один коміт на кілька

**Ситуація:** один коміт містить занадто багато змін.

```bash
git rebase -i HEAD~2
```

```
# Змінюємо pick → edit:
edit a1b2c3d feat: add auth and update profile page and fix header
pick b2c3d4e chore: update deps
```

Git зупиниться на цьому коміті. Далі:

```bash
git reset HEAD~          # розпакувати коміт назад у робочу директорію

git add src/auth/        # додати тільки auth-файли
git commit -m "feat(auth): add login and registration"

git add src/profile/     # додати profile-файли
git commit -m "feat(profile): update user profile page"

git add src/components/header/
git commit -m "fix(header): correct logo alignment"

git rebase --continue    # продовжити rebase
```

---

## Конфлікти під час rebase

Якщо під час rebase виникає конфлікт:

```bash
# 1. Git зупиняється і показує конфлікт
CONFLICT (content): Merge conflict in src/auth.js

# 2. Вирішуємо конфлікт вручну у файлі
# Видаляємо маркери <<<<<<, ======, >>>>>>

# 3. Додаємо вирішений файл
git add src/auth.js

# 4. Продовжуємо rebase
git rebase --continue

# Або — скасувати весь rebase і повернутись до початку
git rebase --abort
```

### Корисні команди під час rebase

| Команда | Що робить |
|---|---|
| `git rebase --continue` | Продовжити після вирішення конфлікту або edit |
| `git rebase --abort` | Скасувати rebase, повернути все як було |
| `git rebase --skip` | Пропустити поточний коміт |

---

## Золоті правила

### ⚠️ Не переписуй публічну історію

```bash
# НЕБЕЗПЕЧНО — якщо гілка вже запушена і інші з нею працюють:
git rebase -i origin/main

# Після force push колеги отримають конфлікти історії
git push --force  # ← може зламати роботу команди
```

Якщо все ж треба force push — використовуй безпечний варіант:

```bash
git push --force-with-lease  # відмовить, якщо хтось вже запушив у цю гілку
```

### ✅ Коли rebase -i безпечний

- Локальні коміти, які ще не запушені
- Власна feature-гілка, з якою ніхто більше не працює
- Перед відкриттям Pull Request — прибрати "WIP", "fix typo" коміти

### Типовий workflow перед PR

```bash
# 1. Переглянути свої коміти
git log --oneline main..HEAD

# 2. Почистити історію
git rebase -i main

# 3. Запушити чисту гілку
git push --force-with-lease origin feature/my-feature
```

---

## Корисні посилання

- [Git rebase документація](https://git-scm.com/docs/git-rebase)
- [Atlassian: Rewriting history](https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase)
- [Oh Shit, Git!?!](https://ohshitgit.com/) — як виправити типові помилки в Git
