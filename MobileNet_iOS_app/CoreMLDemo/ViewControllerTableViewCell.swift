//
//  ViewControllerTableViewCell.swift
//  CoreMLDemo
//
//  Created by 李奇 on 2018/10/12.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit

class ViewControllerTableViewCell: UITableViewCell {

    @IBOutlet weak var myImage: UIImageView!
    
    @IBOutlet weak var myLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
