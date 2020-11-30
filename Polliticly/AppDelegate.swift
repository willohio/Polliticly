//
//  AppDelegate.swift
//  Polliticly
//
//  Created by William Santiago  on 07/06/2020.
//  Copyright © 2020 William Santiago. All rights reserved.
//

import UIKit
import Firebase

import UIKit
import UIKit
import SVProgressHUD
import Firebase
import FirebaseAuth
import Toaster
import FirebaseDatabase
import IQKeyboardManagerSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        if !(UserDefaults.standard.string(forKey: "email")?.isEmpty ?? true) {
            loadDashboardViewController()
        }
        else{
            loadLoginScreen()
        }
       
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func loadLoginScreen()
    {
        let viewControlller = LoginViewViewController(nibName: String(describing:  LoginViewViewController
            .self), bundle: nil)
        let navigationController = UINavigationController.init(rootViewController: viewControlller)
        self.window?.rootViewController = navigationController
        navigationController.navigationBar.isHidden = true
        self.window?.makeKeyAndVisible()
    }
    
    func loadDashboardViewController()
    {
        
        let tabBarCnt = UITabBarController()
        tabBarCnt.tabBar.tintColor = UIColor.purple
        tabBarCnt.tabBar.backgroundColor = UIColor.white
        
        tabBarCnt.tabBar.layer.borderWidth = 0
        tabBarCnt.tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBarCnt.tabBar.layer.shadowRadius = 25
        tabBarCnt.tabBar.layer.shadowColor = UIColor.darkGray.cgColor
        tabBarCnt.tabBar.layer.shadowOpacity = 0.4

        //Polls
        let viewControlller = DashboardViewController(nibName: String(describing:  DashboardViewController
            .self), bundle: nil)
        let navigationController = UINavigationController.init(rootViewController: viewControlller)
        navigationController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Group 11161"), tag: 0)
        
        //Create Polls Controller
        
        let createPollsViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreatePollViewController") as! CreatePollViewController
        let createPollsNavigationController = UINavigationController.init(rootViewController: createPollsViewController)

        createPollsNavigationController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Group 70"), tag: 0)
        
        //Send Message Controller
        let sendMessageViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        let sendMessageNavigationController = UINavigationController.init(rootViewController: sendMessageViewController)

        sendMessageNavigationController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Group 44"), tag: 0)
        
        //init tabbar
        tabBarCnt.viewControllers = [navigationController,createPollsNavigationController,sendMessageNavigationController]
        
        self.window?.rootViewController = tabBarCnt
        navigationController.navigationBar.isHidden = true
        createPollsNavigationController.navigationBar.isHidden = true
        sendMessageNavigationController.navigationBar.isHidden = true

        self.window?.makeKeyAndVisible()
    }
    
    func loginCheck(type: String) {
            Auth.auth().signIn(withEmail: UserDefaults.standard.string(forKey: "email") ?? "", password: UserDefaults.standard.string(forKey: "password") ?? "") { (user, error) in
                if error != nil {
                    SVProgressHUD.dismiss()
                    Toast(text: "Incorrect Email or Password!!!").show()
                }
                else {
                    SVProgressHUD.dismiss()
                    self.loadDashboardViewController()
                }
            }
    }


}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

