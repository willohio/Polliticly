//
//  CommentsLabel.swift
//  Polliticly
//
//  Created by William Santiago  on 07/06/2020.
//  Copyright © 2020 William Santiago. All rights reserved.
//

import Foundation
class CommentsModel {
    var name: String!
    var comment: String!
    var timeStamp: Double!
    init(name: String, comment: String, timeStamp: Double) {
        self.name = name
        self.comment = comment
        self.timeStamp = timeStamp
    }
}
