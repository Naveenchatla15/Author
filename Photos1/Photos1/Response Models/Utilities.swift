//
//  Utilities.swift
//  Photos1
//
//  Created by Mac on 05/05/23.
//

import Foundation
import UIKit


let phtosAPI = "https://picsum.photos/v2/list?page=pageNo&limit=20"


extension UIViewController
{
    func showToast(message:String)
    {
        let toastLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.height - 125, width: self.view.frame.width - 50, height: 35))
        toastLabel.backgroundColor = UIColor(named: "primary")
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 13.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 18
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            UIView.animate(withDuration: 2.0, delay: 0.2, options: .curveEaseOut, animations:
                            {
                toastLabel.alpha = 0.0
                
            }) { (isCompleted) in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

@IBDesignable extension UIView {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
