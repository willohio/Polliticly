//
//  CommentsCell.swift
//  Polliticly
//
//  Created by Apple on 14/06/2020.
//  Copyright © 2020 Future Vision Tech. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
