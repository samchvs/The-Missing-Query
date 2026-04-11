class CharacterModel {
  final String path;
  final double height;
  final double top;
  final String name;
  final double badgeLeft;
  final double badgeTop;
  final double badgeWidth;

  const CharacterModel({
    required this.path,
    required this.height,
    required this.top,
    required this.name,
    required this.badgeLeft,
    required this.badgeTop,
    required this.badgeWidth,
  });

  static const List<CharacterModel> all = [
    CharacterModel(
      path: 'assets/Beanie.png',
      height: 90.0,
      top: 90.0,
      name: 'Beanie',
      badgeLeft: 8.0,
      badgeTop: -0.20,
      badgeWidth: 70.0,
    ),
    CharacterModel(
      path: 'assets/Carrotino.png',
      height: 75.0,
      top: 95.0,
      name: 'Carrotino',
      badgeLeft: 20.0,
      badgeTop: 5.0,
      badgeWidth: 33.0,
    ),
    CharacterModel(
      path: 'assets/Broccoliandro.png',
      height: 75.0,
      top: 95.0,
      name: 'Broccoliandro',
      badgeLeft: 20.0,
      badgeTop: 7.0,
      badgeWidth: 45.0,
    ),
    CharacterModel(
      path: 'assets/Tomathomas.png',
      height: 75.0,
      top: 95.0,
      name: 'Tomathomas',
      badgeLeft: 12.0,
      badgeTop: 6.0,
      badgeWidth: 55.0,
    ),
  ];
}

/// Per-character display config used in the HomeScreen user display badge.
class CharacterDisplayConfig {
  final String path;
  final double width;

  const CharacterDisplayConfig({required this.path, required this.width});

  static const List<CharacterDisplayConfig> homeConfigs = [
    CharacterDisplayConfig(path: 'assets/Beanie.png', width: 62.0),
    CharacterDisplayConfig(path: 'assets/Carrotino.png', width: 30.0),
    CharacterDisplayConfig(path: 'assets/Broccoliandro.png', width: 43.0),
    CharacterDisplayConfig(path: 'assets/Tomathomas.png', width: 52.0),
  ];
}
