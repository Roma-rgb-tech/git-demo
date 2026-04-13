# Git Workflow: Конспект

## Зміст
1. [Gitflow](#gitflow)
2. [Trunk-based Development](#trunk-based-development)
3. [Conventional Commits](#conventional-commits)
4. [Pull Requests & Code Review](#pull-requests--code-review)

---

## Gitflow

**Gitflow** — це структурована модель розгалуження, що використовує дві основні гілки (main, develop) та допоміжні (feature, release, hotfix) для організації процесу розробки. Вона забезпечує незалежну розробку фіч, стабільний реліз-цикл та чітке управління версіями. 

### Структура гілок

| Гілка | Роль |
|---|---|
| `main` | Продакшн-код. Завжди стабільний. Тільки злиття з `release` або `hotfix`. |
| `develop` | Основна гілка розробки. Інтеграція всіх фіч. |
| `feature/*` | Нова функціональність. Відгалужується від `develop`, зливається назад у `develop`. |
| `release/*` | Підготовка до релізу. Відгалужується від `develop`, зливається в `main` і `develop`. |
| `hotfix/*` | Термінові виправлення в продакшні. Відгалужується від `main`, зливається в `main` і `develop`. |

### Типовий цикл

```
develop → feature/my-feature → develop → release/1.0.0 → main (tag v1.0.0)
                                                        ↘ develop
```

```bash
# Створити feature-гілку
git checkout develop
git checkout -b feature/user-auth

# Завершити роботу над фічею
git checkout develop
git merge --no-ff feature/user-auth
git branch -d feature/user-auth

# Підготовка релізу
git checkout -b release/1.2.0
# ... тести, фіксація версій, bugfixes ...
git checkout main
git merge --no-ff release/1.2.0
git tag -a v1.2.0 -m "Release 1.2.0"
git checkout develop
git merge --no-ff release/1.2.0
```

### Переваги та недоліки

✅ Чітка структура для великих команд  
✅ Паралельна підтримка кількох версій  
❌ Складний для маленьких команд  
❌ Повільний цикл релізів  
❌ Конфлікти при довгоживучих гілках  

---

## Trunk-based Development

**Trunk-based Development (TBD)** — підхід, при якому всі розробники часто інтегрують код в одну спільну гілку (`main` або `trunk`), як правило, не рідше одного разу на день.

### Ключові відмінності від Gitflow

| Параметр | Gitflow | Trunk-based |
|---|---|---|
| Основна гілка | `develop` | `main` / `trunk` |
| Тривалість feature-гілок | Дні / тижні | Години / 1–2 дні |
| Частота злиття | Рідко | Кілька разів на день |
| Кількість активних гілок | Багато | Мінімум |
| Релізи | Через `release`-гілки | Feature flags або теги |

### Практики TBD

```bash
# Короткоживуча feature-гілка
git checkout -b feat/add-button
# ... кілька годин роботи ...
git push origin feat/add-button
# → Pull Request → Merge в main того ж дня
```

**Feature Flags** — техніка, коли незавершений код вже в `main`, але вимкнений за допомогою прапора:

```javascript
if (featureFlags.newCheckout) {
  renderNewCheckout();
} else {
  renderOldCheckout();
}
```

### Чому TBD популярний у CI/CD

- **Менше merge-конфліктів** — інтеграція відбувається часто, поки гілки не встигають розійтися
- **Швидший feedback** — CI запускається на кожен коміт у `main`
- **Постійна готовність до деплою** — `main` завжди в робочому стані
- **Спрощений pipeline** — немає складної логіки злиття між кількома довгоживучими гілками


---
 
## GitHub Flow
 
**GitHub Flow** — спрощена модель розгалуження від GitHub. На відміну від Gitflow, тут лише одна довгоживуча гілка — `main`. Вся робота відбувається у короткоживучих гілках, які одразу зливаються в `main` через Pull Request.
 
### Принцип роботи
 
```
main
 ├── feature/login      → PR → merge → deploy
 ├── fix/header-bug     → PR → merge → deploy
 └── docs/update-readme → PR → merge → deploy
```
 
> `main` завжди deployable — кожен merge одразу йде в продакшн (або запускає деплой).
 
### Цикл розробки (6 кроків)
 
```
1. Створи гілку від main
       ↓
2. Роби коміти
       ↓
3. Відкрий Pull Request (навіть якщо не готово — для обговорення)
       ↓
4. Обговорення та Code Review
       ↓
5. Merge в main
       ↓
6. Деплой
```
 
```bash
# 1. Створити гілку
git checkout main
git pull origin main
git checkout -b feature/dark-mode
 
# 2. Розробка + коміти
git add .
git commit -m "feat(ui): add dark mode toggle"
 
# 3. Запушити та відкрити PR
git push origin feature/dark-mode
# → відкрити Pull Request на GitHub
 
# 4. Після approve — merge в main (зазвичай Squash merge)
# 5. GitHub Actions автоматично деплоїть main
```
 
### Порівняння з Gitflow та TBD
 
| Параметр | Gitflow | GitHub Flow | Trunk-based |
|---|---|---|---|
| Довгоживучих гілок | Багато (`main`, `develop`) | Одна (`main`) | Одна (`main`) |
| Тривалість feature-гілок | Дні / тижні | 1–3 дні | Години |
| Релізи | Через `release`-гілки | Кожен merge = реліз | Кожен merge = реліз |
| Версіонування | Теги на `main` | Теги або CD | Feature flags + теги |
| Підходить для | Великих команд, SaaS з версіями | Більшості команд | Зрілих команд з CI |
 
### Переваги та недоліки
 
✅ Простий і зрозумілий — легко пояснити новачку  
✅ Добре інтегрується з GitHub Actions / CI  
✅ Швидкий цикл — від ідеї до продакшну за день  
✅ Немає "release branch hell" як у Gitflow  
❌ Не підходить, якщо треба підтримувати кілька версій одночасно  
❌ Вимагає дисципліни: `main` завжди має бути робочим  
❌ Без feature flags важко мерджити незавершені великі фічі  
 
### Коли обирати GitHub Flow
 
- Веб-застосунки з безперервним деплоєм (SaaS, стартапи)
- Команди до ~20 розробників
- Один активний реліз у продакшні
- Є налаштований CI/CD pipeline

 
---

## Conventional Commits

**Conventional Commits** — специфікація для стандартизованих повідомлень комітів. Дозволяє автоматично генерувати CHANGELOG і визначати версії (semver).

### Формат

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

### Типи комітів

| Тип | Коли використовувати | Semver |
|---|---|---|
| `feat` | Нова функціональність | MINOR |
| `fix` | Виправлення бага | PATCH |
| `docs` | Зміни тільки в документації | — |
| `style` | Форматування, пробіли (не логіка) | — |
| `refactor` | Рефакторинг без нових фіч і фіксів | — |
| `test` | Додавання або виправлення тестів | — |
| `chore` | Оновлення залежностей, білд-система | — |
| `perf` | Покращення продуктивності | PATCH |
| `ci` | Зміни в CI/CD конфігурації | — |
| `revert` | Відкат попереднього коміту | — |

### Приклади

```bash
# Нова фіча
git commit -m "feat(auth): add OAuth2 login with Google"

# Виправлення бага з вказанням scope
git commit -m "fix(cart): prevent duplicate items on rapid click"

# Документація
git commit -m "docs(readme): update installation instructions"

# Задачі по супроводу
git commit -m "chore(deps): upgrade react from 18.2 to 18.3"

# Breaking change (підвищує MAJOR версію)
git commit -m "feat(api)!: remove deprecated /v1/users endpoint

BREAKING CHANGE: /v1/users is removed, use /v2/users instead"
```

### Інструменти

- **[commitlint](https://commitlint.js.org/)** — валідація повідомлень комітів
- **[commitizen](https://commitizen-tools.github.io/commitizen/)** — інтерактивний CLI для написання комітів
- **[standard-version](https://github.com/conventional-changelog/standard-version)** / **[release-please](https://github.com/googleapis/release-please)** — автоматичний CHANGELOG і версіювання

```bash
# Встановити commitlint
npm install --save-dev @commitlint/cli @commitlint/config-conventional

# commitlint.config.js
module.exports = { extends: ['@commitlint/config-conventional'] };

# Додати в package.json (з husky)
# "commit-msg": "commitlint --edit $1"
```

---

## Pull Requests & Code Review

**Pull Request (PR)** / **Merge Request (MR)** — механізм пропозиції змін до основної кодової бази з обов'язковим переглядом командою.

### Типовий процес

```
1. Розробник створює гілку
       ↓
2. Пише код, робить коміти (Conventional Commits)
       ↓
3. Відкриває Pull Request
       ↓
4. CI/CD запускає автоматичні перевірки (тести, лінтер, білд)
       ↓
5. Code Review (1–2 ревʼювери)
       ↓
6. Автор відповідає на коментарі / вносить зміни
       ↓
7. Approve → Merge (squash / rebase / merge commit)
       ↓
8. Гілку видаляють
```

### Хороший PR — це

- **Маленький** — ідеально до 400 рядків змін
- **Один фокус** — одна фіча або один фікс
- **Зрозумілий опис** — що змінено, чому, як перевірити
- **Linked issue** — посилання на задачу в трекері

### Шаблон опису PR

```markdown
## Що зроблено
Коротко описати суть змін.

## Чому
Посилання на issue або опис проблеми.
Closes #123

## Як перевірити
1. Відкрити сторінку /checkout
2. Додати товар у кошик
3. Переконатися, що дублікати не зʼявляються

## Скріншоти / відео (якщо є UI-зміни)

## Чеклист
- [ ] Тести написані / оновлені
- [ ] Документація оновлена
- [ ] Немає console.log
```

### Code Review: поради ревʼюеру

```
✅ Перевіряй логіку, а не стиль (для стилю є лінтер)
✅ Давай конкретні пропозиції, не просто "погано"
✅ Відрізняй: "треба виправити" vs "можна покращити (nit:)"
✅ Хваль хороші рішення
✅ Review протягом 24 годин — не блокуй команду
```

**Приклад конструктивного коментаря:**
```
# ❌ Погано
"Це неправильно"

# ✅ Добре
"nit: тут можна використати Array.find() замість filter()[0],
це явніше передає намір знайти один елемент.
Але якщо хочеш — залиш як є, не критично."
```

### Стратегії злиття

| Стратегія | Коли використовувати |
|---|---|
| **Merge commit** | Зберегти повну історію гілки |
| **Squash and merge** | Зжати всі коміти PR в один (чистіша `main`) |
| **Rebase and merge** | Лінійна історія без merge-комітів |

> 💡 **Популярний вибір:** Squash merge у TBD — кожен PR стає одним семантичним комітом в `main`.

---

## Корисні посилання

- [Conventional Commits Spec](https://www.conventionalcommits.org/)
- [Gitflow by Vincent Driessen](https://nvie.com/posts/a-successful-git-branching-model/)
- [Trunk Based Development](https://trunkbaseddevelopment.com/)
- [Google Engineering Practices: Code Review](https://google.github.io/eng-practices/review/)
