# Dart Preferences

Apply these to Dart code alongside the shared preferences in the skill entry point.

## Fallible APIs

Return explicit Result values for expected failures in repository and service APIs, using a Future of the result for asynchronous work. The user prefers Rust-like failure values over making callers catch exceptions throughout the application.

Catch expected exceptions close to the operation that throws, or at its adapter boundary, and convert them into meaningful typed failure values. Preserve the underlying cause and useful stack information. Callers propagate, transform, or handle those results through the result contract.

## Result dependency

Reuse an established compatible Result library in the project. Where none exists and this pattern is being introduced, add a library dependency rather than defining another Result hierarchy. The recommended default is `result_dart`; use `dart pub add result_dart` or `flutter pub add result_dart`, resolving a release compatible with the project's SDK and dependency conventions.

Use the package's actual API:

- `Success(value)` and `Failure(error)` represent the two outcomes.
- `Result<T>` fixes the failure type to `Exception`. Use `ResultDart<T, F>` when the failure type should be explicit; `AsyncResultDart<T, F>` is its Future alias.
- `fold(onSuccess, onFailure)` handles both branches; `map`, `flatMap`, and `mapError` support transformations and propagation.
- For success without a payload, use the package's `Unit` and `unit` value.

Match the resolved library version when using its helpers. The package recommendation implements the user's preference; it does not require replacing another suitable Result dependency or changing an established API during an unrelated feature change.

## JSON conversion

Prefer generated JSON converters with `json_serializable` when an application has several API models. About a dozen models with roughly ten fields each is an established example where generation is preferred, rather than a hard numeric threshold.

Use `json_annotation` for annotations and `json_serializable` with `build_runner` as development dependencies. Keep the generated converters in their `.g.dart` parts and use `dart run build_runner build` or the project's established generation command.

Enable `disallowUnrecognizedKeys: true` on generated decoders, directly or through shared generator configuration, to preserve the default of rejecting unknown fields. Convert expected decoding exceptions into typed Results at the adapter boundary.

This preference concerns JSON conversion. It does not establish a default for generating other model behavior, and existing project conventions still determine whether generation is used.
