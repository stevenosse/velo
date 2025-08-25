# Velo Workspace

A comprehensive state management solution for Flutter applications, consisting of multiple packages for different use cases.

## Packages

This workspace contains the following packages:

- **[velo](packages/velo/)** - A lightweight, type-safe state management solution for Flutter applications built on top of ValueNotifier and Provider.
- **[velo_test](packages/velo_test/)** - Testing utilities and helpers for the Velo state management package.

### 🧪 [velo_test](packages/velo_test/)

## Extensions
- VSCode Extension - [Velo](https://marketplace.visualstudio.com/items?itemName=stevenosse.velo-vscode)
- OpenVSX Extension - [Velo](https://open-vsx.org/extension/stevenosse/velo-vscode)

Testing utilities and helpers for the Velo state management package.

**Features:**
- 🎯 **Mock Velo classes**: Easy mocking for unit tests
- 📊 **State verification**: Verify state emissions and changes
- 🔍 **Widget testing**: Specialized helpers for widget tests
- ⏱️ **Async testing**: Support for testing async state changes
- 📈 **Test coverage**: Comprehensive testing utilities

## Quick start

For detailed usage instructions and examples, please refer to the individual package documentation:

- **[Velo package documentation](packages/velo/README.md)** - Core state management functionality
- **[Velo test package documentation](packages/velo_test/README.md)** - Testing utilities and helpers

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/velo.git`
3. Install dependencies: `flutter pub get`
4. Run tests: `flutter test`
5. Make your changes
6. Run quality checks: `flutter analyze && dart format --set-exit-if-changed .`
7. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.
