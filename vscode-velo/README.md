# Velo VSCode Extension

[![CI](https://github.com/stevenosse/velo/workflows/CI/badge.svg)](https://github.com/stevenosse/velo/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![VS Code Marketplace](https://img.shields.io/visual-studio-marketplace/v/stevenosse.velo-vscode)](https://marketplace.visualstudio.com/items?itemName=stevenosse.velo-vscode)

A comprehensive VSCode extension for [Velo](https://github.com/stevenosse/velo) state management - bringing powerful code generation, snippets, and productivity tools to Flutter developers using Velo.

## ✨ Features

### 🎯 Code Generation Commands

- **New Velo**: Generate a complete Velo class with boilerplate code
- **New State**: Create state classes with Equatable support and copyWith methods
- **New Velo + State**: Generate both Velo and State classes together
- **New Test**: Create test files with velo_test integration

### 🔄 Code Actions & Quick Fixes

- **Widget Wrapping**: Wrap selected widgets with:
  - `VeloBuilder<T, S>`
  - `VeloListener<T, S>`
  - `VeloConsumer<T, S>`
  - `Provider<T>`
  
- **Widget Conversion**: Convert between Velo widgets:
  - `VeloBuilder` ↔ `VeloConsumer`
  - `Provider` → `MultiProvider`

### 📝 Rich Code Snippets

Over 20 intelligent snippets including:

- `velo-class` - Complete Velo class template
- `velo-state` - State class with Equatable and copyWith
- `velo-builder` - VeloBuilder widget template
- `velo-consumer` - VeloConsumer widget template
- `velo-async` - Async method template with loading states
- `context-read` - context.read<T>() snippet
- And many more...

### 🧪 Testing Support

- Generate mock Velo classes using velo_test
- Create comprehensive test suites
- Widget test helpers with VeloBuilder setup

## 🚀 Installation

### From VS Code Marketplace

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "Velo"
4. Click Install

### From VSIX

Download the latest `.vsix` file from [releases](https://github.com/stevenosse/velo/releases) and install via:

```bash
code --install-extension velo-vscode-x.x.x.vsix
```

## 📖 Usage

### Commands

Access commands via:
- **Command Palette** (Ctrl+Shift+P): Search for "Velo"
- **Context Menu**: Right-click in Explorer on folders
- **Quick Actions**: Use Ctrl+. on selected code

### Code Actions

1. Select any widget or code snippet
2. Press `Ctrl+.` (or `Cmd+.` on Mac)
3. Choose from available Velo actions:
   - Wrap with VeloBuilder
   - Wrap with VeloConsumer  
   - Convert between widget types

### Snippets

Start typing any snippet prefix and press Tab:

```dart
// Type 'velo-class' and press Tab
class CounterVelo extends Velo<CounterState> {
  CounterVelo() : super(const CounterState());
  
  // Add your methods here
}
```

## 🎬 Demo

### Creating a New Velo

![New Velo Demo](assets/demo-new-velo.gif)

### Widget Wrapping

![Widget Wrapping Demo](assets/demo-widget-wrap.gif)

### Code Snippets

![Snippets Demo](assets/demo-snippets.gif)

## 🔧 Configuration

The extension works out of the box with no configuration required. It automatically:

- Detects Dart files and activates
- Analyzes your code for existing Velo types
- Provides contextual suggestions based on your codebase

## 📋 Requirements

- VS Code 1.74.0 or higher
- Flutter/Dart extension
- A Flutter project using the Velo package

## 🛠 Development

### Setup

```bash
git clone https://github.com/stevenosse/velo.git
cd velo/vscode-velo
npm install
```

### Running

- Press `F5` to run the extension in a new Extension Development Host window
- Make changes and reload the window to test

### Testing

```bash
npm test              # Run unit tests
npm run test:coverage # Run tests with coverage
npm run lint          # Run linting
```

### Building

```bash
npm run compile  # Compile TypeScript
npm run package  # Create VSIX package
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](../../CONTRIBUTING.md) for details.

### Development Guidelines

1. Follow existing code style and patterns
2. Add tests for new features
3. Update documentation as needed
4. Ensure CI passes before submitting PR

## 📊 Comparison with Bloc Extension

| Feature | Velo Extension | Bloc Extension |
|---------|----------------|----------------|
| Code Generation | ✅ | ✅ |
| Widget Wrapping | ✅ | ✅ |
| Snippets | ✅ | ✅ |
| Testing Support | ✅ | ✅ |
| State Class Generation | ✅ | ✅ |
| Bundle Size | ~200KB | ~500KB |
| Learning Curve | Low | Medium |

## 🐛 Known Issues

- Large Dart files (>10k lines) may experience slower code actions
- Widget detection may not work with complex nested structures

See [Issues](https://github.com/stevenosse/velo/issues) for a complete list.

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.

## 💝 Support

- 🌟 Star the [repository](https://github.com/stevenosse/velo)
- 🐛 [Report issues](https://github.com/stevenosse/velo/issues)
- 💡 [Request features](https://github.com/stevenosse/velo/discussions)
- ❓ [Ask questions](https://github.com/stevenosse/velo/discussions)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the excellent [Bloc VSCode extension](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)
- Built for the [Velo state management package](https://github.com/stevenosse/velo)
- Thanks to all contributors and users of the Velo ecosystem

---

**Enjoy using Velo with enhanced productivity! 🚀**