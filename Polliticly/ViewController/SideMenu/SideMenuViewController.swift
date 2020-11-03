//
//  SideMenuViewController.swift
//  CloudClinik
//
//  Created by Apple on 16/04/2020.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import UIKit
import UIKit
import SVProgressHUD
import Firebase
import Toaster
import iOSDropDown
import SideMenu
import FirebaseDatabase
import FirebaseAuth
class SideMenuViewController: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var imageProfileView: UIImageView!
    
    
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        SettingViewController.loadImage(imageView: imageProfileView, urlString: UserDefaults.standard.string(forKey: image) ?? "", placeHolderImageString: "placeHolder")
        getProfileData()
    }

    //MARK:- UIActions
    @IBAction func dismissTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func profileTapped(_ sender: Any) {
        let viewComtroller = SettingViewController(nibName: String(describing: SettingViewController.self), bundle: nil)
        self.navigationController?.pushViewController(viewComtroller, animated: true)
    }
    
    @IBAction func changePassword(_ sender: Any) {
        let viewComtroller = ChangePasswordViewController(nibName: String(describing: ChangePasswordViewController.self), bundle: nil)
        self.navigationController?.pushViewController(viewComtroller, animated: true)
        
    }
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Logout!", message: "Are you sure, you want to logout?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default , handler:{ (UIAlertAction)in
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            appDelegate.loadLoginScreen()
            self.dismiss(animated: true)
        }))

        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler:{ (UIAlertAction)in
            self.dismiss(animated: true)
        }))

        self.present(alert, animated: true, completion: {
            
        })
        
    }
    
    
    func getProfileData(){
        ref = Database.database().reference(withPath: "Users").child(Auth.auth().currentUser?.uid ?? "")
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() { return }
                    for child in snapshot.children {
                        let childSnap = child as! DataSnapshot
                        if childSnap.key == "email" {
                            self.lblEmail.text = childSnap.value as? String ?? ""
                        }
                        
                        if childSnap.key == "firstName" {
                            self.lblName.text = childSnap.value as? String ?? ""
                        }
                        
                        if childSnap.key == "lastName" {
                            let last = childSnap.value as? String ?? ""
                            self.lblName.text = self.lblName.text! + " " + last
                        }
                    }
        })
    }
    
}
