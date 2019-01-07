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
        
        webView.addObserver(self, forKeyPath: progressObserverKey,
                            options: .new, context: nil)
        
        mainView.insertSubview(webView, belowSubview: progressBar)
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
    
    /**
     URL scheme이 다른 앱인 경우 해당 URL을 앱 외부로 요청한다.
     
     - parameter requestURL: 요청한 URL
     - returns : 다른 앱을 요청한 경우 true
    */
    func openOtherApp(by requestURL: URL?) -> Bool {
        guard let url = requestURL else { return false }
        guard url.scheme != "http" else { return false }
        guard url.scheme != "https" else { return false }
        guard url.scheme != Config.schmes else { return false }
        
        UIApplication.shared.open(url)
        
        return true
    }
}

class MainViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    ///웹뷰
    lazy var webView = WKWebView()
    
    ///웹뷰 프로그레스 옵저버 키
    let progressObserverKey = "estimatedProgress"
    
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
        
        
        loadRequest(to: "https://m.naver.com")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView.frame = mainView.bounds
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //프로그레스 로딩 애니메이션
        guard let key = keyPath, key == progressObserverKey else { return }
        
        progressBar.isHidden = webView.estimatedProgress == 1
        
        let progress = Float(webView.estimatedProgress)
        if progressBar.progress > progress {
            progressBar.setProgress(progress, animated: true)
        }
    }
}

