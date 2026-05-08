# VentureIQ

AI-powered startup idea validation platform that provides instant, comprehensive feasibility analysis through a panel of specialized AI agents.

## Tech Stack

### Backend
- **Runtime:** Python 3.13
- **Framework:** FastAPI with async support
- **AI/ML:** LangGraph for multi-agent orchestration, Google Gemini & OpenRouter LLMs
- **Database:** PostgreSQL 17 (primary), Redis 7 (caching/rate-limiting), ChromaDB (vector store)
- **Auth:** Firebase Authentication with JWT token exchange
- **Package Manager:** uv

### Mobile
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Routing:** GoRouter
- **HTTP Client:** Dio

### Infrastructure
- **Containerization:** Docker & Docker Compose
- **Database Migrations:** Alembic

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.41.4+ (stable channel)
- [Python](https://www.python.org/downloads/) 3.13+
- [uv](https://docs.astral.sh/uv/) (Python package manager)
- [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/install/)
- Android Studio / Xcode (for mobile emulators)

## Project Structure

```
ventureiq/
├── mobile/                  # Flutter app
│   ├── lib/
│   │   ├── core/            # Theme, networking, constants, DI
│   │   ├── features/        # Feature-first modules
│   │   └── main.dart
│   ├── test/
│   └── pubspec.yaml
├── backend/                 # Python FastAPI + LangGraph
│   ├── app/
│   │   ├── api/v1/          # REST endpoints + WebSocket handlers
│   │   ├── agents/          # LangGraph agent definitions
│   │   ├── core/            # Config, security, logging
│   │   ├── db/              # Database connection, base models
│   │   ├── models/          # SQLAlchemy models
│   │   ├── schemas/         # Pydantic schemas
│   │   ├── services/        # Business logic layer
│   │   └── main.py
│   ├── tests/
│   ├── migrations/          # Alembic
│   ├── pyproject.toml
│   └── Dockerfile
├── docker-compose.yml       # Dev environment (Redis, PostgreSQL, ChromaDB)
├── .env.example
└── README.md
```

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd ventureiq
```

### 2. Environment Configuration

```bash
cp .env.example .env
# Edit .env with your API keys and configuration
```

### 3. Start Infrastructure Services

```bash
docker compose up -d redis postgres chromadb
```

### 4. Backend Setup

```bash
cd backend
uv sync
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`.

Verify the backend is running:
```bash
curl http://localhost:8000/api/v1/health
```

### 5. Mobile App Setup

```bash
cd mobile
flutter pub get
flutter run
```

## Development Workflow

### Backend Development

```bash
cd backend

# Run the development server with hot reload
uvicorn app.main:app --reload

# Run linting
ruff check app/

# Run formatting
ruff format app/

# Run tests
pytest
```

### Mobile Development

```bash
cd mobile

# Run the app
flutter run

# Run analyzer
flutter analyze

# Run tests
flutter test
```

### Docker Services

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f

# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v
```

## API Documentation

When the backend is running, interactive API docs are available at:
- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc

## License

Proprietary — All rights reserved.
