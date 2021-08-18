# CityMotion-Plugin Documentation

**Version 1.5.+**

CityMotion-Plugin wrapper code on iOS or Android provides local real-time transportation information in a web app designed to be integrated into other apps.  The Plugin loads the CityMotion-Web (CMW) web app, which runs on a ReactJS framework.  This app performs standard HTTP calls about every minute to update transportation information and display it on "cards".

# Core Features

- Individual cards display information and are responsive with a minimum width of 300px and a maximum width of 500px. This should accommodate most mobile and tablet device dimensions.
- Responsive design: Columns will break depending on the device resolution. Mobile has 1 column, tablet has 2 or 3 columns, and desktops beyond have up to 4 columns.
- Auto updating: About every 55 seconds, the web application will request new arrival data and asynchronously update cards. There is no need to auto-refresh the page.  For Location Codes, only row data is affected.  For Coordinates calls, cards may appear or disappear if the user is moving.
- Show more routes: Cards that have an large number of options will show more upon tapping a footer button. 
- Show all departure times: The first two departures will be shown by default; card rows can be tapped to expand to show all predictions.
- Route alerts: Card rows will show agency alerts when available.
- Update recovery: In the event of network connection interruption or slowdown, we will automatically retry loading cards, with an intelligent back-off schedule.

# Base URL

To clarify the base URL domains used in this documentation: 

- https://citymo.io is our short link service that conceals the longer endpoint URL. Most users with a basic integration will be given this URL.

- https://citymotion.io is the direct endpoint which is appended query parameters. It is preferred only advanced integration users use this endpoint. 

# Integration Use Cases

CityMotion-Plugin is intended to be used in the following ways:

