//
//  WebsiteViewController.swift
//  playdate-app
//
//  Created by Serena  Zamarripa on 4/14/20.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import WebKit

class WebsiteViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    var ticketsUrl: String!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var fwdButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var safariButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backButton.isEnabled = webView.canGoBack
        fwdButton.isEnabled = webView.canGoForward
        
        let myURL = URL(string: ticketsUrl)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        backButton.isEnabled = webView.canGoBack
        fwdButton.isEnabled = webView.canGoForward
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        backButton.isEnabled = webView.canGoBack
        fwdButton.isEnabled = webView.canGoForward
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        webView.goBack()
    }
    
    @IBAction func fwdBtnPressed(_ sender: Any) {
        webView.goForward()
    }
    
    @IBAction func reloadBtnPressed(_ sender: Any) {
        webView.reload()
    }
    
    @IBAction func safariBtnPressed(_ sender: Any) {
        if let url = webView.url {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
