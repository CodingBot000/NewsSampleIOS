//
//  WebViewScreen.swift
//  News
//
//  Created by switchMac on 7/21/24.
//

import SwiftUI

struct WebViewScreen: UIViewControllerRepresentable {
    let url: URL
    let title: String
    
    func makeUIViewController(context: Context) -> WebViewController {
        let webViewController = WebViewController()
        webViewController.url = url
        webViewController.titleText = title
        return webViewController
    }
    
    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {

    }
}

