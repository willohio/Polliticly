//
//  UserQuestionsAnsweredModel.swift
//  Polliticly
//
//  Created by William Santiago  on 07/06/2020.
//  Copyright © 2020 William Santiago. All rights reserved.
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
