# 📊 MutualFunds iOS App

An iOS app built with **SwiftUI + Firebase + Swift Concurrency** that allows users to:
- 🔐 Login with Firebase Authentication  
- 🔍 Search mutual funds via [MFAPI](https://www.mfapi.in/)  
- ⭐ Save selected funds & past viewed funds to **Firestore**  
- 📑 Filter funds by AMC, category, or type  
- 📈 Compare multiple funds with a clean **Swift Charts** NAV comparison view  

---

## 🚀 Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/vanshsharma5503/MutualFunds.git
   cd MutualFunds
   
2.**Open the project in Xcode
open MutualFundsApp.xcodeproj

3. **Install dependencies
   -Make sure you have Xcode 26 and iOS 26 SDK.
   -This project uses Swift Packages (Firebase, Charts). Xcode will auto-resolve them.

##Design Choices
  -Entire app is written in SwiftUI with MVVM for state management.
  -Reusable components for fund cards, charts, and filter views.
  -For comparing NAV trends between multiple funds in an interactive way.

## 🎥 Demo Video
https://drive.google.com/file/d/1jWflFUIQaxt9CqA_55edEuYsOTx5BUVF/view?usp=sharing
