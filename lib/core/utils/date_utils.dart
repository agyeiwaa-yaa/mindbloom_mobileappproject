import 'package:intl/intl.dart';

class MindBloomDateUtils {
  static String prettyDate(DateTime date) => DateFormat('EEE, d MMM yyyy').format(date);

  static String prettyDateTime(DateTime date) => DateFormat('d MMM yyyy, h:mm a').format(date);

  static String dayKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
}
