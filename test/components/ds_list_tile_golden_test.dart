// Feature: DsListTile draws the same in every state, test brand, and mode
// (contracts/golden-tests.md, Golden matrix).
import 'package:flutter_test/flutter_test.dart';

import '../support/ds_component_cases.dart';
import '../support/ds_golden_matrix.dart';

void main() {
  group('Given a DsListTile drawn for its golden images', () {
    DsGoldenMatrix.describeGoldens(DsComponentCases.listTile);
  });
}
