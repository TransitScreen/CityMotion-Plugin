//
//  CityMotion Plugin Demo App
//
//  CMW-LocationCode.swift
//  View Controller Module
//
//  API Documentation v1.2.*
//  Copyright © 2020 TransitScreen. All rights reserved.
//

import UIKit
import WebKit

class CMWLocationCodeController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    // MARK: CityMotion WebView URL values for Location Code
    var API_KEY = "" // 64 character api key given to you
    var LOCATION_CODE = "" // ie: building1234
    var ADDITIONAL_PARAMS = "" // ie: &barPosition=top

    // MARK: Production root URL, no need to change unless instructed to
    var cityMotionDomain = "https://citymotion.io/partner"

    // MARK: Scene UI
    var safeAreaView: UIView!
    var browserView: UIView!
    var navigationBar: UINavigationBar!
    
    var webView: WKWebView!
    var loadingSpinner: UIActivityIndicatorView!
    var cityMotionWhiteColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
    
    override func loadView() {
        super.loadView()
        setupSceneScaffolding();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneOnViewDidLoad();

        // MARK: Load CityMotion-Webapp
        let cityMotionURL = "\(cityMotionDomain)/?key=\(API_KEY)&locationCode=\(LOCATION_CODE)\(ADDITIONAL_PARAMS)"
        if let url = URL(string: cityMotionURL) {
            self.webView.load(URLRequest(url: url))
        }

        // MARK: Front-end support flag
        self.webView.evaluateJavaScript("window.isIOSPluginLocationCode = true;")
    }
    
    // MARK: FEATURE SUPPORT: External App Link Handler
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
        
        // MARK: Initialize WebView
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.allowsBackForwardNavigationGestures = true
        
        // MARK: Disable web view caching as CityMotion has continuous deployment
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }
    
    // Scene scaffolding: Processes dismiss on navigation tap
    @objc func dismissView(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Scene scaffolding: We use a scene setup loading spinner in this example for slow phones
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingSpinner.stopAnimating()
    }
}
