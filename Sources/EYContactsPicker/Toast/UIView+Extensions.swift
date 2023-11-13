//
//  File.swift
//  
//
//  Created by Ihab yasser on 16/07/2023.
//

import Foundation
import UIKit

extension UIView {
    
    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowRadius = 5
    }
}
