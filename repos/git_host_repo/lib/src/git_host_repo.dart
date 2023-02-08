export './gitlab_host_repo.dart';
import 'dart:io';

import 'package:git/git.dart';
import 'package:path/path.dart' as p;

abstract class GitHostRepo {
  Future<bool> get gitDir => GitDir.isGitDir(p.current);
  Future<List<BranchReference>> get branches {
    return GitDir.fromExisting(p.current).then((value) => value.branches());
  }

  Future<BranchReference> get current {
    return GitDir.fromExisting(p.current)
        .then((value) => value.currentBranch());
  }

  Future<List<BranchReference>> findPrefixBranch(RegExp filter) async {
    return branches.then(
      (value) => value
          .where(
            (element) => filter.hasMatch(element.branchName),
          )
          .toList(),
    );
  }

  Future<Map<String, Commit>> getCommitDifference(
    String source,
    String target,
  ) async {
    return GitDir.fromExisting(p.current).then((value) async {
      final pr = await value.runCommand(
        [
          'rev-list',
          '--format=raw',
          '$source..$target',
        ],
      );
      return Commit.parseRawRevList(pr.stdout as String);
    });
  }

  Future<void> checkout(
    String branch, {
    bool newBranch = false,
  }) =>
      command([
        'checkout',
        if (newBranch) '-b',
        branch,
      ]);

  Future<void> command(List<String> command) =>
      GitDir.fromExisting(p.current).then(
        (value) => value.runCommand(command).then(
          (value) {
            print(command.toString());
            stdout.write(value.stdout);
            stderr.write(value.stderr);
          },
        ),
      );
}
