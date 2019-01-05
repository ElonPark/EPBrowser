//
//  MainViewController.swift
//  EPBrowser
//
//  Created by Nebula_MAC on 05/01/2019.
//  Copyright © 2019 park.elon. All rights reserved.
//

import UIKit
import WebKit

extension MainViewController {
 
    ///웹뷰 초기화
    func initWebView() {
        let contentController = WKUserContentController()
        
        for message in WebKitMessages.allCases {
            contentController.add(self, name: message.rawValue)
        }
        
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = .all
        configuration.userContentController = contentController
        
        let preferences = configuration.preferences
        preferences.minimumFontSize = 5
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        webView = WKWebView(frame: CGRect.zero,
                            configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

class MainViewController: UIViewController {

    lazy var webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

