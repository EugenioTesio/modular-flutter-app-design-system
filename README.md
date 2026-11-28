# modular-flutter-app-design-system

The design system of the modular Flutter app: tokens, light and dark themes, and accessible components (`DsButton`, `DsTextField`, `DsPageScaffold`, and more). The package is `design_system`, and its single public library is `package:design_system/design_system.dart`.

## How consumers get it

Micro apps and the App Shell don't depend on this package directly. They depend on [Foundations](https://github.com/EugenioTesio/modular-flutter-app-foundations), which pins one release of this package through a git tag and re-exports its public library unchanged. Importing `package:foundations/foundations.dart` is enough to use every component.

Releases are tagged `vX.Y.Z` and follow semantic versioning. [CHANGELOG.md](CHANGELOG.md) lists what each release changed.

## Developing

The package depends at runtime on the Flutter SDK only.

```bash
flutter pub get
dart analyze
flutter test
```

### Token lint and contrast gate

`lints/` holds `design_system_lints`, an analyzer plugin that reports literal colors and spacing, and literal icon sizes, border widths, opacities, and primitive brand colors inside components. The root `analysis_options.yaml` enables it, and the package must report 0 issues. Use `dart analyze`: `flutter analyze` doesn't run analyzer plugins, so it never shows these reports. The rules' own tests run with `cd lints && dart test`.

Other projects opt in from their `analysis_options.yaml`:

```yaml
plugins:
  design_system_lints:
    path: ../design-system/lints
```

`DsContrastGate.check(brand)` lists every semantic color pair of a brand that falls below its required contrast in light or dark mode. The repository's tests run it on every file in `widgetbook/brands/`. In debug builds, placing a failing brand prints one warning that names the failing pairs.

### Golden images

Each component's states are compared with golden images in `test/components/goldens/`, one per state, brand, and mode. A comparison passes when at most 5% of the pixels differ, so images generated on macOS also pass on Linux. A failure writes difference images to a git-ignored `failures/` folder.

Run only the golden tests:

```bash
flutter test --tags golden
```

After an intentional visual change, regenerate the images, then review them in the diff:

```bash
flutter test --update-goldens --tags golden
```

Check them on Linux with Docker:

```bash
docker run --rm -v "$PWD":/w -w /w ghcr.io/cirruslabs/flutter:3.47.9 flutter test --tags golden
```

The `widgetbook/` app shows every component in every brand file, mode, and viewport, with a toggle for the developer guidelines overlay:

```bash
cd widgetbook && flutter run -d macos
```

To try a local change in Foundations before it is released, add a git-ignored `pubspec_overrides.yaml` to the Foundations checkout that points `design_system` to this repository's folder.

## Versions and lifecycle

**Versions.** Releases follow semantic versioning and are tagged `vX.Y.Z`. Before 1.0, a minor release (`0.2.0` → `0.3.0`) may break the API, and a patch release (`0.2.0` → `0.2.1`) never does. From 1.0, only a major release breaks. Every release has a [CHANGELOG.md](CHANGELOG.md) entry with Added, Changed, Deprecated, Removed, and Fixed, and a **Migration** section with before and after code whenever something breaks. Foundations states which release it delivers, and a Foundations release that adopts a breaking one is breaking too.

**Component statuses.** Every component declares its status in `info.status` and on a `**Status**:` line of its documentation, and the Widgetbook shows it next to the name.

| Status | What it means for you |
|--------|-----------------------|
| `experimental` | New. It may change or be removed in any minor release, and the change is listed in the changelog. New components start here. |
| `stable` | Settled. It changes only as semantic versioning allows. |
| `deprecated` | On its way out. Its documentation names the replacement and the release that removes it. |

**Deprecations.** A deprecated element carries `@Deprecated('Use <replacement>. Removed in <version>.')`, so your code shows a warning where it uses it. It stays for at least one minor release before it is removed, and the changelog's Migration section shows how to move off it. For example, `DsBrand.standard` is deprecated in favor of `DsBrand.whiteLabel` and is removed in 0.3.0.

**Brand-schema versions.** Every brand file declares a `schemaVersion`. `DsBrandParser.supportedSchemaVersions` lists the versions a release reads, and its changelog entry repeats them. Adding, renaming, or removing a required token bumps the schema version, and the changelog lists the token paths that changed. A file with an unsupported version is rejected with a message that names the supported ones. `0.2.0` reads version 1.

## Conventions

[CLAUDE.md](CLAUDE.md) holds the conventions every contributor and AI assistant follows: public API documentation, naming, and tests written in Gherkin notation.
