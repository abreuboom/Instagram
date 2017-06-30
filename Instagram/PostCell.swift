//
//  PostCell.swift
//  Instagram
//
//  Created by John Abreu on 6/27/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var likes: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
