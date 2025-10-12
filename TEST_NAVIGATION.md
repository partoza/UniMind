# 🧪 UniMind Test Navigation

This document explains how to use the test navigation system for easy screen testing and development.

## 📁 Files Created

- `lib/main_test.dart` - Test version of main.dart with navigation menu
- `lib/main_production.dart` - Backup of production main.dart
- `switch_to_test.bat` - Script to switch to test mode
- `switch_to_production.bat` - Script to switch to production mode

## 🚀 How to Use

### **Option 1: Quick Switch (Recommended)**

**For Command Prompt:**
```cmd
# Switch to TEST mode
.\switch_to_test.bat

# Switch to PRODUCTION mode  
.\switch_to_production.bat
```

**For PowerShell:**
```powershell
# Switch to TEST mode
.\switch_to_test.ps1

# Switch to PRODUCTION mode  
.\switch_to_production.ps1
```

### **Option 2: Manual Switch**
```cmd
# Test mode
copy lib\main_test.dart lib\main.dart

# Production mode
copy lib\main_production.dart lib\main.dart
```

## 🎯 Test Navigation Features

### **📱 Available Test Screens:**

#### **Authentication & Setup**
- **Loading Page** - Initial loading screen
- **Login Page** - User authentication
- **Profile Setup** - Complete setup flow

#### **Individual Profile Steps**
- **Gender Selection** - Gender selection step
- **College Department** - Department selection
- **Program & Year** - Program and year selection
- **Strengths Selection** - Strengths selection
- **Weaknesses Selection** - Weaknesses selection
- **Avatar Selection** - Avatar selection

#### **Main App Screens**
- **Home Page** - Main home screen
- **Matched Page** - Study partner match screen

#### **Firebase Test**
- **Test Firebase Connection** - Check Firebase connectivity

## 🔧 Development Workflow

1. **Start Testing:**
   ```cmd
   .\switch_to_test.bat
   flutter run
   ```
   or
   ```powershell
   .\switch_to_test.ps1
   flutter run
   ```

2. **Test Individual Screens:**
   - Use the navigation menu to jump to any screen
   - Test different user flows
   - Debug UI issues

3. **Return to Production:**
   ```cmd
   .\switch_to_production.bat
   flutter run
   ```
   or
   ```powershell
   .\switch_to_production.ps1
   flutter run
   ```

## ✨ Benefits

- **🎯 Quick Access** - Jump to any screen instantly
- **🔍 Easy Debugging** - Test individual components
- **📱 UI Testing** - Check responsive design
- **🚀 Fast Development** - No need to go through full flows
- **🔄 Easy Switching** - Toggle between test and production

## 🛠️ Customization

To add new test screens, edit `lib/main_test.dart`:

```dart
_buildTestButton(
  context,
  'Your Screen Name',
  'Description of the screen',
  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YourScreen())),
),
```

## 📝 Notes

- Test mode bypasses Firebase authentication
- All screens are accessible without login
- Perfect for UI/UX testing and development
- Remember to switch back to production before deployment
