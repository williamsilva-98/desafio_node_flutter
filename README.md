# Desafio - API e App de Usuários

Projeto completo: **API REST** em Node.js (backend) e **app** em Flutter que consomem a API para cadastro e listagem de usuários.

---

## Visão geral

- **Backend:** API em Express + Sequelize + MySQL (cadastro e listagem com filtros).
- **App:** Flutter com arquitetura MVVM (Bloc, GetIt, Dio), tela de listagem com filtros e tela de cadastro.

---

## Como rodar o projeto

### 1. Rodar a API (backend)

A API precisa estar no ar para o app funcionar.

#### Opção A: Com Docker (recomendado)

Na pasta `backend`:

```bash
cd backend
docker compose up --build
```

Quando aparecer no log **`🚀 Server running on port 3000`**, a API está em http://localhost:3000.

Para parar:

```bash
docker compose down
```

- **API:** http://localhost:3000  
- **MySQL:** localhost:3306 (usuário `root`, senha `secret`, banco `desafio_db`)

Não é necessário ter Node.js nem MySQL instalados.

#### Opção B: Sem Docker

Requisitos: **Node.js** 18+, **MySQL** 8 rodando, **npm**.

1. Crie o arquivo `.env` na pasta `backend` (copie de `.env.example` e ajuste):

```env
NODE_ENV=development
PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_NAME=desafio_db
DB_USER=root
DB_PASSWORD=secret
```

2. Crie o banco `desafio_db` no MySQL (se ainda não existir).

3. Instale dependências e inicie:

```bash
cd backend
npm install
npm run dev
```

A API estará em http://localhost:3000.

---

### 2. Rodar o app Flutter

Requisitos: **Flutter** 3.10+ (SDK ^3.10.7). A API deve estar rodando em http://localhost:3000.

Na pasta **`app`**:

```bash
cd app
flutter pub get
flutter run
```

Escolha o dispositivo (Chrome, iOS Simulator, Android Emulator ou dispositivo físico).

**iOS Simulator:** no Mac, abra o simulador com `open -a Simulator` (ou via Xcode) e depois rode `flutter run`; quando perguntar o dispositivo, escolha o iPhone listado. Ou rode direto em um dispositivo específico: `flutter run -d "iPhone 16"` (o nome pode variar conforme as versões instaladas). No simulador iOS, `localhost` do Mac já aponta para a API rodando na máquina — não é preciso alterar a URL.

**Android Emulator:** a API em `localhost` do PC é acessada como `http://10.0.2.2:3000`. Se necessário, altere a URL em `app/lib/core/constants/api_constants.dart` (variável `baseUrl`).

---

## Testes

### Backend

Na pasta `backend`:

```bash
npm test
```

Cobre as regras de negócio no serviço de usuários (validações, e-mail duplicado, criação e listagem com filtros).

### App Flutter

Na pasta `app`:

```bash
flutter test
```

Inclui testes unitários (modelo, service, repository, Cubits) e testes de widget (listagem, formulário, tela inicial).

---

## Endpoints da API

| Método | Rota   | Descrição |
|--------|--------|-----------|
| POST   | /users | Cria um usuário (body: `{ "name": "...", "email": "..." }`) |
| GET    | /users | Lista usuários. Query opcional: `?name=...` e/ou `?email=...` (busca parcial) |

**Exemplos:**

```bash
# Criar usuário
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"name":"João Silva","email":"joao@email.com"}'

# Listar todos
curl http://localhost:3000/users

# Listar filtrando
curl "http://localhost:3000/users?name=João"
curl "http://localhost:3000/users?email=joao"
```

---

## Estrutura do backend

```
backend/src/
  app.js                    # Express, rotas e middleware de erro
  server.js                 # Inicialização (conexão DB, listen)
  infra/database/
    sequelize.js             # Conexão Sequelize (MySQL)
  shared/
    errors/app_error.js      # Classe AppError (erros operacionais)
    middlewares/error_handler.js
  modules/user/
    user_model.js           # Modelo Sequelize (User)
    user_repository.js      # Acesso a dados (create, findAll)
    user_service.js         # Regras de negócio e validações
    user_controller.js       # Handlers HTTP (create, getAll)
    user_routes.js           # Rotas POST/GET /users
    tests/user_service.test.js
```

---

## Decisões técnicas do backend

