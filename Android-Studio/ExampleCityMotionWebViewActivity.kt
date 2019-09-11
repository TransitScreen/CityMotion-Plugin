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

        /* externalLinks=universal handler */
        /* Insert code from Universal-Links.kt */

        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        webView.overScrollMode = WebView.OVER_SCROLL_NEVER

        /* Determine if we should load URL or resume state */
        if (savedInstanceState !== null) {
            webView.restoreState(savedInstanceState)
        } else {
            webView.loadUrl("https://citymotion.io/?key=YOUR_KEY&OTHER_PARAMS")
        }

    }

}
