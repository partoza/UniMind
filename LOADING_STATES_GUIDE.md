# 🔄 Loading States Implementation Guide

This document explains how to use the loading states implemented in UniMind.

## 📁 Files Created/Modified

- `lib/widgets/loading_widget.dart` - Reusable loading components
- `lib/views/auth/login_page.dart` - Updated with loading states
- `lib/main.dart` - Updated test navigation with loading states

## 🎯 Loading Components Available

### **1. LoadingWidget**
Full-screen loading widget with UniMind branding.

```dart
// Basic usage
LoadingWidget()

// With custom message
LoadingWidget(message: "Loading your profile...")

// With custom colors
LoadingWidget(
  message: "Signing in...",
  primaryColor: Color(0xFFB41214),
  backgroundColor: Colors.white,
)
```

### **2. LoadingOverlay**
Overlay loading on top of existing content.

```dart
// Wrap your content
LoadingOverlay(
  child: YourContent(),
  isLoading: true,
  message: "Processing...",
)
```

### **3. NavigationLoading**
Helper for navigation with loading states.

```dart
// Push with loading
await NavigationLoading.pushWithLoading(
  context,
  NextPage(),
  loadingMessage: "Loading next page...",
);

// Push replacement with loading
await NavigationLoading.pushReplacementWithLoading(
  context,
  HomePage(),
  loadingMessage: "Going to home...",
);
```

## 🚀 Implementation Examples

### **Login with Loading State**

```dart
// In login_page.dart
bool _isLoading = false;

// Google Sign-In button
onPressed: _isLoading ? null : () async {
  setState(() {
    _isLoading = true;
  });

  try {
    final user = await AuthService().signInWithGoogle();
    if (user != null) {
      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingOverlay(
          child: SizedBox.shrink(),
          isLoading: true,
          message: "Checking your profile...",
        ),
      );

      // Check profile and navigate
      // ... profile checking logic ...

      // Hide loading
      Navigator.of(context).pop();
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
  }
},

// Button content shows loading state
child: _isLoading
  ? Row(
      children: [
        CircularProgressIndicator(),
        Text("Signing in..."),
      ],
    )
  : Row(
      children: [
        Image.asset("assets/google icon.png"),
        Text("Continue with Google"),
      ],
    ),
```

### **Navigation with Loading**

```dart
// In test navigation
_buildTestButton(
  context,
  'Home Page',
  'Main home screen',
  () => NavigationLoading.pushWithLoading(
    context,
    const HomePage(),
    loadingMessage: "Loading home...",
  ),
),
```

## 🎨 Loading State Features

### **Visual Elements**
- **Circular Progress Indicator** - Standard Flutter loading spinner
- **UniMind Branding** - Logo and colors matching app theme
- **Custom Messages** - Contextual loading messages
- **Professional Overlay** - Semi-transparent background with centered loading

### **User Experience**
- **Prevents Multiple Taps** - Disables buttons during loading
- **Clear Feedback** - Users know something is happening
- **Smooth Transitions** - Loading states appear/disappear smoothly
- **Error Handling** - Loading stops on errors with user feedback

## 🔧 Customization Options

### **LoadingWidget Customization**
```dart
LoadingWidget(
  message: "Custom message",
  showLogo: true,                    // Show/hide logo
  backgroundColor: Colors.white,      // Background color
  primaryColor: Color(0xFFB41214),    // Primary color for spinner
)
```

### **LoadingOverlay Customization**
```dart
LoadingOverlay(
  child: YourContent(),
  isLoading: true,
  message: "Processing...",
  overlayColor: Colors.black,        // Overlay background color
)
```

## 📱 Usage in Different Scenarios

### **1. Authentication Loading**
- Google Sign-In process
- Profile verification
- Account creation

### **2. Navigation Loading**
- Page transitions
- Data loading
- API calls

### **3. Form Submission Loading**
- Profile updates
- Data saving
- File uploads

### **4. Data Fetching Loading**
- User profiles
- Study partners
- Matches

## ✨ Benefits

- **🎯 Better UX** - Users know the app is working
- **🚫 Prevents Errors** - Stops multiple simultaneous actions
- **🎨 Professional Look** - Consistent loading design
- **⚡ Smooth Performance** - Non-blocking loading states
- **🔧 Easy to Use** - Simple API for developers

## 🚀 Ready to Use!

The loading states are now implemented and ready to use throughout the app. They provide a professional, consistent user experience during all loading operations!
