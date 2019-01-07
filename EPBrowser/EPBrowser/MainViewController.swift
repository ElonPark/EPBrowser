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
 
    func setTitle(_ title: String) {
        navigationItem.title = title
    }
    
    ///웹뷰 초기화
    func initWebView() -> WKWebView {
        guard self.webView == nil else { return self.webView! }
        
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
        
        let webView = WKWebView(frame: CGRect.zero,
                            configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        webView.addObserver(self, forKeyPath: progressObserverKey,
                            options: .new, context: nil)
        
        return webView
    }
    
    func loadRequest(to urlString: String) {
        guard urlString.hasPrefix("http") else { return }
        guard let url = URL(string: urlString) else { return }
        
        webView?.load(URLRequest(url: url))
    }
    
    func goBack() {
        guard let webView = self.webView, webView.canGoBack else { return }
        webView.goBack()
    }
    
    func goForward() {
        guard let webView = self.webView, webView.canGoForward else { return }
        webView.goForward()
    }
    
    func reload() {
        webView?.reload()
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
    
    /**
     ## 팝업 웹뷰 생성
     
     - Parameter config: 생성될 웹뷰의 WKWebViewConfiguration
     
     - Returns: 새롭게 생성 된 웹뷰
     */
    ///새창 생성
    func createPopUpVC(config: WKWebViewConfiguration) -> MainViewController? {
        guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else { return nil }
        
        popupVC.webView = WKWebView(frame: CGRect.zero, configuration: config)
        popupVC.webView?.navigationDelegate = popupVC
        popupVC.webView?.uiDelegate = popupVC
    
        popupVC.webView?.allowsBackForwardNavigationGestures = true
        popupVC.webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        popupVC.webView?.addObserver(self, forKeyPath: progressObserverKey,
                            options: .new, context: nil)
        
        return popupVC
    }
    
    @objc func closeWebView() {
        navigationController?.popViewController(animated: true)
    }
}

class MainViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    ///웹뷰
    var webView: WKWebView?
    
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
    
    deinit {
        if viewIfLoaded != nil {
            webView?.removeObserver(self, forKeyPath: progressObserverKey)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if webView == nil {
            webView = initWebView()
            loadRequest(to: "http://clien.net")
        }
        
        if let webView = self.webView {
            mainView.insertSubview(webView, belowSubview: progressBar)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView?.frame = mainView.bounds
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //프로그레스 로딩 애니메이션
        guard let key = keyPath, key == progressObserverKey else { return }
        
        guard let webView = self.webView else { return }
        progressBar.isHidden = webView.estimatedProgress == 1
        
        let progress = Float(webView.estimatedProgress)
        if progressBar.progress < progress {
            progressBar.setProgress(progress, animated: true)
        }
    }
}

