# Changelog

All notable changes to the Velo Test package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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