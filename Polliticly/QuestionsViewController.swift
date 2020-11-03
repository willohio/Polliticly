//
//  QuestionsViewController.swift
//  Polliticly
//
//  Created by Future Vision Tech  on 07/06/2020.
//  Copyright © 2020 Future Vision Tech. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import Toaster
import FirebaseDatabase
import FirebaseAuth
class QuestionsViewController: UIViewController {

    var ref: DatabaseReference!
    var ref2: DatabaseReference!
    var ref3: DatabaseReference!
    var questionsModel = [QuestionsModel]()
    var userQuestionsAnsweredModel = [UserQuestionsAnsweredModel]()
    public static var questionSelected: QuestionsModel!
    public static var userQuestionsAnsweredSelected: UserQuestionsAnsweredModel!
    public static var myName: String = ""
    var liked = [Bool]()
    var isAllowedToReload: Bool = false
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        SVProgressHUD.show(withStatus: "Loading Questions...")
        self.getData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Get the presented navigationController and the view controller it contains
        let navigationController = segue.destination
        navigationController.modalPresentationStyle = .fullScreen
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign out", style: UIAlertAction.Style.destructive, handler: {(_: UIAlertAction!) in
            UserDefaults.standard.setValue("", forKey: "email")
            UserDefaults.standard.setValue("", forKey: "password")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window!.rootViewController = mainViewController
            appDelegate.window!.makeKeyAndVisible()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func getData() {
        ref = Database.database().reference(withPath: "Questions")
        ref.observe(.value, with: { snapshot in
            if !snapshot.exists() {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    Toast(text: "No Questions Found!!!").show()
                }
                return
            }
            self.questionsModel = [QuestionsModel]()
            for child in snapshot.children {
                let childSnap = child as! DataSnapshot
                if let itemDictionary = childSnap.value as? [String:AnyObject] {
                    self.questionsModel.append(QuestionsModel(id: childSnap.key, title: itemDictionary["title"] as! String, option1: itemDictionary["option1"] as! String, option2: itemDictionary["option2"] as! String, option3: itemDictionary["option3"] as! String, option4: itemDictionary["option4"] as! String, likes: itemDictionary["likes"] as! Int, comments: itemDictionary["comments"] as! Int))
                    self.userQuestionsAnsweredModel.append(UserQuestionsAnsweredModel(id: childSnap.key, liked: false, optionSelected: ""))
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.tableView.reloadData()
                    }
                }
            }
            self.ref2 = Database.database().reference(withPath: "Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered")
            self.ref2.observe(.value, with: { snapshot in
                if !snapshot.exists() {
                    print("empty")
                    return
                }
                for child in snapshot.children {
                    let childSnap = child as! DataSnapshot
                    if let itemDictionary = childSnap.value as? [String:AnyObject] {
                        for i in 0..<self.questionsModel.count {
                            print("\(childSnap.key)")
                            if childSnap.key == self.questionsModel[i].id {
                                print("Found")
                                self.userQuestionsAnsweredModel[i].liked = (itemDictionary["liked"] as? Bool ?? false)
                                self.userQuestionsAnsweredModel[i].optionSelected = (itemDictionary["optionSelected"] as? String ?? "")
                            }
                        }
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            self.tableView.reloadData()
                        }
                    }
                }
            })
        })
        
        ref3 = Database.database().reference(withPath: "Users").child(Auth.auth().currentUser?.uid ?? "")
        ref3.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { return }
            var userName: String = ""
            for child in snapshot.children {
                let childSnap = child as! DataSnapshot
                if childSnap.key == "userName" {
                    userName = childSnap.value as! String
                }
//                else if childSnap.key == "lastName" {
//                    lastName = childSnap.value as! String
//                }
            }
            QuestionsViewController.myName = userName
        })
        
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
extension QuestionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 475
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questionsModel.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionsTableViewCell", for: indexPath) as? QuestionsTableViewCell
        cell?.titleTextView.text = self.questionsModel[indexPath.row].title
        cell?.option1Button.setTitle(self.questionsModel[indexPath.row].option1, for: .normal)
        cell?.option2Button.setTitle(self.questionsModel[indexPath.row].option2, for: .normal)
        cell?.option3Button.setTitle(self.questionsModel[indexPath.row].option3, for: .normal)
        cell?.option4Button.setTitle(self.questionsModel[indexPath.row].option4, for: .normal)
        cell?.likesLabel.text = "\(self.questionsModel[indexPath.row].likes ?? 0)"
        cell?.commentsLabel.text = "\(self.questionsModel[indexPath.row].comments ?? 0)"
        if self.userQuestionsAnsweredModel[indexPath.row].liked {
            cell?.likeImageView.image = UIImage(named: "heart_filled")
        }
        else {
            cell?.likeImageView.image = UIImage(named: "heart")
        }
        cell?.likesButton.tag = indexPath.row
        cell?.commentsButton.tag = indexPath.row
        cell?.shareButton.tag = indexPath.row
        cell?.option1Button.tag = indexPath.row
        cell?.option2Button.tag = indexPath.row
        cell?.option3Button.tag = indexPath.row
        cell?.option4Button.tag = indexPath.row
        if self.userQuestionsAnsweredModel[indexPath.row].optionSelected == "option1" {
            cell?.option1Button.backgroundColor = self.hexStringToUIColor(hex: "#C8CED0")
            cell?.option2Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
            cell?.option3Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
            cell?.option4Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
        }
        else if self.userQuestionsAnsweredModel[indexPath.row].optionSelected == "option2" {
            cell?.option1Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
            cell?.option2Button.backgroundColor = self.hexStringToUIColor(hex: "#C8CED0")
            cell?.option3Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
            cell?.option4Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
        }
        else if self.userQuestionsAnsweredModel[indexPath.row].optionSelected == "option3" {
            cell?.option1Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
            cell?.option2Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
            cell?.option3Button.backgroundColor = self.hexStringToUIColor(hex: "#C8CED0")
            cell?.option4Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
        }
        else if self.userQuestionsAnsweredModel[indexPath.row].optionSelected == "option4" {
            cell?.option1Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
            cell?.option2Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
            cell?.option3Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
            cell?.option4Button.backgroundColor = self.hexStringToUIColor(hex: "#C8CED0")
        }
        cell?.option1Button.addTarget(self, action: #selector(QuestionsViewController.option1ButtonPresed(sender:)), for: .touchUpInside)
        cell?.option2Button.addTarget(self, action: #selector(QuestionsViewController.option2ButtonPresed(sender:)), for: .touchUpInside)
        cell?.option3Button.addTarget(self, action: #selector(QuestionsViewController.option3ButtonPresed(sender:)), for: .touchUpInside)
        cell?.option4Button.addTarget(self, action: #selector(QuestionsViewController.option4ButtonPresed(sender:)), for: .touchUpInside)
        cell?.likesButton.addTarget(self, action: #selector(QuestionsViewController.likesButtonPresed(sender:)), for: .touchUpInside)
        cell?.commentsButton.addTarget(self, action: #selector(QuestionsViewController.commentsButtonPresed(sender:)), for: .touchUpInside)
        cell?.shareButton.addTarget(self, action: #selector(QuestionsViewController.shareButtonPresed(sender:)), for: .touchUpInside)
        return cell!
    }
    
    @objc func shareButtonPresed(sender: UIButton) {
        let text = "Question: \(self.questionsModel[sender.tag].title ?? "")\n\nOption 1: \(self.questionsModel[sender.tag].option1 ?? "")\n\nOption 2: \(self.questionsModel[sender.tag].option2 ?? "")\n\nOption 3: \(self.questionsModel[sender.tag].option3 ?? "")"
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    @objc func option1ButtonPresed(sender: UIButton) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(self.questionsModel[sender.tag].id)
        addReference.child("optionSelected").setValue("option1")
        addReference.child("question").setValue(self.questionsModel[sender.tag].title)
        addReference.child("option1").setValue(self.questionsModel[sender.tag].option1)
        addReference.child("option2").setValue(self.questionsModel[sender.tag].option2)
        addReference.child("option3").setValue(self.questionsModel[sender.tag].option3)
        addReference.child("option4").setValue(self.questionsModel[sender.tag].option4)
    }
    @objc func option2ButtonPresed(sender: UIButton) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(self.questionsModel[sender.tag].id)
        addReference.child("optionSelected").setValue("option2")
        addReference.child("question").setValue(self.questionsModel[sender.tag].title)
        addReference.child("option1").setValue(self.questionsModel[sender.tag].option1)
        addReference.child("option2").setValue(self.questionsModel[sender.tag].option2)
        addReference.child("option3").setValue(self.questionsModel[sender.tag].option3)
        addReference.child("option4").setValue(self.questionsModel[sender.tag].option4)
    }
    @objc func option3ButtonPresed(sender: UIButton) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(self.questionsModel[sender.tag].id)
        addReference.child("optionSelected").setValue("option3")
        addReference.child("question").setValue(self.questionsModel[sender.tag].title)
        addReference.child("option1").setValue(self.questionsModel[sender.tag].option1)
        addReference.child("option2").setValue(self.questionsModel[sender.tag].option2)
        addReference.child("option3").setValue(self.questionsModel[sender.tag].option3)
        addReference.child("option4").setValue(self.questionsModel[sender.tag].option4)
    }
    @objc func option4ButtonPresed(sender: UIButton) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(self.questionsModel[sender.tag].id)
        addReference.child("optionSelected").setValue("option4")
        addReference.child("question").setValue(self.questionsModel[sender.tag].title)
        addReference.child("option1").setValue(self.questionsModel[sender.tag].option1)
        addReference.child("option2").setValue(self.questionsModel[sender.tag].option2)
        addReference.child("option3").setValue(self.questionsModel[sender.tag].option3)
        addReference.child("option4").setValue(self.questionsModel[sender.tag].option4)
    }
    @objc func likesButtonPresed(sender: UIButton) {
        var numberOfLikes: Int = 0
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(self.questionsModel[sender.tag].id)
        if self.userQuestionsAnsweredModel[sender.tag].liked {
            self.userQuestionsAnsweredModel[sender.tag].liked = false
            numberOfLikes = self.questionsModel[sender.tag].likes - 1
            addReference.child("liked").setValue(false)
            
        }
        else {
            self.userQuestionsAnsweredModel[sender.tag].liked = true
            numberOfLikes = self.questionsModel[sender.tag].likes + 1

            addReference.child("liked").setValue(true)
        }
        let addReference2 = Database.database().reference().child("Questions").child(self.questionsModel[sender.tag].id)
        addReference2.child("likes").setValue(numberOfLikes)
    }
    @objc func commentsButtonPresed(sender: UIButton) {
        QuestionsViewController.questionSelected = self.questionsModel[sender.tag]
        QuestionsViewController.userQuestionsAnsweredSelected = self.userQuestionsAnsweredModel[sender.tag]
        
    }
}
