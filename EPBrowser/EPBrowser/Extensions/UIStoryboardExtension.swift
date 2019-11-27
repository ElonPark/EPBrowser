//
//  UIStoryboardExtension.swift
//  EPBrowser
//
//  Created by Elon on 2019/11/27.
//  Copyright © 2019 park.elon. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiate<T: UIViewController>(by storyboardName: UIStoryboard.Storyboard) -> T? {
          let type = String(describing: T.Type.self)
          guard let identifier = type.components(separatedBy: ".").first else { return nil }
          
          let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
          let vc = storyboard.instantiateViewController(withIdentifier: identifier)
          
          return vc as? T
      }
}

extension UIStoryboard {
    enum Storyboard: String {
        case main = "Main"
    }
    
    static func webViewVC() -> WebViewController? {
        return UIStoryboard.instantiate(by: .main)
    }
}
