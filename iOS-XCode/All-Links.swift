//
// All-Links.swift
// Example Code for CityMotion-Web Integration
// externalLinks=all
//

import UIKit
import WebKit

extension WebViewController {

    // Decide the Policy for Navigation Actions for your CityMotion WebView
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        if let requestUrl = navigationAction.request.url?.absoluteString {
            print("requestUrl?", requestUrl) // Helpful debug

            if (requestUrl.contains("CM_UNIVERSAL_LINK")) {
                // Send all universal links to UIApplication for handling
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            } else if (requestUrl.contains("CM_URI")) {
                // Send URI links to UIApplication if possible
                if (UIApplication.shared.canOpenURL(navigationAction.request.url!)) {
                    UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                    return
                } else {
                    // Try to obtain and open the App Store Link passed from CityMotion
                    if let range = requestUrl.range(of: #"(?<=CM_URI=).*$"#,
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
            }
        }

        // Otherwise all URLs may load in WebView
        decisionHandler(.allow)

    }
}

