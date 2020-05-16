# CityMotion-Plugin Integration Partner API Documentation
**Version 1.2.+**

CityMotion-Plugin provides local real-time transportation information in a web app designed to be integrated into other apps. 

The Plugin loads the CityMotion-Web (CMW) web app, which uses the ReactJS framework.  This app performs standard HTTP calls about every minute to its API to update transportation information and display it on "cards".

CMW is designed to be loaded inside a native WebView browser view within your app or website. Individual cards are responsive with a minimum width of 300px and a maximum width of 500px, to preserve legibility of the information presented. This should accommodate most mobile and tablet device dimensions.

*Use cases:* There are two different use cases, corresponding to different endpoints: LocationCode, which loads information at a fixed location like a building ("hub"); and Coordinates, which loads information at any desired location (latitude/longitude). 

*Levels of integration:* In addition, there are two different levels of integration. The simplest way to use CityMotion-Plugin is "*Basic Integration*," where we supply you with a short link to load in your WebView. Basic integration supports all features except links to external apps. *Advanced integration* allows external app links.

---

# API Endpoints

This section describes the URL endpoints available and their optional parameters. See the Custom Third Party Integration Guide for how to set up your app so these links work properly.

For most basic integrations we will assign a short link in the form of https://citymo.io/{locationCode} and manage the redirection URL. For Advanced Integration partners utilizing the full API, they may proceed to use the features outlined in this document.

## Location Code Endpoint

GET a CityMotion-Web for a single Location Code.  

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

GET a CityMotion-Web at a set of coordinates.

This endpoint returns a fully-formed HTML webpage (using the React framework), that displays transportation choices at the supplied coordinates. The information asynchronously updates every 55 seconds.

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

--

# Levels of Integration

## Basic Integration

In Basic Integration, you load a short link we provide into your Native Webview.
  - All features work except external links. Universal Links typically do work depending on your app's webview policy.
  - This is often a Location Code endpoint. 
  - If you use the Coordinates endpoint, coordinate information must be manually set in the URL. This requires that you have already requested user permission for Location Services, determined the user's latitude and longitude and added those parameters to the URL. This is appropriate for showing a user's location at a specific moment. If you need the app to follow the user's movements, you will need to reload the app with a new URL each time the user moves. 
  
## Advanced Integration

In Advanced Integration, you use the Plugin code we provide to load.
  - All features work including external links (CMW provides plugin to handle external app redirects)
  - This provides full integration with Coordinates endpoint (CMW provides plugin to hook into Location Services)

### iOS

For both LocationCode and Coordinates plugins, the plugin provides external link handler requests. 

The Coordinates plugin provides the following:
- Requests users permission
- Handles if the user rejects permission by redirect them to the LocationServices settings menu
- Passes users location into the CityMotion Webview on a regular interval.  We will only detect significant movements so to prevent over-requesting the API.  

### Android

For both LocationCode and Coordinates plugins, the plugin provides external link handler requests.

--

# Frequent Questions

### When should I use barPosition?
- In large cities where there may be too many options, having a filter bar lets users find what they are looking for faster.  

### When should I use openTo?
- This may be helpful if you know your user wants to quickly see popular transit options such as the Subway in New York. 

### Why can't I see a certain transportation or service card?
- that service may not currently be running or be available in your area.  If you feel like a service is missing please reach out to us to confirm. 

