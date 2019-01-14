//
//  WebViewController.swift
//  EPBrowser
//
//  Created by Nebula_MAC on 05/01/2019.
//  Copyright © 2019 park.elon. All rights reserved.
//

import UIKit
import WebKit


extension WebViewController {
 
    ///제목 설정
    func setTitle(_ title: String) {
        navigationItem.title = title
    }
    
    ///툴바 보기
    func showToolBarView() {
        guard toolbar.isHidden else { return }
        toolbar.isHidden = false
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: { [unowned self] in
                        self.toolbarConstraintsHeight.constant = self.toolBarHeight
                        self.view.layoutIfNeeded()
        })
    }
    
    ///툴바 숨김
    func hideToolBarView() {
        guard !toolbar.isHidden else { return }
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: { [unowned self] in
                        self.toolbarConstraintsHeight.constant = 0
                        self.view.layoutIfNeeded()
                        
            }, completion: { [unowned self] (_) -> Void in
                self.toolbar.isHidden = true
        })
    }
    
    ///웹뷰 사용자 콘텐츠 설정
    func webViewUserContent() -> WKUserContentController {
        let contentController = WKUserContentController()
        
        ///웹에서 받을 메시지 설정
        for message in WebKitMessages.allCases {
            contentController.add(self, name: message.rawValue)
        }
        
        ///도큐멘트가 준비되면 메시지 전송
        let documentReadyJS = "webkit.messageHandlers.documentReady.postMessage(true)"
        let documentReadyScript = WKUserScript(source: documentReadyJS, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(documentReadyScript)
        
        return contentController
    }
    
    ///웹뷰 설정
    func webViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = .all
        configuration.userContentController = webViewUserContent()
        
        let preferences = configuration.preferences
        preferences.minimumFontSize = 5
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        return configuration
    }
    
    ///프로그레스 업데이트
    func updateProgress(to progressBar: UIProgressView, by value: Double) {
        let progress = Float(value)
        progressBar.isHidden = progress == 1
        
        guard progressBar.progress < progress else { return }
        progressBar.setProgress(progress, animated: true)
    }
    
    ///웹뷰 프로그레스 옵저버
    func setProgressObserver() {
        progressObserveToken = webView?.observe(\.estimatedProgress, options: .new) { [weak self] (_, estimatedProgress) in
            guard let newValue = estimatedProgress.newValue else { return }
            guard let progressBar = self?.progressBar else { return }
            
            self?.updateProgress(to: progressBar, by: newValue)
        }
    }
    
    ///웹뷰 초기화
    func initWebView() -> WKWebView {
        guard self.webView == nil else { return self.webView! }
   
        ///웹뷰 설정
        let webView = WKWebView(frame: CGRect.zero,
                            configuration: webViewConfiguration())
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.delegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return webView
    }
    
    ///웹페이지 이동 요청
    func loadRequest(to urlString: String) {
        logger.info(urlString)
        
        guard urlString.hasPrefix("http") else { return }
        guard let url = URL(string: urlString) else { return }
        
        webView?.load(URLRequest(url: url))
    }
    
    ///뒤로가기
    func goBack() {
        guard let webView = self.webView, webView.canGoBack else { return }
        webView.goBack()
    }
    
    ///앞으로가기
    func goForward() {
        guard let webView = self.webView, webView.canGoForward else { return }
        webView.goForward()
    }
    
    ///새로고침
    func reload() {
        webView?.reload()
    }
    
    ///자바스크립트 Alert
    func alertPanel(with message: String, title: String?, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인",
                                     style: .default) { _ in
            completionHandler()
        }
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    ///자바스크립트 확인 Alert
    func alertConfirmPanel(with message: String, title: String?, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인",
                                     style: .default) { _ in
            completionHandler(true)
        }
        
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel) { _ in
            completionHandler(false)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    ///자바스크립트 입력 Alert
    func alertTextInputPanel(withPrompt prompt: String, defaultText: String?, completionHandler: @escaping (String?) -> Void) {
        
        let alert = UIAlertController(title: prompt,
                                      message: prompt,
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = defaultText
        }
        
        let okAction = UIAlertAction(title: "확인",
                                     style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        }
        
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel) { _ in
            completionHandler(nil)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    /**
     URL scheme이 다른 앱인 경우 해당 URL을 앱 외부로 요청한다.
     
     - parameter requestURL: 요청한 URL
     - returns : 다른 앱을 요청한 경우 true
    */
    func openOtherApp(by requestURL: URL?) -> Bool {
        guard let url = requestURL else { return false }
        guard let host = url.host else { return false }
        guard let scheme = url.scheme else { return false }
        guard url.scheme != Config.schmes else { return false }
        
        if host.contains("itunse.apple.com") {
            UIApplication.shared.open(url)
            return true
            
        } else if scheme != "http" && scheme != "https" {
            UIApplication.shared.open(url)
            return true
        }
        
        return false
    }
    
    ///새창 닫기
    @objc func closePopup() {
        let windowCloseJS = "javascript:window.close();"
        popupVC?.webView?.evaluateJavaScript(windowCloseJS)
    }
    
    ///새창 닫기 버튼
    func navigationBackButton() -> UIBarButtonItem {
        let closeButton = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(closePopup))
        
        return closeButton
    }
    
    /**
     ## 팝업 웹뷰 생성
     
     - Parameter config: 생성될 웹뷰의 WKWebViewConfiguration
     
     - Returns: 새롭게 생성 된 웹뷰
     */
    func createPopUpVC(config: WKWebViewConfiguration) -> WebViewController? {
        guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController else { return nil }
        
        popupVC.webView = WKWebView(frame: CGRect.zero, configuration: config)
        popupVC.webView?.navigationDelegate = popupVC
        popupVC.webView?.uiDelegate = popupVC
        popupVC.webView?.scrollView.delegate = popupVC
    
        popupVC.webView?.allowsBackForwardNavigationGestures = true
        popupVC.webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        popupVC.navigationItem.leftBarButtonItem = navigationBackButton()

        return popupVC
    }
}

class WebViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var toolbarConstraintsHeight: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    ///웹뷰
    var webView: WKWebView?
    
    ///프로그레스 옵저버 토큰
    var progressObserveToken: NSKeyValueObservation? = nil
    
    ///툴바 높이
    var toolBarHeight: CGFloat = 44
    
    ///마지막 웹뷰 스크롤 위치
    var lastOffsetY: CGFloat = 0
    
    ///새창
    var popupVC: WebViewController?
    
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        goBack()
    }
    
    @IBAction func goForward(_ sender: UIBarButtonItem) {
        goForward()
    }
    
    @IBAction func reload(_ sender: UIBarButtonItem) {
        reload()
    }
    
    
    // - MARK: View lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if webView == nil {
            webView = initWebView()
            loadRequest(to: "http://www.naver.com")
        }
        
        if let webView = self.webView {
            ///프로그레스 옵버저
            setProgressObserver()
            mainView.insertSubview(webView, belowSubview: progressBar)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView?.frame = mainView.bounds
    }
}
