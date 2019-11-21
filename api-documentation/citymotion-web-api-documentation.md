# CityMotion Webview - Integration Partner API Documentation**
**Version 1.2.2+**

CityMotion Webview (CMW) provides local real-time mobility information displayed on "cards" in a web app designed to be integrated into other apps. CMW is a HTML5 webpage using the ReactJS framework, which performs standard HTTP calls about every minute to its API to update information.

CMW is designed to be loaded inside a native WebView browser view within your app. Individual cards are responsive with a minimum width of 300px and a maximum width of 500px, to preserve legibility of the information presented. This should accommodate most mobile and tablet device dimensions.  
  
![](https://docs.google.com/drawings/u/2/d/srk9uzTS4DczC1XLPjhRbVQ/image?w=662&h=530&rev=179&ac=1&parent=1ldiMw__g5M9SjEOS0bMHZb7xrZLqV0b3-WrbKrPcsas)


# API Endpoints

This section describes the URL endpoints available and their optional parameters. See the integration section for how to setup your app so these links work properly.

## Location Code Endpoint

GET a CityMotion Webview for a single Location Code  

This endpoint returns a fully-formed HTML webpage (using the React framework), that displays transportation choices at a single physical location associated with a Location Code. The information asynchronously updates every 55 seconds.

 This endpoint does not require location services. If you are using this endpoint, in addition to the API Key, TransitScreen will provide you with a location code you can use to select a location.

 > URL: https://citymotion.io?locationCode={CODE}&key={KEY}
 > Method: GET
 > URL Params:

### Required Parameters

#### key
Usage: `key = (string: your customer key, all lowercase)`
Example: `key=abcdefghijklmopqrstuv`
Description: This Customer Key is provided by TransitScreen to identify your organization and authorize use.  It is only associated with the locationCode you are given.  
#### locationCode
Usage: `locationCode = (string: a short phrase with letters and/or numbers, no spaces, lowercased)`
Example: `locationCode=building123`

### Optional Parameters
See Optional Parameters Guide

### Error handling:

Page will show an error message if location code or customer key is incorrect


## Optional Parameters Guide
These apply to all endpoints in our API.  All optional parameters means these do not need to be included for CityMotion to function properly.  They provide live customization pathways of the webview display.  These features exist on the webpage side, not your app.

### barPosition
Description:  Shows a navigation bar which lets the user filter out cards between different transportation modes.  
Usage: `barPosition = (none, top, bottom)`
Example: `barPosition=top`
Options:
- Default: `none` or do not include this parameter
- `top` shows a navigation bar at the top of the viewport
- `bottom` shows a navigation bar at the bottom of the viewport

### openTo
Description:  Opens the viewport to show only selected transportation modes.  Combined with barPosition, lets the user begin in a particular filter.  Without a barPosition, the user will be permanently stuck in this filter. 
Usage: `openTo = (all, train, bus, bike, car, shuttle)`
Example: `openTo=train`
Options:
 - Default: `all` or do not include this parameter, this will show all card options
 - `train` shows rail type transit such as trolley, streetcar, light rail, commuter trains, Amtrak, etc
 - `bus` shows buses
 - `bike` shows all bikeshare, ebikes, scooters, etc
 - `car` shows all car sharing services such as car2go, zipcar, etc
 - `shuttle` shows any private shuttles that are linked to your account

### externalLinks
Notice: **This feature requires custom native app code, see Custom Third Party Integration Guide**
Description: This will show link buttons to external apps such as Uber.
Usage: `externalLinks = (true, none)`
Example: `externalLinks=true`
Options:
- Default: `none` or do not include this parameter, no link buttons will appear
- `true` All link buttons will appear, **this requires Custom Third Party Integration Guide**

# Custom Third Party Integration Guide

# Frequent Questions

### When should I use barPosition?
- In large cities where there may be too many options, having a filter bar lets users find what they are looking for faster.  

### When should I use openTo?
- This may be helpful if you know your user wants to quickly see popular transit options such as the Subway in New York. 

### Why can't I see a certain transportation or service card?
- Transit may not be running or is available in your area.  If you feel like a service is missing please reach out to us to confirm. 

