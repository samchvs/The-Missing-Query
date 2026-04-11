class AppStrings {
  AppStrings._();

  // Auth
  static const String usernameLabel = 'Username:';
  static const String passwordLabel = 'Password:';
  static const String welcomePrefix = 'WELCOME, ';
  static const String loginValidationError =
      'Please enter a valid username and password';
  static const String passwordMinLength = 'Minimum 8 characters required';
  static const String passwordSymbolRequired = 'Requires a symbol or number';

  // Home
  static const String moreTabsSoon = 'More tabs coming soon!';

  // Settings tabs
  static const String profileTab = 'PROFILE';
  static const String audioTab = 'AUDIO';
  static const String leaderboardTab = 'LEADERBOARD';
  static const String aboutTab = 'ABOUT';

  // Tutorial Screen 1
  static const String tutorialGreeting = 'HEY THERE, DETECTIVE!';
  static const String tutorialIntro =
      'Welcome to your first investigation.\n'
      'A case has just come in, and we need your help to solve it.\n'
      "Don't worry! you won't be doing this alone.......";

  // Tutorial Screen 4 (folder screen)
  static const String tutorial4CaseIntro =
      'Select the CASE OF BEANIE: THE STOLEN PASS.\n\n'
      'Oh noooo, that\'s my case! Let\'s investigate and find the culprit. '
      'Please help me find out who did it.';

  // Tutorial Case Screen
  static const String caseDescriptionTitle = 'Case Description';
  static const String caseDescriptionBody =
      'Beanie\u2019s VIP meal card was stolen just before lunch.\n'
      'Several students were seen in the hallway at the same time, each with their own story.\n'
      'Beanie needs to figure out who had the opportunity and motive to use the card.';
  static const String clickNext = 'NEXT';
  static const String clickNextPrefix = 'click ';

  // Tutorial Case 3
  static const String targetQuery = 'SELECT * FROM Hallway_Logs;';
}
