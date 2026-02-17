import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:game_poker/data/model/user.dart';
import 'package:game_poker/data/services/data_manager.dart';
import 'package:game_poker/presentation/pages/auth/login_page.dart';
import 'package:game_poker/route.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/constants/game_constants.dart';
import '../../../extract_widgets/section_title.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage>
    with TickerProviderStateMixin {
  final DataManager dataManger = DataManager();
  late final PageController _gameController;
  late final PageController _tournamentController;
  late final AnimationController _glowController;
  late final AnimationController _pulseController;

  int _currentTournamentPage = 0;
  int _currentGamePage = 0;

  @override
  void initState() {
    super.initState();
    _gameController = PageController();
    _tournamentController = PageController();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gameController.dispose();
    _tournamentController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = dataManger.currentUser;

    if (user == null) {
      return const LoginPage();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        // appBar: _buildNeonAppBar(user),
        body: Stack(
          children: [
            // Background Image
            Image.asset(
              'assets/GameBDG.jpeg',
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),
            // Light Dark Overlay for readability
            Container(
              color: Colors.black.withOpacity(0.3),
              width: double.infinity,
              height: double.infinity,
            ),
            // Main Content
            _buildMainContent(context),
          ],
        ),
      ),
    );
  }

  // PreferredSizeWidget _buildNeonAppBar(User user) {
  //   return AppBar(
  //     backgroundColor: Colors.transparent,
  //     elevation: 0,
  //     leading: Padding(
  //       padding: const EdgeInsets.only(left: 16),
  //       child: AnimatedBuilder(
  //         animation: _glowController,
  //         builder: (context, child) {
  //           return Container(
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.teal.withOpacity(
  //                     0.3 + _glowController.value * 0.2,
  //                   ),
  //                   blurRadius: 12 + _glowController.value * 8,
  //                   spreadRadius: 2,
  //                 ),
  //               ],
  //             ),
  //             child: CircleAvatar(
  //               radius: 22,
  //               backgroundImage: NetworkImage(
  //                 user.profile ??
  //                     'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&h=400&fit=crop',
  //               ),
  //               onBackgroundImageError: (_, __) => const Icon(Icons.person),
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //     title: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           user.name,
  //           style: const TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w700,
  //             color: Colors.white,
  //             letterSpacing: 0.5,
  //           ),
  //         ),
  //         const SizedBox(height: 2),
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //               decoration: BoxDecoration(
  //                 color: Colors.green.shade900.withOpacity(0.3),
  //                 borderRadius: BorderRadius.circular(4),
  //                 border: Border.all(
  //                   color: Colors.green.shade400.withOpacity(0.3),
  //                 ),
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   const Icon(
  //                     Icons.monetization_on_rounded,
  //                     size: 14,
  //                     color: Color(0xFF4CAF50),
  //                   ),
  //                   const SizedBox(width: 4),
  //                   Text(
  //                     '\$${user.balance.toInt()}',
  //                     style: TextStyle(
  //                       fontSize: 15,
  //                       color: Colors.green.shade400,
  //                       fontWeight: FontWeight.bold,
  //                       letterSpacing: 0.5,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //     actions: [
  //       Container(
  //         margin: const EdgeInsets.only(right: 20),
  //         decoration: BoxDecoration(
  //           color: Colors.white.withOpacity(0.05),
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(color: Colors.white.withOpacity(0.1)),
  //         ),
  //         child: IconButton(
  //           icon: const Icon(
  //             Icons.notifications_none_rounded,
  //             color: Colors.white,
  //             size: 26,
  //           ),
  //           onPressed: () {},
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildAnimatedBackground() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black,
          Colors.black.withOpacity(0.9),
          const Color(0xFF0A1F1A),
        ],
      ).createShader(bounds),
      blendMode: BlendMode.dstATop,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.2,
            colors: [
              const Color(0xFF1A4C3A).withOpacity(0.15),
              Colors.black,
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.05),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.05),
                      blurRadius: 80,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle( title: 'GAME MODES',),
          const SizedBox(height: 5),
          _buildGameCarousel(),
          const SizedBox(height: 5),
          _buildGameIndicator(),
          const SizedBox(height: 5),
          SectionTitle(title: "Profile"),
          const SizedBox(height: 5),
          _buildProfile(),
        ],
      ),
    );
  }
  Widget _buildProfile(){
    final user = dataManger.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Main Profile Card
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.tealAccent.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.1),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      // Left: Avatar Section
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.tealAccent.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          backgroundImage: NetworkImage(GameConstants.profileImage),
                          onBackgroundImageError: (_, __) {},
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Middle: User Info and Stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Player Name
                            Text(
                              "Daddy",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),

                            // Email
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.6),
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),

                            // Stats Row - Compact
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMiniStatCard(
                                    icon: Icons.monetization_on_rounded,
                                    value: '\$${user.balance.toStringAsFixed(0)}',
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _buildMiniStatCard(
                                    icon: Icons.trending_up_rounded,
                                    value: 'L${user.level}',
                                    color: Colors.amberAccent,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _buildMiniStatCard(
                                    icon: Icons.sports_score_rounded,
                                    value: '${user.wins}W',
                                    color: Colors.tealAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Right: Edit Button
                      Container(
                        height: 84,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.tealAccent.withOpacity(0.7),
                              Colors.teal.withOpacity(0.5),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navigate to profile details
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'EDIT',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.6,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 0.6,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildGameCarousel() {
    return SizedBox(
      height: 150,

      child: PageView(
        controller: _gameController,
        onPageChanged: (index) => setState(() => _currentGamePage = index),
        children: [
          _buildGameCard(
            onTap: () {
              _showGameBuyInDialog('1v1 SHOWDOWN');
            },
            title: '1v1 SHOWDOWN',
            subtitle: 'HEAD TO HEAD',
            prize: '\$500 PRIZE',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8B0000), Color(0xFF330000)],
            ),
            icon: Icons.sports_kabaddi_rounded,
            imageUrl:
                'https://imgs.search.brave.com/N3Ik8svV5nK70wGvm8R_42oz9i2_6QO-zE3fLrTNnyw/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wNDYv/Mjg4LzM1My9zbWFs/bC9hLWNsb3NlLXVw/LW9mLWEtcGlsZS1v/Zi1wb2tlci1jaGlw/cy1vbi1hLXRhYmxl/LWJhbm5lci1waG90/by5qcGVn',
          ),
          _buildGameCard(
            onTap: () {
              Navigator.pushNamed(context, GameRoute.texas);
            },
            title: '9-MAX TABLE',
            subtitle: 'MULTIPLAYER',
            prize: '\$1,200 PRIZE',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00695C), Color(0xFF003D33)],
            ),
            icon: Icons.people_rounded,
            imageUrl:
                'https://imgs.search.brave.com/l6r_d8IkGVvDwPfAnQFslL9HXgGCeoGpp1_rSmSXA9E/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzLzg0L2Zl/Lzc3Lzg0ZmU3NzA5/ODg3ZTMyZDIyMmZl/NGMyYWU1MzM2MDky/LmpwZw',
          ),
          _buildGameCard(
            onTap: () {
              Navigator.pushNamed(context, GameRoute.texas);
            },
            title: 'TOURNAMENT',
            subtitle: 'MULTIPLAYER',
            prize: '\$1,200 PRIZE',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00695C), Color(0xFF003D33)],
            ),
            icon: Icons.people_rounded,
            imageUrl:
            'https://imgs.search.brave.com/r8EW2i_pDRnm2_187cPacxaDCbswFlPvWsDxUcPj0Os/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzLzAyL2Y3/L2Q3LzAyZjdkNzFl/NjlkY2Q2YmY5ZDU4/YjdiMGRiM2Y2ZTUz/LmpwZw',
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String subtitle,
    required String prize,
    required LinearGradient gradient,
    required IconData icon,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade900.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.green.shade400.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                prize,
                                style: TextStyle(
                                  color: Colors.green.shade300,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(
                                    0.3 + _pulseController.value * 0.2,
                                  ),
                                  blurRadius: 15 + _pulseController.value * 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                gradient: const RadialGradient(
                                  colors: [Colors.white, Color(0xFFE0E0E0)],
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.black,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameIndicator() {
    return Center(
      child: SmoothPageIndicator(
        controller: _gameController,
        count: 3,
        effect: ExpandingDotsEffect(
          expansionFactor: 2.5,
          spacing: 8,
          dotHeight: 6,
          dotWidth: 6,
          radius: 20,
          dotColor: Colors.grey.shade800,
          activeDotColor: Colors.tealAccent,
        ),
      ),
    );
  }

  Widget _buildTournamentCarousel() {
    final tournaments = [
      {
        'name': 'TEXAS HOLD\'EM',
        'entry': 'FREE',
        'prize': '\$2,000',
        'players': '128',
        'time': 'STARTING SOON',
        'blinds': '5/10 → 100/200',
        'image':
            'https://imgs.search.brave.com/r8EW2i_pDRnm2_187cPacxaDCbswFlPvWsDxUcPj0Os/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzLzAyL2Y3/L2Q3LzAyZjdkNzFl/NjlkY2Q2YmY5ZDU4/YjdiMGRiM2Y2ZTUz/LmpwZw',
      },
      {
        'name': 'OMAH',
        'entry': '\$50',
        'prize': '\$5,000',
        'players': '256',
        'time': 'IN 15 MIN',
        'blinds': '25/50 → 500/1000',
        'image':
            'https://imgs.search.brave.com/sux3-2nXUQkItrcaSXOQi5YyU6ibANSiiIhMp-NshFY/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMzAv/ODA2Lzc0MS9zbWFs/bC8zZC1pbGx1c3Ry/YXRpb24tb2YtY2Fz/aW5vLWNoaXBzLWFu/ZC1jYXJkcy1vdmVy/LWJsYWNrLWJhY2tn/cm91bmQtd2l0aC1i/b2tlaC1lZmZlY3Qt/Y2FzaW5vLWdhbWUt/cG9rZXItY2FyZC1w/bGF5aW5nLWdhbWJs/aW5nLWNoaXBzLWJs/YWNrLWFuZC1nb2xk/LXN0eWxlLWJhbm5l/ci1iYWNrZHJvcC1i/YWNrZ3JvdW5kLWNv/bmNlcHQtYWktZ2Vu/ZXJhdGVkLWZyZWUt/cGhvdG8uanBn',
      },
      {
        'name': 'DEEP STACK',
        'entry': 'FREE',
        'prize': '\$10,000',
        'players': '512',
        'time': '1 HOUR',
        'blinds': '10/20 → 200/400',
        'image':
            'https://imgs.search.brave.com/T-UdSAy4s0auSHppdHQm7sdcUG9I3cWQ_PgUDIRhChI/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMzQv/MjM4LzA1OS9zbWFs/bC9wb2tlci1iYW5u/ZXItdGVtcGxhdGUt/bGF5b3V0LW1vY2t1/cC1mb3Itb25saW5l/LWNhc2luby1ncmVl/bi10YWJsZS10b3At/dmlldy1vbi13b3Jr/cGxhY2UtcGhvdG8u/anBn',
      },
      {
        'name': 'TURBO',
        'entry': '\$100',
        'prize': '\$15,000',
        'players': '300',
        'time': '30 MIN',
        'blinds': '100/200 → 2000/4000',
        'image':
            'https://imgs.search.brave.com/McayXJPEw-cSOsTb2AuJlv-C21QWX9QWz8F6hZrXkn0/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wNDYv/ODM3LzI0My9zbWFs/bC9oaWdoLXN0YWtl/cy1wb2tlci1nYW1l/LXNldHVwLXdpdGgt/cGxheWluZy1jYXJk/cy1jaGlwcy1hbmQt/ZGljZS1pbi1hbi1l/bGVnYW50LWNhc2lu/by1pbnRlcmlvci1w/aG90by5qcGc',
      },
      {
        'name': 'SUNDAY SPECIAL',
        'entry': 'FREE',
        'prize': '\$25,000',
        'players': '1000',
        'time': '2 HOURS',
        'blinds': '50/100 → 1000/2000',
        'image':
            'https://imgs.search.brave.com/XDq2kD3_wdjgVR0N542RkFca11R8ZeYQA9BPnTFdszE/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/cHJlbWl1bS1waG90/by9wb2tlci1jaGlw/cy1idWxsZXRzLWxp/ZS1wb2tlci10YWJs/ZV85NTk4MDAtMTcz/MS5qcGc_c2VtdD1h/aXNfaHlicmlkJnc9/NzQw',
      },
    ];

    return SizedBox(
      height: 260,
      child: PageView.builder(
        controller: _tournamentController,
        onPageChanged: (index) =>
            setState(() => _currentTournamentPage = index),
        itemCount: tournaments.length,
        itemBuilder: (context, index) {
          final tournament = tournaments[index];
          return _buildTournamentCard(
            name: tournament['name']!,
            entry: tournament['entry']!,
            prize: tournament['prize']!,
            players: tournament['players']!,
            time: tournament['time']!,
            blinds: tournament['blinds']!,
            imageUrl: tournament['image']!,
          );
        },
      ),
    );
  }

  Widget _buildTournamentCard({
    required String name,
    required String entry,
    required String prize,
    required String players,
    required String time,
    required String blinds,
    required String imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.teal.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      const Color(0xFF0A2A1F).withOpacity(0.95),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade900.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.amber.shade600.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            color: Colors.amber.shade400,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            time,
                            style: TextStyle(
                              color: Colors.amber.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTournamentChip(
                          icon: Icons.people_rounded,
                          label: '$players players',
                        ),
                        const SizedBox(width: 12),
                        _buildTournamentChip(
                          icon: Icons.sports_esports_rounded,
                          label: entry,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTournamentChip(
                      icon: Icons.trending_up_rounded,
                      label: blinds,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRIZE POOL',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              prize,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00897B), Color(0xFF004D40)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Text(
                            'REGISTER',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentIndicator() {
    return SmoothPageIndicator(
      controller: _tournamentController,
      count: 5,
      effect: ScrollingDotsEffect(
        spacing: 8,
        dotHeight: 6,
        dotWidth: 6,
        radius: 20,
        dotColor: Colors.grey.shade800,
        activeDotColor: Colors.tealAccent,
      ),
    );
  }

  Widget _buildLeaderboard() {
    return Container(
      height: 500,
      margin: const EdgeInsets.only(bottom: 32),
      child: FutureBuilder<List<User>>(
        future: DataManager().getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final players = snapshot.data ?? [];
          if (players.isEmpty) {
            return _buildEmptyState();
          }

          players.sort((a, b) => b.balance.compareTo(a.balance));
          final topPlayers = players.take(20).toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: topPlayers.length,
            itemBuilder: (context, index) {
              final player = topPlayers[index];
              final rank = index + 1;
              final isCurrentUser =
                  player.email == DataManager().currentUser?.email;

              return _buildLeaderboardItem(
                player: player,
                rank: rank,
                isCurrentUser: isCurrentUser,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required User player,
    required int rank,
    required bool isCurrentUser,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isCurrentUser
              ? [Colors.teal.withOpacity(0.15), Colors.teal.withOpacity(0.05)]
              : [
                  Colors.white.withOpacity(0.03),
                  Colors.white.withOpacity(0.01),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? Colors.tealAccent.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          width: isCurrentUser ? 1.2 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Rank with special styling for top 3
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rank <= 3
                    ? _getRankColor(rank).withOpacity(0.15)
                    : Colors.transparent,
                border: rank <= 3
                    ? Border.all(
                        color: _getRankColor(rank).withOpacity(0.5),
                        width: 1,
                      )
                    : null,
              ),
              child: Center(
                child: rank <= 3
                    ? Icon(
                        Icons.star_rounded,
                        color: _getRankColor(rank),
                        size: 20,
                      )
                    : Text(
                        '#$rank',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Avatar with glow effect for top ranks
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: rank <= 2
                    ? [
                        BoxShadow(
                          color: _getRankColor(rank).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.05),
                backgroundImage: player.profile != null
                    ? NetworkImage(player.profile!)
                    : null,
                child: player.profile == null
                    ? Icon(
                        Icons.person_rounded,
                        color: Colors.white.withOpacity(0.3),
                        size: 28,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        player.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isCurrentUser
                              ? Colors.tealAccent
                              : Colors.white,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.tealAccent.withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            'YOU',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.tealAccent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${player.level}  •  ${player.wins} wins',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      size: 16,
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${player.balance.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.casino_rounded,
                      size: 14,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      player.chips.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white;
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.redAccent.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load leaderboard',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No players yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showGameBuyInDialog(String gameName) {
    final user = dataManger.currentUser;
    if (user == null) return;

    String selectedAmount = '500';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(32),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.attach_money_rounded,
                    color: Colors.blue.shade700,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'SELECT YOUR BUY-IN',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Available Balance: \$${user.balance.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                // Display selected amount
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Selected Amount',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${selectedAmount}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Quick amount buttons
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildGameAmountButton(
                            500,
                            user,
                            selectedAmount,
                            (amount) {
                              setState(() {
                                selectedAmount = amount.toStringAsFixed(0);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGameAmountButton(
                            1000,
                            user,
                            selectedAmount,
                            (amount) {
                              setState(() {
                                selectedAmount = amount.toStringAsFixed(0);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGameAmountButton(
                            5000,
                            user,
                            selectedAmount,
                            (amount) {
                              setState(() {
                                selectedAmount = amount.toStringAsFixed(0);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGameAmountButton(
                            10000,
                            user,
                            selectedAmount,
                            (amount) {
                              setState(() {
                                selectedAmount = amount.toStringAsFixed(0);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Divider
                Container(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 24),
                // Custom amount input
                const Text(
                  'OR ENTER CUSTOM AMOUNT',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '\$',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                selectedAmount = value;
                              });
                            }
                          },
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: selectedAmount,
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                          controller: TextEditingController(text: selectedAmount),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Pass the selected amount to the game
                        Navigator.pushNamed(
                          context,
                          GameRoute.gameOneVSOne,
                          arguments: selectedAmount,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CONTINUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameAmountButton(
    double amount,
    User user,
    String selectedAmount,
    Function(double) onAmountSelected,
  ) {
    final isAffordable = amount <= user.balance;
    final isSelected = selectedAmount == amount.toStringAsFixed(0);

    return GestureDetector(
      onTap: isAffordable
          ? () {
              onAmountSelected(amount);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.shade700
              : (isAffordable ? Colors.blue.shade100 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.blue.shade900
                : (isAffordable ? Colors.blue.shade300 : Colors.grey.shade400),
            width: 1.5,
          ),
        ),
        child: Text(
          '\$${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isAffordable ? Colors.blue.shade700 : Colors.grey.shade600),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
