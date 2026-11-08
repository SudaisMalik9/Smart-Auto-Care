

# Contributing to Smart Auto Care

Thank you for contributing to Smart Auto Care!

## Team Rules

1. Do not push directly to the `main` branch.
2. Create a separate branch for every feature or bug fix.
3. Keep commits small and use clear commit messages.
4. Test your changes before submitting them.
5. Submit a Pull Request (PR) for merging changes.
6. Resolve review feedback and wait for the project lead to approve and merge.

## Branch Naming

Use these formats:

- `feature/feature-name`
- `bugfix/bug-name`
- `docs/documentation-name`

## Development Workflow

1. Pull the latest changes.
2. Create a new branch.
3. Make your changes.
4. Run tests and code analysis.
5. Commit and push your branch.
6. Open a Pull Request.
7. The project lead checks the CI results, reviews the code, approves, and merges.

## Automated Checks

GitHub Actions runs on Pull Requests targeting `main` and on pushes to `main`.
The project lead can also start a run manually from the Actions tab after the
workflow is merged into `main`.

- Repository files and folders are checked on every run.
- When `mobile_app/pubspec.yaml` exists, CI installs Flutter dependencies,
  checks formatting with `dart format --output=none --set-exit-if-changed .`,
  and runs `flutter analyze` from `mobile_app/`.
- Flutter tests run with `flutter test` when `mobile_app/test/` contains
  `*_test.dart` files. Add tests with the application code.
- Python 3.12 is configured when backend Python files or `requirements.txt`
  exist. CI installs `backend/requirements.txt` when present and checks Python
  syntax with `python -m compileall -q .` from `backend/`.
- Backend files named `test_*.py` or `*_test.py` enable `python -m pytest`.
  Add test dependencies to `backend/requirements.txt`. Configure Django test
  settings and PostgreSQL services when the backend is integrated; CI does
  not provision a database yet. Separate Python code in `web/` needs its own
  checks when that project is added.

The Actions run summary shows each check's result. A skipped check means its
project or test files are absent; it is not evidence that application code
passed testing. CI does not merge code or enforce approval. On the current
private GitHub Free repository, the team must follow the branch and review
rules, and only the project lead should merge into `main`.

## Code Quality

- Follow Dart and Flutter coding conventions.
- Use meaningful variable and function names.
- Avoid committing passwords, API keys, or database credentials.
- Add comments where code needs explanation.
- Keep the code clean and maintainable.

## Team Communication

Discuss major changes with the team before implementation. Report bugs and conflicts early.


