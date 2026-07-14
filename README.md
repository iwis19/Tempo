# Tempo 🌲

iOS application that helps users stay productive throughout the day by managing time in a financial way.

--- 

## Repository Note

1. Working on putting on Apple app store, will stay public here until then :)

---

## Demos & Pages

https://github.com/user-attachments/assets/da43c45b-a43b-4440-8f2a-b3ad0682dc74



---

## Key Features

1. **Daily Activity Logging**
   - Users add activities with a title, duration, category
   - Separates into categories: earned, required, spent
   - Converts logged minutes into dollar values using the user's inputted hourly rate
   - Currently defaults to Ontario minimum wage as of June 7, 2026
2. **User Login Auth**
   - Allows users to log in using Google accounts using Google Identity
   - Wired to Supabase Auth
3. **Daily Statement System**
   - Creates daily statements displaying today's net, category totals, etc
   - Open and closes statements to finalize details of the day
4. **Analytics**
   - View past performance by day, week, month, qtr, year
   - Offers bar charts, category breakdowns, comparisons with previous intervals
   - Insights on logged days, average days, spending shares, etc

---

## Tech Stack
- **Swift** (SwiftUI, Foundations, Charts, UserDefaults)
- **Supabase**
- **Google OAuth**
- **SQL Rules**

---

## Set Up
- Hopefully will be on the App Store some day :)

---

## Project Structure
```text
Tempo-main/
├── Tempo.xcodeproj/                     
│   └── project.xcworkspace/
│       └── xcshareddata/
│           └── swiftpm/                 
├── Tempo/
│   ├── Assets.xcassets/                 # App icons, colors, wallpapers, assets
│   │   ├── AppIcon.appiconset/
│   │   ├── Icon.imageset/
│   │   ├── wallpaper.imageset/
│   │   └── *.colorset/                  # Custom Tempo color palette
│   ├── Design/                          # Design resources & documentation
│   │   ├── ColorPalette
│   │   ├── Learnings.md
│   │   ├── TODO.md
│   │   └── Syne-Regular.ttf
│   ├── Models/                          # Core app data models
│   │   ├── Chart.swift
│   │   ├── DayPart.swift
│   │   ├── Feedback.swift
│   │   ├── Flowtone.swift
│   │   ├── GraphData.swift
│   │   ├── Statement.swift
│   │   └── Tab.swift
│   ├── Services/                        # External services & user management
│   │   ├── Supabase.swift
│   │   └── User.swift
│   ├── Utilities/                       # Shared helpers, templates, notifications
│   │   ├── DemoData.swift
│   │   ├── Functions.swift
│   │   ├── NotificationHandler.swift
│   │   ├── SignInHelper.swift
│   │   ├── Templates.swift
│   │   └── UserStore.swift
│   ├── Views/                           
│   │   ├── ContentView.swift            # Root tab/navigation container
│   │   ├── LaunchPage.swift             # App launch/onboarding screen
│   │   ├── Home/
│   │   │   └── HomePage.swift           # Dashboard/home experience
│   │   ├── Today/
│   │   │   ├── TodayPage.swift          # Daily tracking screen
│   │   │   └── TodayStatementSheet.swift
│   │   ├── History/
│   │   │   └── HistoryPage.swift        # Historical analytics & charts
│   │   └── Profile/
│   │       ├── ProfilePage.swift
│   │       ├── ProfileNameSheet.swift
│   │       ├── ProfileHourlyRateSheet.swift
│   │       ├── ProfileDailyReminderSheet.swift
│   │       ├── ProfileDailyStatementGuideSheet.swift
│   │       ├── ProfileFeedbackSheet.swift
│   │       └── ProfileTimeCategoriesSheet.swift
│   ├── TempoApp.swift                  
│   └── Info.plist                       
├── README.md
├── LICENSE
└── .gitignore
```

---

## Lessons Learned
- Stay calm when the coding session is not going great especially while learning and adapting to a new language
- Managing logic flow throughout a mobile application
- Considering user experiences such as simplifying app interactions and incentivizing use
- Designing UI/UX
- Refactoring chunks of code to unify logic and naming processes
- How basic authentication works, following a tutorial

---

## Future Goals
- Even further simplify activity adding process
- Find areas of the app where I can integrate APIs to learn in Swift

---

## License
MIT
