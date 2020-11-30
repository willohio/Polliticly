//
//  LoginViewViewController.swift
//  Polliticly
//
//  Created by Apple on 13/06/2020.
//  Copyright © 2020 William Santiago. All rights reserved.
//

import UIKit
import UIKit
import SVProgressHUD
import Firebase
import FirebaseAuth
import Toaster
import FirebaseDatabase
class LoginViewViewController: UIViewController {
    @IBOutlet weak var viewContent: UIView!

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        loginCheck(type: "Button")
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
        let viewController = RegisterationViewController(nibName: String(describing: RegisterationViewController.self), bundle: nil)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func loginCheck(type: String) {
        if type == "Auto" {
            SVProgressHUD.show(withStatus: "Login...")
            Auth.auth().signIn(withEmail: UserDefaults.standard.string(forKey: "email") ?? "", password: UserDefaults.standard.string(forKey: "password") ?? "") { (user, error) in
                if error != nil {
                    SVProgressHUD.dismiss()
                    Toast(text: "Incorrect Email or Password!!!").show()
                }
                else {
                    SVProgressHUD.dismiss()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainViewController = storyboard.instantiateViewController(withIdentifier: "main")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window!.rootViewController = mainViewController
                    appDelegate.window!.makeKeyAndVisible()
                }
            }
        }
        else {
            if emailTextField.text?.isEmpty ?? true || passwordTextField.text?.isEmpty ?? true {
                Toast(text: "Please enter email & password!!!").show()
            }
            else {
                SVProgressHUD.show(withStatus: "Login...")
                Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                    if error != nil {
                        SVProgressHUD.dismiss()
                        Toast(text: "Incorrect Email or Password!!!").show()
                    }
                    else {
                        SVProgressHUD.dismiss()
                        UserDefaults.standard.setValue(self.emailTextField.text!, forKey: "email")
                        UserDefaults.standard.setValue(self.passwordTextField.text!, forKey: "password")
                        appDelegate.loadDashboardViewController()
                    }
                }
            }
        }
    }
    
   func setupView(){
        viewContent.layer.cornerRadius = 24
        viewContent.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]

        emailTextField.setLeftPaddingPoints(8)
        passwordTextField.setRightPaddingPoints(8)
        passwordTextField.setLeftPaddingPoints(8)
        emailTextField.setRightPaddingPoints(8)
        if !(UserDefaults.standard.string(forKey: "email")?.isEmpty ?? true) {
            loginCheck(type: "Auto")
        }
        
    }

}

