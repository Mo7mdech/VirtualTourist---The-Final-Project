//
//  AlertExtension.swift
//  VirtualTourist
//
//  Created by Mohammed Jarad on 13/07/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    func alert(title: String, message: String?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
