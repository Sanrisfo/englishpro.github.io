Testing Guide

Overview

- This project includes unit and widget tests for critical flows: authentication, routing, core models, and UI smoke tests. Mockito is used to isolate external services.

What’s Covered

- Auth state: AuthProvider lifecycle (setUser, logout, updateUser)
- Login flow: LoginScreen with injected mock SupabaseAuthService
- Register flow: RegisterScreen validation and successful navigation
- Splash routing: decides Startup screen based on SharedPreferences
- Models: User, CourseModel, QuestionModel roundtrips and getters

Running Tests

- Opción rápida (Windows PowerShell)
  - scripts/run_tests.ps1
  - Con cobertura: scripts/run_tests.ps1 -Coverage
  - Con docs: scripts/run_tests.ps1 -Docs

- Opción rápida (macOS/Linux)
  - bash scripts/run_tests.sh
  - Con cobertura: bash scripts/run_tests.sh --coverage
  - Con docs: bash scripts/run_tests.sh --docs

- Comandos básicos (desde app/)
  - flutter pub get
  - flutter test
  - Un test específico: flutter test test/login_screen_test.dart

Using Mockito

- Mockito and build_runner are added as dev_dependencies in app/pubspec.yaml
- Current tests define lightweight Mock classes directly via extends Mock without codegen

Coverage (optional)

- From app/: flutter test --coverage
- The file coverage/lcov.info is produced. To view HTML, use genhtml (lcov package) or VS Code coverage extensions

Generating API Docs

- From app/: dart doc (or flutter pub run dartdoc) -> opens doc/api/index.html

CI

- Se incluye .github/workflows/flutter-tests.yml para ejecutar tests y publicar cobertura en cada push/PR.

Notes

- Tests avoid networking by injecting mocks and using SharedPreferences.setMockInitialValues
- If you later refactor services for more DI, you can generate mocks with annotations and build_runner
