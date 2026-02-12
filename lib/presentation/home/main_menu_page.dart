import 'package:flutter/material.dart';
import 'package:game_poker/core/app_size.dart';
import 'package:game_poker/data/model/user.dart';
import 'package:game_poker/data/services/data_manager.dart';
import 'package:game_poker/presentation/pages/auth/login_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final PageController _controller = PageController();
  final PageController _controllerTournament = PageController();
  int _currentPageTournament = 0;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final DataManager dataManger = DataManager();
    final user = dataManger.currentUser;

    if (user == null) {
      return const LoginPage();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _bar(user),
        body: Stack(children: [_bg(), _listBar(context)]),
      ),
    );
  }

  SafeArea _listBar(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            _text("HOLD'EM"),

            _game(context),

            _dot(),

            SizedBox(height: 20),
            _text("TOURNAMENT"),

            _listTournament(),

            SizedBox(height: 20),
            
            SizedBox(
              height: 500,
              child: FutureBuilder<List<User>>(
                future: DataManager().getAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final players = snapshot.data ?? [];

                  return ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final data = players[index];
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          data.name,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _listTournament() {
    return SizedBox(
      height: 220,
      child: PageView(
        children: [
          _tournamentGame(
            image:
                'https://imgs.search.brave.com/r8EW2i_pDRnm2_187cPacxaDCbswFlPvWsDxUcPj0Os/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzLzAyL2Y3/L2Q3LzAyZjdkNzFl/NjlkY2Q2YmY5ZDU4/YjdiMGRiM2Y2ZTUz/LmpwZw',
            text1: "Texas Hold'em Poker",
            text2: "18 Players • Freeroll",
            text3: "Starts in 10 min • Prize up to \$200",
            btn: "REGISTER NOW",
          ),

          _tournamentGame(
            image:
                'https://imgs.search.brave.com/sux3-2nXUQkItrcaSXOQi5YyU6ibANSiiIhMp-NshFY/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMzAv/ODA2Lzc0MS9zbWFs/bC8zZC1pbGx1c3Ry/YXRpb24tb2YtY2Fz/aW5vLWNoaXBzLWFu/ZC1jYXJkcy1vdmVy/LWJsYWNrLWJhY2tn/cm91bmQtd2l0aC1i/b2tlaC1lZmZlY3Qt/Y2FzaW5vLWdhbWUt/cG9rZXItY2FyZC1w/bGF5aW5nLWdhbWJs/aW5nLWNoaXBzLWJs/YWNrLWFuZC1nb2xk/LXN0eWxlLWJhbm5l/ci1iYWNrZHJvcC1i/YWNrZ3JvdW5kLWNv/bmNlcHQtYWktZ2Vu/ZXJhdGVkLWZyZWUt/cGhvdG8uanBn',

            text1: "Texas Hold'em Turbo",
            text2: "20 Players • Daily Tournament",
            text3: "Buy-in: Free • Prize pool up to \$300",
            btn: "JOIN TOURNAMENT",
          ),

          _tournamentGame(
            image:
                'https://imgs.search.brave.com/T-UdSAy4s0auSHppdHQm7sdcUG9I3cWQ_PgUDIRhChI/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wMzQv/MjM4LzA1OS9zbWFs/bC9wb2tlci1iYW5u/ZXItdGVtcGxhdGUt/bGF5b3V0LW1vY2t1/cC1mb3Itb25saW5l/LWNhc2luby1ncmVl/bi10YWJsZS10b3At/dmlldy1vbi13b3Jr/cGxhY2UtcGhvdG8u/anBn',
            text1: "Texas Hold'em Poker",
            text2: "30 Players • Guaranteed Prize",
            text3: "Starts in 25 min • Prize up to \$500",
            btn: "REGISTER",
          ),

          _tournamentGame(
            image:
                'https://imgs.search.brave.com/McayXJPEw-cSOsTb2AuJlv-C21QWX9QWz8F6hZrXkn0/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wNDYv/ODM3LzI0My9zbWFs/bC9oaWdoLXN0YWtl/cy1wb2tlci1nYW1l/LXNldHVwLXdpdGgt/cGxheWluZy1jYXJk/cy1jaGlwcy1hbmQt/ZGljZS1pbi1hbi1l/bGVnYW50LWNhc2lu/by1pbnRlcmlvci1w/aG90by5qcGc',
            text1: "Omaha Poker Tournament",
            text2: "40 Players • Mid-day Event",
            text3: "Buy-in: Free • Prize up to \$800",
            btn: "ENTER NOW",
          ),

          _tournamentGame(
            image:
                'https://imgs.search.brave.com/XDq2kD3_wdjgVR0N542RkFca11R8ZeYQA9BPnTFdszE/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/cHJlbWl1bS1waG90/by9wb2tlci1jaGlw/cy1idWxsZXRzLWxp/ZS1wb2tlci10YWJs/ZV85NTk4MDAtMTcz/MS5qcGc_c2VtdD1h/aXNfaHlicmlkJnc9/NzQw',
            text1: "Texas Hold'em Deepstack",
            text2: "50 Players • Evening Tournament",
            text3: "Late reg open • Prize up to \$1,200",
            btn: "PLAY TOURNAMENT",
          ),
        ],
      ),
    );
  }

  Widget _tournamentGame({
    required String image,
    required String text1,
    required String text2,
    required String text3,
    required String btn,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.45),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "POKER TOURNAMENT",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(text1, style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                text2,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                text2,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    btn,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.chevron_right_sharp,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Align _text(String text) {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: text.split("").map((letter) {
          // random rotation for each letter
          double angle = 0.4 * 0.4; // -0.25 to 0.25 radians
          return Transform.rotate(
            angle: angle,
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  SmoothPageIndicator _dot() {
    return SmoothPageIndicator(
      controller: _controller,
      count: 2,
      effect: ScrollingDotsEffect(
        spacing: 6,
        radius: 8,
        dotHeight: 6,
        dotWidth: 6,
        dotColor: Color(0xFFB2DFDB).withOpacity(0.3),
        activeDotColor: Color(0xFF00796B),
      ),
    );
  }

  Widget _game(BuildContext context) {
    return SizedBox(
      height: 170,
      child: PageView(
        controller: _controller,
        onPageChanged: (int index) {
          setState(() {
            _currentPage = index;
          });
        },

        children: [
          SizedBox(
            width: AppSize.width(context),
            height: 150,
            child: _playGameOne(
              'https://imgs.search.brave.com/N3Ik8svV5nK70wGvm8R_42oz9i2_6QO-zE3fLrTNnyw/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudmVjdGVlenku/Y29tL3N5c3RlbS9y/ZXNvdXJjZXMvdGh1/bWJuYWlscy8wNDYv/Mjg4LzM1My9zbWFs/bC9hLWNsb3NlLXVw/LW9mLWEtcGlsZS1v/Zi1wb2tlci1jaGlw/cy1vbi1hLXRhYmxl/LWJhbm5lci1waG90/by5qcGVn',
              'HEAD TO HEAD BATTLE',
              () {},
            ),
          ),
          SizedBox(
            width: AppSize.width(context),
            height: 150,
            child: _playGameMuti(
              'https://imgs.search.brave.com/l6r_d8IkGVvDwPfAnQFslL9HXgGCeoGpp1_rSmSXA9E/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzLzg0L2Zl/Lzc3Lzg0ZmU3NzA5/ODg3ZTMyZDIyMmZl/NGMyYWU1MzM2MDky/LmpwZw',
              'HEAD TO HEAD BATTLE',
              () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _playGameOne(String image, String text, VoidCallback link) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          image: DecorationImage(
            image: NetworkImage(image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2),
              BlendMode.darken,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.07),
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
              ),

              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            child: Transform.rotate(
                              angle: 0.2, // Rotate 0.1 radians (~5.7 degrees)
                              child: Text(
                                "1",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                  height: 0.9,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 12,
                                      color: Colors.black87,
                                      offset: Offset(3, 3),
                                    ),
                                    Shadow(
                                      blurRadius: 20,
                                      color: Colors.redAccent,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          WidgetSpan(
                            child: Transform.rotate(
                              angle: 0, // Rotate -0.1 radians (~ -5.7 degrees)
                              child: Text(
                                "VS",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                  height: 0.9,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 12,
                                      color: Colors.black87,
                                      offset: Offset(3, 3),
                                    ),
                                    Shadow(
                                      blurRadius: 20,
                                      color: Colors.redAccent,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          WidgetSpan(
                            child: Transform.rotate(
                              angle: 0.2,
                              child: Text(
                                "1  ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                  height: 0.9,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 12,
                                      color: Colors.black87,
                                      offset: Offset(3, 3),
                                    ),
                                    Shadow(
                                      blurRadius: 20,
                                      color: Colors.redAccent,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      text,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.90),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                        shadows: const [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),

                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),

                        child: SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: link,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: BeveledRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "PLAY",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppSize.width(context) * 0.06,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_sharp,
                                  color: Colors.white,
                                  size: AppSize.width(context) * 0.06,
                                ),
                              ],
                            ),
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
      ),
    );
  }

  Widget _playGameMuti(String image, String text, VoidCallback link) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          image: DecorationImage(
            image: NetworkImage(image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2),
              BlendMode.darken,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.07),
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
              ),

              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            child: Transform.rotate(
                              angle: 0.2, // Rotate 0.1 radians (~5.7 degrees)
                              child: Text(
                                "9",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                  height: 0.9,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 12,
                                      color: Colors.black87,
                                      offset: Offset(3, 3),
                                    ),
                                    Shadow(
                                      blurRadius: 20,
                                      color: Colors.redAccent,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          WidgetSpan(
                            child: Transform.rotate(
                              angle: 0, // Rotate -0.1 radians (~ -5.7 degrees)
                              child: Text(
                                "player",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                  height: 0.9,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 12,
                                      color: Colors.black87,
                                      offset: Offset(3, 3),
                                    ),
                                    Shadow(
                                      blurRadius: 20,
                                      color: Colors.redAccent,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      text,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.90),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                        shadows: const [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),

                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),

                        child: SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: link,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: BeveledRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "PLAY",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppSize.width(context) * 0.06,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_sharp,
                                  color: Colors.white,
                                  size: AppSize.width(context) * 0.06,
                                ),
                              ],
                            ),
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
      ),
    );
  }

  AppBar _bar(User user) {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      elevation: 2,
      leading: Padding(
        padding: EdgeInsets.only(left: 16),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
            user.profile ??
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&h=400&fit=crop',
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            'Balance: \$${user.balance.toInt()}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.message_rounded, color: Colors.blue.shade700),
            onPressed: () {},
            padding: EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  Widget _bg() {
    return SizedBox.expand(
      child: Image.asset('assets/background.png', fit: BoxFit.cover),
    );
  }
}
