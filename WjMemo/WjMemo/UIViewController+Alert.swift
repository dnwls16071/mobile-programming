//
//  UIViewController+Alert.swift
//  WjMemo
//
//  Created by 203a21 on 2022/06/09.
//

import UIKit

extension UIViewController  {
    func alert(title: String = "알림", message: String)   {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인합니다.", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
