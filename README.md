# 🐾 PawCare - Complete Pet Care Platform

<p align="center">
  <img src="assets/images/pawcare.png" alt="PawCare Logo" width="200"/>
</p>

**PawCare** is a comprehensive mobile application that connects pet owners with trusted pet care service providers. Built with Flutter, it offers a unified platform for managing all aspects of pet care—from booking veterinary appointments to purchasing pet supplies, tracking health records, and connecting with other pet lovers.

---

## 📱 What is PawCare?

PawCare is a two-sided marketplace that serves both **pet owners** and **service providers**:

### For Pet Owners
- **Manage Pet Profiles**: Store comprehensive information about your pets including breed, age, medical history, and vaccination records
- **Book Services**: Find and book appointments with verified veterinarians, groomers, and boarding facilities
- **Shop Pet Products**: Browse and purchase pet food, toys, accessories, and healthcare products
- **Health Tracking**: Monitor vaccinations, medications, feeding schedules, and health metrics
- **Find Nearby Services**: Use location-based search to discover pet care providers in your area
- **Social Features**: Share updates, photos, and connect with other pet owners
- **Real-time Messaging**: Communicate directly with service providers

### For Service Providers
- **Provider Dashboard**: Specialized dashboards for vets, groomers, pet shops, and boarding facilities
- **Service Management**: Create and manage service offerings with pricing and availability
- **Appointment Management**: View, accept, and manage bookings from pet owners
- **Inventory Management**: Track products, orders, and stock levels (for pet shops)
- **Verification System**: Get verified through document submission to build trust
- **Earnings Tracking**: Monitor revenue and transaction history
- **Calendar Integration**: Manage availability and booking schedules

---

## ✨ Key Features

### 🏥 Veterinary Services
- Browse verified veterinary clinics and professionals
- Book health check-ups, consultations, and emergency services
- Access pet health records and vaccination history
- Receive appointment reminders and notifications
- Prescription management and vaccination scheduling

### ✂️ Grooming Services
- Find certified pet groomers in your area
- Book grooming appointments (bathing, trimming, nail care)
- View groomer portfolios and ratings
- Schedule recurring grooming sessions

### 🏠 Boarding & Care
- Search for pet boarding facilities
- Book extended pet care when traveling
- View facility photos and amenities
- Read reviews from other pet owners

### 🛍️ Pet Shop & Products
- Browse extensive catalog of pet products
- Filter by category, price, and brand
- Add items to cart and place orders
- Track order history and delivery status
- Manage shopping cart across sessions

### 📍 Location-Based Discovery
- Find nearby vets, groomers, and pet shops using interactive maps
- Integration with OpenStreetMap for accurate location data
- Filter services by type and distance
- View provider details and ratings directly on the map

### 📊 Health & Wellness Tracking
- Complete pet health record management
- Vaccination schedule with reminders
- Feeding time tracking and dietary management
- Growth charts and health metrics
- Medical history documentation

### 💬 Messaging & Communication
- Real-time chat with service providers using WebSocket
- Share photos and documents
- Appointment confirmations and updates
- Support inquiries

### 🔐 Authentication & Security
- Secure user authentication with JWT tokens
- Social login (Google Sign-In, Sign in with Apple)
- Role-based access control (User vs Provider)
- Encrypted storage for sensitive data using flutter_secure_storage

---

## 🏗️ Architecture

PawCare follows **Clean Architecture** principles with a **feature-first** organization pattern:

```
lib/
├── app/               # Application shell, theme, routing, bootstrap
├── core/              # Cross-cutting concerns (API, services, providers)
├── shared/            # Reusable UI components and navigation
└── features/          # Feature modules
    ├── auth/          # Authentication & registration
    ├── pet/           # Pet profile management
    ├── bookings/      # Appointment booking system
    ├── services/      # Service marketplace
    ├── shop/          # Pet shop & e-commerce
    ├── provider/      # Provider dashboard & management
    ├── health_records/# Health tracking & records
    ├── messages/      # Real-time messaging
    ├── posts/         # Social feed & community
    └── map/           # Location-based services
```

### Feature Layer Structure
Each feature follows Clean Architecture layers:

```
feature/
├── data/             # Data sources, models, repositories
│   ├── datasources/  # Remote API & local cache
│   ├── models/       # JSON models & converters
│   └── repositories/ # Repository implementations
├── domain/           # Business logic layer
│   ├── entities/     # Core business models
│   ├── repositories/ # Repository contracts
│   └── usecases/     # Business use cases
└── presentation/     # UI layer
    ├── pages/        # Screen widgets
    ├── widgets/      # Reusable UI components
    ├── view_model/   # State management (Riverpod)
    └── state/        # State objects
```

