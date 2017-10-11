//
//  KeyboardView.swift
//  WebKeyboard
//
//  Created by Paul Von Schrottky on 9/25/17.
//  Copyright © 2017 Meta. All rights reserved.
//

import UIKit

class KeyboardView: UIView {
    
    
    var callback: ((String?) -> Void)?
    var clear: (() -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.lightGray
    }
    
    @IBAction func tap(_ sender: UIButton) {
        callback?(sender.titleLabel?.text)
    }
    
    @IBAction func clear(_ sender: Any) {
        clear?()
    }
}
