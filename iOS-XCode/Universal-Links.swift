//
// Universal-Links.swift
// Example Code for CityMotion-Web Integration
// externalLinks=universal
//

import UIKit
import WebKit

extension WebViewController {

    // Decide the Policy for Navigation Actions for your CityMotion WebView
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        if let requestUrl = navigationAction.request.url?.absoluteString {
            print("requestUrl?", requestUrl) // Helpful debug

            // Send all universal links to UIApplication for handling
            if (requestUrl.contains("CM_UNIVERSAL_LINK")) {
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }

        // Otherwise all URLs may load in WebView
        decisionHandler(.allow)
    }

}