---

## 🚀 How PawCare Works

### User Flow (Pet Owner)

1. **Onboarding & Registration**
   - Download and launch the app
   - Complete onboarding screens showcasing features
   - Register with email/password or social login
   - Set up user profile

2. **Pet Management**
   - Add pet profiles with photos, breed, age, and medical info
   - Input vaccination records and health history
   - Set up feeding schedules and reminders

3. **Discovering Services**
   - Browse the home screen for quick access to services
   - Use the explore page to see all available services
   - View nearby providers on the map
   - Read reviews and ratings

4. **Booking Appointments**
   - Select a service type (veterinary, grooming, boarding)
   - Choose a service provider
   - Pick available date and time slots
   - Select which pet the booking is for
   - Add notes and confirm booking
   - Receive confirmation notification

5. **Shopping**
   - Browse pet products by category
   - Add items to cart
   - Review cart and apply any promotions
   - Complete checkout
   - Track order status

6. **Health Tracking**
   - View pet health dashboard
   - Mark vaccinations as completed
   - Log medications and treatments
   - Track feeding times
   - View health trends and charts

### Provider Flow

1. **Provider Registration**
   - Register as a provider with specific type (vet, groomer, shop owner)
   - Submit verification documents
   - Complete profile setup

2. **Service Setup**
   - Create service offerings with descriptions and pricing
   - Set availability and working hours
   - Upload facility photos and certifications

3. **Managing Bookings**
   - View incoming appointment requests
   - Accept or decline bookings
   - Manage calendar and availability
   - Communicate with pet owners
   - Update booking status

4. **Inventory Management (Pet Shops)**
   - Add products to inventory
   - Set pricing and stock levels
   - Process orders
   - Update order fulfillment status

---

## 🛠️ Technology Stack

### Frontend Framework
- **Flutter** 3.9.2 - Cross-platform mobile development
- **Dart** - Programming language

### State Management
- **Riverpod** 3.0 - Reactive state management
- **riverpod_annotation** - Code generation for providers

### Networking
- **Dio** 5.4 - HTTP client for API calls
- **dio_smart_retry** - Automatic retry logic
- **pretty_dio_logger** - Network request logging
- **connectivity_plus** - Network connectivity monitoring
- **web_socket_channel** - Real-time messaging

### Local Storage
- **Hive** 2.2 - Fast, lightweight NoSQL database
- **shared_preferences** - Key-value storage
- **flutter_secure_storage** - Encrypted storage for sensitive data
- **path_provider** - Access to device file system

### Authentication
- **jwt_decoder** - JWT token parsing
- **google_sign_in** - Google OAuth integration
- **sign_in_with_apple** - Apple Sign-In integration

### Media & Files
- **image_picker** - Camera & gallery access
- **flutter_image_compress** - Image optimization
- **video_compress** - Video compression
- **video_thumbnail** - Generate video thumbnails
- **cached_network_image** - Image caching
- **flutter_cache_manager** - Cache management
- **file_picker** - File selection
- **flutter_svg** - SVG rendering

### Maps & Location
- **flutter_map** - Interactive map display
- **latlong2** - Latitude/longitude utilities
- **geolocator** - GPS location services
- **permission_handler** - Runtime permissions

### UI Components
- **table_calendar** - Calendar widget for bookings
- **fl_chart** - Charts and data visualization
- **cupertino_icons** - iOS-style icons

### Background Tasks
- **workmanager** - Background job scheduling
- **flutter_local_notifications** - Local push notifications

### Routing
- **go_router** 16.1 - Declarative routing

### Utilities
- **freezed** - Immutable data classes
- **json_annotation** - JSON serialization
- **uuid** - Unique ID generation
- **intl** - Internationalization
- **equatable** - Value equality
- **dartz** - Functional programming (Either type)

---

## 📋 Prerequisites

- **Flutter SDK**: 3.9.2 or higher
- **Dart SDK**: Included with Flutter
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA
- **Platform SDKs**:
  - Android: Android Studio with Android SDK 21+
  - iOS: Xcode 14+ (macOS only)
- **Device/Emulator**: Physical device or emulator for testing

---

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd petcare
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation** (for models, providers, etc.)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Configure API endpoint**
   - Update `lib/core/api/api_endpoints.dart` with your backend API URL

5. **Run the app**
   ```bash
   # Run on connected device
   flutter run

   # Run on specific device
   flutter devices
   flutter run -d <device-id>

   # Run in release mode
   flutter run --release
   ```

---

