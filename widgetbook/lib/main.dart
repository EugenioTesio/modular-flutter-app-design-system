import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'brand_files/brand_file_loader.dart';
import 'widgetbook_app.dart';

/// Starts the Widgetbook: reads every brand file in `brands/`, then shows the
/// catalog.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final brands = await BrandFileLoader.load(rootBundle);
  runApp(DsWidgetbook(brands: brands));
}
