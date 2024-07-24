//
//  WebViewController.swift
//  News
//
//  Created by switchMac on 7/21/24.
//


import WebKit
import SwiftUI

class WebViewController: UIViewController {
    var url: URL!
    var titleText: String!
    
    private var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = titleText
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
