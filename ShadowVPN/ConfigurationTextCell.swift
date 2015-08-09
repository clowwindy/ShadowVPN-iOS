//
//  ConfigurationTextCell.swift
//  ShadowVPN
//
//  Created by clowwindy on 8/8/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

import UIKit

let labelWidth = CGFloat(120.0)

class ConfigurationTextCell: UITableViewCell {
    var textField: UITextField = UITextField()
    
    init() {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        self.contentView.addSubview(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let oldFrame = self.textLabel?.frame
        self.textLabel?.frame = CGRect(x: oldFrame!.origin.x, y: oldFrame!.origin.y, width: labelWidth, height: (oldFrame?.height)!)
        textField.frame = CGRect(x: oldFrame!.origin.x + labelWidth + 10,
            y: (oldFrame?.origin.y)!,
            width: self.frame.width - (oldFrame!.origin.x + labelWidth + 10),
            height: (oldFrame?.height)!)
    }
}
