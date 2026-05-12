import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/app_animations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutTab extends StatefulWidget {
  const AboutTab({super.key});

  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  int _currentPage = 0;
  final int _totalPages = 4;

  final List<List<String>> _teamPages = [
    [AppAssets.chaves, AppAssets.caranto, AppAssets.galang],
    [AppAssets.manalo, AppAssets.agmata, AppAssets.ramos],
  ];

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
      debugPrint('Could not launch $url');
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double headerWidth = 180.0;
    final double cardWidth = (screenWidth * 0.15).clamp(80.0, 115.0);

    final String headerAsset;
    if (_currentPage == 0) {
      headerAsset = AppAssets.aboutGame;
    } else if (_currentPage == 1) {
      headerAsset = AppAssets.heyTitle;
    } else {
      headerAsset = AppAssets.meetTeam;
    }

    return Stack(
      children: [
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: _currentPage == 0 ? 0.3 : 1.0,
                child: BouncingButton(
                  onPressed: _prevPage,
                  child: Image.asset(AppAssets.arrowLeftBtn, width: 25),
                ),
              ),
              const SizedBox(width: 10),
              Image.asset(headerAsset, width: headerWidth, fit: BoxFit.contain),
              const SizedBox(width: 10),
              Opacity(
                opacity: _currentPage == _totalPages - 1 ? 0.3 : 1.0,
                child: BouncingButton(
                  onPressed: _nextPage,
                  child: Image.asset(AppAssets.arrowRightBtn, width: 25),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 85,
          left: 25,
          right: 25,
          height: 220,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Align(
              key: ValueKey<int>(_currentPage),
              alignment: Alignment.topCenter,
              child: _buildContentForPage(_currentPage, cardWidth),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentForPage(int index, double cardWidth) {
    if (index == 0) {
      return _buildAboutGameContent();
    } else if (index == 1) {
      return _buildHeyTitleContent();
    } else {
      return _buildTeamGrid(index - 2, cardWidth);
    }
  }

  Widget _buildAboutGameContent() {
    return Row(
      key: const ValueKey<int>(0),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Image.asset(AppAssets.titleGame, width: 180, fit: BoxFit.contain),
            const SizedBox(height: 5),
            const Text(
              'CAN YOU SOLVE THE CASE?',
              style: TextStyle(
                color: Color(0xFF4E342E),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        const SizedBox(
          width: 280,
          child: Text(
            'This game is an interactive investigation experience where players take on the role of a digital detective.\n\n'
            'Solve cases by analyzing clues, running SQL queries, and connecting pieces of evidence to uncover the truth.\n\n'
            'Every decision matters. Every query reveals something new.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: Color(0xFF542E2E),
              fontFamily: 'Londrina Solid',
              fontWeight: FontWeight.w300,
              fontSize: 14,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeyTitleContent() {
    return Row(
      key: const ValueKey<int>(1),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Left: Description Text
        const SizedBox(
          width: 330,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '   We are Beanie, Carrotino, Tomathomas, and Broccoliandro—a group of curious (and slightly suspicious 👀) companions who love solving mysteries together.',
                style: TextStyle(
                  color: Color(0xFF542E2E),
                  fontFamily: 'Londrina Solid',
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 15),
              Text(
                '   We may look like ordinary vegetables, but each of us has a unique personality, skill, and story to tell. Join us as we explore clues, uncover secrets, and solve cases one mystery at a time. We are your partners in investigation—and we’ll be with you every step of the way.',
                style: TextStyle(
                  color: Color(0xFF542E2E),
                  fontFamily: 'Londrina Solid',
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Right: Character Cards Grid 
        SizedBox(
          width: 140,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCharacterCard(
                    'BEANIE',
                    Transform.scale(
                      scale: 1.4,
                      child: AppAnimations.helloBeanie(height: 45),
                    ),
                    const Color(0xFF00ACC1),
                  ),
                  const SizedBox(width: 6),
                  _buildCharacterCard(
                    'TOMATHOMAS',
                    Transform.scale(
                      scale: 1.4,
                      child: AppAnimations.dancingTomathomas(height: 45),
                    ),
                    const Color(0xFFD32F2F),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCharacterCard(
                    'CARROTINO',
                    Transform.scale(
                      scale: 1.4,
                      child: AppAnimations.wavingCarrotino(height: 45),
                    ),
                    const Color(0xFFF1790B),
                  ),
                  const SizedBox(width: 6),
                  _buildCharacterCard(
                    'BROCCOLIANDRO',
                    Transform.translate(
                      offset: const Offset(0, 5),
                      child: Transform.scale(
                        scale: 1.4,
                        child: AppAnimations.dancingBroccoliandro(height: 45),
                      ),
                    ),
                    const Color(0xFF43A047),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterCard(String name, Widget animation, Color themeColor) {
    return Container(
      width: 65,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        border: Border.all(color: const Color(0xFFFBC02D), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: const EdgeInsets.all(4.0), child: animation),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamGrid(int teamPageIndex, double cardWidth) {
    return Row(
      key: ValueKey<int>(teamPageIndex + 2),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTeamMember(teamPageIndex, 0, cardWidth),
        const SizedBox(width: 8),
        _buildTeamMember(teamPageIndex, 1, cardWidth),
        const SizedBox(width: 8),
        _buildTeamMember(teamPageIndex, 2, cardWidth),
      ],
    );
  }

  Widget _buildTeamMember(int pageIndex, int memberIndex, double cardWidth) {
    final String assetPath = _teamPages[pageIndex][memberIndex];
    return BouncingButton(
      onPressed: () {
        if (assetPath == AppAssets.manalo) {
          _launchURL('https://www.linkedin.com/in/pmmanalo/');
        } else if (assetPath == AppAssets.agmata) {
          _launchURL(
            'https://www.linkedin.com/in/christal-kaye-agmata-282b24373/',
          );
        } else if (assetPath == AppAssets.ramos) {
          _launchURL('https://www.linkedin.com/in/gelo-ramos/');
        } else if (assetPath == AppAssets.galang) {
          _launchURL(
            'https://www.linkedin.com/in/janelle-carla-galang-b31548346/',
          );
        } else if (assetPath == AppAssets.caranto) {
          _launchURL('https://www.linkedin.com/in/rgee-caranto-379262364/');
        } else if (assetPath == AppAssets.chaves) {
          _launchURL('https://www.linkedin.com/in/samantha-chaves-638748333/');
        }
      },
      child: Image.asset(assetPath, width: cardWidth, fit: BoxFit.contain),
    );
  }
}
