package com.transitscreen.cmwdemo

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import java.net.URL

/* REPLACE THIS with your production URL */
const val cityMotionWebviewLocationCodeURL = "https://staging.citymotion.io/?key=LhYnxcU6a8GiV0o5CP4KBwpAYE3nJydf76DchXsQGUH9ybowGVzUlhr9TPJzr2OZ&locationCode=modolabs&externalLinks=true"

class CityMotionWebviewLocationCode : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_city_motion_webview_location_code)

        /* Create webview */
        val webView = findViewById<WebView>(R.id.webViewFrame)
        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        webView.overScrollMode = WebView.OVER_SCROLL_NEVER

        /* Determine if we should load or resume state */
        if (savedInstanceState !== null) {
            webView.restoreState(savedInstanceState)
        } else {
            webView.loadUrl(cityMotionWebviewLocationCodeURL)
        }

        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(
                view: WebView?,
                request: WebResourceRequest?
            ): Boolean {
                // Detect CityMotion specific links for handling
                if (request?.url != null) {
                    val checkUrl = request.url.toString()
                    println("External Link Override To: ${checkUrl}")
                    // This attempts to start an activity with the link
                    try {
                        val intent = Intent(Intent.ACTION_VIEW)
                        if (checkUrl.contains("CM_UNIVERSAL_LINK") || checkUrl.contains("play.google.com")) {
                            // We can just read the original request as URIs
                            intent.data = request.url
                            startActivity(intent)
                        } else if (checkUrl.contains("CM_URI")) {
                            // URI string links must be parsed
                            intent.data = Uri.parse(checkUrl)
                            startActivity(intent)
                        }
                    } catch (e: ActivityNotFoundException) {
                        // If the above fails for any reason, try to open Google Play link
                        println("External Link Unreachable: " + e.toString())
                        val regex = Regex(pattern = "(?<=APP_STORE_LINK=).*\$")
                        val matchUrl = regex.find(checkUrl)?.value
                        println("External Link Match ${matchUrl}")
                        if (matchUrl.isNullOrEmpty() == false) {
                            val intent = Intent(Intent.ACTION_VIEW)
                            intent.data = Uri.parse(matchUrl)
                            startActivity(intent) // This action will rerun this method
                        }
                    }
                    // Return true for all CM links means unreachable links are safely ignored
                    return true
                }
                // Otherwise all links are navigated inside the WebView
                return false
            }
        }
    }
}
