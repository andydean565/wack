class Release {
  final String tag;
  final String subject;
  final String body;
  final String date;

  Release({
    required this.tag,
    required this.subject,
    required this.body,
    required this.date,
  });

  static Release fromGit(dynamic json) => Release(
        tag: (json['tag'] as String).replaceAll('refs/tags/', ''),
        subject: json['subject'],
        body: json['body'],
        date: json['date'],
      );
}
