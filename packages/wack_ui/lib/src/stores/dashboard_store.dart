import 'package:config_repo/config_repo.dart';
import 'package:flutter/material.dart';
import 'package:git_host_repo/git_host_repo.dart';
import 'package:mobx/mobx.dart';
import 'package:ticket_host_repo/ticket_host_repo.dart';

part 'dashboard_store.g.dart';

class DashboardStore = _DashboardStore with _$DashboardStore;

abstract class _DashboardStore with Store, ChangeNotifier {
  String directory = '/Users/andrew/Projects/gitlab/subcontractor_app/';
  String? branch;
  Ticket? ticket;
  List<String>? branches;

  final ConfigRepo configRepo;
  final GitHostRepo gitRepo;
  final TicketHostRepo ticketRepo;

  @action
  Future<void> init() async {
    await _fetch();
    await _ticketCheck();
    notifyListeners();
  }

  @action
  Future<void> _fetch() async {
    branch = await gitRepo.current.then((value) => value.branchName);
    branches = await gitRepo.branches.then(
      (value) => value.map((e) => e.branchName).toList(),
    );
  }

  @action
  Future<void> _ticketCheck() async {
    var keys = ticketRepo.findKey(branch!);
    if (keys.isNotEmpty) {
      ticket = await ticketRepo.getTicket(keys.first);
    } else {
      ticket = null;
    }
    notifyListeners();
  }

  Future<void> updateBranch(String branch) async {
    await gitRepo.checkout(branch);
    await _fetch();
    await _ticketCheck();
  }

  _DashboardStore({
    required this.configRepo,
    required this.gitRepo,
    required this.ticketRepo,
  });
}
