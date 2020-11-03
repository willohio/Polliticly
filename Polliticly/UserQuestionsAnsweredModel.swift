//
//  UserQuestionsAnsweredModel.swift
//  Polliticly
//
//  Created by Future Vision Tech  on 07/06/2020.
//  Copyright © 2020 Future Vision Tech. All rights reserved.
//

import Foundation
class UserQuestionsAnsweredModel: NSObject {
    var id: String!
    var liked: Bool!
    var optionSelected: String!
    var question = ""
    var seleted = ""
    override init() {
        
    }
    init(id: String, liked: Bool, optionSelected: String) {
        self.id = id
        self.liked = liked
        self.optionSelected = optionSelected
    }
}
