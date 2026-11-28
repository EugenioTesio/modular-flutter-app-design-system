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

The `example/` app is a gallery of every component:

```bash
cd example && flutter run
```

To try a local change in Foundations before it is released, add a git-ignored `pubspec_overrides.yaml` to the Foundations checkout that points `design_system` to this repository's folder.

## Conventions

[CLAUDE.md](CLAUDE.md) holds the conventions every contributor and AI assistant follows: public API documentation, naming, and tests written in Gherkin notation.
