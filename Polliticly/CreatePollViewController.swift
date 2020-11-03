//
//  CreatePollViewController.swift
//  Polliticly
//
//  Created by tp on 6/29/20.
//  Copyright © 2020 Future Vision Tech. All rights reserved.
//

import UIKit
import SideMenu
import DSTextView
import IQKeyboardManagerSwift

class CreatePollViewController: UIViewController {

    @IBOutlet weak var containerView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.layer.cornerRadius = 25
        setupSideMenu()
        IQKeyboardManager.shared.enable = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func menuBtnClicked(_ sender: Any) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)

    }
    
    func setupSideMenu(){
        
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        SideMenuManager.default.menuFadeStatusBar = false
        
        let menuLeftNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuAnimationBackgroundColor = UIColor.white
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuWidth = UIScreen.main.bounds.size.width
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
