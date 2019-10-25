//
//  CityMotion Webview Demo App
//  LandingController.swift
//  Landing Scene that simulates a third-party integration app
//

import UIKit
import WebKit

class LandingController: UIViewController {
    
    @IBOutlet weak var headerTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            headerTitle.text = "CityMotion Webview Demo App v\(appVersion)"
        }
        
    }
        
}

