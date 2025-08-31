# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2025-08-31

### Breaking changes
- Renamed `loadingWidget` to `errorWidget` in `VeloBuilder` for better clarity

### Fixed
- Critical memory leak in `VeloConsumer` listener management
- Race condition in `VeloConsumer` state updates
- Missing API documentation for pub.dev score improvement

### Changed
- Optimized `Velo.emit()` performance by removing redundant comparisons
- Improved error handling consistency across all widgets
- Enhanced null safety throughout the codebase

## [1.1.0] - 2025-08-24

- Minor improvements and bug fixes
- Enhanced test coverage
- Updated documentation

## [1.0.0] - 2025-07-23

### Added
- Initial release of Velo state management package
- `Velo<S>` abstract class extending `ValueNotifier<S>` with `Equatable` support
- `VeloBuilder<N, S>` widget for rebuilding UI on state changes
- `VeloConsumer<N, S>` widget combining builder and listener functionality
- `VeloListener<N, S>` widget for side effects without rebuilding
- `MultiVeloListener` widget for providing multiple Velos
- Comprehensive test suite with 23 test cases
- Complete documentation with examples and best practices
- English and French documentation support

### Features
- **Efficient State Comparison**: Uses `Equatable` to prevent unnecessary rebuilds
- **Simple API**: Minimal learning curve compared to complex state management solutions
- **Flutter Native**: Built on `ValueNotifier` for optimal performance
- **Provider Integration**: Works seamlessly with the Provider package
- **Error Handling**: Graceful error handling in all widgets
- **Async Support**: `emitAsync()` method for handling Future-based state updates
- **Type Safety**: Full type safety with generic constraints

### Security
- Safe type casting with proper null checks
- Error boundaries in all widgets prevent crashes
- Memory leak prevention with proper disposal patterns

### Documentation
- Complete API documentation with examples
- Usage patterns and best practices
- Comparison with flutter_bloc
- Testing guidelines and examples

### Testing
- Unit tests for core `Velo` functionality
- Widget tests for all provided widgets
- Edge case testing (null states, error conditions, concurrent operations)
- Performance tests for rapid state changes
- Integration tests with Provider

### Performance Improvements
- Eliminated double listening in `VeloConsumer`
- Optimized state comparison logic
- Reduced unnecessary rebuilds through `Equatable` integration
- Efficient memory usage with proper listener management