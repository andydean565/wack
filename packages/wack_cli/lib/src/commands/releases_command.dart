import 'package:args/command_runner.dart';
import 'package:config_repo/config_repo.dart';
import 'package:git_host_repo/git_host_repo.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ticket_host_repo/ticket_host_repo.dart';

/// {@template tickets_command}
/// A command which fetches tickets.
/// {@endtemplate}
class ReleasesCommand extends Command<int> {
  /// {@macro tickets_command}
  ReleasesCommand({
    required Logger logger,
  }) : _logger = logger {}

  final Logger _logger;

  @override
  String get description => 'get releases (tags)';

  static const String commandName = 'releases';

  @override
  String get name => commandName;

  late ConfigRepo config = ConfigRepo.fromEnv()!;
  late GitHostRepo gitRepo = GitlabHostRepo();

  @override
  Future<int> run() async {
    final tags = await gitRepo.getReleases();
    for (final e in tags) {
      _logger.info(
        '${e.tag}',
      );
    }
    return ExitCode.success.code;
  }
}
// git for-each-ref --format '%(refname) %09 %(taggerdate) %(subject) %(taggeremail)' refs/tags  --sort=taggerdate
