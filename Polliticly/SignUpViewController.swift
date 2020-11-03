//
//  SignUpViewController.swift
//  Polliticly
//
//  Created by Future Vision Tech  on 07/06/2020.
//  Copyright © 2020 Future Vision Tech. All rights reserved.
//

import UIKit
import Toaster
import SVProgressHUD
import Firebase
import FirebaseAuth
import FirebaseMessaging
import iOSDropDown
import IQKeyboardManagerSwift
import DatePickerDialog
import FirebaseDatabase
import FirebaseAuth
class SignUpViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var genderTextField: DropDown!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = true
        firstNameTextField.layer.cornerRadius = 8
        lastNameTextField.layer.cornerRadius = 8
        userNameTextField.layer.cornerRadius = 8
        emailTextField.layer.cornerRadius = 8
        passwordTextField.layer.cornerRadius = 8
        birthdayTextField.layer.cornerRadius = 8
        genderTextField.layer.cornerRadius = 8
        zipCodeTextField.layer.cornerRadius = 8
        emailTextField.setLeftPaddingPoints(8)
        passwordTextField.setRightPaddingPoints(8)
        passwordTextField.setLeftPaddingPoints(8)
        emailTextField.setRightPaddingPoints(8)
        firstNameTextField.setLeftPaddingPoints(8)
        lastNameTextField.setRightPaddingPoints(8)
        lastNameTextField.setLeftPaddingPoints(8)
        firstNameTextField.setRightPaddingPoints(8)
        birthdayTextField.setLeftPaddingPoints(8)
        genderTextField.setRightPaddingPoints(8)
        genderTextField.setLeftPaddingPoints(8)
        birthdayTextField.setRightPaddingPoints(8)
        zipCodeTextField.setRightPaddingPoints(8)
        zipCodeTextField.setLeftPaddingPoints(8)
        
        genderTextField.optionArray = ["Male", "Female", "Non-Binary", "Other", "Prefer Not to Say"]
        genderTextField.arrowColor = self.hexStringToUIColor(hex: "#C8CED0")
        //spokenGenderTextField.rowBackgroundColor = UIColor.white
        genderTextField.didSelect{(selectedText , index ,id) in
            self.genderTextField.text = selectedText
        }
    }
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func donePressed(_ sender: Any) {
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let birthday = birthdayTextField.text ?? ""
        let gender = genderTextField.text ?? ""
        let zipCode = zipCodeTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let userName = userNameTextField.text ?? ""
        if firstName.isEmpty || lastName.isEmpty || email.isEmpty || birthday.isEmpty || gender.isEmpty || zipCode.isEmpty || password.isEmpty || userName.isEmpty {
            Toast(text: "Please enter all data!!!").show()
        }
        else {
            SVProgressHUD.show(withStatus: "Creating account...")
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if error != nil {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        Toast(text: error?.localizedDescription ?? "Sign Up Error!!!").show()
                    }
                }
                else {
                    let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "")
                    addReference.child("firstName").setValue(firstName)
                    addReference.child("lastName").setValue(lastName)
                    addReference.child("email").setValue(email)
                    addReference.child("birthday").setValue(birthday)
                    addReference.child("gender").setValue(gender)
                    addReference.child("zipCode").setValue(zipCode)
                    addReference.child("userName").setValue(userName)
                    addReference.child("userID").setValue(Auth.auth().currentUser?.uid ?? "")
                    UserDefaults.standard.setValue(email, forKey: "email")
                    UserDefaults.standard.setValue(password, forKey: "password")
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
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
    @IBAction func firstNameReturnTextFieldPressed(_ sender: Any) {
        firstNameTextField.resignFirstResponder()
    }
    @IBAction func lastNameReturnTextFieldPressed(_ sender: Any) {
        lastNameTextField.resignFirstResponder()
    }
    @IBAction func passwordReturnTextFieldPressed(_ sender: Any) {
        passwordTextField.resignFirstResponder()
    }
    @IBAction func emailReturnTextFieldPressed(_ sender: Any) {
        emailTextField.resignFirstResponder()
    }
    @IBAction func birthdayReturnTextFieldPressed(_ sender: Any) {
        birthdayTextField.resignFirstResponder()
    }
    @IBAction func genderReturnTextFieldPressed(_ sender: Any) {
        genderTextField.resignFirstResponder()
    }
    @IBAction func zipCodeReturnTextFieldPressed(_ sender: Any) {
        zipCodeTextField.resignFirstResponder()
    }
    @IBAction func userNameReturnTextFieldPressed(_ sender: Any) {
        userNameTextField.resignFirstResponder()
    }
    @IBAction func genderTextFieldEditingBegin(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func birthdayTextFieldEditingBegin(_ sender: Any) {
        DatePickerDialog().show("Select Date of Birth", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                self.birthdayTextField.text = formatter.string(from: dt)
            }
        }
        self.view.endEditing(true)
    }
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    
}
