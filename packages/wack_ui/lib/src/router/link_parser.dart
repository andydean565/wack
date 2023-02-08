import 'package:flutter/material.dart';

import 'app_link.dart';

class LinkParser extends RouteInformationParser<Link> {
  @override
  Future<Link> parseRouteInformation(RouteInformation routeInformation) async {
    final link = Link.fromLocation(routeInformation.location);
    return link;
  }

  @override
  RouteInformation? restoreRouteInformation(Link configuration) {
    final location = configuration.toLocation();
    return RouteInformation(location: location);
  }
}
