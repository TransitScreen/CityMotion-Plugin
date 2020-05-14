//
//  CityMotion Plugin Demo App
//  HomeController.swift
//  Home Scene that simulates a third-party integration app
//

import UIKit
import WebKit

class HomeController: UIViewController {
    
    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var customerKey: UITextField!
    
    @IBOutlet weak var locationCode: UITextField!
    
    @IBOutlet weak var parameters: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            headerTitle.text = "CityMotion Plugin Demo App v\(appVersion)"
        }

    }

    // MARK: This Demo allows the UI to pass in key and location code from the Home controller scene
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        if segue.destination is CMWLocationCodeController {
            let vc = segue.destination as? CMWLocationCodeController
            vc?.cityMotionWebviewKey = customerKey.text!
            vc?.cityMotionLocationCode = locationCode.text!
            vc?.cityMotionParameters = parameters.text!
        } else if segue.destination is CMWCoordinatesController {
            let vc = segue.destination as? CMWCoordinatesController
            vc?.cityMotionWebviewKey = customerKey.text!
            vc?.cityMotionParameters = parameters.text!
        }
    }
    
    // MARK: Just a segue validator to ensure required fields are not empty
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "LOCATION_CODE") {
            if customerKey.text!.isEmpty {
                customerKey.becomeFirstResponder()
                return false
            } else if locationCode.text!.isEmpty {
                locationCode.becomeFirstResponder()
                return false
            }
        } else if (identifier == "COORDINATES") {
            if customerKey.text!.isEmpty {
                customerKey.becomeFirstResponder()
                return false
            }
        }
        return true
    }

}

// MARK: Let keyboard be dismissable
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
