export './gitlab_host_repo.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;

abstract class GitHostRepo {
  Future<bool> get gitDir => GitDir.isGitDir(p.current);
}
