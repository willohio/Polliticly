//
//  DashboardViewController.swift
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
import iOSDropDown
import SideMenu
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class DashboardViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var contentView: UIView!
    var ref: DatabaseReference!
   var ref2: DatabaseReference!
   var ref3: DatabaseReference!
   var questionsModel = [QuestionsModel]()
   var userQuestionsAnsweredModel = [UserQuestionsAnsweredModel]()
   public static var questionSelected: QuestionsModel!
   public static var userQuestionsAnsweredSelected: UserQuestionsAnsweredModel!
    
    @IBOutlet weak var settingDropDown: DropDown!
    
    var myGender = ""
    var myZipCode = ""
    var myEthnicity = ""
    var myAge = 0
    var isAgeAllow = false
    var isZipCodeAllow = false
    var isEthnicityAllow = false
    var isGenderAllow = false
    var option1Count = 0
    var option2Count = 0
    var option3Count = 0
    var option4Count = 0
   public static var myName: String = ""
   var liked = [Bool]()
   var isAllowedToReload: Bool = false
    var arrQuestion = [QuestionsModel]()
    var arrAnswers = [UserQuestionsAnsweredModel]()
    @IBOutlet weak var tableQuestionsView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableQuestionsView.estimatedRowHeight = 85
        SVProgressHUD.show(withStatus: "Loading Questions...")
        self.getData()
        setupView()
        setupSideMenu()
    }
    
    
    
    @IBAction func sideMenuTapped(_ sender: Any) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    func getSelectedOptions(){
        let ref = Database.database().reference(withPath: "Users")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                print("empty")
                return
            }
            self.option1Count = 0
            self.option2Count = 0
            self.option3Count = 0
            self.option4Count = 0
            
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                let userDict = userSnap.value as! [String:AnyObject] //child data
                if let answered = userDict["QuestionsAnswered"] as? [String:AnyObject]{
                    print(answered)
                    
                    UserDefaults.standard.synchronize()
                    for item in answered{
                        let answer = item.value as! [String:AnyObject]
                        let obj = UserQuestionsAnsweredModel()
                        obj.question = answer["question"] as? String ?? ""
                        obj.seleted = answer["optionSelected"] as? String ?? ""

                        self.arrAnswers.append(obj)
                        
                        let selectedAnswer = answer["optionSelected"] as? String ?? ""
                        if selectedAnswer == "option1"{
                            self.option1Count = self.option1Count + 1
                        }
                        else if selectedAnswer == "option2"{
                            self.option2Count = self.option2Count + 1
                        }
                        else if selectedAnswer == "option3"{
                            self.option3Count = self.option3Count + 1
                        }
                        else if selectedAnswer == "option4"{
                            self.option4Count = self.option4Count + 1
                        }
                    }
                
                    
                }
                
            }
            for (_, element) in self.arrAnswers.enumerated() {
                for (_, element2) in self.questionsModel.enumerated() {
                    if element.question == element2.title{
                        if element.seleted == "option1"{
                            element2.optionSelected1 =  element2.optionSelected1 + 1
                        }
                        if element.seleted == "option2"{
                            element2.optionSelected2 =  element2.optionSelected2 + 1
                        }
                        if element.seleted == "option3"{
                            element2.optionSelected3 =  element2.optionSelected3 + 1
                        }
                        if element.seleted == "option4"{
                            element2.optionSelected4 =  element2.optionSelected4 + 1
                        }
                        
                    }
                }
            }
           
            UserDefaults.standard.set(self.option1Count, forKey: "option1")
            UserDefaults.standard.set(self.option2Count, forKey: "option2")
            UserDefaults.standard.set(self.option3Count, forKey: "option3")
            UserDefaults.standard.set(self.option4Count, forKey: "option4")
            
            let totalAnswered = UserDefaults.standard.integer(forKey: "option1") + UserDefaults.standard.integer(forKey: "option2") + UserDefaults.standard.integer(forKey: "option3") + UserDefaults.standard.integer(forKey: "option4")
            UserDefaults.standard.set(totalAnswered, forKey: "totalAnswered")
            UserDefaults.standard.synchronize()
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.tableQuestionsView.reloadData()
            }
        })
        
    }
    
    func getData() {
        var imageName = "\(UserDefaults.standard.string(forKey: "email") ?? "").jpg"
        let path  = "profile/image\(imageName)"
        
        let storageRef = Storage.storage().reference(withPath: path)
        storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
           print(url?.absoluteString) // <- Your url
            UserDefaults.standard.set(url?.absoluteString, forKey: image)
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
                        if childSnap.key == "zipCode" {
                            self.myZipCode = childSnap.value as? String ?? ""
                        }
                        if childSnap.key == "gender" {
                            self.myGender = childSnap.value as? String ?? ""
                        }
                        
                        if childSnap.key == "ethnicity" {
                            self.myZipCode = childSnap.value as? String ?? ""
                        }
                        
                        if childSnap.key == "birthday" {
                            self.myAge = self.getAgeFromDOF(date: childSnap.value as? String ?? "")
                        }
                        
                       
        //
                    }
                    DashboardViewController.myName = userName
                    self.ref = Database.database().reference(withPath: "Questions")
                    self.ref.observe(.value, with: { snapshot in
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
                                let arrGender = itemDictionary["filterGender"] as? [String] ?? []
                                let arrEthnicity = itemDictionary["filterEthnicity"] as? [String] ?? []
                                let arrZipCode = itemDictionary["filterZipCode"] as? [String] ?? []
                                let ageLimit = itemDictionary["age"] as? String ?? ""
                                let IntAge = Int(ageLimit) ?? 0
                                
                                self.isAgeAllow = false
                                self.isGenderAllow = false
                                self.isZipCodeAllow = false
                                self.isEthnicityAllow = false
                                
                                
                                
                                if arrGender.count > 0 {
                                    if arrGender.contains(self.myGender){
                                        self.isGenderAllow = true
                                    }
                                    else {
                                        self.isGenderAllow = false
                                    }
                                }
                                else {
                                    self.isGenderAllow = true
                                }
                                
                                if arrEthnicity.count > 0 {
                                    if arrEthnicity.contains(self.myEthnicity){
                                        self.isEthnicityAllow = true
                                    }
                                    else {
                                        self.isEthnicityAllow = false
                                    }
                                }
                                else{
                                    self.isEthnicityAllow = true
                                }
                                
                                if IntAge > 0 {
                                    if self.myAge < IntAge {
                                        self.isGenderAllow = true
                                    }
                                    else{
                                        self.isAgeAllow = false
                                    }
                                }
                                else{
                                    self.isAgeAllow = true
                                }
                                
                                if arrZipCode.count > 0 {
                                    if arrZipCode.contains(self.myZipCode){
                                        self.isZipCodeAllow = true
                                    }
                                    else {
                                        self.isZipCodeAllow = false
                                    }
                                }
                                else{
                                    self.isZipCodeAllow = true
                                }
                                self.arrQuestion.append(QuestionsModel(id: childSnap.key, title: itemDictionary["title"] as? String ?? "", option1: itemDictionary["option1"] as? String ?? "", option2: itemDictionary["option2"] as? String ?? "", option3: itemDictionary["option3"] as? String ?? "", option4: itemDictionary["option4"] as? String ?? "", likes: itemDictionary["likes"] as? Int ?? 0, comments: itemDictionary["comments"] as? Int ?? 0))
                                
                                if self.isEthnicityAllow && self.isAgeAllow && self.isZipCodeAllow && self.isGenderAllow{
                                    self.questionsModel.append(QuestionsModel(id: childSnap.key, title: itemDictionary["title"] as? String ?? "", option1: itemDictionary["option1"] as? String ?? "", option2: itemDictionary["option2"] as? String ?? "", option3: itemDictionary["option3"] as? String ?? "", option4: itemDictionary["option4"] as? String ?? "", likes: itemDictionary["likes"] as? Int ?? 0, comments: itemDictionary["comments"] as? Int ?? 0))
                                    self.userQuestionsAnsweredModel.append(UserQuestionsAnsweredModel(id: childSnap.key, liked: false, optionSelected: ""))
                                }
                                
                                self.getSelectedOptions()
//                                DispatchQueue.main.async {
//                                    SVProgressHUD.dismiss()
//                                    self.tableQuestionsView.reloadData()
//                                }
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
                                        self.tableQuestionsView.reloadData()
                                    }
                                }
                            }
                        })
                    })
                    
                    
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

    func getAgeFromDOF(date: String) -> Int {

        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "mm/dd/yyyy"
        let dateOfBirth = dateFormater.date(from: date)

        let calender = Calendar.current

        let dateComponent = calender.dateComponents([.year, .month, .day], from:
        dateOfBirth!, to: Date())

        return dateComponent.year ?? 0
    }

    
    // MARK: - TableView Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
     return self.questionsModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
     tableView.register(UINib(nibName: String(describing: QuestionTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: QuestionTableViewCell.self))
        
        
     let cell : QuestionTableViewCell! = tableView.dequeueReusableCell(withIdentifier: String(describing: QuestionTableViewCell.self)) as? QuestionTableViewCell
     
        
    
        cell?.titleTextView.text = self.questionsModel[indexPath.row].title
        
        cell.lblOption1.text = self.questionsModel[indexPath.row].option1
        cell.lblOption2.text = self.questionsModel[indexPath.row].option2
        cell.lblOption3.text = self.questionsModel[indexPath.row].option3
        cell.lblOption4.text = self.questionsModel[indexPath.row].option4
        
        cell?.likesLabel.text = "\(self.questionsModel[indexPath.row].likes ?? 0)"
        cell?.commentsLabel.text = "\(self.questionsModel[indexPath.row].comments ?? 0) Comments"
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
            cell?.option1Button.backgroundColor = self.hexStringToUIColor(hex: "#8A13D6")
            cell.lblOption1.textColor = .white
            cell.lblOption2.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            cell.lblOption3.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            cell.lblOption4.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            cell?.option2Button.backgroundColor = .clear
            cell?.option3Button.backgroundColor = .clear
            cell?.option4Button.backgroundColor = .clear
            let total = self.questionsModel[indexPath.row].optionSelected1 + self.questionsModel[indexPath.row].optionSelected2 + self.questionsModel[indexPath.row].optionSelected3 + self.questionsModel[indexPath.row].optionSelected4
            
            let value = Double(self.questionsModel[indexPath.row].optionSelected1) / Double(total) * 100
            let roundedString = String(format: "%.2f", value)
            cell.lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
        }
        else if self.userQuestionsAnsweredModel[indexPath.row].optionSelected == "option2" {
            cell?.option1Button.backgroundColor = .clear
            cell?.option2Button.backgroundColor = self.hexStringToUIColor(hex: "#8A13D6")
            cell?.option3Button.backgroundColor = .clear
            cell?.option4Button.backgroundColor = .clear
            
            cell.lblOption2.textColor = .white
            cell.lblOption1.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            cell.lblOption3.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            cell.lblOption4.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            let total = self.questionsModel[indexPath.row].optionSelected1 + self.questionsModel[indexPath.row].optionSelected2 + self.questionsModel[indexPath.row].optionSelected3 + self.questionsModel[indexPath.row].optionSelected4
            
            let value = Double(self.questionsModel[indexPath.row].optionSelected2) / Double(total) * 100
            let roundedString = String(format: "%.2f", value)
            cell.lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
        }
        else if self.userQuestionsAnsweredModel[indexPath.row].optionSelected == "option3" {
            cell?.option1Button.backgroundColor = .clear
            cell?.option2Button.backgroundColor = .clear
            cell?.option3Button.backgroundColor = self.hexStringToUIColor(hex: "#8A13D6")
            cell?.option4Button.backgroundColor = .clear
            
            cell.lblOption3.textColor = .white
            cell.lblOption1.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            cell.lblOption2.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            cell.lblOption4.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            
            let total = self.questionsModel[indexPath.row].optionSelected1 + self.questionsModel[indexPath.row].optionSelected2 + self.questionsModel[indexPath.row].optionSelected3 + self.questionsModel[indexPath.row].optionSelected4
            
            let value = Double(self.questionsModel[indexPath.row].optionSelected3) / Double(total) * 100
            let roundedString = String(format: "%.2f", value)
            cell.lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"

        }
        else if self.userQuestionsAnsweredModel[indexPath.row].optionSelected == "option4" {
            cell?.option1Button.backgroundColor = .clear
            cell?.option2Button.backgroundColor = .clear
            cell?.option3Button.backgroundColor = .clear
            
            cell.lblOption4.textColor = .white
            cell.lblOption1.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            cell.lblOption2.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            cell.lblOption3.textColor = self.hexStringToUIColor(hex: "#8A13D6")
            
            let total = self.questionsModel[indexPath.row].optionSelected1 + self.questionsModel[indexPath.row].optionSelected2 + self.questionsModel[indexPath.row].optionSelected3 + self.questionsModel[indexPath.row].optionSelected4
            let value = Double(self.questionsModel[indexPath.row].optionSelected4) / Double(total) * 100
            let roundedString = String(format: "%.2f", value)
            cell.lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
            
            


            cell?.option4Button.backgroundColor = self.hexStringToUIColor(hex: "#8A13D6")
        }
        else{
            cell.lblThankyou.isHidden = true
            
        }
        cell?.option1Button.addTarget(self, action: #selector(option1ButtonPresed(sender:)), for: .touchUpInside)
        cell?.option2Button.addTarget(self, action: #selector(option2ButtonPresed(sender:)), for: .touchUpInside)
        cell?.option3Button.addTarget(self, action: #selector(option3ButtonPresed(sender:)), for: .touchUpInside)
        cell?.option4Button.addTarget(self, action: #selector(option4ButtonPresed(sender:)), for: .touchUpInside)
        cell?.likesButton.addTarget(self, action: #selector(likesButtonPresed(sender:)), for: .touchUpInside)
        cell?.commentsButton.addTarget(self, action: #selector(commentsButtonPresed(sender:)), for: .touchUpInside)
        cell?.shareButton.addTarget(self, action: #selector(shareButtonPresed(sender:)), for: .touchUpInside)
        
     return cell
       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
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
        
        let cell = tableQuestionsView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! QuestionTableViewCell
        let total = self.questionsModel[sender.tag].optionSelected1 + self.questionsModel[sender.tag].optionSelected2 + self.questionsModel[sender.tag].optionSelected3 + self.questionsModel[sender.tag].optionSelected4
        let value = Double(self.questionsModel[sender.tag].optionSelected1) / Double(total) * 100
        let roundedString = String(format: "%.2f", value)
        cell.lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
        cell.lblThankyou.isHidden = false
        cell.lblThankyou.zoomIn()
        tableQuestionsView.reloadData()
    }
    @objc func option2ButtonPresed(sender: UIButton) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(self.questionsModel[sender.tag].id)
        addReference.child("optionSelected").setValue("option2")
        addReference.child("question").setValue(self.questionsModel[sender.tag].title)
        addReference.child("option1").setValue(self.questionsModel[sender.tag].option1)
        addReference.child("option2").setValue(self.questionsModel[sender.tag].option2)
        addReference.child("option3").setValue(self.questionsModel[sender.tag].option3)
        addReference.child("option4").setValue(self.questionsModel[sender.tag].option4)
        
        
        let cell = tableQuestionsView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! QuestionTableViewCell
        let total = self.questionsModel[sender.tag].optionSelected1 + self.questionsModel[sender.tag].optionSelected2 + self.questionsModel[sender.tag].optionSelected3 + self.questionsModel[sender.tag].optionSelected2
        let value = Double(self.questionsModel[sender.tag].optionSelected1) / Double(total) * 100
        let roundedString = String(format: "%.2f", value)
        cell.lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
        cell.lblThankyou.isHidden = false
        cell.lblThankyou.zoomIn()
        tableQuestionsView.reloadData()
    }
    @objc func option3ButtonPresed(sender: UIButton) {
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(self.questionsModel[sender.tag].id)
        addReference.child("optionSelected").setValue("option3")
        addReference.child("question").setValue(self.questionsModel[sender.tag].title)
        addReference.child("option1").setValue(self.questionsModel[sender.tag].option1)
        addReference.child("option2").setValue(self.questionsModel[sender.tag].option2)
        addReference.child("option3").setValue(self.questionsModel[sender.tag].option3)
        addReference.child("option4").setValue(self.questionsModel[sender.tag].option4)
        
        let cell = tableQuestionsView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! QuestionTableViewCell
        let total = self.questionsModel[sender.tag].optionSelected1 + self.questionsModel[sender.tag].optionSelected2 + self.questionsModel[sender.tag].optionSelected3 + self.questionsModel[sender.tag].optionSelected3
        let value = Double(self.questionsModel[sender.tag].optionSelected1) / Double(total) * 100
        let roundedString = String(format: "%.2f", value)
        cell.lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
        cell.lblThankyou.isHidden = false
        cell.lblThankyou.zoomIn()
        tableQuestionsView.reloadData()
        
    }
    @objc func option4ButtonPresed(sender: UIButton) {
        
        
        let addReference = Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").child("QuestionsAnswered").child(self.questionsModel[sender.tag].id)
        addReference.child("optionSelected").setValue("option4")
        addReference.child("question").setValue(self.questionsModel[sender.tag].title)
        addReference.child("option1").setValue(self.questionsModel[sender.tag].option1)
        addReference.child("option2").setValue(self.questionsModel[sender.tag].option2)
        addReference.child("option3").setValue(self.questionsModel[sender.tag].option3)
        addReference.child("option4").setValue(self.questionsModel[sender.tag].option4)
        
        let cell = tableQuestionsView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! QuestionTableViewCell
        let total = self.questionsModel[sender.tag].optionSelected1 + self.questionsModel[sender.tag].optionSelected2 + self.questionsModel[sender.tag].optionSelected3 + self.questionsModel[sender.tag].optionSelected4
        let value = Double(self.questionsModel[sender.tag].optionSelected1) / Double(total) * 100
        let roundedString = String(format: "%.2f", value)
        cell.lblThankyou.text = "Thank you for your reponse, \(roundedString)% chose this option"
        cell.lblThankyou.isHidden = false
        cell.lblThankyou.zoomIn()
        tableQuestionsView.reloadData()
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
        tableQuestionsView.reloadData()
    }
    @objc func commentsButtonPresed(sender: UIButton) {
        let viewController = DetailQuestionViewController(nibName: String(describing: DetailQuestionViewController.self), bundle: nil)
        viewController.userQuestionsAnsweredSelected = self.userQuestionsAnsweredModel[sender.tag]
        viewController.questionSelected = self.questionsModel[sender.tag]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setupView(){
        contentView.layer.cornerRadius = 24
        contentView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        
        settingDropDown.optionArray = ["Setting", "Logout"]
        settingDropDown.arrowColor = self.hexStringToUIColor(hex: "#7E3BF2")
        //spokenGenderTextField.rowBackgroundColor = UIColor.white
        settingDropDown.didSelect{(selectedText , index ,id) in
            if index == 0{
                let viewController = SettingViewController(nibName: String(describing: SettingViewController.self), bundle: nil)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else{
                
            }
        }
        
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
}
