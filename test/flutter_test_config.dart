import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'support/ds_golden_comparator.dart';
import 'support/ds_test_fonts.dart';

/// Sets up every test file: the 5% golden comparator and the test fonts.
///
/// flutter_test installs a [LocalFileComparator] for the test file before
/// this runs. It is replaced by a [DsGoldenComparator] for the same folder.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenFileComparator = DsGoldenComparator(
    (goldenFileComparator as LocalFileComparator).basedir.resolve(
      'placeholder_test.dart',
    ),
  );
  await DsTestFonts.load();
  await testMain();
}
