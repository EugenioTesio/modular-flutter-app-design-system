import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/package_config_file_builder.dart';
// The expected-diagnostic type is only exported from a src library.
// ignore: implementation_imports
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart'
    show ExpectedDiagnostic;

/// Rule test fixture for one design system lint rule.
///
/// The package under test is named `design_system`, so files under
/// `lib/src/components/` have the URIs the component-scoped rules look for.
/// A small `flutter` package supplies exactly the types the rules inspect.
/// Tests drive it with `package:test` groups, so they read as Given, When,
/// and Then.
final class DsRuleFixture extends AnalysisRuleTest {
  /// Creates a fixture for the rule that [create] builds.
  DsRuleFixture(this._create);

  final AbstractAnalysisRule Function() _create;

  @override
  String get testPackageRootPath => '$workspaceRootPath/design_system';

  /// Path of a file in the package under test, such as `lib/src/x.dart`.
  String pathOf(String relativePath) => '$testPackageRootPath/$relativePath';

  @override
  void setUp() {
    rule = _create();
    super.setUp();
    newFile(
      pathOf('lib/src/brand/ds_brand.dart'),
      DsRuleFixture._designSystemBrand,
    );
  }

  @override
  void writeTestPackageConfig2({
    PackageConfigFileBuilder? config,
    String? languageVersion,
  }) {
    const flutterRoot = '/packages/ds_flutter_stub';
    for (final MapEntry(key: file, value: content)
        in DsRuleFixture._flutter.entries) {
      newFile('$flutterRoot/lib/$file', content);
    }
    final withFlutter = (config ?? PackageConfigFileBuilder()).copy()
      ..add(name: 'flutter', rootFolder: getFolder(flutterRoot));
    writePackageConfig2(
      testPackageRootPath,
      config: withFlutter,
      languageVersion: languageVersion,
      packageName: 'design_system',
    );
  }

  /// Returns the expected diagnostic of this rule on [snippet] in [code].
  ///
  /// [occurrence] picks a later match when [snippet] appears more than once.
  ExpectedDiagnostic at(String code, String snippet, {int occurrence = 0}) {
    var offset = -1;
    for (var i = 0; i <= occurrence; i++) {
      offset = code.indexOf(snippet, offset + 1);
    }
    if (offset < 0) throw ArgumentError('"$snippet" is not in the code.');
    return lint(offset, snippet.length);
  }

  /// A stand-in for the design system's brand, with its primitive colors.
  static const String _designSystemBrand = r'''
import 'package:flutter/painting.dart';

class DsBrandScale {
  const DsBrandScale(this.shade600);
  final Color shade600;
}

class DsBrandColors {
  const DsBrandColors(this.brand);
  final DsBrandScale brand;
}

class DsBrand {
  const DsBrand(this.colors);
  final DsBrandColors colors;
}
''';

  /// The Flutter types the rules inspect, by library.
  static const Map<String, String> _flutter = {
    'painting.dart': r'''
class Color {
  const Color(int value);
  const Color.fromARGB(int a, int r, int g, int b);
  const Color.fromRGBO(int r, int g, int b, double opacity);
  const Color.from({
    required double alpha,
    required double red,
    required double green,
    required double blue,
  });
  Color withValues({double? alpha}) => this;
  Color withOpacity(double opacity) => this;
}

class Radius {
  const Radius.circular(double radius);
}

class BorderRadius {
  const BorderRadius.circular(double radius);
}

class EdgeInsets {
  const EdgeInsets.all(double value);
  const EdgeInsets.symmetric({double vertical = 0, double horizontal = 0});
  const EdgeInsets.only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  });
  const EdgeInsets.fromLTRB(double left, double top, double right, double bottom);
}

class EdgeInsetsDirectional {
  const EdgeInsetsDirectional.all(double value);
  const EdgeInsetsDirectional.symmetric({
    double vertical = 0,
    double horizontal = 0,
  });
  const EdgeInsetsDirectional.only({
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  });
  const EdgeInsetsDirectional.fromSTEB(
    double start,
    double top,
    double end,
    double bottom,
  );
}

class BorderSide {
  const BorderSide({Object? color, double width = 1.0});
}
''',
    'widgets.dart': r'''
export 'painting.dart';

import 'painting.dart';

class Widget {
  const Widget();
}

class SizedBox extends Widget {
  const SizedBox({double? width, double? height, Widget? child});
  const SizedBox.square({double? dimension, Widget? child});
}

class Row extends Widget {
  const Row({double spacing = 0, List<Widget> children = const []});
}

class Column extends Widget {
  const Column({double spacing = 0, List<Widget> children = const []});
}

class Wrap extends Widget {
  const Wrap({
    double spacing = 0,
    double runSpacing = 0,
    List<Widget> children = const [],
  });
}

class Icon extends Widget {
  const Icon(Object? icon, {double? size, Color? color});
}

class Container extends Widget {
  const Container({Color? color, Object? padding, Widget? child});
}
''',
    'material.dart': r'''
export 'widgets.dart';

import 'widgets.dart';

abstract final class Colors {
  static const Color transparent = Color(0x00000000);
  static const Color red = Color(0xFFF44336);
}

const double kMinInteractiveDimension = 48.0;
''',
    'cupertino.dart': r'''
export 'widgets.dart';

import 'widgets.dart';

abstract final class CupertinoColors {
  static const Color activeBlue = Color(0xFF007AFF);
}
''',
  };
}