- **Sequelize + MySQL:** persistência relacional; `sync()` na subida cria apenas tabelas que não existem, sem apagar dados.
- **Arquitetura em camadas:** controller → service → repository, com regras de negócio e validações no service.
- **E-mail:** duplicidade verificada antes do insert; retorno 409 quando o e-mail já existe.
- **Erros:** 400 para validação (nome/email obrigatório), 409 para e-mail duplicado, via `AppError` e middleware `error_handler`.
- **Filtros:** query params `name` e `email` com busca parcial (LIKE).

---

## Estrutura do app Flutter

```
app/lib/
  main.dart                 # Entry point e configuração do GetIt
  app.dart                  # MaterialApp e tema
  core/
    constants/              # URL e timeouts da API (api_constants.dart)
    di/injection.dart       # Injeção de dependências (GetIt)
    errors/                 # ApiException
    theme/                  # AppTheme (tema claro)
  data/
    models/user.dart        # Modelo de domínio User
    services/user_api_service.dart   # Chamadas HTTP (Dio)
    repositories/user_repository.dart
  features/users/
    view_models/            # UserListCubit, UserFormCubit (ViewModel)
    views/                  # UserListView, UserFormView
```

---

## Decisões técnicas do app Flutter

O app segue o [guia de arquitetura do Flutter](https://docs.flutter.dev/app-architecture/guide), com **MVVM** e separação entre **camada de UI** e **camada de dados**.

### Camada de dados (Model)

- **Services**  
  O `UserApiService` é a camada mais baixa: faz as requisições HTTP com **Dio** (GET/POST em `/users`), trata `DioException` e converte o body de erro da API em `ApiException`. Não guarda estado; só expõe `Future` com os dados ou exceção.

- **Repositories**  
  O `UserRepository` é a **fonte de verdade** dos dados de usuários. Usa o `UserApiService` e expõe métodos como `getUsers` e `createUser`, retornando modelos de domínio (`User`). Aqui ficariam cache, retry e a decisão de onde buscar dados (só API ou também local). A UI não fala com o service diretamente.

- **Models**  
  O `User` é o modelo de domínio (id, name, email, etc.), com `fromJson`/`toJson` alinhados à API. **Equatable** é usado para comparação em estados do Bloc.

### Camada de UI (View + ViewModel)

- **ViewModels (Cubits)**  
  `UserListCubit` e `UserFormCubit` funcionam como **ViewModels**: concentram a lógica da tela, consomem o repositório e expõem **estado** e **comandos**.
  - **UserListCubit:** comando `loadUsers(nameFilter, emailFilter)`; estados `initial`, `loading`, `loaded(users)`, `failure`.
  - **UserFormCubit:** comando `submit(name, email)` (valida e chama `createUser`); estados `initial`, `submitting`, `success`, `validationError`, `apiError`.
  Assim, a lógica fica testável sem widgets e sobrevive a mudanças de configuração (rotação, etc.).

- **Views**  
  As **Views** (`UserListView`, `UserFormView`) só desenham a tela e reagem ao estado do Cubit (`BlocBuilder`/`BlocListener`). Elas disparam os comandos (ex.: ao tocar em “Buscar” ou “Cadastrar”) e mostram loading, lista, erro ou formulário conforme o estado. Não contêm regra de negócio nem chamadas diretas à API.

### Injeção de dependências (GetIt)

- O **GetIt** centraliza a criação de **Dio**, **UserApiService**, **UserRepository** e dos **Cubits**.
- Services e repositórios são **singleton**; Cubits são **factory** (nova instância por tela), para não compartilhar estado entre listagem e formulário.
- Nos testes, usa-se `getIt.reset()` e registram-se mocks (ex.: `UserRepository`) para não chamar a API real.

### Fluxo de dados

1. **Listagem:** View chama `loadUsers()` no Cubit → Cubit chama `UserRepository.getUsers()` → Repository chama `UserApiService.getUsers()` → Dio faz GET → resposta vira `List<User>` e sobe até o estado do Cubit → View re-renderiza com a lista.
2. **Cadastro:** View chama `submit(name, email)` no Cubit → Cubit valida, chama `UserRepository.createUser()` → Service faz POST → sucesso ou `ApiException` voltam ao Cubit → View mostra SnackBar e fecha ou exibe erro.

Cada camada tem uma responsabilidade clara (separação de responsabilidades), o que facilita testes, manutenção e evolução do app.
