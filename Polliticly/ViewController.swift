//
//  ViewController.swift
//  Polliticly
//
//  Created by Future Vision Tech  on 07/06/2020.
//  Copyright © 2020 Future Vision Tech. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseAuth
import Toaster
import FirebaseDatabase
class ViewController: UIViewController {

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewContent.layer.cornerRadius = 24
        viewContent.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        
        emailTextField.layer.cornerRadius = 8
        passwordTextField.layer.cornerRadius = 8
        emailTextField.setLeftPaddingPoints(8)
        passwordTextField.setRightPaddingPoints(8)
        passwordTextField.setLeftPaddingPoints(8)
        emailTextField.setRightPaddingPoints(8)
        signInButton.layer.cornerRadius = 24
        registerButton.layer.cornerRadius = 24
        if !(UserDefaults.standard.string(forKey: "email")?.isEmpty ?? true) {
            loginCheck(type: "Auto")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Get the presented navigationController and the view controller it contains
        let navigationController = segue.destination
        navigationController.modalPresentationStyle = .fullScreen
    }
    
    @IBAction func emailTextFieldReturnPressed(_ sender: Any) {
        emailTextField.resignFirstResponder()
    }
    
    @IBAction func passwordTextFieldReturnPressed(_ sender: Any) {
        passwordTextField.resignFirstResponder()
    }
    @IBAction func signInPressed(_ sender: Any) {
        loginCheck(type: "Button")
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
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainViewController = storyboard.instantiateViewController(withIdentifier: "main")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window!.rootViewController = mainViewController
                        appDelegate.window!.makeKeyAndVisible()
                    }
                }
            }
        }
    }

}