1. *Location Code* - A URL referencing a `locationCode` that provides a fixed location with pre-determined cards (ie: https://citymo.io/{LOCATION_CODE} or https://citymotion.io/?key={KEY}&locationCode={LOCATION_CODE})

  - *In-App* - Load this URL in a WebView inside your third-party app. This supports most features except for external app links.

  - *In-App with Plugin Code* - Load this URL in a WebView using our Plugin wrapper code.  This supports all features including external app links. 

  - *External Browser* - Load this URL in a Safari browser (triggered from your app). This supports all features without use of wrapper code. 

2. *Coordinates* - A URL referencing a `coordinates` (latitude, longitude) that will query our API for information at that spot. (ie: http://citymotion.io/?key={KEY}&coordinates={LAT,LNG})  

  - *In-App* - Load this URL in a WebView inside your third-party app. This supports most features except for external app links.

  - *In-App with Plugin Code* - Load this URL in a WebView using our Plugin wrapper code.  This supports all features including external app links. 

  - *External Browser* - Load this URL in a Safari browser (triggered from your app). This supports all features without use of wrapper code. 

3. *Geolocation* - A URL flagged with `geolocation=true` that will attempt to ask the user's browser for their current location. (ie: http://citymotion.io/?key={KEY}&geolocation=true) 

  - *In-App* - This method is not supported, it requires Plugin Code. 

  - *In-App with Plugin Code* - Our Plugin wrapper code will automatically begin sending geolocation information to the WebView. 

  - *External Browser* - Load this URL in a Safari browser (triggered from your app). This supports all features without use of wrapper code. 

# Endpoints

This section describes the endpoints available and their optional parameters. For *In-App with Plugin Code* integrations, see README files inside Android-Studio or iOS-XCode respective.

For most basic integrations we will assign a short link in the form of https://citymo.io/{locationCode} and manage the redirection URL. Advanced Integration partners can use all the features outlined in this document.

===

## Location Code Endpoint

This endpoint returns the CMW web app that displays transportation choices at a single physical location associated with a Location Code.  The information is curated by TransitScreen for your users.  This endpoint does not require location services. If you are using this endpoint, TransitScreen will provide you an API key and Location Code.

- URL Format: `https://citymotion.io?locationCode={CODE}&key={KEY}{&OPTIONAL_PARAMS}`

- Working Example: `https://citymotion.io?locationCode=cmwdc&key=vurtEDilAilDpbLkciHwQzsGbckHozgQ3aM7HEyK4dtyTitQUAsvgGrwD0G9q8VL`

- Working Example with Optional Parameters: `https://citymotion.io?locationCode=cmwdc&key=vurtEDilAilDpbLkciHwQzsGbckHozgQ3aM7HEyK4dtyTitQUAsvgGrwD0G9q8VL&externalLinks=true&barPosition=bottom&menu=static`

*Required Parameters*

- `key` - This Key is provided by TransitScreen to identify your organization and authorize use.  It is only associated with the locationCode you are given. Example: `key=abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz01`

- `locationCode` - Your Location Code identifies your custom Hub screen to show the user. Only use this parameter alone to identify your location as this parameter overrides `coordinates` if both are present. Example: `locationCode=building123`

- Also see [Optional Parameters](#optional-parameters-guide) below

===

## Coordinates Endpoint

This endpoint returns the CMW web app that displays transportation choices at the supplied coordinates. Do not use the `locationCode` parameter in the URL as it will override the coordinates.

- URL Format: `https://citymotion.io?coordinates={LATITUDE},{LONGITUDE}&key={KEY}{&OPTIONAL_PARAMS}`

- Working Example: `https://citymotion.io?coordinates=38.9,-77.03&key=vurtEDilAilDpbLkciHwQzsGbckHozgQ3aM7HEyK4dtyTitQUAsvgGrwD0G9q8VL`

- Working Example with Optional Parameters: `https://citymotion.io?coordinates=38.9,-77.03&key=vurtEDilAilDpbLkciHwQzsGbckHozgQ3aM7HEyK4dtyTitQUAsvgGrwD0G9q8VL&menu=static&barPosition=bottom&maps=true`

*Required Parameters*

- `key` - Provided by TransitScreen to identify your organization. Your key must be authorized to use coordinates endpoint. Example: `key=abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz01`

- `coordinates` - A set of latitude and longitude separated by comma. We prefer values are truncated to 4 decimal places (ie: 0.0001). This parameter must be set alone with the above key.  It will be overriden in the presence of `locationCode`. Example: `coordinates=38.9019,-77.0389`

- Also see [Optional Parameters](#optional-parameters-guide) below.

===

## Geolocation Endpoint

This endpoint returns the CMW web app and requests the browser's geolocation service. Do not use the `coordinates` or `locationCode` parameter in the URL as it will override this endpoint.  This endpoint may only be used in standalone browsers such as Safari, Chrome, and Firefox.  For usage *In-App* it requires our custom Plugin wrapper code as iOS WebViews do not allow permission to access geolocation without custom code.

- URL Format: `https://citymotion.io?geolocation=true&key={KEY}{&OPTIONAL_PARAMS}`

- Working Example: `https://citymotion.io?geolocation=true&key=vurtEDilAilDpbLkciHwQzsGbckHozgQ3aM7HEyK4dtyTitQUAsvgGrwD0G9q8VL`

- Working Example with Optional Parameters: `https://citymotion.io?geolocation=true&key=vurtEDilAilDpbLkciHwQzsGbckHozgQ3aM7HEyK4dtyTitQUAsvgGrwD0G9q8VL&menu=anywhere&barPosition=bottom&maps=true`

*Required Parameters*

- `key` - Provided by TransitScreen to identify your organization. Your key must be authorized to use coordinates endpoint. Example: `key=abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz01`

- `geolocation=true` - This triggers the app to request the browser geolocation.

- Also see [Optional Parameters](#optional-parameters-guide) below.

===

## Optional Parameters Guide
These features enhance CityMotion by enabling additional functionality in its web app, but are not required for it to function properly. They apply to all API endpoints.

### Card Maps (maps)
- Description:  Enables a pop-up that displays an interactive map when the user taps the map icon on a card header.
- Requirements: None, uses client-side Mapbox
- Parameter Name: `maps`
- Parameter Values:
  + Default: `none` or do not include this parameter. Maps not enabled.
  + `true`: Enables maps
- Example: `maps=true`

### UI Theme (ui)
- Description:  Changes the color theme to the specified mode.  Currently enables a dark mode. Default theme is light.
- Requirements: None
- Parameter Name: `ui`
- Parameter Values:
  - Default: `light` or do not include this parameter. Shows the default light theme.
  - `dark` changes the color theme to a Dark Mode
- Example: `ui=dark`

### Navigation Bar (barPosition)
- Description:  Shows a navigation bar which lets the user navigate between different transportation modes such as buses and trains.
- Requirements: None
- Parameter Name: `barPosition` 
- Parameter Values: 
  - Default: `none` or do not include this parameter. No bar appears.
  - `top` shows a navigation bar at the top of the viewport
  - `bottom` shows a navigation bar at the bottom of the viewport
- Example: `barPosition=top`

### Landing View (openTo)
- Description:  Opens the viewport to specified transportation category.  Combined with Navigation Bar, lets the user begin in a particular transportation mode.  If Navigation Bar is not enabled, the user will not be able to change which mode is being shown.
- Requirements: None
- Parameter Name: `openTo`
- Parameter Values:
  - Default: `all` or do not include this parameter. All cards will appear.
  - `train` shows rail type transit such as trolley, streetcar, light rail, commuter trains, Amtrak, etc
  - `bus` shows buses
  - `bike` shows all bikeshare, ebikes, scooters, etc
  - `car` shows all car sharing services such as car2go, zipcar, etc
  - `shuttle` shows any private shuttles that are linked to your account
- Example: `openTo=train`

### Card Favorites (favorites)
- Description: Allows users to favorite cards.  Adds a star icon to the header of each card.  Tapping on the star icon will "favorite" the card and store the card in browser cookie memory.  The next time the user returns, the card will be prioritized to the top and the star will remain selected. 
- Requirements: Cookies allowed. Should work with the default cookie preservation behavior of WebView Safari. Do not clear session cookies.
- Parameter Name: `favorites` 
- Parameter Values:
  - Default: `none` or do not include this parameter. Favorite icon will not appear and cards will not be sorted by favorites.
  - `true` enables this feature
- Example: `favorites=true`

### Location Header (menu)
- Description: Displays a header that lets the user change their current location to a different location by searching. If using the locationCode API, the user can change to any authorized hub location. If using the Coordinates API, the user can change to any location.  
- Requirements: Cookies allowed. Should work with the default cookie preservation behavior of WebView Safari. Do not clear session cookies.
- Parameter Name: `menu` 
- Parameter Values:
  - Default: `none` or do not include this parameter. No header will appear.
  - `static` simply displays address information about the current location code or coordinates given by the URL
  - `hub` allows a dropdown toggle to switch between location codes attached to the customer key given
  - `anywhere` allows a fully-featured location search dropdown that will save search results for later access
- Example: `menu=anywhere`

### External App Links (externalLinks)
- Notice: **This feature requires custom native app code, see Custom Third Party Integration Guide**
- Description: This will show link buttons to external apps such as Uber.
- Requirements: Requires custom native app code.  Without this code, buttons will either do nothing, or navigate by behavior of a Universal Link.
- Parameter Name: `externalLinks`
- Parameter Values:
  - Default: `none` or do not include this parameter, no link buttons will appear
  - `universal` only buttons with an https address will appear (ie: Uber, Lyft), **this does not necessarily require Custom code but may produce unintended results if the user does not have the external app downloaded**
  - `true` all link buttons will appear, **this requires Custom Third Party Integration Guide to navigate users to external apps**
Example: `externalLinks=true`

### Language (lang)
- Description: Translates all text into the target language. 
- Requirements: The app supports a limited number of languages and only the ones specified here at this time.
- Parameter Name: `lang` 
- Parameter Values:
  - Default: `none` or do not include this parameter. Defaults to US English.
  - `fr` Standard French
  - `fr_ca` Canadian French
- Example: `lang=fr`

# In-App Integration

This section further details *In-App* integrations of CityMotion-Plugin in your third party application (WebView).

## Basic Integration

In Basic Integration, you load a short link we provide into your Native Webview.
  - All features work except external links. Universal Links typically do work depending on your app's webview policy.
  - This is often to display a Location Code endpoint. 
  - With the Coordinates endpoint, the app does not continue to track the user.  
  
## Advanced Integration

In Advanced Integration, you use the Plugin code we provide to load.
  - All features work including external links (CMW provides plugin to handle external app redirects)
  - This provides full integration with Coordinates endpoint and continues to track the user's location (CMW provides plugin to hook into Location Services)

### iOS

For both LocationCode and Coordinates plugins, the plugin provides external link handler requests. 

The Coordinates plugin provides the following:
- Requests users permission
- Handles if the user rejects permission by redirect them to the LocationServices settings menu
- Passes users location into the CityMotion Webview on a regular interval.  We will only detect significant movements so to prevent over-requesting the API.  

### Android

For both LocationCode and Coordinates plugins, the plugin provides external link handler requests.

===

# Frequently Asked Questions

### When should I use barPosition?
- In large cities where there may be too many options, having a filter bar lets users find what they are looking for faster.  

### When should I use openTo?
- This may be helpful if you know your user wants to quickly see popular transit options such as the Subway in New York. 

### Why can't I see a certain transportation or service card?
- That service may not currently be running or be available in your area.  If you feel like a service is missing please reach out to us to confirm. 