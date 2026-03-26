# Git Branch та Git Merge 

## 1. Що таке branch

Branch (гілка) — це окрема лінія розробки в Git.  
Вона дозволяє працювати над новою функцією без зміни основного коду.

За замовчуванням головна гілка:

- main
- або master

Приклад:

main → стабільний код  
feature → нова функція  
bugfix → виправлення помилки  


---

## 2. Перегляд гілок

Показати локальні гілки

```bash
git branch
```

Показати всі гілки (включаючи віддалені)

```bash
git branch -a
```

Поточна гілка позначена `*`


---

## 3. Створення гілки

```bash
git branch feature-login
```

Гілка створиться, але Git не переключиться на неї.


---

## 4. Переключення між гілками

Старий спосіб:

```bash
git checkout feature-login
```

Новий спосіб:

```bash
git switch feature-login
```


---

## 5. Створити гілку і одразу перейти

```bash
git checkout -b feature-api
```

або

```bash
git switch -c feature-api
```


---

## 6. Видалення гілки

Звичайне видалення

```bash
git branch -d feature-api
```

Примусове видалення

```bash
git branch -D feature-api
```


---

## 7. Що таке merge

Merge — це об'єднання двох гілок.

Наприклад:

feature → main


---

## 8. Merge гілки

1. Перейти в main

```bash
git checkout main
```

2. Виконати merge

```bash
git merge feature-login
```

Тепер зміни з feature-login будуть у main.


---

## 9. Fast-forward merge

Якщо main не змінювався, Git просто пересуне pointer.

```
main ----A
           \
feature ----B
```

Після merge

```
main ----A----B
```


---

## 10. Merge commit

Якщо були зміни в обох гілках, Git створює merge commit.

```
      A---B feature
     /
C---D main
```

Після merge

```
      A---B
     /     \
C---D-------M
```

M = merge commit


---

## 11. Merge conflict

Конфлікт виникає якщо змінено один і той самий файл.

Git покаже

```
CONFLICT (content)
```

В файлі буде

```
<<<<<<< HEAD
код main
=======
код feature
>>>>>>> feature
```

Потрібно вручну виправити файл.

Після цього

```bash
git add .
git commit
```


---

## 12. Корисні команди

Статус

```bash
git status
```

Лог з графом

```bash
git log --oneline --graph --all
```

Це дуже важлива команда.


---

## 13. Типовий workflow

```bash
git checkout main
git pull

git checkout -b feature-auth

git add .
git commit -m "add auth"

git checkout main
git merge feature-auth
```


---

## 14. Коли використовують branch

- нова функція
- виправлення багу
- експерименти
- робота в команді
- pull request workflow
- GitHub / GitLab / Bitbucket

Без branch не працюють у реальних проектах.
