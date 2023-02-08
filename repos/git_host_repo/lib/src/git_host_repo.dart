export './gitlab_host_repo.dart';
import 'dart:convert';
import 'dart:io';

import 'package:git/git.dart';
import 'package:git_host_repo/src/models/models.dart';
import 'package:path/path.dart' as p;

abstract class GitHostRepo {
  final String? directory;

  GitHostRepo({required this.directory}) {}

  Future<bool> get gitDir => GitDir.isGitDir((this.directory ?? p.current));

  Future<List<BranchReference>> get branches {
    return GitDir.fromExisting((this.directory ?? p.current))
        .then((value) => value.branches());
  }

  Future<Map<String, Tag>> get tags {
    return GitDir.fromExisting((this.directory ?? p.current))
        .then((value) async {
      final tags = <String, Tag>{};

      await for (var tag in value.tags()) {
        tags[tag.objectSha] = tag;
      }

      return tags;
    });
  }

  Future<BranchReference> get current {
    return GitDir.fromExisting((this.directory ?? p.current))
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
    return GitDir.fromExisting((this.directory ?? p.current))
        .then((value) async {
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

  Future<List<Release>> getReleases() async {
    return GitDir.fromExisting((this.directory ?? p.current))
        .then((value) async {
      final pr = await value.runCommand(
        [
          'for-each-ref',
          '--format={"tag":"%(refname)","date":"%(taggerdate)","subject":"%(subject:sanitize)","body":""}',
          "--sort=taggerdate",
          "refs/tags/v*"
        ],
      );

      var tags = (pr.stdout as String).split('\n');
      return tags.where((element) => element.isNotEmpty).map((e) {
        return Release.fromGit(json.decode(e));
      }).toList();
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
      GitDir.fromExisting((this.directory ?? p.current)).then(
        (value) => value.runCommand(command).then(
          (value) {
            print(command.toString());
            stdout.write(value.stdout);
            stderr.write(value.stderr);
          },
        ),
      );
}
