# CityMotion-Plugin Integration Partner API Documentation
**Version 1.2.+**

CityMotion-Plugin provides local real-time mobility information displayed on "cards" in a web app designed to be integrated into other apps. The Plugin loads CityMotion-Web (CMW) which is a HTML5 webpage using the ReactJS framework.  This page performs standard HTTP calls about every minute to its API to update page information.

CMW is designed to be loaded inside a native WebView browser view within your app. Individual cards are responsive with a minimum width of 300px and a maximum width of 500px, to preserve legibility of the information presented. This should accommodate most mobile and tablet device dimensions.  

---

# API Endpoints

This section describes the URL endpoints available and their optional parameters. See the integration section for how to setup your app so these links work properly.

## Location Code Endpoint

GET a CityMotion WebView for a single Location Code.  

This endpoint returns a fully-formed HTML webpage (using the React framework), that displays transportation choices at a single physical location associated with a Location Code.  The information is curated by TransitScreen for your users. The information asynchronously updates every 55 seconds.

This endpoint does not require location services. If you are using this endpoint, TransitScreen will provide you an API key and Location Code.

- Usage: `https://citymotion.io?locationCode={CODE}&key={KEY}{&OPTIONAL_PARAMS}`
- Base Example: `https://citymotion.io?locationCode=building123&key=abcdefghijklmopqrstuv`
- Example with Parameters: `https://citymotion.io?locationCode=building123&key=abcdefghijklmopqrstuv&externalLinks=true&barPosition=top`
- Method: `GET`

### Required Parameters

#### key
- Description: This Customer Key is provided by TransitScreen to identify your organization and authorize use.  It is only associated with the locationCode you are given.  
- Usage: `key = (string: your customer key, all lowercase)`
- Example: `key=abcdefghijklmopqrstuv`

#### locationCode
- Description: Your Location Code is provided by TransitScreen to identify your custom Hub screen to show the user.   
- Usage: `locationCode = (string: a short phrase with letters and/or numbers, no spaces, lowercased)`
- Example: `locationCode=building123`

#### Optional Parameters
See Optional Parameters Guide

### Error Handling
Page will show an error message if location code or customer key is incorrect.

## Coordinates Endpoint

GET a CityMotion Webview at a set of coordinates.

This endpoint returns a fully-formed HTML webpage (using the React framework), that displays transportation choices at the supplied coordinates.  The information is curated by TransitScreen for your users. The information asynchronously updates every 55 seconds.

Obtain your user’s Location Services latitude and longitude and pass the information to the endpoint URL string.  If the user changes location, the webpage will not update to the user’s location.   You must update the URL string with the new coordinates and reload the WebView.  

If you use both locationCode and coordinates endpoints, the locationCode will override the coordinates.

- Usage: `https://citymotion.io?coordinates={LATITUDE},{LONGITUDE}&key={KEY}{&OPTIONAL_PARAMS}`
- Base Example: `https://citymotion.io?coordinates=38.9,-77.03&key=abcdefghijklmopqrstuv`
- Example with Parameters: `https://citymotion.io?coordinates=38.9,-77.03&key=abcdefghijklmopqrstuv&externalLinks=true&barPosition=top`
- Method: `GET`

### Required Parameters

#### key
- Description: This Customer Key is provided by TransitScreen to identify your organization and authorize use.  It is only associated with the locationCode you are given.  
- Usage: `key = (string: your customer key, all lowercase)`
- Example: `key=abcdefghijklmopqrstuv`

#### coordinates
- Description: A set of latitude and longitude separated by comma. We prefer values are truncated to 4 decimal places (ie: 0.0001).
- Usage: `coordinates = (string: only numbers, no spaces)`
- Example: `coordinates=38.9019,-77.0389`

#### Optional Parameters
See Optional Parameters Guide

### Error Handling
Page will show an error message if the customer key is incorrect.  

---

## Optional Parameters Guide
These apply to all endpoints in our API.  All optional parameters means these do not need to be included for CityMotion to function properly.  They provide live customization pathways of the webview display.  These features exist on the webpage side, not your app.

### UI Theme "Dark Mode" (ui)
- Description:  Changes the color theme to the specified mode.  Currently enables a dark mode. Default theme is light.
- Requirements: None
- Usage: `ui = (dark, none)`
- Default: Not enabled if not specified.
- Example: `ui=dark`
- Options:
  - Default: `none` or do not include this parameter, will show the default light theme
  - `dark` changes the color theme to a Dark Mode

