# CityMotion Plugin App for iOS WebView Integration

`CMPlugin` is a working iOS app environment that demonstrates the Plugin Modules to be used in your app.  Plugins support a basic WebView loading the CityMotion-Webapp (React).  The Webapp provides the full CityMotion web experience and only relies on native code when WebView cannot provide functionality.  This demonstration app is setup to mimic a typical multi-screen user dashboard app such as a tenant experience app.

# Plugin Modules

Refer to the [API Documentation](https://github.com/TransitScreen/CityMotion-Plugin/blob/master/api-documentation/citymotion-web-api-documentation.md) for full CityMotion-Webapp API endpoints and additional parameters.  This guide only briefly notes where endpoints and parameters interact with native code.

## CMPlugin-Coordinates

View Controller which generates a WebView showing transportation options at the user's location. The Webapp continues to follow real-time location updates from the user's device.

API Endpoint: `https://citymotion.io/partner?`

API Parameters: `&key={API_KEY}&coordinates={LAT},{LNG}&{ADDITIONAL_PARAMS}`

Working Example: https://citymotion.io/?key=vurtEDilAilDpbLkciHwQzsGbckHozgQ3aM7HEyK4dtyTitQUAsvgGrwD0G9q8VL&coordinates=38.9072,-77.0369&barPosition=bottom

Affected Parameters Native Handlers:
- `coordinates={LAT},{LNG}` and `menu=anywhere`
  - Location Updates Handler to pass real-time user coordinates to WebView
  - Location Services Permissions Handler with recovery during user denial. If not used, permissions must be enabled prior to landing on the webview screen.
- `externalLinks=true`
  - External App Link Handler for universal links and deep links such as Uber, Lyft, Mobile Ticketing, etc

## CMPlugin-LocationCode

View Controller which generates a WebView showing transportation options at the specific location code (called a Hub).  The Webapp continues to serve updates only at that location.

API Endpoint: `https://citymotion.io/partner?`

API Parameters: `&key={API_KEY}&locationCode={LOCATION_CODE}`

Working Example: https://citymotion.io/?key=vurtEDilAilDpbLkciHwQzsGbckHozgQ3aM7HEyK4dtyTitQUAsvgGrwD0G9q8VL&locationCode=cmwdc

Affected Parameters Native Handlers:
- `locationCode={LOCATION_CODE}`
  - No Location Services is needed for this Module. 
- `externalLinks=true`
  - External App Link Handler for universal links and deep links such as Uber, Lyft, Mobile Ticketing, etc

# Plugin Feature Support

Modules also provides optional scene scaffolding support: 
- Automatic initialization of UI elements in the View
- General iOS version related compatibility support

Code notes will provide direction in regards to what functionality each code block serves.  We recognize you may ultimately implement alternative ways to provide the noted feature support and scaffolding.  Please reach out to your technical contact if you have questions.  

# Base App Requirements

Cookies:
  - Many parameters rely on Cookies to save user data. All iOS versions automatically allow and store WebView cookies.  As of iOS 11, note that HTTPCookieStorage is not confined to the WebView, therefore do not clear out this cookie in your app or the user will lose preferences.

Location Services (only for CMPlugin-Coordinates):
  - `requestAlwaysAuthorization()` requires enabling of Capabilities -> Background Modes -> Location Updates
  - `Info.plist` should set all four location privacy fields

External App Linking:
  - The native code handler avoids calling canOpenURL (LSApplicationQueriesSchemes) by trying to directly open up the app and if failing, falls back to redirecting the user to the an embedded App Store link.  

# ChangeLog Notes 

- As the user moves, Location Updates now pass the location directly to the webpage via , instead of reloading the URL as previously implemented
- iOS 11 now prefers using `requestWhenInUseAuthorization()` to request location permissions
- Uses Apple recommended WKWebView implementation instead of UIWebView
