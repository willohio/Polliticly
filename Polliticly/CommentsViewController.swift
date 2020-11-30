//
//  CommentsViewController.swift
//  Polliticly
//
//  Created by William Santiago  on 07/06/2020.
//  Copyright © 2020 William Santiago. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import Toaster
import IQKeyboardManagerSwift
import FirebaseDatabase
import FirebaseAuth
class CommentsViewController: UIViewController {
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var option1Button: UIButton!
    var commentsModel = [CommentsModel]()
    @IBOutlet weak var option4Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    var ref: DatabaseReference!
    var ref2: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = true
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        commentTextField.layer.cornerRadius = 8
        commentTextField.setLeftPaddingPoints(8)
        commentTextField.setRightPaddingPoints(8)
        self.titleTextView.text = QuestionsViewController.questionSelected.title
        self.option1Button.setTitle(QuestionsViewController.questionSelected.option1, for: .normal)
        self.option2Button.setTitle(QuestionsViewController.questionSelected.option2, for: .normal)
        self.option3Button.setTitle(QuestionsViewController.questionSelected.option3, for: .normal)
        self.option4Button.setTitle(QuestionsViewController.questionSelected.option4, for: .normal)
        if QuestionsViewController.userQuestionsAnsweredSelected.optionSelected == "option1" {
            self.option1Button.backgroundColor = self.hexStringToUIColor(hex: "#C8CED0")
        }
        else if QuestionsViewController.userQuestionsAnsweredSelected.optionSelected == "option2" {
            self.option2Button.backgroundColor = self.hexStringToUIColor(hex: "#C8CED0")
        }
        else if QuestionsViewController.userQuestionsAnsweredSelected.optionSelected == "option3" {
            self.option3Button.backgroundColor = self.hexStringToUIColor(hex: "#C8CED0")
        }
        else if QuestionsViewController.userQuestionsAnsweredSelected.optionSelected == "option4" {
            self.option4Button.backgroundColor = self.hexStringToUIColor(hex: "#C8CED0")
        }
        self.likeLabel.text = "\(QuestionsViewController.questionSelected.likes ?? 0)"
        self.commentsLabel.text = "\(QuestionsViewController.questionSelected.comments ?? 0)"
        if QuestionsViewController.userQuestionsAnsweredSelected.liked {
            self.likeImageView.image = UIImage(named: "heart_filled")
        }
        else {
           self.likeImageView.image = UIImage(named: "heart")
        }
        tableView.delegate = self
        tableView.dataSource = self
        SVProgressHUD.show(withStatus: "Loading Comments...")
        getData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    
    @IBAction func saveCommentPressed(_ sender: Any) {
        if commentTextField.text?.isEmpty ?? true {
            Toast(text: "Please enter comment!!!").show()
        }
        else {
            self.commentTextField.resignFirstResponder()
            self.view.endEditing(true)
            let timeStamp = "\(Int(Date().timeIntervalSince1970))"
            
            let addReference2 = Database.database().reference().child("Questions").child(QuestionsViewController.questionSelected.id)
            let comments = Int(self.commentsLabel.text ?? "0")!
            addReference2.child("comments").setValue(comments + 1)
            
            let addReference = Database.database().reference().child("Questions").child(QuestionsViewController.questionSelected.id).child("AllComments").child(Auth.auth().currentUser?.uid ?? "").child(timeStamp)
            addReference.child("name").setValue(QuestionsViewController.myName)
            addReference.child("comment").setValue(self.commentTextField.text)
            self.commentTextField.text = ""
        }
    }
    @IBAction func commentTextFieldReturnPressed(_ sender: Any) {
        self.commentTextField.resignFirstResponder()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func getData() {
        ref = Database.database().reference(withPath: "Questions").child(QuestionsViewController.questionSelected.id).child("AllComments")
        ref.observe(.value, with: { snapshot in
            if !snapshot.exists() {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                return
            }
            self.commentsModel = [CommentsModel]()
            for child in snapshot.children {
                let childSnap = child as! DataSnapshot
                if let itemDictionary = childSnap.value as? [String:AnyObject] {
                    for key in itemDictionary.keys {
                        if let modelDictionary = itemDictionary["\(key)"] as? [String:AnyObject] {
                            self.commentsModel.append(CommentsModel(name: modelDictionary["name"] as! String, comment: modelDictionary["comment"] as? String ?? "", timeStamp: Double("\(key)")!))
                            DispatchQueue.main.async {
                                self.commentsModel = self.commentsModel.sorted(by: {
                                    $0.timeStamp < $1.timeStamp
                                })
                                SVProgressHUD.dismiss()
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.commentsLabel.text = "\(self.commentsModel.count)"
            }
        })
        
        ref2 = Database.database().reference(withPath: "Questions").child(QuestionsViewController.questionSelected.id)
        ref2.observe(.value, with: { snapshot in
            if !snapshot.exists() { return }
            for child in snapshot.children {
                let childSnap = child as! DataSnapshot
                if childSnap.key == "likes" {
                    QuestionsViewController.questionSelected.likes = Int("\(childSnap.value ?? "0")")
                    DispatchQueue.main.async {
                        self.likeLabel.text = "\(QuestionsViewController.questionSelected.likes ?? 0)"
                    }
                }
            }
        })
    }
    @IBAction func option1Pressed(_ sender: Any) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(QuestionsViewController.questionSelected.id)
        addReference.child("optionSelected").setValue("option1")
        addReference.child("question").setValue(QuestionsViewController.questionSelected.title)
        addReference.child("option1").setValue(QuestionsViewController.questionSelected.option1)
        addReference.child("option2").setValue(QuestionsViewController.questionSelected.option2)
        addReference.child("option3").setValue(QuestionsViewController.questionSelected.option3)
        addReference.child("option4").setValue(QuestionsViewController.questionSelected.option4)
        self.option1Button.backgroundColor = self.hexStringToUIColor(hex: "#C8CED0")
        self.option2Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
        self.option3Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
        self.option4Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
    }
    @IBAction func option2Pressed(_ sender: Any) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(QuestionsViewController.questionSelected.id)
        addReference.child("optionSelected").setValue("option2")
        addReference.child("question").setValue(QuestionsViewController.questionSelected.title)
        addReference.child("option1").setValue(QuestionsViewController.questionSelected.option1)
        addReference.child("option2").setValue(QuestionsViewController.questionSelected.option2)
        addReference.child("option3").setValue(QuestionsViewController.questionSelected.option3)
        addReference.child("option4").setValue(QuestionsViewController.questionSelected.option4)
        self.option1Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
        self.option2Button.backgroundColor = self.hexStringToUIColor(hex: "#C8CED0")
        self.option3Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
        self.option4Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
    }
    @IBAction func option3Pressed(_ sender: Any) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(QuestionsViewController.questionSelected.id)
        addReference.child("optionSelected").setValue("option3")
        addReference.child("question").setValue(QuestionsViewController.questionSelected.title)
        addReference.child("option1").setValue(QuestionsViewController.questionSelected.option1)
        addReference.child("option2").setValue(QuestionsViewController.questionSelected.option2)
        addReference.child("option3").setValue(QuestionsViewController.questionSelected.option3)
        addReference.child("option4").setValue(QuestionsViewController.questionSelected.option4)
        self.option1Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
        self.option2Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
        self.option3Button.backgroundColor = self.hexStringToUIColor(hex: "#C8CED0")
        self.option4Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
    }
    @IBAction func option4Pressed(_ sender: Any) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(QuestionsViewController.questionSelected.id)
        addReference.child("optionSelected").setValue("option4")
        addReference.child("question").setValue(QuestionsViewController.questionSelected.title)
        addReference.child("option1").setValue(QuestionsViewController.questionSelected.option1)
        addReference.child("option2").setValue(QuestionsViewController.questionSelected.option2)
        addReference.child("option3").setValue(QuestionsViewController.questionSelected.option3)
        addReference.child("option4").setValue(QuestionsViewController.questionSelected.option4)
        self.option1Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
        self.option2Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
        self.option3Button.backgroundColor = self.hexStringToUIColor(hex: "#9381FF")
        self.option4Button.backgroundColor = self.hexStringToUIColor(hex: "#C8CED0")
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        var numberOfLikes: Int = 0
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(QuestionsViewController.questionSelected.id)
        if QuestionsViewController.userQuestionsAnsweredSelected.liked {
            QuestionsViewController.userQuestionsAnsweredSelected.liked = false
            numberOfLikes = QuestionsViewController.questionSelected.likes - 1
            addReference.child("liked").setValue(false)
            
        }
        else {
            QuestionsViewController.userQuestionsAnsweredSelected.liked = true
            numberOfLikes = QuestionsViewController.questionSelected.likes + 1
            addReference.child("liked").setValue(true)
        }
        let addReference2 = Database.database().reference().child("Questions").child(QuestionsViewController.questionSelected.id)
        QuestionsViewController.questionSelected.likes = numberOfLikes
        addReference2.child("likes").setValue(numberOfLikes)
        self.likeLabel.text = "\(numberOfLikes)"
    }
    @IBAction func sharePressed(_ sender: Any) {
        let text = "Question: \(QuestionsViewController.questionSelected.title ?? "")\n\nOption 1: \(QuestionsViewController.questionSelected.option1 ?? "")\n\nOption 2: \(QuestionsViewController.questionSelected.option2 ?? "")\n\nOption 3: \(QuestionsViewController.questionSelected.option3 ?? "")"
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height + 20
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
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
extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsModel.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsTableViewCell", for: indexPath) as? CommentsTableViewCell
        cell?.nameLabel.text = self.commentsModel[indexPath.row].name
        cell?.commentTextView.text = self.commentsModel[indexPath.row].comment
        return cell!
    }
}