### Navigation Bar (barPosition)
- Description:  Shows a navigation bar which lets the user navigate between different transportation categories.
- Requirements: None
- Usage: `barPosition = (none, top, bottom)`
- Default: Not enabled if not specified.
- Example: `barPosition=top`
- Options:
  - Default: `none` or do not include this parameter
  - `top` shows a navigation bar at the top of the viewport
  - `bottom` shows a navigation bar at the bottom of the viewport

### Landing View (openTo)
- Description:  Opens the viewport to specified transportation category.  Combined with Navigation Bar, lets the user begin in a particular landing view.  Without a Navigation Bar, the user will be permanently shown only the specified category.
- Requirements: None
- Usage: `openTo = (all, train, bus, bike, car, shuttle)`
- Example: `openTo=train`
- Options:
  - Default: `all` or do not include this parameter, this will show all card options
  - `train` shows rail type transit such as trolley, streetcar, light rail, commuter trains, Amtrak, etc
  - `bus` shows buses
  - `bike` shows all bikeshare, ebikes, scooters, etc
  - `car` shows all car sharing services such as car2go, zipcar, etc
  - `shuttle` shows any private shuttles that are linked to your account

### Card Favorites (favorites)
- Description: Allows users to favorite cards.  Adds a star icon to the header of each card.  Tapping on the star icon will "favorite" the card and store the card in browser cookie memory.  The next time the user returns, the card will be prioritized to the top and the star will remain selected. 
- Requirements: Should work with the default cookie preservation behavior of WebView Safari. Do not clear session cookies.
- Usage: `favorites = (true)` 
- Example: `favorites=true`
- Options:
  - Default: `none` or do not include this parameter, stars will not appear
  - `true` enables this feature

### External App Links (externalLinks)
- Notice: **This feature requires custom native app code, see Custom Third Party Integration Guide**
- Description: This will show link buttons to external apps such as Uber.
- Requirements: Requires custom native app code.  Without this code, buttons will do nothing.
- Usage: `externalLinks = (true, none)`
- Example: `externalLinks=true`
- Options:
  - Default: `none` or do not include this parameter, no link buttons will appear
  - `true` All link buttons will appear, **this requires Custom Third Party Integration Guide**
  
# Custom Third Party Integration Guide
CityMotion Webview (CMW) is intended to work inside your third-party native mobile apps (Customer App).  We define two levels of integration:

- Minor Integration - Customer loads the CMW URL in their Native Webview 
  - All features work except external links (which are blocked by native webview policy)
  - Limited integration with Coordinates endpoint (Customer must pass in latitude and longitude from outside)
  
- Major Integration - Customer loads the CMW with Plugin code
  - All features work including external links (CMW provides plugin to handle external app redirects)
  - Full integration with Coordinates endpoint (CMW provides plugin to hook into Location Services)

The full CMW experience **requires Major Integration** especially for the highly requested **external links** feature. 

## Major Integration

### iOS

For both LocationCode and Coordinates plugins, the plugin provides external link handler requests. 

The Coordinates plugin provides the following:
- Requests users permission
- Handles if the user rejects permission by redirect them to the LocationServices settings menu
- Passes users location into the CityMotion Webview on a regular interval.  We will only detect significant movements so to prevent over-requesting the API.  

### Android

For both LocationCode and Coordinates plugins, the plugin provides external link handler requests.

## Minor Integration

### iOS and Android
- Simply load a Location Code URL in your Webview
- The Coordinates URL requires that you have already requested user permission for Location Services, determined the user's latitude and longitude and added those parameters to the URL.

# Core Features

CMW has built-in core features that allow the user experience to be more useful in accessing information. These may be behaviors already noted in this documentation.

- Row Tap to Expand: Card rows will expand to show more prediction information available from the API than the first two predictions.  Tapping again will collapse it.
- See More Card Rows: Stops that have an excessive amount of incoming vehicle routes will be hidden and a footer button will be available to expand to see these additional rows. 
- Responsive Column Design: Columns will break depending on the device resolution. Mobile has 1 column, tablet has 2 or 3 columns, and desktops beyond have up to 4 columns.
- Auto Updating: About every 55 seconds, the web application will request new arrival data from the API and asynchronously update cards. There is no need to auto-refresh the page.  For Location Codes, only row data is affected.  For Coordinates calls, cards may appear or disappear if the user is moving.
- Update Recovery: In the event of network connection interruption or slowdown, the updater will back off and continue re-attempting to call the server for new API data. 

# Frequent Questions

### When should I use barPosition?
- In large cities where there may be too many options, having a filter bar lets users find what they are looking for faster.  

### When should I use openTo?
- This may be helpful if you know your user wants to quickly see popular transit options such as the Subway in New York. 

### Why can't I see a certain transportation or service card?
- Transit may not be running or is available in your area.  If you feel like a service is missing please reach out to us to confirm. 

