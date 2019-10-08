//
//  CityMotion Webview Demo App
//
//  CMW-Coordinates.swift
//  View Controller Module
//  - Implements CityMotion Webview as a Coordinates endpoint
//  - Passes Location Services updates
//  - Includes support for external links
//
//  Demo v0.5.0
//  For CMW Documentation v1.2.0
//  Copyright © 2019 TransitScreen. All rights reserved.
//

import Foundation

import UIKit
import WebKit
import CoreLocation

// MARK: Replace this with your API Key
let cityMotionWebviewKey = "PUT YOUR KEY HERE"

// MARK: Production root URL, no need to change unless instructed to
let cityMotionWebviewCoordinatesURL = "https://citymotion.io"

class CMWCoordinatesController: UIViewController, WKUIDelegate, WKNavigationDelegate, CLLocationManagerDelegate {
    
    // MARK: Scene UI
    var safeAreaView: UIView!
    var browserView: UIView!
    var navigationBar: UINavigationBar!
    
    var webView: WKWebView!
    var loadingSpinner: UIActivityIndicatorView!
    
    var firstUpdate: Bool!
    var allowUpdate: Bool!
    
    var lat: Double!
    var long: Double!

    let cityMotionWhiteColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
    let locationManager = CLLocationManager()
    
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
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
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
        
        if let requestUrl = navigationAction.request.url?.absoluteString {
            print("requestUrl?", requestUrl) // Helpful debug
            
            if (requestUrl.contains("CM_UNIVERSAL_LINK") || requestUrl.contains("CM_URI")) {
                // Send all links to UIApplication if possible, method avoids canOpenURL which requires Info.plist query permissions
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: {
                    (success) in
                    if !success {
                        // Try to obtain and open the App Store Link passed from CityMotion
                        if let range = requestUrl.range(of: #"(?<=APP_STORE_LINK=).*$"#,
                                                        options: .regularExpression) {
                            if !requestUrl[range].isEmpty {
                                if let appStoreLink = URL(string: String(requestUrl[range])) {
                                    UIApplication.shared.open(appStoreLink, options: [:], completionHandler: nil)
                                    decisionHandler(.cancel)
                                    return
                                }
                            }
                        }
                    }
                })
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
        let finalURL = "\(cityMotionWebviewCoordinatesURL)?key=\(cityMotionWebviewKey)&coordinates=\(lat),\(long)&externalLinks=true";

        // MARK: Load Webview with update throttle
        if self.allowUpdate {
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

}
