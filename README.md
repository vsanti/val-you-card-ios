# Val-You Card iOS

Native iOS app for the Val-You Card membership discount platform. Built with SwiftUI and Clean Architecture.

## Architecture

The project follows **Clean Architecture** with three distinct layers:

```
ValYouCard/
├── Domain/              # Business logic (no framework dependencies)
│   ├── Entities/        # Data models (User, Offer, Category, Store)
│   ├── Repositories/    # Repository protocols (abstractions)
│   └── UseCases/        # Business rules (single-responsibility)
│
├── Data/                # External data sources
│   ├── Network/         # APIClient, Environment config
│   ├── Keychain/        # Secure token storage
│   └── Repositories/    # Protocol implementations (API calls)
│
├── Presentation/        # UI layer (SwiftUI + ViewModels)
│   ├── Theme/           # Colors, styling (matches web brand)
│   ├── Components/      # Reusable UI components
│   ├── Auth/            # Sign In, Sign Up, Forgot Password
│   ├── Home/            # Featured deals, categories, new deals
│   ├── Search/          # Deal search with filters & pagination
│   ├── DealDetail/      # Store offers with redeem flow
│   ├── Account/         # Profile, membership status, settings
│   └── Membership/      # Plan selection & Stripe checkout
│
├── App/                 # App entry point & DI container
│   ├── ValYouCardApp.swift
│   ├── RootView.swift
│   └── DependencyContainer.swift
│
└── Resources/           # Assets, Info.plist, config templates
```

## Key Patterns

- **Dependency Injection** via composition root (`DependencyContainer`)
- **Protocol-oriented** repository layer for testability
- **Use Cases** encapsulate business logic independently of UI
- **MVVM** in presentation layer with `@StateObject` ViewModels
- **async/await** for all networking
- **Keychain** for secure auth token storage

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Swift 6.0

## Setup

1. Clone the repo
2. Copy `ValYouCard/Resources/Debug.xcconfig.template` to `Debug.xcconfig`
3. Fill in your API keys and URLs
4. Generate the project: `xcodegen generate`
5. Open `ValYouCard.xcodeproj` in Xcode
6. Build and run

## Environment Variables

Configure in your `.xcconfig` file:

| Key | Description |
|-----|-------------|
| `API_URL` | Deals API base URL |
| `REDEEM_API_URL` | Redeem API URL |
| `STRAPI_URL` | Strapi CMS URL |
| `BACKEND_URL` | Next.js backend URL |
| `ACCESS_TOKEN` | Deals API access token |
| `MEMBER_KEY` | Member key for API auth |
| `STRIPE_PUBLISHABLE_KEY` | Stripe public key |

## Features

- Browse and search exclusive deals with category/distance filters
- View store details and individual offers
- Redeem offers (in-store, online, print)
- User authentication (sign in, sign up, forgot password)
- Member ID card display
- Membership upgrade via Stripe
- Manage subscription through Stripe portal
- Pull-to-refresh and infinite scroll pagination
