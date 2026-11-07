import 'package:flutter/widgets.dart';
import 'package:jdonut/l10n/gen/app_localizations.dart';

export 'package:jdonut/l10n/gen/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
