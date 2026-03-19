# CheckDev Monorepo

**CheckDev** — платформа для подготовки к техническим собеседованиям. Монорепозиторий объединяет все микросервисы проекта в единую кодовую базу.

---

## Архитектура

Система построена на микросервисной архитектуре с использованием **Spring Boot 2.7** и **Spring Cloud**. Сервисы взаимодействуют друг с другом через **Eureka Service Discovery**, асинхронное взаимодействие — через **Apache Kafka**.

Каждый сервис, работающий с данными, использует **собственную базу данных** (Database per Service pattern).

```
                          ┌──────────────┐
                          │   cd_site    │
                          │  (Gateway)   │
                          └──────┬───────┘
                                 │
                          ┌──────┴───────┐
                          │  cd_eureka   │
                          │  (Discovery) │
                          └──────┬───────┘
                                 │
              ┌──────────┬───────┼────────┬──────────────┐
              │          │       │        │              │
        ┌─────┴──┐ ┌─────┴──┐ ┌─┴──────┐ ┌┴───────────┐ ┌┴─────────┐
        │cd_auth │ │cd_desc │ │cd_mock │ │cd_generator│ │cd_notif. │
        │  [DB]  │ │  [DB]  │ │  [DB]  │ │    [DB]    │ │   [DB]   │
        └────────┘ └────────┘ └────────┘ └────────────┘ └──────────┘
              │          │       │        │              │
              └──────────┴───────┼────────┴──────────────┘
                                 │
                          ┌──────┴───────┐
                          │ Apache Kafka │
                          └──────────────┘
```

## Сервисы

| Сервис | Описание | Порт | База данных |
|---|---|---|---|
| **cd_eureka** | Service Discovery — реестр микросервисов | `8761` | — |
| **cd_auth** | Аутентификация и авторизация (OAuth2, JWT) | `9900` | `cd_auth` |
| **cd_desc** | Управление контентом — вопросы, темы, категории | `9902` | `cd_desc` |
| **cd_generator** | Генерация контента и тестовых данных | — | `cd_generator` |
| **cd_mock** | Mock-сервис для интервью | — | `cd_mock` |
| **cd_notification** | Уведомления (email, Telegram) | — | `cd_notification` |
| **cd_site** | Web-интерфейс и API Gateway | `9100` | — |

## Технологический стек

- **Java 21**
- **Spring Boot 2.7** / **Spring Cloud 2021.0.x**
- **Spring Security + OAuth2**
- **Spring Data JPA + Hibernate**
- **PostgreSQL 16** — отдельная БД для каждого сервиса
- **Apache Kafka** — асинхронное взаимодействие между сервисами
- **Liquibase** — миграции БД
- **Netflix Eureka** — Service Discovery
- **Lombok**
- **Docker** / **Docker Compose**
- **Jenkins** — CI/CD
- **Maven** — multi-module сборка
- **JaCoCo** — покрытие тестами
- **Checkstyle** — контроль качества кода

## Структура проекта

```
checkdev-mono/
├── compose.yml              # Docker Compose — инфраструктура + сервисы
├── init-db.sh               # Скрипт инициализации БД для каждого сервиса
├── .env                     # Переменные окружения (не в Git)
├── pom.xml                  # Корневой агрегатор Maven
├── README.md
└── services/
    ├── cd_eureka/           # Service Discovery
    │   ├── Dockerfile
    │   ├── pom.xml
    │   └── src/
    ├── cd_auth/             # Аутентификация
    │   ├── Dockerfile
    │   ├── pom.xml
    │   └── src/
    ├── cd_desc/             # Контент
    │   ├── Dockerfile
    │   ├── pom.xml
    │   └── src/
    ├── cd_generator/        # Генератор
    │   ├── Dockerfile
    │   ├── pom.xml
    │   └── src/
    ├── cd_mock/             # Mock-сервис
    │   ├── Dockerfile
    │   ├── pom.xml
    │   └── src/
    ├── cd_notification/     # Уведомления
    │   ├── Dockerfile
    │   ├── pom.xml
    │   └── src/
    └── cd_site/             # Web / Gateway
        ├── Dockerfile
        ├── pom.xml
        └── src/
```

