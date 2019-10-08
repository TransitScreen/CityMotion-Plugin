package com.transitscreen.cmwdemo

import android.Manifest
import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.Looper
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.*
import com.google.android.gms.tasks.Task
import java.util.*

/* REPLACE THIS with your production API Key */
const val cityMotionWebviewAPIKey = "LhYnxcU6a8GiV0o5CP4KBwpAYE3nJydf76DchXsQGUH9ybowGVzUlhr9TPJzr2OZ"

/* Do not change this unless instructed to */
const val cityMotionWebviewProductionEndpoint = "https://citymotion.io"

class CityMotionWebviewCoordinates : AppCompatActivity() {

    private lateinit var locationCallback: LocationCallback
    var locationRequest: LocationRequest? = null

    var currentLatitude: Double? = null
    var currentLongitude: Double? = null

    var doUpdates: Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_city_motion_webview_coordinates)

        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                1000
            )
        } else {
            this.loadApp()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        if (requestCode == 1000) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                this.loadApp()
            } else {
                // User rejected permission
            }
        }
    }

    fun loadApp() {

        /* Create webview */
        val webView = findViewById<WebView>(R.id.webViewFrame)
        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        webView.overScrollMode = WebView.OVER_SCROLL_NEVER
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

        /* These settings can be tweaked but are targeted for occasional location updates */
        locationRequest = LocationRequest.create()?.apply {
            interval = 30000
            fastestInterval = 15000
            priority = LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY
        }

        val fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        // get the user's current location
        fusedLocationClient.getLastLocation()
            .addOnSuccessListener({ location ->
                if (location != null) {
                    println("LOCATION ${location}")
                    this.currentLatitude = location!!.getLatitude()
                    this.currentLongitude = location!!.getLongitude()
                    val url = "${cityMotionWebviewProductionEndpoint}/?key=${cityMotionWebviewAPIKey}&externalLinks=true&coordinates=${this.currentLatitude},${this.currentLongitude}"
                    print("Load URL ${url}")
                    webView.loadUrl(url)

                    /* First location update throttle */
                    Timer().schedule(object : TimerTask() {
                        override fun run() {
                            doUpdates = true
                        }
                    }, 60000)

                }
            })
            .addOnFailureListener({ e ->
                e.printStackTrace()
            })

        // track location changes
        fusedLocationClient.requestLocationUpdates(
            locationRequest,
            object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult?) {
                    if (locationResult != null) {
                        val location = locationResult.lastLocation
                        println("LOCATION ${location}")
                        currentLatitude = location.latitude
                        currentLongitude = location.longitude
                        if (doUpdates) {
                            val url = "${cityMotionWebviewProductionEndpoint}/?key=${cityMotionWebviewAPIKey}&externalLinks=true&coordinates=${currentLatitude},${currentLongitude}"
                            print("Load URL ${url}")
                            webView.loadUrl(url)
                            doUpdates = false

                            /* We throttle location updates to 60 seconds to prevent spamming our server */
                            Timer().schedule(object : TimerTask() {
                                override fun run() {
                                    doUpdates = true
                                }
                            }, 60000)

                        }
                    }
                }
            },
            Looper.myLooper()
        )
    }
}
