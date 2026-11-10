import 'package:intl/intl.dart';

String timeAgo(DateTime date, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
  if (diff.inDays < 7) return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
  return DateFormat('d MMM yyyy').format(date);
}

String fullDate(DateTime date) => DateFormat("MMM d, yyyy 'at' h:mm a").format(date);

String shortDate(DateTime date) => DateFormat('MMM d, h:mm a').format(date);
