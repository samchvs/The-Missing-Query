import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutTab extends StatefulWidget {
  const AboutTab({super.key});

  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  int _currentPage = 0;

  final List<List<String>> _teamPages = [
    [AppAssets.manalo, AppAssets.agmata, AppAssets.ramos],
    [AppAssets.galang, AppAssets.caranto, AppAssets.chaves],
  ];

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
      debugPrint('Could not launch $url');
    }
  } 

  void _nextPage() {
    if (_currentPage < _teamPages.length - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double headerWidth = 180.0;
    final double cardWidth = (screenWidth * 0.15).clamp(80.0, 115.0);

    return Align(
      alignment: const Alignment(0, 0.4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: headerWidth + 80,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  AppAssets.meetTeam,
                  width: headerWidth,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  left: 0,
                  child: Opacity(
                    opacity: _currentPage == 0 ? 0.3 : 1.0,
                    child: BouncingButton(
                      onPressed: _prevPage,
                      child: Image.asset(AppAssets.arrowLeftBtn, width: 25),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Opacity(
                    opacity: _currentPage == _teamPages.length - 1 ? 0.3 : 1.0,
                    child: BouncingButton(
                      onPressed: _nextPage,
                      child: Image.asset(AppAssets.arrowRightBtn, width: 25),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Row(
              key: ValueKey<int>(_currentPage),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTeamMember(0, cardWidth),
                const SizedBox(width: 8),
                _buildTeamMember(1, cardWidth),
                const SizedBox(width: 8),
                _buildTeamMember(2, cardWidth),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(int index, double cardWidth) {
    final String assetPath = _teamPages[_currentPage][index];

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
