import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/core/constants/app_colors.dart';
import 'package:graphics_project/data/models/character_model.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';

class ProfileTab extends StatefulWidget {
  final String username;
  final String characterPath;
  final AuthController authController;
  final Function(String) onUsernameChanged;
  final Function(String) onCharacterChanged;

  const ProfileTab({
    super.key,
    required this.username,
    required this.characterPath,
    required this.authController,
    required this.onUsernameChanged,
    required this.onCharacterChanged,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late String _localUsername;
  late String _localCharacter;

  @override
  void initState() {
    super.initState();
    _localUsername = widget.username;
    _localCharacter = widget.characterPath;
    // Ensure leaderboard data is loaded to show the rank
    widget.authController.leaderboard.fetchLeaderboard();
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.username != oldWidget.username) {
      _localUsername = widget.username;
    }
    if (widget.characterPath != oldWidget.characterPath) {
      _localCharacter = widget.characterPath;
    }
  }

  Future<void> _showEditModal(BuildContext context) async {
    final TextEditingController modalController =
        TextEditingController(text: _localUsername);

    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      useSafeArea: false,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(AppAssets.usernameModal, width: 450, fit: BoxFit.contain),
                    Positioned(
                      top: 48,
                      left: 180,
                      right: 50,
                      child: Material(
                        color: Colors.transparent,
                        child: TextField(
                          controller: modalController,
                          autofocus: true,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 70,
                      child: BouncingButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Image.asset(AppAssets.cancelBtn, width: 140, fit: BoxFit.contain),
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      right: 70,
                      child: BouncingButton(
                        onPressed: () async {
                          if (modalController.text.trim().isNotEmpty) {
                            final newName = modalController.text.trim();
                            setState(() => _localUsername = newName);
                            widget.onUsernameChanged(newName);
                            await widget.authController.updateUsername(newName);
                            if (context.mounted) Navigator.of(context).pop();
                          }
                        },
                        child: Image.asset(AppAssets.confirmBtn, width: 140, fit: BoxFit.contain),
                      ),
                    ),
                  ],
                ),
              ),
              KeyboardAccessoryBar(
                controller: modalController,
                textStyle: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCharacterModal(BuildContext context) async {
    int currentIndex = 0;

    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      useSafeArea: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final CharacterModel character = CharacterModel.all[currentIndex];
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: false,
                body: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(AppAssets.characterModal, width: 300, fit: BoxFit.contain),
                          Positioned(
                            top: character.top,
                            child: Image.asset(
                              character.path,
                              height: character.height,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            top: 190,
                            child: Text(
                              character.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 60,
                            top: 140,
                            child: BouncingButton(
                              onPressed: () {
                                setModalState(() {
                                  currentIndex--;
                                  if (currentIndex < 0) {
                                    currentIndex = CharacterModel.all.length - 1;
                                  }
                                });
                              },
                              child: Image.asset(AppAssets.arrowLeftBtn, width: 30, fit: BoxFit.contain),
                            ),
                          ),
                          Positioned(
                            right: 60,
                            top: 140,
                            child: BouncingButton(
                              onPressed: () {
                                setModalState(() {
                                  currentIndex++;
                                  if (currentIndex >= CharacterModel.all.length) {
                                    currentIndex = 0;
                                  }
                                });
                              },
                              child: Image.asset(AppAssets.arrowRightBtn, width: 30, fit: BoxFit.contain),
                            ),
                          ),
                          Positioned(
                            bottom: 35,
                            left: 40,
                            child: BouncingButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Image.asset(AppAssets.cancelBtn, width: 100, fit: BoxFit.contain),
                            ),
                          ),
                          Positioned(
                            bottom: 35,
                            right: 40,
                            child: BouncingButton(
                              onPressed: () {
                                widget.onCharacterChanged(character.path);
                                Navigator.of(context).pop();
                              },
                              child: Image.asset(AppAssets.confirmBtn, width: 100, fit: BoxFit.contain),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final CharacterModel charData = CharacterModel.all.firstWhere(
      (c) => c.path == _localCharacter,
      orElse: () => CharacterModel.all.first,
    );

    return Align(
      alignment: const Alignment(-0.15, -0.5),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(AppAssets.usernameEdit, width: 320, fit: BoxFit.contain),
          Positioned(
            left: charData.badgeLeft,
            top: charData.badgeTop,
            child: Image.asset(
              _localCharacter,
              width: charData.badgeWidth,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 80,
            left: -100,
            child: Image.asset(AppAssets.rankDisplay, width: 550, fit: BoxFit.contain),
          ),
          ListenableBuilder(
            listenable: widget.authController.leaderboard,
            builder: (context, _) {
              final leaderboard = widget.authController.leaderboard;
              final currentUser = widget.authController.currentUser;
              final entries = leaderboard.entries;
              final userIndex = entries.indexWhere((e) => e.idFk == currentUser?.id);
              
              // If not in top 10, show '?' or leave empty
              final total = leaderboard.totalPlayers;
              final String rankText = userIndex == -1 
                ? 'RANK ? OUT OF $total' 
                : 'RANK ${userIndex + 1} OUT OF $total';

              return Positioned(
                left: 150, // Shifted left to center longer text
                top: 108,
                child: SizedBox(
                  width: 250, // Wider container for longer text
                  child: Text(
                    rankText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 22, // Slightly smaller to fit
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Londrina Solid',
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 100,
            top: 24,
            child: Text(
              _localUsername,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 250,
            top: 11.5,
            child: BouncingButton(
              onPressed: () => _showEditModal(context),
              child: Image.asset(AppAssets.editBtn, width: 100, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            left: 65,
            top: 43,
            child: BouncingButton(
              onPressed: () => _showCharacterModal(context),
              child: Image.asset(AppAssets.pencilBtn, width: 20, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
