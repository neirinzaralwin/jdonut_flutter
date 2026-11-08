import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut/core/router/app_router.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/connection_banner.dart';
import 'package:jdonut/l10n/gen/app_localizations.dart';

class JDonutApp extends ConsumerWidget {
  const JDonutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) =>
          Stack(children: [?child, const ConnectionBanner()]),
    );
  }
}
