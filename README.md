lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   └── game_constants.dart
│   └── enums/
│       └── game_enums.dart
│
├── data/
│   ├── models/
│   │   ├── card_model.dart
│   │   ├── deck.dart
│   │   ├── poker_hand.dart
│   │   ├── player.dart
│   │   └── user.dart
│   └── services/
│       └── data_manager.dart
│
├── game/
│   └── poker_game.dart
│
├── presentation/
│   ├── pages/
│   │   ├── auth/
│   │   │   └── login_page.dart
│   │   ├── home/
│   │   │   └── main_menu_page.dart
│   │   ├── profile/
│   │   │   └── profile_page.dart
│   │   ├── game/
│   │   │   ├── texas_holdem_page.dart
│   │   │   ├── one_vs_one_page.dart
│   │   │   └── tournament_page.dart
│   │   └── utils/
│   │       └── format_utils.dart           ← _formatDate, _formatDateTime
│   │
│   └── widgets/
│       ├── cards/
│       │   └── realistic_playing_card.dart
│       ├── dialogs/
│       │   └── action_selection_dialog.dart
│       └── panels/
│           └── mini_action_panel.dart
│
└── routes.dart                     # poker
