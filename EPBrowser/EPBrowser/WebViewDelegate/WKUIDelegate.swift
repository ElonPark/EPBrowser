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
        defer {
            let urlString = navigationAction.request.url?.absoluteString ?? ""
            Log.verbose(urlString)
        }
        
        guard !openOtherApp(by: navigationAction.request.url) else { return nil }
        guard let popupVC = createPopUpVC(config: configuration) else {
            webView.load(navigationAction.request)
            return nil
        }
        
        self.popupVC = popupVC
        navigationController?.pushViewController(popupVC, animated: true)
        
        return popupVC.webView
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        popupVC?.progressObserveToken?.invalidate()
        
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
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        alertPanel(
            with: message,
            title: webView.url?.host,
            completionHandler: completionHandler
        )
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        alertConfirmPanel(
            with: message,
            title: webView.url?.host,
            completionHandler: completionHandler
        )
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        alertTextInputPanel(
            withPrompt: prompt,
            defaultText: defaultText,
            completionHandler: completionHandler
        )
    }
    
}
