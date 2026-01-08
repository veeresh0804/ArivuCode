/// App-wide constants
class AppConstants {
  // Private constructor
  AppConstants._();

  // ============ App Info ============
  static const String appName = 'ArivuCode';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Code. Challenge. Conquer.';

  // ============ Supported Languages ============
  static const List<String> supportedLanguages = [
    'Python',
    'C',
    'C++',
    'Java',
    'JavaScript',
  ];

  static const Map<String, String> languageExtensions = {
    'Python': '.py',
    'C': '.c',
    'C++': '.cpp',
    'Java': '.java',
    'JavaScript': '.js',
  };

  static const Map<String, String> languageIcons = {
    'Python': '🐍',
    'C': '©️',
    'C++': '➕',
    'Java': '☕',
    'JavaScript': '🟨',
  };

  // ============ Difficulty Levels ============
  static const String difficultyEasy = 'Easy';
  static const String difficultyMedium = 'Medium';
  static const String difficultyHard = 'Hard';

  static const List<String> difficultyLevels = [
    difficultyEasy,
    difficultyMedium,
    difficultyHard,
  ];

  // ============ Points System ============
  static const int pointsEasy = 10;
  static const int pointsMedium = 25;
  static const int pointsHard = 50;
  static const int pointsStreak = 5; // Bonus per day
  static const int pointsBeatFriend = 15; // Bonus for beating friend's time

  static const Map<String, int> difficultyPoints = {
    difficultyEasy: pointsEasy,
    difficultyMedium: pointsMedium,
    difficultyHard: pointsHard,
  };

  // ============ Streak Thresholds ============
  static const int streakResetHours = 24;
  static const int streakBronze = 3;
  static const int streakSilver = 7;
  static const int streakGold = 30;
  static const int streakPlatinum = 100;

  // ============ Time Limits (in seconds) ============
  static const int timeLimitEasy = 300; // 5 minutes
  static const int timeLimitMedium = 600; // 10 minutes
  static const int timeLimitHard = 900; // 15 minutes

  static const Map<String, int> defaultTimeLimits = {
    difficultyEasy: timeLimitEasy,
    difficultyMedium: timeLimitMedium,
    difficultyHard: timeLimitHard,
  };

  // ============ Code Execution ============
  static const int maxCodeLength = 10000; // characters
  static const int executionTimeout = 10; // seconds
  static const int maxOutputLength = 5000; // characters

  // ============ Achievement IDs ============
  static const String achievementFirstSolve = 'first_solve';
  static const String achievementStreak3 = 'streak_3';
  static const String achievementStreak7 = 'streak_7';
  static const String achievementStreak30 = 'streak_30';
  static const String achievement10Solved = 'solved_10';
  static const String achievement30Solved = 'solved_30';
  static const String achievement100Solved = 'solved_100';
  static const String achievementFirstWin = 'first_win';
  static const String achievementSpeedDemon = 'speed_demon';
  static const String achievementPerfectionist = 'perfectionist';

  // ============ UI Constants ============
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // ============ Animation Durations ============
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ============ Code Editor Settings ============
  static const double codeFontSizeMin = 10.0;
  static const double codeFontSizeDefault = 14.0;
  static const double codeFontSizeMax = 24.0;
  static const double codeFontSizeStep = 2.0;

  static const String codeEditorHint = 
      'Write your code here...\n\nPaste is disabled to encourage original coding.';

  // ============ Preferences Keys ============
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyFontSize = 'code_font_size';
  static const String prefKeyPasteEnabled = 'paste_enabled';
  static const String prefKeyNotifications = 'notifications_enabled';
  static const String prefKeyFirstLaunch = 'first_launch';
  static const String prefKeyUserId = 'user_id';
  static const String prefKeyUsername = 'username';
}
