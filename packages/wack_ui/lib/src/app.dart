import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wack_ui/src/pages/dashboard_page.dart';
import 'package:wack_ui/src/stores/app_store.dart';
import 'package:wack_ui/src/stores/stores.dart';

import 'router/app_router.dart';
import 'router/link_parser.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late AppStore store;
  late AppRouter _router;
  final routeParser = LinkParser();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    store = AppStore()..init();
    _router = AppRouter(
      store: store,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wack',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Container(child: child),
      ),
      debugShowCheckedModeBanner: false,
      routeInformationParser: routeParser,
      routerDelegate: _router,
    );
  }
}
