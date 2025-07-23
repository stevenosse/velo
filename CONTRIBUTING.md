# Contributing to Velo 🚴

Thank you for your interest in contributing to Velo! We welcome contributions from everyone.

## 🚀 Getting started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Git

### Development setup

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/yourusername/velo.git
   cd velo
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Verify setup**
   ```bash
   flutter test
   flutter analyze
   dart format --set-exit-if-changed .
   ```

## 📝 Development guidelines

### Code style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter_lints` for linting rules
- Run `dart format .` before committing
- Ensure `flutter analyze` passes without warnings

### Testing

- **All new code must have tests**
- Maintain 100% test coverage
- Add widget tests for UI components
- Add unit tests for business logic
- Run tests with: `flutter test --coverage`

### Documentation

- Document all public APIs with dartdoc comments
- Include code examples in documentation
- Update README.md if adding new features
- Update CHANGELOG.md following [semantic versioning](https://semver.org/)

## 🔄 Contribution workflow

### 1. Create a branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 2. Make changes

- Keep commits atomic and focused
- Write clear commit messages
- Follow conventional commits format:
  ```
  type(scope): description
  
  Examples:
  feat(core): add new emit method for async operations
  fix(widgets): resolve memory leak in VeloConsumer
  docs(readme): update installation instructions
  test(core): add tests for edge cases
  ```

### 3. Test your changes

```bash
# Run all tests
flutter test

# Check code coverage
flutter test --coverage

# Run static analysis
flutter analyze

# Check formatting
dart format --set-exit-if-changed .

# Verify pub readiness
flutter pub publish --dry-run
```

### 4. Submit a pull request

- Push your branch to your fork
- Create a pull request against the `develop` branch
- Fill out the pull request template completely
- Link any related issues

## 🐛 Reporting bugs

Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) and include:

- Flutter and Dart versions
- Velo version
- Platform (iOS, Android, Web, Desktop)
- Minimal reproduction code
- Expected vs actual behavior

## 💡 Feature requests

Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) and include:

- Use case description
- Proposed solution
- Alternative solutions considered
- Code examples (if applicable)

## 📋 Code review process

1. **Automated checks**: All PRs must pass CI/CD checks
2. **Code review**: At least one maintainer review required
3. **Testing**: All tests must pass, coverage must be maintained
4. **Documentation**: New features must be documented

### Review criteria

- ✅ Code follows project style guidelines
- ✅ All tests pass and coverage is maintained
- ✅ Changes are backward compatible (unless breaking change is justified)
- ✅ Public APIs are documented
- ✅ Performance impact is acceptable
- ✅ Security implications are considered

## 🏷️ Release process

Velo follows [semantic versioning](https://semver.org/):

- **MAJOR** version for incompatible API changes
- **MINOR** version for backward-compatible functionality additions
- **PATCH** version for backward-compatible bug fixes

## 🤝 Community guidelines

- Be respectful and inclusive
- Help others learn and grow
- Focus on constructive feedback
- Follow the [Code of Conduct](CODE_OF_CONDUCT.md)

## 📞 Getting help

- 💬 [GitHub Discussions](https://github.com/username/velo/discussions) for questions
- 🐛 [GitHub Issues](https://github.com/username/velo/issues) for bugs
- 📧 Email maintainers for security issues

Thank you for contributing to Velo! 🎉