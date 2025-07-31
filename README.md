# LeetCompanion2 🚀

A sleek macOS menu bar app that keeps track of your LeetCode progress and upcoming contests. Built with SwiftUI for a native macOS experience.

## Features ✨

- **Real-time Stats**: View your LeetCode problem-solving statistics (Easy, Medium, Hard, Total)
- **Global Ranking**: See your current global ranking on LeetCode
- **Contest Notifications**: Get notified 15 minutes before upcoming LeetCode contests
- **Daily Challenge**: Quick access to today's daily coding challenge
- **Menu Bar Integration**: Lives in your menu bar for quick access
- **Secure Authentication**: Uses macOS Keychain for secure session storage

## Screenshots 📸

The app displays in a clean popover from your menu bar showing:
- Your LeetCode username and global ranking
- Problem-solving statistics in an organized grid
- Next upcoming contest information
- Today's daily challenge with direct link

## Requirements 📋

- macOS 12.0+ (Monterey or later)
- Xcode 14.0+ (for building from source)
- Active LeetCode account

## Installation 🛠️

### Option 1: Build from Source
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/LeetCompanion2.git
   cd LeetCompanion2
   ```

2. Open `LeetCodeStats.xcodeproj` in Xcode

3. Build and run the project (⌘+R)

### Option 2: Download Release
Check the [Releases](https://github.com/yourusername/LeetCompanion2/releases) page for pre-built binaries.

## Setup & Usage 🚀

1. **First Launch**: The app will appear in your menu bar as a star icon ⭐
2. **Authentication**: On first use, you'll be prompted to provide your LeetCode session cookie:
   - Go to [leetcode.com](https://leetcode.com) and log in
   - Open Developer Tools → Application → Cookies
   - Copy the `LEETCODE_SESSION` cookie value
   - Paste it when prompted in the app
3. **Automatic Updates**: The app will refresh your stats automatically
4. **Notifications**: Grant notification permissions to receive contest reminders

## How It Works 🔧

The app uses LeetCode's GraphQL API to fetch:
- User profile and statistics
- Upcoming contest information  
- Daily coding challenge details

Authentication is handled securely through:
- Browser cookie detection (automatic)
- Manual cookie input (fallback)
- macOS Keychain storage (secure)

## Privacy & Security 🔒

- **No Data Collection**: Your data stays on your device
- **Secure Storage**: Session tokens stored in macOS Keychain
- **Local Processing**: All API calls made directly from your machine
- **Open Source**: Full source code available for review

## Development 👨‍💻

### Project Structure
```
LeetCodeStats/
├── LeetCodeStatsApp.swift      # App entry point
├── AppDelegate.swift           # Menu bar setup
├── DashboardView.swift         # Main UI
├── LeetCodeViewModel.swift     # Business logic & API
├── Keychain.swift             # Secure storage
├── GraphQLRoot.swift          # API models
└── Assets.xcassets           # App icons & assets
```

### Key Technologies
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data binding
- **URLSession**: Network requests to LeetCode API
- **Security Framework**: Keychain integration
- **UserNotifications**: Contest reminder system

## Contributing 🤝

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting 🔧

### Common Issues

**"Error - check console"**
- Your LeetCode session cookie may have expired
- Try logging out and back into LeetCode, then restart the app

**App not showing stats**
- Ensure you're logged into LeetCode in your browser
- Check that your username is public on LeetCode

**Notifications not working**
- Grant notification permissions in System Preferences → Notifications

### Debug Mode
Uncomment line 50 in `LeetCodeViewModel.swift` to reset stored credentials:
```swift
// Keychain.delete() // Uncomment for reset
```

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments 🙏

- LeetCode for their excellent platform and API
- The Swift community for amazing tools and resources
- All contributors who help improve this project

---

**Note**: This is an unofficial app and is not affiliated with LeetCode. LeetCode is a trademark of LeetCode LLC.
