# Changelog

All notable changes to the Velo package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Velo state management package
- Core `Velo` class for state management
- `VeloBuilder` widget for reactive UI updates
- `VeloListener` widget for side effects
- `VeloConsumer` widget combining builder and listener
- `MultiVeloListener` widget for multiple Velo instances
- Integration with Provider package
- Support for async state updates with `emitAsync`
- Comprehensive test coverage
- Example application demonstrating usage

### Features
- Built on Flutter's native `ValueNotifier`
- Integration with `Equatable` for efficient state comparisons
- Type-safe state management
- Minimal dependencies
- Cross-platform support (Android, iOS, Web, Desktop)