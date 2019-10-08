package com.transitscreen.cmwdemo

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Example activity simulating the landing page of your app

        // Add buttons to navigate to our CityMotionWebview activities
        locationCodeButton.setOnClickListener(View.OnClickListener {
            val intent = Intent(this, CityMotionWebviewLocationCode::class.java)
            startActivity(intent)
        })

        coordinatesButton.setOnClickListener(View.OnClickListener {
            val intent = Intent(this, CityMotionWebviewCoordinates::class.java)
            startActivity(intent)
        })

    }
}
