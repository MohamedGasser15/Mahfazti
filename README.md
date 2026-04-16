# Mahfazati (My Wallet) 💰

A comprehensive personal wallet and expense tracking application with a .NET backend API and Flutter mobile app.

**Live Demo:** [https://mahfazati.runasp.net/](https://mahfazati.runasp.net/)

## 📱 Features

### Backend API (.NET)
- **Authentication & Authorization** - JWT-based authentication with ASP.NET Identity
- **Wallet Management** - Track income, expenses, and balances
- **Category Management** - Organize transactions by custom categories
- **Budget Tracking** - Set and monitor budgets per category
- **Voice Expense Entry** - Add expenses using voice commands
- **Profile Management** - User profile settings and preferences
- **Email Notifications** - Email templates and sending capabilities
- **API Documentation** - Interactive API docs powered by Scalar

### Mobile App (Flutter)
- **Cross-Platform** - Available for Android, iOS, Web, Linux, macOS, and Windows
- **Biometric Authentication** - Secure login with fingerprint/face recognition
- **Beautiful UI** - Modern design with custom fonts and animations
- **Charts & Analytics** - Visual spending insights with fl_chart
- **Multi-language Support** - Localization support (l10n)
- **State Management** - Built with BLoC pattern
- **Secure Storage** - Encrypted local storage for sensitive data

## 🏗️ Project Structure

```
/workspace
├── apps/
│   ├── api/                      # .NET Backend API
│   │   ├── MyWallet/             # API Layer (Controllers, Program.cs)
│   │   ├── MyWallet.Application/ # Business Logic & Services
│   │   ├── MyWallet.Domain/      # Domain Entities
│   │   └── MyWallet.Infrastructure/ # Data Access & Repositories
│   │
│   └── mobile/                   # Flutter Mobile Application
│       ├── lib/                  # Dart source code
│       ├── assets/               # Images, fonts, icons
│       ├── android/              # Android platform files
│       ├── ios/                  # iOS platform files
│       └── ...                   # Other platform support
│
└── README.md
```

## 🚀 Getting Started

### Prerequisites

**Backend:**
- .NET SDK 8.0 or later
- SQL Server
- Visual Studio 2022 or VS Code

**Mobile:**
- Flutter SDK 3.10+
- Dart SDK 3.10+
- Android Studio / Xcode (for mobile development)

### Backend Setup

1. Navigate to the API directory:
   ```bash
   cd apps/api
   ```

2. Update the connection string in `appsettings.json`:
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=YOUR_SERVER;Database=MyWallet;Trusted_Connection=True;TrustServerCertificate=True;"
   }
   ```

3. Configure JWT settings in `appsettings.json`:
   ```json
   "Jwt": {
     "Key": "YourSuperSecretKeyThatIsAtLeast32CharactersLong",
     "Issuer": "MyWalletAPI",
     "Audience": "MyWalletUsers"
   }
   ```

4. Restore packages and run:
   ```bash
   dotnet restore
   dotnet run --project MyWallet/MyWallet.API.csproj
   ```

5. Access the API documentation at: `https://localhost:7000/scalar`

### Mobile App Setup

1. Navigate to the mobile directory:
   ```bash
   cd apps/mobile
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Create `.env` file for environment variables (if needed):
   ```bash
   cp .env.example .env
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## 🛠️ Tech Stack

### Backend
- **Framework:** ASP.NET Core Web API
- **Database:** SQL Server with Entity Framework Core
- **Authentication:** ASP.NET Identity + JWT
- **Architecture:** Clean Architecture (Domain, Application, Infrastructure, API)
- **Mapping:** AutoMapper
- **Documentation:** Scalar + OpenAPI/Swagger
- **Caching:** MemoryCache

### Mobile
- **Framework:** Flutter
- **State Management:** BLoC + Provider
- **HTTP Client:** Dio
- **Local Storage:** SharedPreferences, Flutter Secure Storage
- **Charts:** fl_chart
- **UI Components:** 
  - google_fonts
  - font_awesome_flutter
  - flutter_animate
  - shimmer (loading states)
  - flutter_slidable
- **Authentication:** local_auth (biometric)
- **Connectivity:** connectivity_plus, network_info_plus
- **Voice Input:** speech_to_text

## 📦 Key Dependencies

### Backend
- Microsoft.AspNetCore.Identity
- Microsoft.EntityFrameworkCore.SqlServer
- AutoMapper
- JWT Bearer Authentication
- Scalar.AspNetCore

### Mobile
```yaml
dependencies:
  flutter_bloc: ^9.1.1
  provider: ^6.0.5
  dio: ^5.3.2
  fl_chart: ^1.2.0
  speech_to_text: ^7.3.0
  local_auth: ^2.1.6
  flutter_secure_storage: ^10.0.0
  google_fonts: ^8.0.2
  flutter_animate: ^4.5.0
```

## 🔐 Security Features

- JWT token-based authentication
- Password hashing with ASP.NET Identity
- Biometric authentication support (mobile)
- Secure encrypted storage for tokens
- Role-based authorization (Admin/User policies)
- CORS configuration for API access

## 📝 API Endpoints

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `/api/auth/register` | POST | Register new user | No |
| `/api/auth/login` | POST | Login user | No |
| `/api/wallet` | GET/POST | Manage wallet | Yes |
| `/api/category` | GET/POST/PUT/DELETE | Manage categories | Yes |
| `/api/budget` | GET/POST/PUT/DELETE | Manage budgets | Yes |
| `/api/profile` | GET/PUT | User profile | Yes |
| `/api/voice-expense` | POST | Add expense via voice | Yes |

## 🎨 Mobile App Screens

- Onboarding screens
- Login/Register with biometric support
- Dashboard with spending analytics
- Transaction list with search/filter
- Category management
- Budget tracking with visual charts
- Profile settings
- Voice input for quick expense entry

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For issues and questions, please open an issue on the repository.

---

**Built with ❤️ using .NET and Flutter**
