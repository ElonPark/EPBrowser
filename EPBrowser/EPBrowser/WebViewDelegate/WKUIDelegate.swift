//
//  WKUIDelegate.swift
//  EPBrowser
//
//  Created by Nebula_MAC on 05/01/2019.
//  Copyright © 2019 park.elon. All rights reserved.
//

import UIKit
import WebKit

extension WebViewController: WKUIDelegate {

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        let url = navigationAction.request.url?.absoluteString ?? ""
        logger.verbose(url)
        
        if openOtherApp(by: navigationAction.request.url) {
            return nil
        }
       
        if let popupVC = createPopUpVC(config: configuration) {
            self.popupVC = popupVC
            navigationController?.pushViewController(popupVC, animated: true)
            
        } else {
            webView.load(navigationAction.request)
        }
        
        return popupVC?.webView
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if let popup = popupVC {
            popup.webView?.removeObserver(popup, forKeyPath: progressObserverKey)
        }
        
        navigationController?.popViewController(animated: true)
    }

    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        
        return true
    }
    
    func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
        
    }
    
    func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
    }
    
}
