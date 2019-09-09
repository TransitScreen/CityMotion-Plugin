package com.YOURAPP

import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.webkit.WebView
import android.webkit.WebViewClient
import android.content.Intent
import android.net.Uri
import android.widget.Toast
import android.content.ActivityNotFoundException
import android.webkit.URLUtil
import android.webkit.WebResourceRequest

class CityMotionWebViewActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_webview)

        /* Create webview */
        val webView = findViewById<WebView>(R.id.WebViewFrame)
        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {

                // Detect CityMotion specific links for handling
                if (request?.url != null) {
                    val checkUrl = request.url.toString()
                        // Else: this navigates all universal links via Intent to Chrome or prompts the installed app
                        try {
                            println("External Link Navigate: " + request.toString())
                            val intent = Intent(Intent.ACTION_VIEW)
                            if (checkUrl.contains("CM_UNIVERSAL_LINK")) {
                                // Load and read the universal link
                                intent.data = request.url
                                startActivity(intent)
                            } else if (checkUrl.contains("CM_URI")) {
                                // URI: Try to directly open the local app
                                intent.data = Uri.parse(checkUrl)
                                startActivity(intent)
                            }
                        } catch (e: ActivityNotFoundException) {
                            println("External Link Unreachable: " + e.toString())
                        }
                        // Return true for all CM links means unreachable URI links are safely ignored
                        return true
                }

                // Otherwise all links are navigated inside the WebView
                return false
            }

        }
        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        webView.overScrollMode = WebView.OVER_SCROLL_NEVER

        /* Determine if we should load or resume state */
        if (savedInstanceState !== null) {
            webView.restoreState(savedInstanceState)
        } else {
            webView.loadUrl("https://citymotion.io")
        }

    }

}
