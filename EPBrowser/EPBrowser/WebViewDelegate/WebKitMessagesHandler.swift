//
//  WebKitMessagesHandler.swift
//  EPBrowser
//
//  Created by Nebula_MAC on 05/01/2019.
//  Copyright © 2019 park.elon. All rights reserved.
//

import UIKit
import WebKit

extension WebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let webKitMessage = WebKitMessages(rawValue: message.name) else { return }
        
        switch webKitMessage {
        case .documentReady:
            progressBar.isHidden = true
        }
    }
}
