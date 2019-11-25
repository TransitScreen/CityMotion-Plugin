package com.transitscreen.cmwdemo

import android.Manifest
import android.app.Activity
import android.app.AlertDialog
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.Looper
import android.provider.Settings
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.*
import java.util.*
import android.content.DialogInterface
import android.util.Log


/* REPLACE THIS with your production API Key */
const val cityMotionWebviewAPIKey = "LhYnxcU6a8GiV0o5CP4KBwpAYE3nJydf76DchXsQGUH9ybowGVzUlhr9TPJzr2OZ"

/* ADD OPTIONAL PARAMETERS here if needed ie: &param=prop&param=prop */
const val cityMotionWebviewParameters = "&externalLinks=true"

/* Base Production URL, do not change unless instructed to */
const val cityMotionWebviewProductionEndpoint = "https://citymotion.io"

class CityMotionWebviewCoordinates : AppCompatActivity() {

    private lateinit var locationCallback: LocationCallback
    var locationRequest: LocationRequest? = null

    var currentLatitude: Double? = null
    var currentLongitude: Double? = null

    var doUpdates: Boolean = false

    var appWasLoaded: Boolean = false // Identifies if the webview elements were setup

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

    override fun onRestart() {
        super.onRestart()

        // Returning from location permissions screen
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            // User has rejected permission, maintain the redirect dialog
            Log.d("CMWDebug", "onRestart - Ask Permission")
            this.showLocationAlert()
        } else {
            Log.d("CMWDebug", "onRestart - App Loaded? ${appWasLoaded}")
            // Permission was granted and we can initialize webview and location services
            // But only if it was never loaded in the first place
            // This is because the requestLocationUpdates listener can recover/update webview
            if (appWasLoaded == false) {
                this.loadApp()
            }
        }

    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        if (requestCode == 1000) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Log.d("CMWDebug", "onRequestPermissionsResults Load App")
                this.loadApp()
            } else {
                Log.d("CMWDebug", "onRequestPermissionsResults Rejected")
                // User rejected permission
                this.showLocationAlert()
            }
        }
    }

    fun showLocationAlert() {
        appWasLoaded = false

        val alertDialog = AlertDialog.Builder(this)
            // set icon
            .setIcon(android.R.drawable.ic_dialog_alert)
            // set title
            .setTitle("Location Permissions")
            // set message
            .setMessage("Turn your Location ON to show nearby mobility choices.")
            // set positive button
            .setPositiveButton(
                "Open Location Permissions",
                DialogInterface.OnClickListener { dialogInterface, i ->
                    // set what would happen when positive button is clicked
                    openApplicationSettings()
//                finish()
                })
            // set negative button
//            .setNegativeButton("No", DialogInterface.OnClickListener { dialogInterface, i ->
//                //set what should happen when negative button is clicked
//            })
            .show()
    }

    fun openApplicationSettings() {
        // Redirecting to OS Location Settings menu
        startActivityForResult(Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS), 0);

        // Redirect to App Level locations settings
//        val intent = Intent()
//        intent.action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
//        val uri = Uri.fromParts("package", this.packageName, null)
//        intent.data = uri
//        startActivity(intent)
    }

    fun loadApp() {

        this.appWasLoaded = true

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
                    Log.d("CMWDebug External Link Override To", checkUrl)
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
                        Log.d("CMWDebug External Link Unreachable: ", "${e}")
                        val regex = Regex(pattern = "(?<=APP_STORE_LINK=).*\$")
                        val matchUrl = regex.find(checkUrl)?.value
                        Log.d("CMWDebug External Link Match", matchUrl)
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

        // Initially obtain the user's current location
        fusedLocationClient.getLastLocation()
            .addOnSuccessListener { location ->
                // Listener will return null if location is "not available"
                // https://developers.google.com/android/reference/com/google/android/gms/location/FusedLocationProviderClient.html#getLastLocation()
                if (location == null) {
                    Log.d("CMWDebug getLastLocation", "Location was null")
                    showLocationAlert()
                } else {
                    Log.d("CMWDebug getLastLocation", "${location}")
                    this.currentLatitude = location.getLatitude()
                    this.currentLongitude = location.getLongitude()
                    val url = "${cityMotionWebviewProductionEndpoint}/?key=${cityMotionWebviewAPIKey}&coordinates=${this.currentLatitude},${this.currentLongitude}${cityMotionWebviewParameters}"
                    Log.d("CMWDebug Load URL", url)
                    webView.loadUrl(url)

                    /* First location update throttle */
                    Timer().schedule(object : TimerTask() {
                        override fun run() {
                            doUpdates = true
                        }
                    }, 60000)
                }
            }
            .addOnFailureListener { e ->
                Log.d("CMWDebug", "addOnFailureListener", e)
            }

        // Proceed to continue tracking user's location changes
        fusedLocationClient.requestLocationUpdates(
            locationRequest,
            object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult?) {
                    if (locationResult != null) {
                        // LocationResult can succeed even if data is invalid
                        // Last Location can be null https://developers.google.com/android/reference/com/google/android/gms/location/LocationResult
                        val location = locationResult.lastLocation

                        if (location == null) {
                            Log.d("CMWDebug onLocationResult", "null")
                            showLocationAlert()
                        } else {
                            Log.d("CMWDebug onLocationResult", "${location}")
                            currentLatitude = location.latitude
                            currentLongitude = location.longitude
                            if (doUpdates) {
                                val url =
                                    "${cityMotionWebviewProductionEndpoint}/?key=${cityMotionWebviewAPIKey}&coordinates=${currentLatitude},${currentLongitude}${cityMotionWebviewParameters}"
                                Log.d("CMWDebug Load URL", url)
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
                }
            },
            Looper.myLooper()
        )
    } // End of loadApp
}
