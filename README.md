# CityMotion Plugin Documentation and Code Examples

This documentation and code is intended to help partner mobile apps integrate CityMotion Plugin. 

An API key and partner agreement are required - please email sales@transitscreen.com.

Once you have those, **please [review this documentation](https://github.com/TransitScreen/CityMotion-Webview/blob/master/api-documentation/citymotion-web-api-documentation.md)** which will tell you what you need to know about the API and different endpoints you can use.

## Core features

- Responsive Column Design: Columns will break depending on the device resolution. Mobile has 1 column, tablet has 2 or 3 columns, and desktops beyond have up to 4 columns.
- Auto Updating: About every 55 seconds, the web application will request new arrival data from the API and asynchronously update cards. There is no need to auto-refresh the page.  For Location Codes, only row data is affected.  For Coordinates calls, cards may appear or disappear if the user is moving.
- Show more routes: Cards that have an large number of options will show more upon tapping a footer button. 
- Show all departure times: The first two departures will be shown by default; card rows can be tapped to expand to show all predictions.
- Route Alerts: Card rows will show agency alerts when available.
- Update Recovery: In the event of network connection interruption or slowdown, we will automatically retry loading cards, with an intelligent back-off schedule.

# Need help?
support@transitscreen.com 
