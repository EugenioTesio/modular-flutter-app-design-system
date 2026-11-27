# Design System

This repository holds `design_system`, the design system of the modular Flutter app. Micro apps and the App Shell get it through Foundations, which pins one release and re-exports `package:design_system/design_system.dart` unchanged, so everything that library exports is public API that micro app developers read.

The conventions below are copied verbatim from the container repository's `CLAUDE.md`. In this repository, "public API" means everything exported from `package:design_system/design_system.dart`.

## Conventions (required in every module)

### Public API documentation

Every public declaration a micro app can use has a proper dartdoc comment, written in the same change as the code. That covers everything exported from `package:foundations/foundations.dart`, and later the public surfaces of Core and each micro app. The style follows the user's reference classes (`WebviewNavigationHandler` and `PageReadyHandler` in their `flutter-safe-webview` package) on top of Effective Dart.

**Classes, contracts, enums, typedefs, and extensions** use this shape, in this order. Skip a paragraph only when it has nothing to say.

The role noun is, for example, "Contract that…", "Value that…", "Exception returned when…", or "Function that…".

```dart
/// <Role noun> that <does what>.
///
/// Use this when/to <situation in which a micro app reaches for it>.
///
/// This is **not** <the thing it is easily confused with>.
///
/// Built-in: <who implements or wires it, for example Core or the host, and what happens automatically>.
///
/// <Rules, behaviors, and edge cases, as prose or a bullet list.>
///
/// Usage from a micro app:
/// ```dart
/// <a short, realistic example>
/// ```
```

- The label line ("Usage from a micro app:", "Usage from a provider:", "Examples:") sits directly above the code block, with no blank line between them. Always tag the fence with a language (`dart`, `json`, `text`).

**Constructors** start "Creates a/an <thing>." and list every parameter:

```dart
/// Creates a route-not-found exception.
///
/// Parameters:
/// * [path] - The location that was requested.
/// * [body] - Optional extra values; defaults to empty.
```

**Methods** start with a third-person verb, list their parameters the same way under `Parameters:`, then say what they return and how they fail (`Err`, throw, or `null`).

**Fields and getters** use a noun phrase ("Address that was registered twice…"). Nullable ones start with "Optional…", and booleans start with "Whether…". Enum values use a short noun phrase.

**Always:**
- Use `///`, never `@param`/`@return`/`@throws` tags.
- Link identifiers with `[Name]`, using `/// @docImport '…';` above `library;` for symbols the file doesn't import. Use backticks only for literals, keywords, code, and names that don't exist yet.
- State defaults, nullability, failures, and privacy rules (no credentials or personal data in logs, analytics, or crash reports).
- Never put spec IDs (`FR-…`, `SC-…`) in public docs.
- `public_member_api_docs` and `comment_references` enforce presence and links; `flutter analyze` and `dart doc --dry-run` must report 0 issues.

### Naming

- Error and failure types are named `…Exception`, `implements Exception`, and live in `lib/src/exceptions/`, one file each. A sealed base keeps its variants in its own file. Contracts return them in an `Err` rather than throwing, except wiring mistakes such as `DuplicateEndpointException`.
- Use "type", not "kind", for classifications: `EndpointType`, `ApiExceptionType`.
- Scope names to their feature: `AppInfoEnvironment`, `BoolFeatureFlag`, `DevicePermissionStatus`. Avoid generic names.
- Don't write loose top-level helpers. Group them as static methods of a class, and don't invent a helper the SDK already provides (use `mapEquals`/`setEquals`).
- Use explicit field names, such as `queryParams`, not `query`.

### Tests

- Describe every test in Gherkin notation: a `// Feature:` header, `group('Given …')`, `test('When …, Then …')`, and `// Given` / `// When` / `// Then` sections in the body.
