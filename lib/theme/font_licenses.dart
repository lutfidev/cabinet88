import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'typography.dart';

/// The SIL Open Font Licence that ships with each vendored face.
///
/// Both faces are bundled rather than fetched (see `pubspec.yaml`), and OFL 1.1
/// requires the licence to travel with them. Registering the text here puts it
/// on Flutter's own licence page, beside the framework's, so the obligation is
/// met by the bundle itself rather than by a screen someone has to remember to
/// build.
abstract final class FontLicenses {
  /// The licence file shipped for each family.
  static const Map<String, String> assets = <String, String>{
    AppFonts.pixelFamily: 'assets/fonts/OFL-PressStart2P.txt',
    AppFonts.bodyFamily: 'assets/fonts/OFL-SpaceGrotesk.txt',
    AppFonts.symbolFamily: 'assets/fonts/OFL-NotoSansSymbols2.txt',
  };

  /// Called once from `main`, before the first frame.
  static void register() {
    LicenseRegistry.addLicense(() async* {
      for (final MapEntry<String, String> face in assets.entries) {
        yield LicenseEntryWithLineBreaks(
          <String>[face.key],
          await rootBundle.loadString(face.value),
        );
      }
    });
  }
}
