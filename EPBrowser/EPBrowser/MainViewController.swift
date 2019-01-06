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
    
    func loadRequest(to urlString: String) {
        guard urlString.hasPrefix("http") else { return }
        guard let url = URL(string: urlString) else { return }
        
        webView.load(URLRequest(url: url))
    }
    
    func goBack() {
        guard webView.canGoBack else { return }
        webView.goBack()
    }
    
    func goForward() {
        guard webView.canGoForward else { return }
        webView.goForward()
    }
    
    func reload() {
        webView.reload()
    }
    
}

class MainViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    
    lazy var webView = WKWebView()
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        goBack()
    }
    
    @IBAction func goForward(_ sender: UIBarButtonItem) {
        goForward()
    }
    
    @IBAction func reload(_ sender: UIBarButtonItem) {
        reload()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initWebView()
        mainView.addSubview(webView)
        
        loadRequest(to: "https://m.naver.com")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView.frame = mainView.bounds
    }
}