## 🧪 Testing

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/features/auth/presentation/pages/login_page_test.dart
```

### Run with coverage
```bash
flutter test --coverage
```

### Static Analysis
```bash
flutter analyze
```

---

## 📂 Project Structure

```
petcare/
├── android/              # Android native configuration
├── ios/                  # iOS native configuration
├── assets/               # Images, fonts, icons
├── lib/
│   ├── main.dart         # Application entry point
│   ├── app/              # App-level configuration
│   │   ├── bootstrap/    # App initialization
│   │   ├── routes/       # Navigation & routing
│   │   └── theme/        # App theme & styling
│   ├── core/             # Core functionality
│   │   ├── api/          # API client & endpoints
│   │   ├── error/        # Error handling
│   │   ├── providers/    # Global providers
│   │   ├── services/     # Core services
│   │   └── usecases/     # Base use case classes
│   ├── shared/           # Shared UI components
│   │   ├── navigation/   # Bottom navigation shell
│   │   └── widgets/      # Reusable widgets
│   └── features/         # Feature modules
│       ├── auth/         # Authentication
│       ├── pet/          # Pet management
│       ├── bookings/     # Appointments
│       ├── services/     # Service marketplace
│       ├── shop/         # E-commerce
│       ├── provider/     # Provider features
│       ├── messages/     # Chat
│       └── ...           # Other features
├── test/                 # Unit & widget tests
├── integration_test/     # Integration tests
├── pubspec.yaml          # Dependencies
└── analysis_options.yaml # Linter rules
```

---

## 🔄 Startup Flow

The app initialization is centralized in `lib/app/bootstrap/app_bootstrap.dart`:

1. **Initialize Hive** - Set up local database and open required boxes
2. **Initialize Notifications** - Configure local notification channels
3. **Load SharedPreferences** - Restore user session and settings
4. **Provider Overrides** - Inject dependencies into Riverpod scope
5. **Launch App** - Create widget tree and navigate to initial route

This approach keeps side effects out of widgets and makes startup behavior testable.

---

## 🧭 Routing Strategy

The app uses **go_router** with role-based route protection:

- **Public Routes**: Splash, onboarding, login, registration
- **User Routes**: Home, explore, shop, bookings, pet management, profile
- **Provider Routes**: Provider dashboard, service management, appointment management
- **Shell Navigation**: Bottom navigation bar for primary user screens

Route guards automatically redirect unauthenticated users to login and prevent unauthorized access to provider features.

---

## 🎨 UI/UX Highlights

- **Material Design 3** principles
- **Responsive layouts** for various screen sizes
- **Smooth animations** and transitions
- **Skeleton loaders** for async content
- **Pull-to-refresh** on list screens
- **Infinite scroll** pagination
- **Empty states** with helpful messages
- **Error handling** with user-friendly messages
- **Dark/light theme** support (configurable)

---

## 🔐 Security Features

- **JWT-based authentication** with secure token storage
- **Encrypted local storage** for sensitive data
- **API request signing** and validation
- **Role-based access control** (RBAC)
- **Input validation** and sanitization
- **Secure file upload** with type and size checks
- **Session management** with automatic logout

---

## 🔧 Development Guidelines

### Code Generation
When adding or modifying data models, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Dependency Injection
- Core providers go in `lib/core/providers`
- Feature providers should be in the feature's root or `di` folder
- Avoid circular dependencies between features
- Use `ref.watch()` for reactive updates, `ref.read()` for one-time access

### State Management
- Use Riverpod StateNotifier for complex state
- Use simple Provider for stateless data
- Keep state immutable using `copyWith` methods
- Add loading, error, and success states

### API Integration
- All endpoints defined in `lib/core/api/api_endpoints.dart`
- API calls happen in data source layers
- Use Either type for error handling in repositories
- Implement retry logic for failed requests

---

## 📖 Pull Request Checklist

Before submitting a PR, ensure:

- [ ] `flutter analyze` passes with no warnings
- [ ] `flutter test` passes for all tests
- [ ] New features follow feature-first architecture
- [ ] Data/domain/presentation layers are properly separated
- [ ] Dependencies are injected via providers, not hardcoded
- [ ] Code is formatted using `dart format`
- [ ] UI changes are tested on both Android and iOS
- [ ] Breaking changes are documented
- [ ] Commit messages follow conventional commits

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the architecture patterns established in the project
4. Write tests for new features
5. Ensure all tests pass and no analyzer warnings exist
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

---

## 📄 License

This project is private and proprietary. All rights reserved.

---

## 📞 Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Contact the development team

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod community for state management solutions
- OpenStreetMap for map data
- All open-source contributors whose packages make this app possible

---

**Made with ❤️ for pet lovers everywhere 🐾**
