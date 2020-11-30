//
//  SettingViewController.swift
//  Polliticly
//
//  Created by Apple on 16/06/2020.
//  Copyright © 2020 William Santiago. All rights reserved.
//

import UIKit
import Toaster
import SVProgressHUD
import Firebase
import FirebaseAuth
import FirebaseMessaging
import iOSDropDown
import DatePickerDialog
import SideMenu
import SDWebImage
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SettingViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var genderTextField: DropDown!
    @IBOutlet weak var birthdayTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var ethicity: DropDown!
    @IBOutlet weak var imageProfileView: UIImageView!
    
    var ref: DatabaseReference!
    var imageName = "\(UserDefaults.standard.string(forKey: "email") ?? "").jpg"
    var path = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        getProfileData()
        path = "profile/image\(imageName)"
        
    }
    
    

    
    @IBAction func wednesdayTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func editTapped(_ sender: UIButton) {
        updateProfile()
    }
    
    
   @IBAction func profileTapped(_ sender: UIButton) {
        ImagePickerManager().pickImage(self){ image in
            //here is the image
            self.imageProfileView.image = image
        }
    }
    
    func setupView(){
           emailTextField.setLeftPaddingPoints(8)
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
           userNameTextField.setRightPaddingPoints(8)
           userNameTextField.setLeftPaddingPoints(8)
        ethicity.setRightPaddingPoints(8)
        ethicity.setLeftPaddingPoints(8)
           genderTextField.optionArray = ["Male", "Female", "Non-Binary", "Other", "Prefer Not to Say"]
          // genderTextField.arrowColor = self.hexStringToUIColor(hex: "#7E3BF2")
           genderTextField.didSelect{(selectedText , index ,id) in
               self.genderTextField.text = selectedText
           }
           
           ethicity.optionArray = ["Asian / Pacific Islander", "Black or African American", "Hispanic or Latino", "Native American or American Indian", "White","Other"]
        //   ethicity.arrowColor = self.hexStringToUIColor(hex: "#7E3BF2")
           //spokenGenderTextField.rowBackgroundColor = UIColor.white
           ethicity.didSelect{(selectedText , index ,id) in
               self.ethicity.text = selectedText
           }
        
        SettingViewController.loadImage(imageView: imageProfileView, urlString: UserDefaults.standard.string(forKey: image) ?? "", placeHolderImageString: "img_placeholder")
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
    
    func getProfileData(){
        ref = Database.database().reference(withPath: "Users").child(Auth.auth().currentUser?.uid ?? "")
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() { return }
                    for child in snapshot.children {
                        let childSnap = child as! DataSnapshot
                        if childSnap.key == "userName" {
                            self.userNameTextField.text = childSnap.value as? String ?? ""
                        }
                        if childSnap.key == "zipCode" {
                            self.zipCodeTextField.text = childSnap.value as? String ?? ""
                        }
                        
                        if childSnap.key == "email" {
                            self.emailTextField.text = childSnap.value as? String ?? ""
                        }
                        if childSnap.key == "gender" {
                            self.genderTextField.text = childSnap.value as? String ?? ""
                        }
                        
                        if childSnap.key == "ethnicity" {
                            self.ethicity.text = childSnap.value as? String ?? ""
                        }
                        
                        if childSnap.key == "birthday" {
                            self.birthdayTextField.text = childSnap.value as? String ?? ""
                        }
                        
                        if childSnap.key == "firstName" {
                            self.firstNameTextField.text = childSnap.value as? String ?? ""
                        }
                        
                        if childSnap.key == "lastName" {
                            self.lastNameTextField.text = childSnap.value as? String ?? ""
                        }
                    }
        })
    }
    
    class func loadImage(imageView: UIImageView, urlString: String, placeHolderImageString: String?)->Swift.Void{
        let placeHolder = UIImage(named: placeHolderImageString ?? "")
        imageView.image = placeHolder
        let encodedString:String = urlString.replacingOccurrences(of: " ", with: "%20")
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imageView.sd_setImage(with: URL(string: encodedString), placeholderImage: placeHolder)
        
        
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
    
    func updateProfile(){
        SVProgressHUD.show()
        self.uploadImagePic(image: imageProfileView.image!, name: self.imageName, filePath: path, completion: { url in
            
            UserDefaults.standard.set(url, forKey: image)
            let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "")
            
            addReference.child("firstName").setValue(self.firstNameTextField.text!)
            addReference.child("lastName").setValue(self.lastNameTextField.text!)
            addReference.child("email").setValue(self.emailTextField.text!)
            addReference.child("birthday").setValue(self.birthdayTextField.text!)
            addReference.child("gender").setValue(self.genderTextField.text!)
            addReference.child("zipCode").setValue(self.zipCodeTextField.text!)
            addReference.child("userName").setValue(self.userNameTextField.text!)
            addReference.child("ethnicity").setValue(self.ethicity.text!)
            
            
    
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                 Toast(text: "Profile updated successfully.").show()
               
            }
            
        })

    }
    
    

}
