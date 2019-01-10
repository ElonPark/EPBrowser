//
//  WebViewScrollViewDelegate.swift
//  EPBrowser
//
//  Created by Nebula_MAC on 10/01/2019.
//  Copyright © 2019 park.elon. All rights reserved.
//

import UIKit

extension WebViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView){
        let hide = scrollView.contentOffset.y > lastOffsetY
        navigationController?.setNavigationBarHidden(hide, animated: true)
        
        if hide {
            hideToolBarView()
        } else {
            showToolBarView()
        }
    }
}
