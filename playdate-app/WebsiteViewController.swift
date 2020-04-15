//
//  WebsiteViewController.swift
//  playdate-app
//
//  Created by Serena  Zamarripa on 4/14/20.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import WebKit

class WebsiteViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    var ticketsUrl: String!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: ticketsUrl)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
    }
}
