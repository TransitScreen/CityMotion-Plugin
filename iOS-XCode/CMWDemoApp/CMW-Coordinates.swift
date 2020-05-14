//
//  CityMotion Plugin Demo App
//
//  CMW-Coordinates.swift
//  View Controller Module
//
//  For CMW Documentation v1.2.*
//  Copyright © 2019 TransitScreen. All rights reserved.
//

import Foundation

import UIKit
import WebKit
import CoreLocation

class CMWCoordinatesController: UIViewController, WKUIDelegate, WKNavigationDelegate, CLLocationManagerDelegate {
    
    // MARK: CityMotion WebView URL values for Location Code
    var cityMotionWebviewKey = ""
    var cityMotionParameters = ""

    // MARK: Production root URL, no need to change unless instructed to
    // /partner path is required now to establish a context for webview only features
    var cityMotionWebviewBaseURL = "https://citymotion.io/partner"

    // MARK: Scene UI
    var safeAreaView: UIView!
    var browserView: UIView!
    var navigationBar: UINavigationBar!
    
    var locationManager: CLLocationManager!
    var webView: WKWebView!
    var loadingSpinner: UIActivityIndicatorView!
    
    var alertPopup: UIAlertController!
    
    var firstUpdate: Bool!
    var allowUpdate: Bool!
    
    var lat: Double!
    var long: Double!

    let cityMotionWhiteColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)

    override func loadView() {
        super.loadView()
        
        self.firstUpdate = true
        self.allowUpdate = true
        
        // MARK: Create Safe Area View
        let safeAreaView = UIView(frame: .zero)
        safeAreaView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(safeAreaView)
        if #available(iOS 11.0, *) {
            // Safe area should reliably handle notches and iOS 13 card stacking
            NSLayoutConstraint.activate([
                safeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                safeAreaView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                safeAreaView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                safeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            ])
        } else {
            // Older iOS 10 just offset the top anchor from status bar
            let topOffset = UIApplication.shared.statusBarFrame.height
            NSLayoutConstraint.activate([
                safeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topOffset),
                safeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                safeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                safeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            ])
        }
        self.safeAreaView = safeAreaView
        
        // MARK: Add header bar with back button
        
        let navigationBar = UINavigationBar(frame: .zero)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        self.safeAreaView.addSubview(navigationBar)
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: self.safeAreaView.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: self.safeAreaView.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: self.safeAreaView.trailingAnchor),
        ])
        self.navigationBar = navigationBar
        
        // MARK: Add wrapper view below header bar to contain the webview "browser"
        let browserView = UIView(frame: .zero)
        browserView.translatesAutoresizingMaskIntoConstraints = false
        self.safeAreaView.addSubview(browserView)
        NSLayoutConstraint.activate([
            browserView.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor),
            browserView.bottomAnchor.constraint(equalTo: self.safeAreaView.bottomAnchor),
            browserView.leadingAnchor.constraint(equalTo: self.safeAreaView.leadingAnchor),
            browserView.trailingAnchor.constraint(equalTo: self.safeAreaView.trailingAnchor),
        ])
        self.browserView = browserView
        
        let loadingSpinner = UIActivityIndicatorView(frame: .zero)
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        self.browserView.addSubview(loadingSpinner)
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: self.browserView.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: self.browserView.centerYAnchor),
        ])
        loadingSpinner.startAnimating()
        self.loadingSpinner = loadingSpinner
        
        // MARK: Add WKWebView
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.browserView.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.browserView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.browserView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: self.browserView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.browserView.trailingAnchor),
        ])
        self.webView = webView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Ask for Location Services permission
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // Request Always if you are configuring background modes in Capabilities
        locationManager.startUpdatingLocation()
