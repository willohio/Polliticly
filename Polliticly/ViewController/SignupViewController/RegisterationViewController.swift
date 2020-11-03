//
//  RegisterViewController.swift
//  Polliticly
//
//  Created by Apple on 13/06/2020.
//  Copyright © 2020 Future Vision Tech. All rights reserved.
//

import UIKit
import Toaster
import SVProgressHUD
import Firebase
import FirebaseAuth
import FirebaseMessaging
import iOSDropDown
import DatePickerDialog
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class RegisterationViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var genderTextField: DropDown!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var ethicity: DropDown!
    
    
    @IBOutlet weak var imageProfileView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    @IBAction func profileTapped(_ sender: UIButton) {
        ImagePickerManager().pickImage(self){ image in
            //here is the image
            self.imageProfileView.image = image
            
        }
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let birthday = birthdayTextField.text ?? ""
        let gender = genderTextField.text ?? ""
        let zipCode = zipCodeTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let userName = userNameTextField.text ?? ""
        let ethinicity = ethicity.text ?? ""
        if firstName.isEmpty || lastName.isEmpty || email.isEmpty || birthday.isEmpty || gender.isEmpty || zipCode.isEmpty || password.isEmpty || userName.isEmpty || ethinicity.isEmpty {
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
                    let imageName = "\(email).jpg"
                    var path = ""
                    path = "profile/image\(imageName)"
                    
                    self.uploadImagePic(image: self.imageProfileView.image!, name: imageName, filePath: path, completion: { url in
                        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "")
                        addReference.child("firstName").setValue(firstName)
                        addReference.child("lastName").setValue(lastName)
                        addReference.child("email").setValue(email)
                        addReference.child("birthday").setValue(birthday)
                        addReference.child("gender").setValue(gender)
                        addReference.child("zipCode").setValue(zipCode)
                        addReference.child("userName").setValue(userName)
                        addReference.child("userID").setValue(Auth.auth().currentUser?.uid ?? "")
                        addReference.child("image").setValue(url!)
                        
                        addReference.child("ethnicity").setValue(ethinicity)
                        UserDefaults.standard.setValue(email, forKey: "email")
                        UserDefaults.standard.setValue(password, forKey: "password")
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            appDelegate.loadDashboardViewController()
                        }
                        
                    })
                    
                }
            }
        }
    }
    
    
    func setupView(){
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
        //spokenGenderTextField.rowBackgroundColor = UIColor.white
        genderTextField.didSelect{(selectedText , index ,id) in
            self.genderTextField.text = selectedText
        }
        
        ethicity.optionArray = ["Asian / Pacific Islander", "Black or African American", "Hispanic or Latino", "Native American or American Indian", "White","Other"]
        ethicity.arrowColor = self.hexStringToUIColor(hex: "#7E3BF2")
        //spokenGenderTextField.rowBackgroundColor = UIColor.white
        ethicity.didSelect{(selectedText , index ,id) in
            self.ethicity.text = selectedText
        }
    }

    
    @IBAction func birthdayTextFieldEditingBegin(_ sender: Any) {
        DatePickerDialog().show("Select Date of Birth", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "mm/dd/yyyy"
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
   

    func uploadImagePic(image: UIImage, name: String, filePath: String,completion: @escaping (_ url: String?) -> Void) {
        guard let imageData: Data = image.jpegData(compressionQuality: 0.1) else {
            return
        }

       

        let storageRef = Storage.storage().reference(withPath: filePath)

        
        storageRef.putData(imageData, metadata: nil) { (metadata, err) in
         storageRef.downloadURL { (url, error) in

            if error != nil {
                print("Failed to download url:", error!)
                 completion(nil)
                return
            }

            let imageUrl = "\(String(describing: url))"
            completion(url?.absoluteString)
                // postRef.child(autoID).setValue(imageUrl)
             }
        }
    }
    
    
}
