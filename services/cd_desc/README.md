## cd_desc

### Описание проекта

`cd_desc` — это микросервис, реализующий логику работы с **категориями** и **темами** (описаниями, постами, сущностями контента) в составе микросервисной системы **CheckDev**.
Он предоставляет REST API для управления категориями и темами, включая операции создания, обновления, получения и удаления.
Проект построен на **Spring Boot**, использует **Spring Data JPA**, **Liquibase** и **Spring Security** для защиты API.


### Основные возможности

* Управление **категориями** (создание, редактирование, удаление, получение списка).
* Управление **темами** (CRUD-операции, получение по категории, получение по идентификатору).
* Работа с DTO (упрощённые и расширенные версии объектов).
* Настраиваемая безопасность через `SecurityConfig`.
* Управление схемой БД через **Liquibase**.
* REST API, совместимый с другими микросервисами CheckDev (например, `auth`, `eureka`).


### Архитектура

```
ru.checkdev.desc/
├── DescSrv.java                  # Главный класс (Spring Boot entry point)
├── config/
│   └── SecurityConfig.java       # Конфигурация безопасности
├── domain/                       # Сущности JPA
│   ├── Category.java
│   └── Topic.java
├── dto/                          # DTO-объекты для REST API
│   ├── CategoryDTO.java
│   ├── CategoryIdNameDTO.java
│   ├── TopicDTO.java
│   └── TopicLiteDTO.java
├── repository/                   # Spring Data репозитории
│   ├── CategoryRepository.java
│   └── TopicRepository.java
├── service/                      # Бизнес-логика
│   ├── CategoryService.java
│   └── TopicService.java
├── utility/
│   └── Utility.java              # Вспомогательные методы
└── web/                          # REST-контроллеры
    ├── CategoriesControl.java
    ├── CategoryControl.java
    ├── TopicControl.java
    └── TopicsControl.java
```


### Технологический стек

| Компонент                       | Назначение                         |
| ------------------------------- | ---------------------------------- |
| **Java 17+**                    | Язык реализации                    |
| **Spring Boot**                 | Основной фреймворк                 |
| **Spring Data JPA (Hibernate)** | ORM и доступ к БД                  |
| **Spring Security**             | Авторизация и защита API           |
| **Liquibase**                   | Миграции базы данных               |
| **PostgreSQL**                  | Основная база данных               |
| **Maven**                       | Система сборки                     |
| **Jenkins**                     | CI/CD пайплайн                     |
| **REST API**                    | Взаимодействие с другими сервисами |


### Конфигурация приложения

Пример файла `src/main/resources/application.properties`:

```properties
spring.application.name=desc
server.port=9011

spring.datasource.url=jdbc:postgresql://localhost:5432/cd_desc
spring.datasource.username=postgres
spring.datasource.password=postgres
spring.jpa.hibernate.ddl-auto=validate
spring.liquibase.change-log=classpath:db/db.changelog-master.xml

eureka.client.service-url.defaultZone=http://localhost:9009/eureka
```


### Работа с базой данных

* **Liquibase** управляет схемой через файл `db.changelog-master.xml`.
* Основные таблицы:

    * `category` — хранит категории.
    * `topic` — хранит темы, принадлежащие категориям.


### REST API (примерные эндпоинты)

| Метод                      | Путь                       | Назначение |
| -------------------------- | -------------------------- | ---------- |
| `GET /categories`          | Получить список категорий  |            |
| `POST /category`           | Создать новую категорию    |            |
| `GET /category/{id}`       | Получить категорию по ID   |            |
| `PUT /category/{id}`       | Обновить категорию         |            |
| `DELETE /category/{id}`    | Удалить категорию          |            |
| `GET /topics`              | Получить список тем        |            |
| `POST /topic`              | Создать тему               |            |
| `GET /topic/{id}`          | Получить тему по ID        |            |
| `GET /topics/{categoryId}` | Получить темы по категории |            |

*(точные пути могут немного отличаться, см. контроллеры в `web/`)*


### Как запустить проект локально

#### 1. Сборка проекта

```bash
mvn clean package
```

#### 2. Запуск

```bash
java -jar target/cd_desc-0.0.1-SNAPSHOT.jar
```

или

```bash
mvn spring-boot:run
```

#### 3. Доступ

Сервис будет доступен по адресу:
[http://localhost:9011](http://localhost:9011)


### Интеграция с Eureka

Чтобы зарегистрировать `cd_desc` в Eureka-сервере (`cd_eureka`):

```properties
eureka.client.register-with-eureka=true
eureka.client.fetch-registry=true
eureka.client.service-url.defaultZone=http://localhost:9009/eureka
```


### Dockerfile (пример)

```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/cd_desc-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 9011
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Сборка:

```bash
docker build -t checkdev-desc .
```

Запуск:

```bash
docker run -p 9011:9011 checkdev-desc
```


### Jenkins (CI/CD)

`Jenkinsfile` содержит стандартный pipeline:

1. **Build** — сборка артефакта через Maven
2. **Test** — запуск юнит-тестов
3. **Deploy** — публикация (например, Docker или сервер)
