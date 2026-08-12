# oil-price-tracker: ручне відтворення в GCP Console (Phase 1+2)

Це та сама архітектура, що вже піднята через Terraform/Ansible, але тепер — крок за
кроком руками в GCP Console, як прямо вимагає завдання ("Do this manually first").
Усі назви, IP і порти нижче — точна копія того, що описано в `infrastructure/terraform/*.tf`,
тож після цього вправи ти зможеш пояснити кожен рядок коду, який вже працює.

---

## Крок 0. Звільнити імена ресурсів

GCP не дозволить створити VM/мережу з іменем, яке вже зайняте Terraform-керованими
ресурсами в цьому ж проєкті. Знеси поточний стек:

```bash
cd infrastructure/terraform
terraform destroy
```

Підтверди `yes`. (Зворотний бік: після ручної вправи, якщо захочеш повернутись на
Terraform, треба або видалити руками створене в Console, або зробити `terraform import`
для кожного ресурсу — Terraform не підхопить чужі об'єкти автоматично.)

---

## Крок 1. VPC-мережа і підмережа

**VPC network → Create VPC network**

- Name: `oil-tracker-vpc`
- Subnet creation mode: **Custom**
- Subnet:
  - Name: `oil-tracker-subnet`
  - Region: `europe-central2`
  - IP address range: `10.10.0.0/24`
- Firewall rules: нічого зі стандартних шаблонів не чіпай, свої створимо окремо в Кроці 3.

---

## Крок 2. Статичні IP

**VPC network → IP addresses → Reserve external static address / Internal**

Внутрішні (тип **Internal**, той самий `oil-tracker-subnet`):

| Name | Address |
|---|---|
| `db-internal-ip` | `10.10.0.10` |
| `history-internal-ip` | `10.10.0.11` |
| `fetcher-internal-ip` | `10.10.0.12` |
| `ui-internal-ip` | `10.10.0.13` |

Зовнішня (тип **External**, тільки для ui — щоб домен потім не зламався):

| Name | Тип |
|---|---|
| `ui-external-ip` | External, Standard, Regional (`europe-central2`) |

---

## Крок 3. Firewall-правила

**VPC network → Firewall → Create firewall rule** — 6 правил, усі на мережі `oil-tracker-vpc`, напрямок Ingress, Action allow:

| Name | Джерело | Target tags | Протокол/порт |
|---|---|---|---|
| `allow-ssh-admin` | Твоя IP `/32` (`curl -s ifconfig.me`) | `db,history,fetcher,ui` | tcp:22 |
| `allow-fetcher-to-history` | Source tags: `fetcher` | `history` | tcp:5672 |
| `allow-history-to-db` | Source tags: `history` | `db` | tcp:5432 |
| `allow-ui-to-history` | Source tags: `ui` | `history` | tcp:8001 |
| `allow-ui-public` | `0.0.0.0/0` | `ui` | tcp:8080 |
| `allow-https-public` | `0.0.0.0/0` | `ui` | tcp:443 |

Для трьох перших "service-to-service" правил обов'язково обери в UI **Source filter: Tags** (не IP ranges) і впиши тег джерела.

---

## Крок 4. Чотири VM

**Compute Engine → VM instances → Create instance** — повторити 4 рази:

| VM | Network tag | Internal IP | External IP |
|---|---|---|---|
| `oil-tracker-db` | `db` | `db-internal-ip` (10.10.0.10) | ефемерна (Standard) |
| `oil-tracker-history` | `history` | `history-internal-ip` | ефемерна |
| `oil-tracker-fetcher` | `fetcher` | `fetcher-internal-ip` | ефемерна |
| `oil-tracker-ui` | `ui` | `ui-internal-ip` | **зарезервована** `ui-external-ip` |

Для кожної:
- Machine type: `e2-small`
- Boot disk: **Ubuntu 24.04 LTS**, 20 GB
- Networking → Network interface: `oil-tracker-vpc` / `oil-tracker-subnet`, Internal IP → **Reserve static internal IP address** → обери відповідну з Кроку 2 (не "Ephemeral")
- External IP: для `ui` — обери зарезервовану `ui-external-ip`; для решти трьох — Standard ефемерна
- Networking → Network tags: впиши тег з таблиці (`db`/`history`/`fetcher`/`ui`)
- Security → Add SSH key вручну (вміст `~/.ssh/id_ed25519.pub`) або скористайся кнопкою SSH у Console (Identity-Aware Proxy) — простіше для одноразової вправи

---

## Крок 5. Docker на кожній VM

Підключись по SSH (кнопка "SSH" в Console навпроти кожної VM) і виконай на **всіх чотирьох**:

```bash
sudo apt remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc || true
sudo apt update && sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

Вийди й зайди по SSH ще раз (щоб `docker` group застосувався), перевір: `docker ps`.

---

## Крок 6. Клонувати репозиторій

На всіх чотирьох:

```bash
git clone https://github.com/ua-academy-projects/push-and-pray.git
cd push-and-pray/infrastructure/docker
```

---

## Крок 7. `.env` на кожній VM

Значення `*_internal_ip` бери з Кроку 2, паролі придумай сам (`openssl rand -base64 24`, як раніше), `OILPRICEAPI_KEY` — реальний ключ з oilpriceapi.com.

**На `oil-tracker-db`:**
```
DB_LAN_IP=10.10.0.10
DB_PASSWORD=<твій пароль>
```

**На `oil-tracker-history`:**
```
DB_LAN_IP=10.10.0.10
HISTORY_LAN_IP=10.10.0.11
DB_PASSWORD=<той самий, що на db>
RABBITMQ_USER=oil_tracker
RABBITMQ_PASSWORD=<твій пароль>
```

**На `oil-tracker-fetcher`:**
```
HISTORY_LAN_IP=10.10.0.11
FETCHER_LAN_IP=10.10.0.12
RABBITMQ_USER=oil_tracker
RABBITMQ_PASSWORD=<той самий, що на history>
OILPRICEAPI_KEY=<реальний ключ>
```

**На `oil-tracker-ui`:**
```
HISTORY_LAN_IP=10.10.0.11
UI_LAN_IP=10.10.0.13
REDIS_PASSWORD=<твій пароль>
```

Створюй файлом `.env` у теці `push-and-pray/infrastructure/docker` (`nano .env`, встав, `Ctrl+O`, `Ctrl+X`).

---

## Крок 8. Підняти сервіси — саме в цьому порядку

**db:**
```bash
docker compose --env-file .env -f compose.database.yaml up -d
docker compose -f compose.database.yaml ps   # чекай "healthy"
```

**history** (після того, як db healthy):
```bash
docker compose --env-file .env -f compose.history.yaml up -d --build
curl http://10.10.0.11:8001/health   # має бути 200
```

**fetcher** (після history):
```bash
docker compose --env-file .env -f compose.fetcher.yaml up -d --build
curl http://10.10.0.12:8002/health
```

**ui** (після fetcher):
```bash
docker compose --env-file .env -f compose.ui.yaml up -d --build
curl http://10.10.0.13:8080/health
```

---

## Крок 9. Перевірка (Phase 2 "Done when")

Із **свого ноутбука** (не з VM):
```bash
curl http://<ui-external-ip>:8080
```
Має віддати той самий HTML дашборду PetroScope, що й раніше.

---

## Що далі (Phase 3-5, вже не обов'язково руками)

PDF вимагає "manually first" явно тільки для Phase 2. Firewall для 8080/443 вже
відкритий у Кроці 3 — Phase 3 фактично закрита. Якщо хочеш довести цю ручну вправу
до кінця:

- **Phase 4 (домен):** онови A-запис у Cloudflare на нову `ui-external-ip` (вона
  щоразу інша, бо резервували заново) — той самий крок, що робив раніше.
- **Phase 5 (HTTPS):** можеш або повторити встановлення Caddy руками (ті самі
  команди, що виконує роль `roles/caddy/tasks/main.yml` — просто прочитай її й
  виконай по кроках через SSH), або, оскільки PDF не вимагає ручного проходу саме
  для цієї фази, просто прогнати вже готову Ansible-роль на цю VM:
  ```bash
  cd infrastructure/ansible
  ansible-playbook site.yml --ask-vault-pass --limit ui --tags caddy
  ```
  (якщо схочеш, можу додати теги в роль — зараз їх там нема, простіше тимчасово
  запустити плейбук цілком на `--limit ui`, він просто повторно виконає й ui_service,
  й caddy — обидва ідемпотентні).

## Повернення на Terraform

Коли награєшся руками — знеси все, що створив у Console (VM → мережу → адреси →
firewall, у зворотному порядку), і піднімай назад один командою:
```bash
cd infrastructure/terraform && terraform apply
cd ../ansible && ansible-playbook site.yml --ask-vault-pass
```
