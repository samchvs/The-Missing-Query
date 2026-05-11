import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_colors.dart';
import 'package:graphics_project/domain/entities/leaderboard_entry.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';

class LeaderboardTab extends StatefulWidget {
  final AuthController authController;

  const LeaderboardTab({super.key, required this.authController});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  @override
  void initState() {
    super.initState();
    widget.authController.leaderboard.fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalH = constraints.maxHeight;
        final totalW = constraints.maxWidth;

        const topPadding = 35.0; // ← increase/decrease this to move content down
        final availableH = totalH - topPadding;

        // Reserve a fixed strip for the column header + refresh button
        const headerH = 34.0;
        const gap = 8.0;
        const refreshAreaH = 24.0; 
        
        final listH = availableH - headerH - gap - refreshAreaH;

        // Row height distributes evenly over slots (restored to smaller size)
        final rowH = (listH / 9).clamp(28.0, 40.0);

        // Proportional column widths
        final rankW  = totalW * 0.18;
        final scoreW  = totalW * 0.18;

        final labelStyle = TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          fontFamily: 'Londrina Solid',
          letterSpacing: 0.5,
        );

        return ListenableBuilder(
          listenable: widget.authController.leaderboard,
          builder: (context, _) {
            final lb = widget.authController.leaderboard;

            return Padding(
              padding: const EdgeInsets.only(top: topPadding, bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // ── Refresh Button (Top Right) ─────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 4),
                    child: BouncingButton(
                      onPressed: () {
                        if (!lb.isLoading) {
                          widget.authController.leaderboard.forceRefresh();
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Refresh ',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 164, 9, 230),
                              fontFamily: 'Londrina Solid',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.refresh_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Column header ────────────────────────────────
                Container(
                  height: headerH,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E5),
                    border: Border.all(color: AppColors.primary, width: 2.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: rankW,
                        child: Center(
                          child: Text('RANK', style: labelStyle),
                        ),
                      ),
                      Expanded(
                        child: Text('USER', style: labelStyle),
                      ),
                      SizedBox(
                        width: scoreW,
                        child: Text(
                          'SCORE',
                          style: labelStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: gap),

                // ── List body ────────────────────────────────────
                Expanded(
                  child: lb.isLoading
                      ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : lb.error != null
                          ? Center(
                              child: Text(
                                lb.error!,
                                style: TextStyle(
                                  color: AppColors.redAccent,
                                  fontSize: 11,
                                ),
                              ),
                            )
                          : lb.entries.isEmpty
                              ? Center(
                                  child: Text(
                                    'No scores yet — be the first!',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: lb.entries.length,
                                  itemBuilder: (context, index) {
                                    return _LeaderboardRow(
                                      rank: index + 1,
                                      entry: lb.entries[index],
                                      isCurrentUser: lb.entries[index].idFk ==
                                          widget.authController.currentUser?.id,
                                      rowHeight: rowH,
                                      rankWidth: rankW,
                                      scoreWidth: scoreW,
                                    );
                                  },
                                ),
                ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single leaderboard row — all sizing is driven by parent constraints
// ─────────────────────────────────────────────────────────────────────────────

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final bool isCurrentUser;
  final double rowHeight;
  final double rankWidth;
  final double scoreWidth;

  const _LeaderboardRow({
    required this.rank,
    required this.entry,
    required this.isCurrentUser,
    required this.rowHeight,
    required this.rankWidth,
    required this.scoreWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Font size proportional to row height
    final fontSize = (rowHeight * 0.55).clamp(14.0, 22.0);

    // Row background colors from mockup
    // Row background colors: Blue for current user, alternating Green/Red for others
    final Color rowBg = isCurrentUser 
        ? const Color(0xFF90CAF9) // More vibrant Blue highlight
        : (rank % 2 == 1 
            ? const Color(0xFFC5E1A5) // More vibrant Light Green
            : const Color(0xFFFFCDD2)); // More vibrant Light Red

    final Color rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFA8A8A8)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : AppColors.primary;

    return Container(
      height: rowHeight,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: rankWidth,
            child: Center(
              child: rank <= 3
                  ? Stack(
                      children: [
                        // Shadow/Outline effect for top 3 ranks
                        Text(
                          '#$rank',
                          style: TextStyle(
                            fontFamily: 'Londrina Solid',
                            fontSize: fontSize + 4,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3
                              ..color = AppColors.primary,
                          ),
                        ),
                        Text(
                          '#$rank',
                          style: TextStyle(
                            fontFamily: 'Londrina Solid',
                            color: rankColor,
                            fontSize: fontSize + 4,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '#$rank',
                      style: TextStyle(
                        fontFamily: 'Londrina Solid',
                        color: AppColors.primary,
                        fontSize: fontSize + 2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 8),

          // Username
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                entry.username,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Londrina Solid',
                  color: AppColors.primary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          // Score
          SizedBox(
            width: scoreWidth,
            child: Center(
              child: Text(
                '${entry.highScore}',
                style: TextStyle(
                  fontFamily: 'Londrina Solid',
                  color: AppColors.primary,
                  fontSize: fontSize + 2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
