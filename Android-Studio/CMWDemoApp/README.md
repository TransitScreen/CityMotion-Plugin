# CMW Demo App for Android Studio

v0.5.3

## Coordinates Endpoint - Location Services Recovery Notes
App will attempt to recovery from when a user turns their Location Settings to OFF at the OS level or at the app-level. 

*OS permissions allowed loading a new activity*
- User loads into a new activity
- User opens up their settings dialog and turns off Location Settings
- User resumes app
- Resume state remains the last coordinate position

*OS permissions disabled loading a new activity*
- User has already set their Location Settings OFF
- User loads into a new activity
- App prompts user to redirect to the Settings screen
- User turns on Location Settings
- User hits back to return to the app
- App will resume and wait for next location update and load webview

*App level permissions allowed loading a new activity*
- User loads into a new activity
- App prompts to Allow
- User taps Allow
- App loads webivew

*App level permissions allowed then disabled loading a new activity*
- User loads into a new activity
- User Allows location, app loads webview
- User goes into Settings menu and disables app-level permissions
- App resumes and remains on the last position
- Only on a complete app or activity level close and reopen will app reprompt for permissions

*App level permissions disabled loading a new activity*
- User loads into a new activity
- App prompts user to redirect to the Settings screen
- User enables Location Settings for the app-level
- App will resume and wait for next location update and load webview




