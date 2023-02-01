export './gitlab_host_repo.dart';
import 'dart:io';

import 'package:git/git.dart';
import 'package:path/path.dart' as p;

abstract class GitHostRepo {
  Future<bool> get gitDir => GitDir.isGitDir(p.current);
  Future<List<BranchReference>> get branches {
    return GitDir.fromExisting(p.current).then((value) => value.branches());
  }

  Future<List<BranchReference>> findPrefixBranch(RegExp filter) async {
    return (await branches)
        .where(
          (element) => filter.hasMatch(element.branchName),
        )
        .toList();
  }

  Future<void> checkout(
    String branch, {
    bool newBranch = false,
  }) async {
    await command([
      'checkout',
      if (newBranch) '-b',
      branch,
    ]);
  }

  Future<void> command(List<String> command) =>
      GitDir.fromExisting(p.current).then(
        (value) => value.runCommand(command).then(
          (value) {
            stdout.write(value.stdout);
            stderr.write(value.stderr);
          },
        ),
      );
}
