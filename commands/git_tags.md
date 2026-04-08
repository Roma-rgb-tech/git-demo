# Git Tags — Конспект

## 1. Що таке тег?

**Tag** — це іменований вказівник на конкретний commit. На відміну від гілки, тег **не рухається** — він завжди вказує на один і той самий момент в історії.

Використовується для позначення **релізів**, **версій**, **важливих точок** у проєкті.

---

## 2. Типи тегів

| Тип | Опис | Зберігає метадані? |
|---|---|---|
| **Lightweight** | Просто вказівник на commit (як закладка) | ❌ |
| **Annotated** | Повноцінний об'єкт Git: автор, дата, повідомлення | ✅ |

> Для релізів завжди використовуй **annotated** теги.

---

## 3. Створення тегів

### Lightweight тег
```bash
git tag v1.0.0
```

### Annotated тег
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
```

### Тег на конкретний commit
```bash
git tag -a v0.9.0 9fceb02 -m "Beta release"
#                 ↑ перші символи хешу commit
```

---

## 4. Перегляд тегів

```bash
git tag                    # список усіх тегів
git tag -l "v1.*"          # фільтр за шаблоном
git show v1.0.0            # деталі тегу + commit
git tag -n                 # список з першим рядком повідомлення
```

---

## 5. Публікація тегів (push)

Git **не пушить теги автоматично** разом із комітами!

```bash
git push origin v1.0.0        # один конкретний тег
git push origin --tags         # всі теги одразу
git push origin --follow-tags  # тільки annotated теги (рекомендовано)
```

---

## 6. Видалення тегів

```bash
# Локально
git tag -d v1.0.0

# На remote
git push origin --delete v1.0.0
# або
git push origin :refs/tags/v1.0.0
```

---

## 7. Checkout на тег

```bash
git checkout v1.0.0
```

⚠️ Переводить репозиторій у стан **detached HEAD** — ти не на гілці, а на конкретному commit.

Щоб почати роботу від тегу — створи гілку:
```bash
git checkout -b hotfix/v1.0.1 v1.0.0
```

---

## 8. Семантичне версіонування (SemVer)

Стандартний формат для тегів-релізів:

```
v MAJOR . MINOR . PATCH
     ↑       ↑      ↑
  Breaking  New    Bug
  changes   feat   fix
```

| Версія | Коли змінювати |
|---|---|
| `MAJOR` | Несумісні зміни API |
| `MINOR` | Нова функція, зворотньо сумісна |
| `PATCH` | Виправлення багів |

Приклади: `v1.0.0`, `v2.3.1`, `v0.9.0-beta.1`

---

## 9. Теги і CI/CD

Теги часто тригерять автоматичний деплой. Приклад для GitHub Actions:

```yaml
on:
  push:
    tags:
      - 'v*'       # запускається при будь-якому тегу типу v1.0.0
```

---

## 10. Корисні команди — шпаргалка

```bash
# Створення
git tag v1.0.0                          # lightweight
git tag -a v1.0.0 -m "Release"          # annotated
git tag -a v1.0.0 <hash> -m "Release"   # на конкретний commit

# Перегляд
git tag                   # всі теги
git tag -l "v2.*"         # фільтр
git show v1.0.0           # деталі
git describe --tags       # останній тег + кількість комітів після нього

# Push
git push origin v1.0.0       # один тег
git push origin --follow-tags # всі annotated теги

# Видалення
git tag -d v1.0.0                       # локально
git push origin --delete v1.0.0         # на remote

# Checkout
git checkout v1.0.0                     # detached HEAD
git checkout -b fix/v1.0.1 v1.0.0      # нова гілка від тегу
```

---

## 11. Різниця: тег vs гілка

| | Тег | Гілка |
|---|---|---|
| Рухається при нових комітах? | ❌ Ні | ✅ Так |
| Призначення | Фіксація версії/релізу | Лінія розробки |
| Зберігає метадані | Тільки annotated | Ні |
| Типовий приклад | `v1.2.0` | `main`, `feature/login` |
