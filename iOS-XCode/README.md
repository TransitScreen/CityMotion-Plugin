# CityMotion Webview for iOS Integration

The `CMWDemoApp` is an XCode production ready demo application that simulates a 
typical partner integration third-party app with the following behavior:

- App opens to a HomeController scene (your "home screen" or "directory")
- Input fields to configure the scene modules
- Buttons to Navigate to CityMotion Webview API endpoints (Location Code and Coordinates)
- Scenes receive your inputs, popup, and load CityMotion
- A back button is provided to dismiss the current scene and return to the Home scene

## Features

- Full support for external links (universal links, deep links)
- Location services permission denied handling and recovery
- iOS 11 support and backwards compatibility

## Location Services Notes

- iOS 11 now prefers requestWhenInUseAuthorization() for basic in-app location permissions
- requestAlwaysAuthorization() requires setup of Capabilities -> Background Modes -> Location Updates
- This Demo App provides Info.plist notes for all four location privacy fields
- As the user moves, the Webview URL changes with the new location coordinates 