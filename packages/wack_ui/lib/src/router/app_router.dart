import 'dart:async';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/pages.dart';
import '../stores/app_store.dart';
import 'app_link.dart';

class AppRouter extends RouterDelegate<Link>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Link> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppStore store;

  AppRouter({
    required this.store,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : navigatorKey = GlobalKey<NavigatorState>();

  @override
  void addListener(VoidCallback listener) {
    store.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    store.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: store,
      child: Observer(
        builder: (context) {
          return Navigator(
            key: navigatorKey,
            pages: _pages(),
            onPopPage: (route, data) => pop(),
          );
        },
      ),
    );
  }

  bool pop() {
    return false;
  }

  @override
  Future<bool> popRoute() {
    return Future.value(pop());
  }

  List<Page> _pages() {
    return [
      const MaterialPage(
        child: LandingPage(),
      ),
      if (store.dashboard != null) ...[
        MaterialPage(
          child: ChangeNotifierProvider.value(
            value: store.dashboard!,
            child: const DashboardPage(),
          ),
        ),
      ],
    ];
  }

  @override
  Future<void> setNewRoutePath(Link configuration) {
    return SynchronousFuture(null);
  }
}
