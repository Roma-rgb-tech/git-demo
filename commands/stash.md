# Git Stash — Конспект

## 1. Що таке stash?

**Stash** — це тимчасове сховище для незакомічених змін. Дозволяє "відкласти" поточну роботу, перемкнутись на іншу задачу, а потім повернутись і продовжити.

Stash зберігає:
- зміни в **tracked** файлах (змінені та staged)
- за бажанням — **untracked** та **ignored** файли

---

## 2. Базові команди

```bash
git stash              # зберегти зміни в stash (= git stash push)
git stash pop          # відновити останній stash і видалити його зі стеку
git stash apply        # відновити останній stash, але НЕ видаляти
git stash list         # переглянути всі stash-и
git stash drop         # видалити останній stash
git stash clear        # видалити ВСІ stash-и
```

---

## 3. Як працює стек stash

Stash працює як **стек** (LIFO — останній зайшов, перший вийшов).

```
git stash        → stash@{0}  ← новий завжди на вершині
git stash        → stash@{0}, stash@{1}
git stash        → stash@{0}, stash@{1}, stash@{2}
git stash pop    → забирає stash@{0}
```

---

## 4. Збереження з повідомленням

```bash
git stash push -m "WIP: форма логіну"
# stash@{0}: On main: WIP: форма логіну
```

Завжди додавай повідомлення — без нього важко зрозуміти, що де лежить.

---

## 5. Перегляд вмісту stash

```bash
git stash list
# stash@{0}: On main: WIP: форма логіну
# stash@{1}: On feature/auth: виправлення валідації

git stash show             # короткий diff останнього stash
git stash show -p          # повний diff останнього stash
git stash show stash@{1}   # конкретний stash
git stash show -p stash@{1}
```

---

## 6. Робота з конкретним stash

```bash
git stash apply stash@{2}   # відновити конкретний (не видаляючи)
git stash drop  stash@{1}   # видалити конкретний
git stash pop   stash@{2}   # відновити і видалити конкретний
```

---

## 7. Збереження untracked та ignored файлів

За замовчуванням stash **не зберігає** нові (untracked) файли.

```bash
git stash push -u           # включити untracked файли
git stash push -u -m "з новими файлами"

git stash push -a           # включити також ignored файли
# -a = --all
```

| Прапорець | Що зберігає |
|---|---|
| (без прапорців) | Тільки tracked змінені файли |
| `-u` / `--include-untracked` | + нові файли (untracked) |
| `-a` / `--all` | + нові + ignored файли |

---

## 8. Stash конкретних файлів

```bash
git stash push -m "тільки стилі" -- src/styles.css src/theme.css
```

---

## 9. Створення гілки зі stash

Якщо після stash основна гілка змінилась і виникають конфлікти при `pop`:

```bash
git stash branch new-feature stash@{0}
# створює нову гілку від того commit, де був зроблений stash
# і одразу застосовує зміни
```

---

## 10. Конфлікти при pop / apply

Якщо зміни зі stash конфліктують із поточним станом файлів — Git повідомить про конфлікт, як при merge.

```bash
git stash pop
# CONFLICT (content): Merge conflict in index.js

# → вирішити конфлікти вручну
# → git add index.js
# → якщо використовував pop — stash вже видалений
# → якщо використовував apply — видалити вручну: git stash drop
```

> ⚠️ При конфлікті `git stash pop` **не видаляє** stash автоматично — він залишається у стеку.

---

## 11. Типові сценарії використання

**Терміново треба переключитись на іншу гілку:**
```bash
git stash push -m "WIP: нова фіча"
git checkout hotfix/bug-123
# ... виправити баг, закомітити ...
git checkout main
git stash pop
```

**Переніс змін на іншу гілку:**
```bash
git stash push -m "зміни не на тій гілці"
git checkout correct-branch
git stash pop
```

**Швидко перевірити чистий стан репозиторію:**
```bash
git stash
# перевірити / запустити тести на чистому коді
git stash pop
```

---

## 12. Шпаргалка

```bash
# Зберегти
git stash                        # швидко
git stash push -m "опис"         # з повідомленням
git stash push -u -m "опис"      # + untracked файли
git stash push -m "опис" -- file # конкретний файл

# Переглянути
git stash list                   # всі stash-и
git stash show -p                # diff останнього
git stash show -p stash@{N}      # diff конкретного

# Відновити
git stash pop                    # відновити + видалити
git stash apply                  # відновити, але зберегти
git stash pop stash@{N}          # конкретний

# Видалити
git stash drop stash@{N}         # один
git stash clear                  # всі

# Гілка зі stash
git stash branch <branch> stash@{N}
```

---

## 13. Stash vs Commit

| | `git stash` | `git commit` |
|---|---|---|
| Зберігається в історії? | ❌ Ні (окремий стек) | ✅ Так |
| Призначення | Тимчасове відкладення | Постійна фіксація |
| Можна запушити? | ❌ Ні | ✅ Так |
| Зручно для | Швидкого переключення | Завершеної роботи |

> Якщо відкладаєш щось більш ніж на день — краще зроби WIP-коміт у гілці, ніж stash.
