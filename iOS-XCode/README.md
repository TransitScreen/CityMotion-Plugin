# CityMotion Webview for iOS Integration

**Version 1.0.0**

The `CMWDemoApp` is an XCode production ready demo application that simulates a 
typical partner integration third-party app with the following behavior:

- App opens to a landing page (your "home screen" or "directory")
- A tappable button can navigate to the CityMotion Webview scene
- The scene presents itself and loads CityMotion Webview
- A back button is provided to escape back to the previous scene

## CMWController Module

At the core of this demo app is the CMWController file which is a 
self-contained module view controller that can be dropped into any application.  

- Simply create a new empty scene and reference this view controller
- All required code is included including support for external links
- Initializes all the necessary views for the scene
- Versioning provided in the code comment header

## Customization

### Viewport
By default the module will takeover an entire scene's width-height dimensions and 
therefore the phone's viewport dimensions.  You can change these dimensions in the 
XXXXXX 
however note the transportation information cards are designed for a minimum 300 pixel width.

## TestFlight

We have published this app in TestFlight under the name "CityMotionWeb Demo App".
Please contact us for access. 

## Versioning

This GitHub repository will reflect the latest published changes.
