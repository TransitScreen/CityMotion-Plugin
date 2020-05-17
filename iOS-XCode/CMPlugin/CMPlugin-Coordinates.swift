//
//  CityMotion Plugin Demo App
//
//  CMW-Coordinates.swift
//  View Controller Module
//
//  API Documentation v1.2.*
//  Copyright © 2020 TransitScreen. All rights reserved.
//

import Foundation

import UIKit
import WebKit
import CoreLocation

class CMWCoordinatesController: UIViewController, WKUIDelegate, WKNavigationDelegate, CLLocationManagerDelegate {
    
    // MARK: URL Parameters you can set
    var API_KEY = "" // 64 character api key given to you
    var ADDITIONAL_PARAMS = "" // ie: &barPosition=bottom

    // MARK: Production Endpoint Domain, no need to change unless instructed to
    var cityMotionDomain = "https://192.168.0.103:8000/partner"

    // MARK: Scene UI
    var safeAreaView: UIView!
    var browserView: UIView!
    var navigationBar: UINavigationBar!
    var webConfiguration: WKWebViewConfiguration!
    
    var locationManager: CLLocationManager!
    var webView: WKWebView!
    var loadingSpinner: UIActivityIndicatorView!
    
    var alertPopup: UIAlertController!
    
    var firstUpdate: Bool!
    
    var lat: Double!
    var long: Double!

    let cityMotionWhiteColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)

    override func loadView() {
        super.loadView()
        setupSceneScaffolding();

        // MARK: Allow talking with Webapp for location updates
        let webConfiguration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        webConfiguration.userContentController = userContentController
        self.webConfiguration = webConfiguration

        // MARK: Add WKWebView upon browserView from setupSceneScaffolding
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        browserView.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.browserView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.browserView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: self.browserView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.browserView.trailingAnchor),
        ])
        self.webView = webView

        // MARK: Loads WebView first and then location updates afterwards
        self.firstUpdate = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneOnViewDidLoad();
        
        // MARK: Initialize WebView
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.allowsBackForwardNavigationGestures = true
        
        // MARK: Disable web view caching as CityMotion has continuous deployment
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0

        // MARK: FEATURE SUPPORT: Location Services
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // Request Always if you are configuring background modes in Capabilities
        locationManager.startUpdatingLocation()
        // locationManager.allowsBackgroundLocationUpdates = true // Request Always

        // MARK: FEATURE SUPPORT: Inform front-end to begin listening for updates
        self.webView.evaluateJavaScript("window.isIOSPluginCoordinates = true;")
    }
    
    // MARK: FEATURE SUPPORT: Location Update Handler
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        
        let lat = lastLocation.coordinate.latitude
        let long = lastLocation.coordinate.longitude
        
        self.lat = lat
        self.long = long

        print("New Location", lat, long)
        
        if (self.firstUpdate) {
            self.firstUpdate = false;
            // MARK: Generate endpoint URL, add optional URL parameters here if needed
            if let cityMotionUrl = URL(string: "\(cityMotionDomain)?key=\(API_KEY)&coordinates=\(lat),\(long)\(ADDITIONAL_PARAMS)") {
                self.webView.load(URLRequest(url: cityMotionUrl))
            }

            // MARK: Switch to Significant Changes to preserve battery
            // You can turn this off if needed, the front-end will determine update throttling
//            if CLLocationManager.significantLocationChangeMonitoringAvailable() {
//                locationManager.stopUpdatingLocation()
//                locationManager.startMonitoringSignificantLocationChanges()
//            }
        } else {
            // MARK: Send location to Webapp via JS injection
            self.webView.evaluateJavaScript("window.CITYMOTION_WEB_IOS_LOCATION_UPDATE('\(lat)', '\(long)');")
        }
    }
    
    // MARK: FEATURE SUPPORT: External App Link Handler
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let requestUrlString = navigationAction.request.url?.absoluteString {
            // print("Request Url String", requestUrlString)
            
            if (requestUrlString.contains("CM_UNIVERSAL_LINK") || requestUrlString.contains("CM_URI")) {
                // Send all links to UIApplication if possible, method avoids canOpenURL which requires Info.plist query permissions
                if let requestUrl = navigationAction.request.url {
                    UIApplication.shared.open(requestUrl, options: [:], completionHandler: {
                        (success) in
                        if success == false {
                            // Link failed so try to obtain and open the App Store Link passed from CityMotion
                            if let range = requestUrlString.range(of: #"(?<=APP_STORE_LINK=).*$"#,
                                                            options: .regularExpression) {
                                // print("App Store Link", requestUrlString[range])
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
    
    // MARK: OPTIONAL FEATURE SUPPORT: Recover from user denying permissions
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

    // MARK: OPTIONAL FEATURE SUPPORT: Handle user denying location permissions
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if CLLocationManager.authorizationStatus() == .denied {
            showLocationStatusAlert()
        }
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

    // Scene scaffolding: This method automatically sets up Scene Views prior to scene load
    // Many apps will have done this already either via Storyboard or existing scene scaffolding
    func setupSceneScaffolding() {
        // MARK: Scene Scaffolding to Create Safe Area View
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
        
        // MARK: Add Scene header bar with Back button
        
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
    
        // MARK: Spinner for slow phones
        let loadingSpinner = UIActivityIndicatorView(frame: .zero)
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        self.browserView.addSubview(loadingSpinner)
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: self.browserView.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: self.browserView.centerYAnchor),
        ])
        loadingSpinner.startAnimating()
        self.loadingSpinner = loadingSpinner
    }
       
    // Scene scaffolding: This method captures optional steps Apple prefers to be set in viewDidLoad
    func setupSceneOnViewDidLoad() {
        // MARK: Initialize Navigation Bar
        let navItems = UINavigationItem.init(title: "CityMotion")
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.done, target: self, action: #selector(dismissView(sender:)))
        navItems.setLeftBarButton(backButton, animated: true)
        self.navigationBar.items = [navItems]
    }
    
    // Scene scaffolding: Processes dismiss on navigation tap
    @objc func dismissView(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Scene scaffolding: We use a scene setup loading spinner in this example for slow phones
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingSpinner.stopAnimating()
    }
    
    // Allows localhost SSL
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        }else{
            completionHandler(.useCredential, nil)
        }
        
    }
}
