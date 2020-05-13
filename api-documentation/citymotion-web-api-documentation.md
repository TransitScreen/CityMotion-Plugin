# CityMotion-Plugin Integration Partner API Documentation
**Version 1.2.+**

CityMotion-Plugin provides local real-time mobility information displayed on "cards" in a web app designed to be integrated into other apps. The Plugin loads CityMotion-Web (CMW) which is a HTML5 webpage using the ReactJS framework.  This page performs standard HTTP calls about every minute to its API to update page information.

CMW is designed to be loaded inside a native WebView browser view within your app. Individual cards are responsive with a minimum width of 300px and a maximum width of 500px, to preserve legibility of the information presented. This should accommodate most mobile and tablet device dimensions.  

---

# API Endpoints

This section describes the URL endpoints available and their optional parameters. See the integration section for how to setup your app so these links work properly.

For most minor integration partners we will assign a short link in the form of https://citymo.io/{locationCode} and manage the redirection URL. For major integration partners utilizing the full API, they may proceed to use the features outlined in this document.

## Location Code Endpoint

GET a CityMotion WebView for a single Location Code.  

This endpoint returns a fully-formed HTML webpage (using the React framework), that displays transportation choices at a single physical location associated with a Location Code.  The information is curated by TransitScreen for your users. The information asynchronously updates every 55 seconds.

This endpoint does not require location services. If you are using this endpoint, TransitScreen will provide you an API key and Location Code.

- URL Format: `https://citymotion.io?locationCode={CODE}&key={KEY}{&OPTIONAL_PARAMS}`
- Working Example: `https://citymotion.io?locationCode=cmwdc&key=vurtEDilAilDpbLkciHwQzsGbckHozgQ3aM7HEyK4dtyTitQUAsvgGrwD0G9q8VL`
- Working Example with Optional Parameters: `https://citymotion.io?locationCode=cmwdc&key=vurtEDilAilDpbLkciHwQzsGbckHozgQ3aM7HEyK4dtyTitQUAsvgGrwD0G9q8VL&externalLinks=true&barPosition=bottom&menu=static`
- Method: `GET`

### Required Parameters

At minimum, an API call requires a customer `key` and a location to be set (either `locationCode` or `coordinates`).

#### key
- Description: This Customer Key is provided by TransitScreen to identify your organization and authorize use.  It is only associated with the locationCode you are given.  
- Parameter Name: `key`
- Parameter Values:
  - String: A 64-character customer key given to you by TransitScreen, all lowercase, no spaces, may contain numbers
- Example: `key=abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz01`

#### locationCode
- Description: Your Location Code is provided by TransitScreen to identify your custom Hub screen to show the user. This parameter should be set alone with the key. If this parameter is set with a `coordinates` value, it will override and only send back Hub screen content.
- Parameter Name: `locationCode`
- Parameter Values:
  - String: A short phrase with letters and/or numbers, no spaces, lowercased
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

- URL Format: `https://citymotion.io?coordinates={LATITUDE},{LONGITUDE}&key={KEY}{&OPTIONAL_PARAMS}`
- Working Example: `https://citymotion.io?coordinates=38.9,-77.03&key=vurtEDilAilDpbLkciHwQzsGbckHozgQ3aM7HEyK4dtyTitQUAsvgGrwD0G9q8VL`
- Working Example with Optional Parameters: `https://citymotion.io?coordinates=38.9,-77.03&key=vurtEDilAilDpbLkciHwQzsGbckHozgQ3aM7HEyK4dtyTitQUAsvgGrwD0G9q8VL&menu=static&barPosition=bottom`
- Method: `GET`

### Required Parameters

#### key
- Description: This Customer Key is provided by TransitScreen to identify your organization. Your key must be authorized to use coordinates endpoint. 
- Parameter Name: `key`
- Parameter Values:
  - String: A 64-character customer key given to you by TransitScreen, all lowercase, no spaces, may contain numbers
- Example: `key=abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz01`

#### coordinates
- Description: A set of latitude and longitude separated by comma. We prefer values are truncated to 4 decimal places (ie: 0.0001). This parameter must be set alone with the above key.  It will be overriden in the presence of `locationCode`. 
- Parameter Name: `coordinates`
- Parameter Values:
  - String: Numeric latitude and longitude coordinates, no spaces, separated by a comma.
- Example: `coordinates=38.9019,-77.0389`

#### Optional Parameters
See Optional Parameters Guide

### Error Handling
Page will show an error message if the customer key is incorrect.  

---

## Optional Parameters Guide
These apply to all endpoints in our API.  All optional parameters means these do not need to be included for CityMotion to function properly.  They provide live customization pathways of the webview display.  These features exist on the webpage side, not your app.

### Card Maps (maps)
- Description:  A card pop-up that displays an interactive map.  Accessed through tapping on a card header map icon. 
- Requirements: None, uses client-side Mapbox
- Parameter Name: `maps`
- Parameter Values:
  + Default: `none` or do not include this parameter. Maps not enabled.
  + `true`: Enables maps
- Example: `maps=true`

### UI Theme "Dark Mode" (ui)
- Description:  Changes the color theme to the specified mode.  Currently enables a dark mode. Default theme is light.
- Requirements: None
- Parameter Name: `ui`
- Parameter Values:
  - Default: `light` or do not include this parameter. Shows the default light theme.
  - `dark` changes the color theme to a Dark Mode
- Example: `ui=dark`

### Navigation Bar (barPosition)
- Description:  Shows a navigation bar which lets the user navigate between different transportation categories.
- Requirements: None
- Parameter Name: `barPosition` 
- Parameter Values: 
  - Default: `none` or do not include this parameter. No bar appears.
  - `top` shows a navigation bar at the top of the viewport
  - `bottom` shows a navigation bar at the bottom of the viewport
- Example: `barPosition=top`

### Landing View (openTo)
- Description:  Opens the viewport to specified transportation category.  Combined with Navigation Bar, lets the user begin in a particular landing view.  Without a Navigation Bar, the user will be permanently shown only the specified category.
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
- Description: Displays a header that describes the user's current location and some options allow for changing the location of nearby transportation options.  
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
  
# Custom Third Party Integration Guide
CityMotion Webview (CMW) is intended to work inside your third-party native mobile apps (Customer App).  We define two levels of integration:

- Minor Integration - Customer loads a short link in their Native Webview 
  - TransitScreen provides a short link that redirects to the final API. We manage the content and features delivered on your short link. 
  - All features work except external links (which require Custom code).  Universal Links typically do work depending on your app's webview policy.
  - This is typically a Location Code endpoint installation.
  - Coordinates endpoints can work but coordinate information must be manually set in the URL. This is appropriate for showing a user's location at a specific moment. This experience will not follow the user around and for example, the page must be reloaded with a new URL each time the user does move.
  
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

- Route Alerts: Card rows will show agency alerts when available.  This core feature is available only in select markets currently in Boston and New York City. 
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

