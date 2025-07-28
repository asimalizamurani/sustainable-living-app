# Sustainable Living App

A comprehensive Flutter application designed to promote sustainable living practices through challenges, tips, and carbon footprint tracking.

## Features

### For Users
- **User Authentication**: Secure login and registration with role-based access
- **Dashboard**: Personalized sustainability metrics and progress tracking
- **Challenges**: Participate in sustainability challenges to earn eco points
- **Eco Tips**: Browse and learn from curated sustainability advice
- **Carbon Tracker**: Log daily activities and track carbon footprint
- **Achievements**: Unlock achievements for sustainable milestones
- **Leaderboard**: Compare progress with other users
- **Profile Management**: Update personal information and preferences

### For Administrators
- **User Management**: View, edit, and manage user accounts
- **Challenge Management**: Create, edit, and manage sustainability challenges
- **Tips Management**: Create and manage eco-friendly tips and advice
- **Analytics**: View platform statistics and user engagement metrics
- **Content Moderation**: Manage featured content and user-generated data

## Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **State Management**: Provider
- **Charts**: fl_chart
- **Image Handling**: image_picker
- **Password Validation**: flutter_pw_validator

## Project Structure

```
lib/
├── models/
│   ├── user_model.dart
│   ├── challenge_model.dart
│   ├── achievement_model.dart
│   ├── eco_tip_model.dart
│   └── carbon_tracker_model.dart
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── challenges_screen.dart
│   ├── eco_tips_screen.dart
│   ├── carbon_tracker_screen.dart
│   ├── profile_screen.dart
│   ├── edit_profile_screen.dart
│   ├── settings_screen.dart
│   ├── admin_dashboard.dart
│   ├── admin_user_management.dart
│   ├── admin_challenge_management.dart
│   ├── admin_tips_management.dart
│   └── admin_analytics.dart
├── services/
│   └── auth_service.dart
└── main.dart
```

## Models

### UserModel
- Basic user information (name, email, password)
- Role-based access (user/admin)
- Sustainability metrics (eco points, carbon footprint)
- Achievement tracking
- Preferences and settings

### ChallengeModel
- Challenge details (title, description, category)
- Difficulty levels and rewards
- Participation tracking
- Date ranges and requirements

### EcoTipModel
- Educational content and advice
- Category classification
- Engagement metrics (views, likes)
- Featured content management

### CarbonTrackerModel
- Activity logging
- Carbon footprint calculations
- Location and time tracking
- Verification system

### AchievementModel
- Milestone tracking
- Reward systems
- Progress indicators
- Unlock criteria

## Getting Started

### Prerequisites
- Flutter SDK (3.6.2 or higher)
- Dart SDK
- Firebase project setup
- Android Studio / VS Code

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd sustainable_living_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a Firebase project
   - Enable Authentication and Firestore
   - Download and add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration in `lib/firebase_options.dart`

4. Run the application:
```bash
flutter run
```

## Firebase Setup

### Authentication
- Enable Email/Password authentication
- Configure password reset functionality
- Set up user role management

### Firestore Collections
- `users`: User profiles and data
- `challenges`: Sustainability challenges
- `eco_tips`: Educational content
- `carbon_tracker`: Activity logs
- `achievements`: User achievements

### Security Rules
```javascript
// Example Firestore security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Admins can read/write all data
    match /{document=**} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## Features in Detail

### User Authentication
- Secure login with email/password
- Password validation and strength checking
- Role-based access control
- Password reset functionality
- Session management

### Dashboard
- Personalized sustainability metrics
- Progress visualization
- Quick action buttons
- Featured content display
- Achievement showcase

### Challenges System
- Category-based challenges (energy, water, waste, etc.)
- Difficulty levels (easy, medium, hard)
- Reward system with eco points
- Progress tracking
- Completion verification

### Carbon Tracking
- Activity logging interface
- Carbon footprint calculations
- Historical data visualization
- Goal setting and monitoring
- Impact assessment

### Admin Panel
- Comprehensive user management
- Content creation and moderation
- Analytics and reporting
- Platform statistics
- Performance monitoring

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact:
- Email: support@sustainableliving.com
- Documentation: [Link to documentation]
- Issues: [GitHub Issues]

## Roadmap

### Phase 1 (Current)
- ✅ User authentication and profiles
- ✅ Basic challenge system
- ✅ Carbon tracking
- ✅ Admin panel

### Phase 2 (Planned)
- 🔄 Social features and community
- 🔄 Advanced analytics
- 🔄 Mobile notifications
- 🔄 Offline support

### Phase 3 (Future)
- 📋 AI-powered recommendations
- 📋 Integration with IoT devices
- 📋 Advanced gamification
- 📋 Multi-language support

## Screenshots

[Add screenshots of key features here]

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Open source community for libraries and tools
- Sustainability experts for content guidance
