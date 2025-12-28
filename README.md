# FitFlow 💪

FitFlow is a modern iOS fitness application powered by Google Gemini AI that provides personalized workout and nutrition plans. It tracks user activity data through HealthKit integration and offers AI-powered recommendations.

## 🎯 Project Purpose

FitFlow's primary goal is to help users achieve their fitness goals by providing:

- **Personalized Workout Plans**: AI-generated weekly workout programs tailored to the user's physical characteristics, goals, and health data
- **Nutrition Guidance**: Daily meal plans and nutrition recommendations aligned with macro goals
- **Health Data Integration**: Automatic tracking of step count, calories burned, workout duration, and other health metrics through HealthKit
- **User-Friendly Interface**: An intuitive and easy-to-use interface built with modern SwiftUI

## ✨ Features

- 🤖 **AI-Powered Program Generation**: Personalized weekly workout and nutrition plans using Google Gemini AI
- 📊 **HealthKit Integration**: Automatic tracking of step count, calories burned, workout duration, and other health metrics
- 🎯 **Goal-Oriented Approach**: Customized programs for user goals such as weight loss, muscle gain, and endurance improvement
- 📱 **Modern UI/UX**: Clean and user-friendly interface built with SwiftUI
- 🍽️ **Detailed Nutrition Plans**: Meal recommendations and preparation recipes aligned with daily macro goals
- 🏋️ **Exercise Videos**: Visual guidance with YouTube video links for each exercise
- 📈 **Progress Tracking**: View progress through daily activity logs and metric cards

## 🏗️ Architecture

FitFlow uses a modular and maintainable architecture following modern iOS development principles:

### Coordinator Pattern
- **AppCoordinator**: Application-wide navigation management
- Page transitions, sheet and fullscreen cover management
- Centralized navigation control to prevent code duplication

### Dependency Injection
- **DependencyContainer**: Service registration and resolution using Singleton pattern
- **@Injected Property Wrapper**: Easy and clean dependency injection
- Protocol-based design for testability and flexibility

### MVVM (Model-View-ViewModel)
- **View**: UI layer with SwiftUI
- **ViewModel**: Business logic and state management
- **Model**: Data models and domain logic

### Layered Architecture
```
FitFlow/
├── Core/
│   ├── Coordinator/      # Navigation management
│   ├── Manager/          # Service layer (HealthKit, Gemini, Storage, Tracking)
│   └── DependencyContainer.swift
├── Model/                # Data models
├── View/                 # SwiftUI views
├── Shared/               # Shared UI components
├── Extension/            # Swift extensions
└── Constants/            # Constants and localization
```

### Service Layer
- **GeminiService**: AI communication and program generation
- **HealthManager**: Reading and managing HealthKit data
- **StorageManager**: Local data storage (UserDefaults)
- **TrackingManager**: User activity tracking

## 📋 Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Google Gemini API Key
- HealthKit permission (for running on iPhone)

## 🚀 Installation

### 1. Clone the Project

```bash
git clone https://github.com/username/FitFlow.git
cd FitFlow
```

### 2. Add Gemini API Key

A Google Gemini API key is required to use FitFlow's AI features:

1. Create your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Open the project in Xcode
3. Right-click on `FitFlow.xcodeproj` and select "Add Files to FitFlow..."
4. Create an `Info.plist` file (if it doesn't exist) or edit the existing `Info.plist` file
5. Add the following key to the `Info.plist` file:

```xml
<key>GEMINI_API_KEY</key>
<string>YOUR_API_KEY_HERE</string>
```

**Alternative Method (Build Settings):**
- Go to project settings in Xcode
- Navigate to the "Info.plist Values" section in Build Settings
- Add the `GEMINI_API_KEY` key and enter its value

**Important Security Note:**
- Never commit your API key to Git
- Add `Info.plist` to your `.gitignore` file (if it contains sensitive information)
- Store the API key securely in production environments

### 3. HealthKit Entitlements

The project already includes HealthKit permissions in the `FitFlow.entitlements` file. If you're creating a new project:

1. Go to project settings in Xcode
2. Navigate to the "Signing & Capabilities" tab
3. Click the "+ Capability" button
4. Add "HealthKit"

### 4. Build the Project

```bash
open FitFlow.xcodeproj
```

After opening the project in Xcode:
1. Select a simulator or real device
2. Run the project with ⌘ + R

## 📱 Usage

### First Time Use

1. **Onboarding Process**: 
   - When the app first opens, personal information (name, goal, height, weight, age) is collected from the user
   - HealthKit permissions are requested
   - AI creates a personalized program based on the user profile

2. **Dashboard**:
   - Daily activity summary
   - Macro goals and progress
   - Quick metrics (calories burned, active time, workout count)
   - Weekly program generated by AI

3. **Workout Details**:
   - Daily workout plan
   - Exercises, sets/reps information
   - YouTube video links

4. **Nutrition Plan**:
   - Daily meal recommendations
   - Macro values
   - Preparation recipes

## 🛠️ Technologies

- **SwiftUI**: Modern UI framework
- **Combine**: Reactive programming
- **HealthKit**: Health data integration
- **Google Generative AI**: AI-powered program generation
- **MVVM**: Architectural pattern
- **Coordinator Pattern**: Navigation management
- **Dependency Injection**: Modular design

## 📁 Project Structure

```
FitFlow/
├── Assets.xcassets/          # Visual assets
├── Constants/                # Constants and localization
├── ContentView.swift         # Main view
├── Core/
│   ├── Coordinator/          # Navigation coordinator
│   ├── Manager/              # Service managers
│   └── DependencyContainer.swift
├── Extension/                # Swift extensions
├── FitFlow.entitlements      # App permissions
├── FitFlowApp.swift          # App entry point
├── Model/                    # Data models
├── Shared/UI/                # Shared UI components
└── View/                     # Screen views
    ├── ActivityLogSheet/     # Activity log screen
    ├── AILoading/            # AI loading screen
    ├── Dashboard/            # Main dashboard
    ├── Error/                # Error screen
    ├── MealPlanDetail/       # Meal plan detail
    ├── Onboard/              # Onboarding flow
    └── WorkoutDetail/        # Workout detail
```

## 🔒 Privacy and Security

- HealthKit data is stored on the device and never sent to any server
- Gemini API key is stored locally
- User data is kept on the device using UserDefaults

## 🤝 Contributing

We welcome your contributions! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

**Note**: This application is for educational and personal use purposes. It does not replace medical advice. Please consult a healthcare professional for any health concerns.

