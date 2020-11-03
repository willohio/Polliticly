//
//  ChangePasswordViewController.swift
//  Polliticly
//
//  Created by Apple on 16/06/2020.
//  Copyright © 2020 Future Vision Tech. All rights reserved.
//

import UIKit
import UIKit
import Toaster
import SVProgressHUD
import Firebase
import FirebaseAuth
import FirebaseMessaging
import iOSDropDown
import DatePickerDialog
class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var tfCurrentPass: UITextField!
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var tfNewPassword: UITextField!
    typealias Completion = (Error?) -> Void

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        steupView()
    }

    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func updatePasswordTapped(_ sender: Any) {
        
        SVProgressHUD.show()
        
        self.changePassword(email: UserDefaults.standard.string(forKey: "email") ?? "", currentPassword: tfCurrentPass.text!, newPassword: tfNewPassword.text!) { (error) in
            if error != nil {
                SVProgressHUD.dismiss()
                Toast(text: error?.localizedDescription).show()
            }
            else {
                SVProgressHUD.dismiss()
                Toast(text: "Password change successfully.").show()
            }
        }
        
        
        
    }
    
    func changePassword(email: String, currentPassword: String, newPassword: String, completion: @escaping (Error?) -> Void) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (result, error) in
            if let error = error {
                completion(error)
            }
            else {
                Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { (error) in
                    completion(error)
                })
            }
        })
    }
    
    func steupView(){
        viewContent.layer.cornerRadius = 24
        viewContent.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        tfCurrentPass.setLeftPaddingPoints(8)
        tfNewPassword.setRightPaddingPoints(8)
    }
    
}
