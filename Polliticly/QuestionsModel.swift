//
//  QuestionsModel.swift
//  Polliticly
//
//  Created by Future Vision Tech  on 07/06/2020.
//  Copyright © 2020 Future Vision Tech. All rights reserved.
//

import Foundation
class QuestionsModel {
    var id: String!
    var title: String!
    var option1: String!
    var option2: String!
    var option3: String!
    var option4: String!
    var likes: Int!
    var comments: Int!
    var optionSelected1 = 0
    var optionSelected2 = 0
    var optionSelected3 = 0
    var optionSelected4 = 0
    init(id: String, title: String, option1: String, option2: String, option3: String, option4: String, likes: Int, comments: Int) {
        self.id = id
        self.title = title
        self.option1 = option1
        self.option2 = option2
        self.option3 = option3
        self.option4 = option4
        self.likes = likes
        self.comments = comments
    }
}
