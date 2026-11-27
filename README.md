# modular-flutter-app-design-system

The design system of the modular Flutter app: tokens, light and dark themes, and accessible components (`DsButton`, `DsTextField`, `DsPageScaffold`, and more). The package is `design_system`, and its single public library is `package:design_system/design_system.dart`.

## How consumers get it

Micro apps and the App Shell don't depend on this package directly. They depend on [Foundations](https://github.com/EugenioTesio/modular-flutter-app-foundations), which pins one release of this package through a git tag and re-exports its public library unchanged. Importing `package:foundations/foundations.dart` is enough to use every component.

Releases are tagged `vX.Y.Z` and follow semantic versioning. [CHANGELOG.md](CHANGELOG.md) lists what each release changed.

## Developing

The package depends at runtime on the Flutter SDK only.

```bash
flutter pub get
flutter analyze
flutter test
```

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
