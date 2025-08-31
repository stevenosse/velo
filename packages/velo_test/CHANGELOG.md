# Changelog

All notable changes to the Velo Test package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2025-08-31

### Changed
- Formatting and linting

## [1.0.2] - 2025-08-31

### Changed
- Updated `VeloTestWidget` to use new `errorWidget` parameter
- Improved error handling in widget test helpers
- Enhanced MockVelo documentation and method descriptions

### Fixed
- Exception handling now catches all errors, not just `Exception` types
- Better disposal detection in MockVelo prevents usage after cleanup

### Added
- Compatibility with velo package v1.2.0

## [1.0.1] - 2025-08-24

### Fixed
- Fixed type casting error when using TypeMatcher instances (like `isA<State>()`) in `veloTest` expect parameter
- Added proper support for both TypeMatcher objects and actual state values in expect assertions
- Improved error handling for mixed matcher and state value scenarios

## [1.0.0] - 2025-08-24

### Added
- Initial release of Velo Test utilities package
- `MockVelo` class for testing with state history tracking
- State verification methods (`verifyStateEmitted`, `verifyStatesEmittedInOrder`)
- Pre-built test helpers (`CounterVelo`, `SimpleVelo`, `CounterState`, `SimpleState`)
- Widget testing utilities (`VeloWidgetTester` extension)
- Test widget creators (`createVeloBuilderTestWidget`, `createVeloListenerTestWidget`)
- Async testing helpers (`waitForCondition`, `waitFor`, `waitForVeloState`)
- Comprehensive documentation and examples

### Features
- State history tracking for all emissions
- Emission count tracking for specific states
- Widget testing support for all Velo widgets
- Timeout handling for async operations
- Integration with flutter_test framework
- Cross-platform testing support