//        locationManager.allowsBackgroundLocationUpdates = true

        // MARK: Initialize Navigation Bar
        let navItems = UINavigationItem.init(title: "CityMotion")
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.done, target: self, action: #selector(dismissView(sender:)))
        navItems.setLeftBarButton(backButton, animated: true)
        self.navigationBar.items = [navItems]
        
        // MARK: Initialize WebView
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        // MARK: Disable web view caching as CityMotion has continuous deployment
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }
    
    @objc func dismissView(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingSpinner.stopAnimating()
    }
    
    // MARK: External Link Handlers
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let requestUrlString = navigationAction.request.url?.absoluteString {
            print("Request Url String", requestUrlString)
            
            if (requestUrlString.contains("CM_UNIVERSAL_LINK") || requestUrlString.contains("CM_URI")) {
                // Send all links to UIApplication if possible, method avoids canOpenURL which requires Info.plist query permissions
                if let requestUrl = navigationAction.request.url {
                    UIApplication.shared.open(requestUrl, options: [:], completionHandler: {
                        (success) in
                        if success == false {
                            // Link failed so try to obtain and open the App Store Link passed from CityMotion
                            if let range = requestUrlString.range(of: #"(?<=APP_STORE_LINK=).*$"#,
                                                            options: .regularExpression) {
                                print("App Store Link", requestUrlString[range])
                                if requestUrlString[range].isEmpty == false {
                                    if let appStoreLink = URL(string: String(requestUrlString[range])) {
                                        UIApplication.shared.open(appStoreLink, options: [:], completionHandler: nil)
                                    }
                                }
                            }
                        }
                    })
                }
                // decidePolicyFor ALWAYS needs a decision
                // Cancel link for both successful and non-successful external link tries
                decisionHandler(.cancel)
            } else {
                // Otherwise all URLs may load in WebView
                decisionHandler(.allow)
            }
            
        }
    }

    // MARK: Location Handler
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        
        let lat = lastLocation.coordinate.latitude
        let long = lastLocation.coordinate.longitude
        
        self.lat = lat
        self.long = long

        print("New Location", lat, long)

        // MARK: Switch to Significant Changes to preserve battery
        if self.firstUpdate {
            self.firstUpdate = false
            if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                locationManager.stopUpdatingLocation()
                locationManager.startMonitoringSignificantLocationChanges()
            }
        }

        // MARK: Generate endpoint URL, add optional URL parameters here if needed
        let finalURL = "\(cityMotionWebviewBaseURL)?key=\(cityMotionWebviewKey)&coordinates=\(lat),\(long)\(cityMotionParameters)";

        // MARK: Load Webview with update throttle
        if self.allowUpdate {
            print("Loading URL", finalURL)
            if let url = URL(string: finalURL) {
                self.webView.load(URLRequest(url: url))
                self.allowUpdate = false
                // Throttles location updates because didUpdateLocations are overly frequent
                // We have set a 60 second timeout here to prevent our server from being spammed
                DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
                   self.allowUpdate = true
                }
            }
        }
    }
    
    // MARK: Recover from user denying permissions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization Status: \(status.rawValue)")
        if status == CLAuthorizationStatus.denied {
            showLocationStatusAlert()
        } else if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if status == CLAuthorizationStatus.notDetermined {
            // User requested to "Re-ask" them
            locationManager.requestWhenInUseAuthorization()
            if self.alertPopup != nil {
                self.alertPopup.dismiss(animated: true, completion: nil)
            }
        }
    }

    // MARK: User denied location permissions
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("User denied location: \(error)")
        showLocationStatusAlert()
    }
    
    func showLocationStatusAlert() {
        let alertPopup = UIAlertController(title: "Location Settings", message: "Please enable 'Allow While Using App' to show nearby mobility choices.", preferredStyle: UIAlertController.Style.alert)
        self.present(alertPopup, animated: true, completion: nil)
        alertPopup.addAction(UIAlertAction(title: "Set Location Settings", style: .default, handler: { action in
            switch action.style {
                case .default:
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("destructive")
                @unknown default: break
                }
        }))
        self.alertPopup = alertPopup
    }

}