## Быстрый старт

### Требования

- Docker и Docker Compose
- Java 21 (для локальной разработки)
- Maven 3.9+

### Запуск через Docker Compose

```bash
# 1. Создай файл .env в корне
cp .env.example .env

# 2. Подними всю систему
docker compose up --build
```

При первом запуске PostgreSQL автоматически создаёт отдельные базы для каждого сервиса через `init-db.sh`:
- `cd_auth`
- `cd_desc`
- `cd_mock`
- `cd_notification`
- `cd_generator`

### Дашборды и UI

| Компонент | URL |
|---|---|
| Eureka Dashboard | [http://localhost:8761](http://localhost:8761) |
| Site | [http://localhost:9100](http://localhost:9100) |
| Auth API | [http://localhost:9900](http://localhost:9900) |
| Kafka UI | [http://localhost:8088](http://localhost:8088) |
| Jenkins | [http://localhost:8090](http://localhost:8090) |

### Локальная разработка

```bash
# Сборка всех модулей
mvn clean package

# Сборка конкретного сервиса
mvn clean package -pl services/cd_auth

# Запуск тестов
mvn test

# Запуск тестов для одного сервиса
mvn test -pl services/cd_auth
```

### Работа в IntelliJ IDEA

1. **File → Open** → выбрать корневой `pom.xml` → **Open as Project**
2. IDEA автоматически распознает все модули
3. Каждый сервис запускается через свой `*Application.java`

## Инфраструктура

### База данных

Используется единый экземпляр **PostgreSQL 16**, в котором для каждого сервиса создаётся отдельная база данных (Database per Service). Инициализация баз выполняется скриптом `init-db.sh` при первом запуске контейнера.

```
PostgreSQL
├── cd_auth          — пользователи, роли, OAuth-клиенты
├── cd_desc          — вопросы, темы, категории
├── cd_mock          — данные mock-интервью
├── cd_notification  — история уведомлений, шаблоны
└── cd_generator     — конфигурации генератора
```

Миграции в каждом сервисе управляются через **Liquibase** и применяются автоматически при старте.

### Apache Kafka

Kafka используется для асинхронного взаимодействия между сервисами (уведомления, события генерации и т.д.).

- Контейнеры подключаются через `broker:9092`
- С хоста (для отладки) — `localhost:9094`
- Мониторинг через **Kafka UI** на порту `8088`

### Jenkins

CI/CD пайплайн доступен на порту `8090`. Конфигурация хранится в Docker volume `jenkins_home`.

## Переменные окружения

| Переменная | Описание | Значение по умолчанию |
|---|---|---|
| `POSTGRES_DB` | Основная база (для инициализации) | `cd_auth` |
| `POSTGRES_USER` | Пользователь PostgreSQL | `postgres` |
| `POSTGRES_PASSWORD` | Пароль PostgreSQL | — |
| `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE` | URL Eureka Server | `http://eureka:8761/eureka` |
| `SPRING_KAFKA_BOOTSTRAP_SERVERS` | Kafka bootstrap | `broker:9092` |

# Запуск CheckDev в Kubernetes (minikube)

## Требования

- [Docker](https://www.docker.com/products/docker-desktop/) 27+
- [minikube](https://minikube.sigs.k8s.io/docs/start/) 1.35+
- [kubectl](https://kubernetes.io/docs/tasks/tools/) 1.32+
- `make` (встроен в Linux/macOS, для Windows: `choco install make`)
- Минимум 4GB свободной RAM и 4 CPU ядра

## Быстрый старт

```bash
# 1. Запустить minikube
minikube start --cpus=4 --memory=4096

# 2. Скопировать .env.example и заполнить значения
cp .env.example .env
nano .env        # заполнить реальные токены и пароли

# 3. Собрать и задеплоить
make deploy

# 4. Дождаться запуска
make status

# 5. Открыть приложение
make open        # http://localhost:8080
```

## Конфигурация (.env)

Все секреты передаются через файл `.env`. При `make deploy` скрипт `generate-secrets.sh` автоматически генерирует `k8s/01-secrets.yaml` из `.env`.

```bash
cp .env.example .env
```

Заполните значения в `.env`:

| Переменная | Описание | Обязательная |
|-----------|---------|:---:|
| `POSTGRES_USER` | Пользователь PostgreSQL | да |
| `POSTGRES_PASSWORD` | Пароль PostgreSQL | да |
| `OAUTH2_CLIENT_ID` | OAuth2 client ID | да |
| `OAUTH2_CLIENT_SECRET` | OAuth2 client secret | да |
| `ACCESS_KEY` | Ключ доступа (notification) | да |
| `HH_TOKEN` | Токен HeadHunter API | да |
| `BOT_USERNAME` | Telegram bot username | нет |
| `BOT_TOKEN` | Telegram bot token | нет |

> `.env` и `k8s/01-secrets.yaml` добавлены в `.gitignore` — они никогда не попадут в Git.

## Makefile команды

| Команда | Описание |
|---------|----------|
| `make deploy` | Сгенерировать секреты + собрать образы + задеплоить |
| `make build` | Только собрать Docker-образы |
| `make secrets` | Только сгенерировать `k8s/01-secrets.yaml` из `.env` |
| `make status` | Показать статус Pod'ов |
| `make logs s=cd-auth` | Логи конкретного сервиса |
| `make open` | Открыть приложение (http://localhost:8080) |
| `make restart` | Перезапустить Pod'ы без пересборки |
| `make down` | Удалить всё |

## Проверка

```bash
# Все Pod'ы должны быть Running
make status

# Логи конкретного сервиса
make logs s=cd-site

# Eureka Dashboard
kubectl port-forward service/cd-eureka-svc 9009:9009 -n checkdev
# http://localhost:9009

# PostgreSQL
kubectl port-forward service/cd-postgres-svc 5432:5432 -n checkdev
psql -h localhost -p 5432 -U postgres -d cd_auth
```

## Структура k8s/

```
k8s/
├── 00-namespace.yaml           # Namespace checkdev
├── 01-secrets.yaml             # ← генерируется из .env (в .gitignore)
├── 01-secrets.example.yaml     # ← шаблон (в Git)
├── 02-configmap.yaml           # Конфигурация + init-скрипт БД
├── 10-postgres.yaml            # PostgreSQL
├── 11-kafka.yaml               # Kafka (KRaft)
├── 20-eureka.yaml              # Eureka Server
├── 30-auth.yaml                # Auth Service
├── 31-desc.yaml                # Description Service
├── 32-generator.yaml           # Generator Service
├── 33-mock.yaml                # Mock Service
├── 40-site.yaml                # Site (UI)
└── 41-notification.yaml        # Notification Service
```

## Остановка

```bash
make down          # удалить все ресурсы
minikube stop      # остановить minikube
```

# Git Flow

Работа ведётся в монорепозитории. Все сервисы версионируются вместе.

```bash
# Создание feature-ветки
git checkout -b feature/CD-123-add-notification-templates

# Коммит с указанием сервиса
git commit -m "[cd_notification] Add email templates for interview reminders"

# Push
git push origin feature/CD-123-add-notification-templates
```

### Соглашение о коммитах

Формат: `[сервис] Описание изменения`

```
[cd_auth] Fix OAuth2 token refresh logic
[cd_desc] Add pagination to topics endpoint
[cd_site] Update landing page layout
[cd_notification] Add Kafka consumer for interview events
[infra] Update Docker Compose configuration
```

## API документация

Сервисы с подключённым **SpringDoc** предоставляют Swagger UI:

- cd_auth: [http://localhost:9900/swagger-ui.html](http://localhost:9900/swagger-ui.html)
- cd_desc: [http://localhost:9902/swagger-ui.html](http://localhost:9902/swagger-ui.html)

---

> Проект создан в рамках обучения и практики построения микросервисных систем на Java / Spring Boot.