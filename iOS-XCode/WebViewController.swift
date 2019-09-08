//
// WebViewControllerExtension.swift
// Example Code for CityMotion-Web Integration
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    // Define variables
    var url: String!
    var webView: WKWebView!

    // We init a WKWebView upon a UIView and add an indicator inside of it
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var browserWindow: UIView!

    // We add a refresh button to the navigation bar
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBAction func refresh(_ sender: Any) {
        webView.reload()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Create WKWebView upon the UIView above
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: self.browserWindow.bounds, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.browserWindow.addSubview(webView)

        // MARK: Disable caching so that CityMotion can always deliver the latest software!
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        // MARK: Load webview
        if let newUrl = self.url {
            if let url = URL(string: newUrl) {
                webView.load(URLRequest(url: url))
                return
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
    }

}

