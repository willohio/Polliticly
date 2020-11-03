//
//  DetailQuestionViewController.swift
//  Polliticly
//
//  Created by Apple on 14/06/2020.
//  Copyright © 2020 Future Vision Tech. All rights reserved.
//

import UIKit
import UIKit
import SVProgressHUD
import Firebase
import Toaster
import FirebaseDatabase
import FirebaseAuth
class DetailQuestionViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option4Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    
    @IBOutlet weak var lblOption1: UILabel!
    @IBOutlet weak var lblOption2: UILabel!
    @IBOutlet weak var lblOption3: UILabel!
    @IBOutlet weak var lblOption4: UILabel!
    
    @IBOutlet weak var lblThankyou: UILabel!
    
    
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    
    
    @IBOutlet weak var txtMessageView: UITextView!
    
    
    var userQuestionsAnsweredSelected: UserQuestionsAnsweredModel!
    var questionSelected: QuestionsModel!
    
    
    var ref: DatabaseReference!
    var ref2: DatabaseReference!
    var ref3: DatabaseReference!
    var commentsModel = [CommentsModel]()
    
    var myName = ""
    
    @IBOutlet weak var tableCommentView: UITableView!
    @IBOutlet weak var contentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }

    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveCommentPressed(_ sender: Any) {
        if txtMessageView.text?.isEmpty ?? true {
            Toast(text: "Please enter comment!!!").show()
        }
        else {
            self.txtMessageView.resignFirstResponder()
            self.view.endEditing(true)
            let timeStamp = "\(Int(Date().timeIntervalSince1970))"
            
            let addReference2 = Database.database().reference().child("Questions").child(questionSelected.id)
            let result = self.commentsLabel.text!.split(separator: " ")
            if result.count > 0{
                let comments = Int(result[0] ?? "") ?? 0
                addReference2.child("comments").setValue(comments + 1)
            }
            
            
            
            let addReference = Database.database().reference().child("Questions").child(questionSelected.id).child("AllComments").child(Auth.auth().currentUser?.uid ?? "").child(timeStamp)
            addReference.child("name").setValue(myName)
            addReference.child("comment").setValue(self.txtMessageView.text)
            self.txtMessageView.text = ""
        }
    }
    

    func setupView(){
        contentView.layer.cornerRadius = 24
        contentView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        self.tableCommentView.estimatedRowHeight = 85
        
//        self.option1Button.setTitle(questionSelected.option1, for: .normal)
//        self.option2Button.setTitle(questionSelected.option2, for: .normal)
//        self.option3Button.setTitle(questionSelected.option3, for: .normal)
//        self.option4Button.setTitle(questionSelected.option4, for: .normal)
        self.lblOption1.text = self.questionSelected.option1
        self.lblOption2.text = self.questionSelected.option2
        self.lblOption3.text = self.questionSelected.option3
        self.lblOption4.text = self.questionSelected.option4
        if userQuestionsAnsweredSelected.optionSelected == "option1" {
            self.option1Button.backgroundColor = self.hexStringToUIColor(hex: "#8A13D6")
            lblOption1.textColor = .white
            lblOption4.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            lblOption2.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            lblOption3.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            let total = self.questionSelected.optionSelected1 + self.questionSelected.optionSelected2 + self.questionSelected.optionSelected3 + self.questionSelected.optionSelected4
            let value = Double(self.questionSelected.optionSelected1) / Double(total) * 100
            let roundedString = String(format: "%.2f", value)
            lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
            lblThankyou.isHidden = false
        }
        else if userQuestionsAnsweredSelected.optionSelected == "option2" {
            self.option2Button.backgroundColor = self.hexStringToUIColor(hex: "#8A13D6")
            lblOption2.textColor = .white
            lblOption1.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            lblOption4.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            lblOption3.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            let total = self.questionSelected.optionSelected1 + self.questionSelected.optionSelected2 + self.questionSelected.optionSelected3 + self.questionSelected.optionSelected4
            let value = Double(self.questionSelected.optionSelected2) / Double(total) * 100
            let roundedString = String(format: "%.2f", value)
            lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
            lblThankyou.isHidden = false
        }
        else if userQuestionsAnsweredSelected.optionSelected == "option3" {
            self.option3Button.backgroundColor = self.hexStringToUIColor(hex: "#8A13D6")
            lblOption3.textColor = .white
            lblOption1.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            lblOption2.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            lblOption4.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            let total = self.questionSelected.optionSelected1 + self.questionSelected.optionSelected2 + self.questionSelected.optionSelected3 + self.questionSelected.optionSelected4
            let value = Double(self.questionSelected.optionSelected3) / Double(total) * 100
            let roundedString = String(format: "%.2f", value)
            lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
            lblThankyou.isHidden = false
        }
        else if userQuestionsAnsweredSelected.optionSelected == "option4" {
            self.option4Button.backgroundColor = self.hexStringToUIColor(hex: "#8A13D6")
            lblOption4.textColor = .white
            lblOption1.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            lblOption2.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            lblOption3.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            let total = self.questionSelected.optionSelected1 + self.questionSelected.optionSelected2 + self.questionSelected.optionSelected3 + self.questionSelected.optionSelected4
            let value = Double(self.questionSelected.optionSelected4) / Double(total) * 100
            let roundedString = String(format: "%.2f", value)
            lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
            lblThankyou.isHidden = false
        }
        else{
             lblThankyou.isHidden = true
        }
        self.likeLabel.text = "\(questionSelected.likes ?? 0)"
        self.commentsLabel.text = "\(questionSelected.comments ?? 0) Comments"
        if userQuestionsAnsweredSelected.liked {
            self.likeImageView.image = UIImage(named: "heart_filled")
        }
        else {
           self.likeImageView.image = UIImage(named: "heart")
        }
        self.titleTextView.text = questionSelected.title
        SVProgressHUD.show(withStatus: "Loading Comments...")
        getData()
        
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
                    self.myName = userName
                })
    }

    func getData() {
        ref = Database.database().reference(withPath: "Questions").child(questionSelected.id).child("AllComments")
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
                                self.tableCommentView.reloadData()
                                if self.commentsModel.count > 0 {
                                    self.tableCommentView.scrollToRow(at: IndexPath(row: self.commentsModel.count - 1, section: 0), at: .bottom, animated: true)
                                }
                                
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.commentsLabel.text = "\(self.commentsModel.count) Comments"
            }
        })
        
        ref2 = Database.database().reference(withPath: "Questions").child(questionSelected.id)
        ref2.observe(.value, with: { snapshot in
            if !snapshot.exists() { return }
            for child in snapshot.children {
                let childSnap = child as! DataSnapshot
                if childSnap.key == "likes" {
                    self.questionSelected.likes = Int("\(childSnap.value ?? "0")")
                    DispatchQueue.main.async {
                        self.likeLabel.text = "\(self.questionSelected.likes ?? 0)"
                    }
                }
            }
        })
        

    }
    @IBAction func option1Pressed(_ sender: Any) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(questionSelected.id)
        addReference.child("optionSelected").setValue("option1")
        addReference.child("question").setValue(questionSelected.title)
        addReference.child("option1").setValue(questionSelected.option1)
        addReference.child("option2").setValue(questionSelected.option2)
        addReference.child("option3").setValue(questionSelected.option3)
        addReference.child("option4").setValue(questionSelected.option4)
        self.option1Button.backgroundColor = self.hexStringToUIColor(hex: "#8A13D6")
        self.option2Button.backgroundColor = .clear
        self.option3Button.backgroundColor = .clear
        self.option4Button.backgroundColor = .clear
        lblOption1.textColor = .white
        lblOption4.textColor = self.hexStringToUIColor(hex: "#8A13D6")
        lblOption2.textColor = self.hexStringToUIColor(hex: "#8A13D6")
        lblOption3.textColor = self.hexStringToUIColor(hex: "#8A13D6")
        lblThankyou.isHidden = false
        
        let total = self.questionSelected.optionSelected1 + self.questionSelected.optionSelected2 + self.questionSelected.optionSelected3 + self.questionSelected.optionSelected4
        
        let value = Double(self.questionSelected.optionSelected1) / Double(total) * 100
        let roundedString = String(format: "%.2f", value)
        lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
    }
    @IBAction func option2Pressed(_ sender: Any) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(questionSelected.id)
        addReference.child("optionSelected").setValue("option2")
        addReference.child("question").setValue(questionSelected.title)
        addReference.child("option1").setValue(questionSelected.option1)
        addReference.child("option2").setValue(questionSelected.option2)
        addReference.child("option3").setValue(questionSelected.option3)
        addReference.child("option4").setValue(questionSelected.option4)
        
        self.option2Button.backgroundColor = self.hexStringToUIColor(hex: "#8A13D6")
        self.option1Button.backgroundColor = .clear
        self.option3Button.backgroundColor = .clear
        self.option4Button.backgroundColor = .clear
        lblThankyou.isHidden = false
        lblOption2.textColor = .white
        lblOption1.textColor = self.hexStringToUIColor(hex: "#8A13D6")
        lblOption4.textColor = self.hexStringToUIColor(hex: "#8A13D6")
        lblOption3.textColor = self.hexStringToUIColor(hex: "#8A13D6")
        
        let total = self.questionSelected.optionSelected1 + self.questionSelected.optionSelected2 + self.questionSelected.optionSelected3 + self.questionSelected.optionSelected4
        let value = Double(self.questionSelected.optionSelected2) / Double(total) * 100
        let roundedString = String(format: "%.2f", value)
        lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
    }
    @IBAction func option3Pressed(_ sender: Any) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(questionSelected.id)
        addReference.child("optionSelected").setValue("option3")
        addReference.child("question").setValue(questionSelected.title)
        addReference.child("option1").setValue(questionSelected.option1)
        addReference.child("option2").setValue(questionSelected.option2)
        addReference.child("option3").setValue(questionSelected.option3)
        addReference.child("option4").setValue(questionSelected.option4)
        lblOption3.textColor = .white
        lblOption1.textColor = self.hexStringToUIColor(hex: "#8A13D6")
        lblOption2.textColor = self.hexStringToUIColor(hex: "#8A13D6")
        lblOption4.textColor = self.hexStringToUIColor(hex: "#8A13D6")
        lblThankyou.isHidden = false
        self.option3Button.backgroundColor = self.hexStringToUIColor(hex: "#8A13D6")
        self.option1Button.backgroundColor = .clear
        self.option2Button.backgroundColor = .clear
        self.option4Button.backgroundColor = .clear
        
        let total = self.questionSelected.optionSelected1 + self.questionSelected.optionSelected2 + self.questionSelected.optionSelected3 + self.questionSelected.optionSelected4
        
        let value = Double(self.questionSelected.optionSelected3) / Double(total) * 100
        let roundedString = String(format: "%.2f", value)
        lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
    }
    @IBAction func option4Pressed(_ sender: Any) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(questionSelected.id)
        addReference.child("optionSelected").setValue("option4")
        addReference.child("question").setValue(questionSelected.title)
        addReference.child("option1").setValue(questionSelected.option1)
        addReference.child("option2").setValue(questionSelected.option2)
        addReference.child("option3").setValue(questionSelected.option3)
        addReference.child("option4").setValue(questionSelected.option4)
        self.option4Button.backgroundColor = self.hexStringToUIColor(hex: "#8A13D6")
        self.option3Button.backgroundColor = .clear
        self.option2Button.backgroundColor = .clear
        self.option1Button.backgroundColor = .clear
        lblOption4.textColor = .white
        lblThankyou.isHidden = false
        lblOption1.textColor = self.hexStringToUIColor(hex: "#8A13D6")
        lblOption2.textColor = self.hexStringToUIColor(hex: "#8A13D6")
        lblOption3.textColor = self.hexStringToUIColor(hex: "#8A13D6")
        
        let total = self.questionSelected.optionSelected1 + self.questionSelected.optionSelected2 + self.questionSelected.optionSelected3 + self.questionSelected.optionSelected4
        let value = Double(self.questionSelected.optionSelected4) / Double(total) * 100
        let roundedString = String(format: "%.2f", value)
        lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        var numberOfLikes: Int = 0
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(questionSelected.id)
        if userQuestionsAnsweredSelected.liked {
            userQuestionsAnsweredSelected.liked = false
            numberOfLikes = questionSelected.likes - 1
            addReference.child("liked").setValue(false)
            
        }
        else {
            userQuestionsAnsweredSelected.liked = true
            numberOfLikes = questionSelected.likes + 1
            addReference.child("liked").setValue(true)
        }
        let addReference2 = Database.database().reference().child("Questions").child(questionSelected.id)
        questionSelected.likes = numberOfLikes
        addReference2.child("likes").setValue(numberOfLikes)
        self.likeLabel.text = "\(numberOfLikes)"
    }
    @IBAction func sharePressed(_ sender: Any) {
        let text = "Question: \(questionSelected.title ?? "")\n\nOption 1: \(questionSelected.option1 ?? "")\n\nOption 2: \(questionSelected.option2 ?? "")\n\nOption 3: \(questionSelected.option3 ?? "")"
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
    
    // MARK: - TableView Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return commentsModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
     tableView.register(UINib(nibName: String(describing: CommentsCell.self), bundle: nil), forCellReuseIdentifier: String(describing: CommentsCell.self))
        
        
     let cell : CommentsCell! = tableView.dequeueReusableCell(withIdentifier: String(describing: CommentsCell.self)) as? CommentsCell
     cell?.nameLabel.text = self.commentsModel[indexPath.row].name
     cell?.commentTextView.text = self.commentsModel[indexPath.row].comment
     return cell
       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }

}

