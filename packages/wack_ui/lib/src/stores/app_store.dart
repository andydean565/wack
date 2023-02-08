import 'package:config_repo/config_repo.dart';
import 'package:flutter/material.dart';
import 'package:git_host_repo/git_host_repo.dart';
import 'package:mobx/mobx.dart';
import 'package:ticket_host_repo/ticket_host_repo.dart';
import 'package:wack_ui/src/stores/stores.dart';

part 'app_store.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store, ChangeNotifier {
  String directory = '/Users/andrew/Projects/gitlab/subcontractor_app/';

  ConfigRepo? configRepo;
  GitHostRepo? gitRepo;
  TicketHostRepo? ticketRepo;

  DashboardStore? dashboard;

  @override
  void addListener(VoidCallback listener) {
    // TODO: implement addListener
    super.addListener(listener);
    dashboard?.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    // TODO: implement removeListener
    super.removeListener(listener);
    dashboard?.removeListener(listener);
  }

  @action
  Future<void> init() async {
    if (directory.isEmpty) {
      debugPrint('error: no directory');
      return;
    }
    gitRepo = GitlabHostRepo(directory: directory);
    bool gitDir = await gitRepo!.gitDir;
    if (!gitDir) {
      debugPrint('error: no git');
      return;
    }

    configRepo = ConfigRepo.fromEnv(file: '$directory/.env');
    if (configRepo == null) {
      debugPrint('error: no config');
      return;
    }

    ticketRepo = JiraHostRepo(
      user: configRepo!.jiraUser,
      token: configRepo!.jiraApiToken,
    );

    dashboard = DashboardStore(
      configRepo: configRepo!,
      gitRepo: gitRepo!,
      ticketRepo: ticketRepo!,
    )..init();
    dashboard?.addListener(notifyListeners);
    notifyListeners();
  }

  _AppStore();
}
