class GeneralUtil {
  static Duration getDuration(String freq) {
    switch (freq) {
      case 'Hour':
        return const Duration(hours: 1);
      case 'Day':
        return const Duration(days: 1);
      case 'Week':
        return const Duration(days: 7);
      case 'Month':
        return const Duration(days: 30);
      case 'Year':
        return const Duration(days: 365);
      default:
        return const Duration(minutes: 1);
    }
  }

  static int getDivisions(String freq) {
    switch (freq) {
      case 'Hour':
        return 60;
      case 'Day':
        return 24;
      case 'Week':
        return 7;
      case 'Month':
        return 30;
      case 'Year':
        return 12;
      default:
        return 60;
    }
  }
}