extension UIView {

/**
 Simply zooming in of a view: set view scale to 0 and zoom to Identity on 'duration' time interval.

 - parameter duration: animation duration
 */
func zoomIn(duration: TimeInterval = 0.2) {
    self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
    UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
        self.transform = .identity
        }) { (animationCompleted: Bool) -> Void in
    }
}

/**
 Simply zooming out of a view: set view scale to Identity and zoom out to 0 on 'duration' time interval.

 - parameter duration: animation duration
 */
func zoomOut(duration : TimeInterval = 0.2) {
    self.transform = .identity
    UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }) { (animationCompleted: Bool) -> Void in
    }
}

/**
 Zoom in any view with specified offset magnification.

 - parameter duration:     animation duration.
 - parameter easingOffset: easing offset.
 */
func zoomInWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
    let easeScale = 1.0 + easingOffset
    let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
    let scalingDuration = duration - easingDuration
    UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
        self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }, completion: { (completed: Bool) -> Void in
            UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.transform = .identity
                }, completion: { (completed: Bool) -> Void in
            })
    })
}

/**
 Zoom out any view with specified offset magnification.

 - parameter duration:     animation duration.
 - parameter easingOffset: easing offset.
 */
func zoomOutWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
    let easeScale = 1.0 + easingOffset
    let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
    let scalingDuration = duration - easingDuration
    UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
        self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }, completion: { (completed: Bool) -> Void in
            UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                }, completion: { (completed: Bool) -> Void in
            })
    })
}

}
