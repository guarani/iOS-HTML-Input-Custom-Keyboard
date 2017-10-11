//
//  ViewController.swift
//  WebKeyboard
//
//  Created by Paul Von Schrottky on 9/25/17.
//  Copyright © 2017 Meta. All rights reserved.
//

import UIKit
import WebKit


class Input: UIView, UIKeyInput {
    var text: String?
    
    var readInputView: UIView?
    
    override var inputView: UIView? {
        get {
            return readInputView
        }
        set {
            readInputView = newValue
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var hasText: Bool {
        return (text ?? "").isEmpty == false
    }

    func insertText(_ text: String) {
        if let txt = self.text {
            self.text = txt.appending(text)
        } else {
            self.text = text
        }
        
    }

    func deleteBackward() {
        if let text = text, text.isEmpty == false {
            self.text = String(text.prefix(upTo: text.index(before: text.endIndex)))
        }
    }
}



class ViewController: UIViewController {

    var input: Input!
    var webView: WKWebView!
    var activeId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let keyboardView = UINib(nibName: "KeyboardView", bundle: nil).instantiate(withOwner: nil, options: nil).first! as! KeyboardView
        keyboardView.frame = CGRect(x: 0, y: 0, width: 37, height: 216)
        keyboardView.callback = { text in
            if let id = self.activeId {
                self.input.insertText(text ?? "")
                let val = self.input.text ?? ""
                self.webView.evaluateJavaScript("document.getElementById('\(id)').value='" + val + "'", completionHandler: nil)
            }
        }
        keyboardView.clear = {
            if let id = self.activeId {
                self.input.deleteBackward()
                let val = self.input.text ?? ""
                self.webView.evaluateJavaScript("document.getElementById('\(id)').value='" + val + "'", completionHandler: nil)
            }
        }
        
        input = Input()
        input.inputView = keyboardView
        input.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(input)
        view.topAnchor.constraint(equalTo: input.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: input.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: input.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: input.rightAnchor).isActive = true
        input.backgroundColor = UIColor.green
        
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        view.topAnchor.constraint(equalTo: webView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: webView.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: webView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: webView.rightAnchor).isActive = true


        webView.load(URLRequest(url: URL(string: "https://news.ycombinator.com/login")!))
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let str = try! String(contentsOfFile: Bundle.main.path(forResource: "inject", ofType: "js")!)
        webView.evaluateJavaScript(str, completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.scheme == "myapp" {
            
            // Reset keyboard and put web view back to how it was.
            if let id = activeId {
                self.webView.evaluateJavaScript("document.getElementById('\(id)').id=null", completionHandler: nil)
                self.input.text = nil
            }
            
            if let dict = navigationAction.request.url?.queryItemsDictionary {
                if let id = dict["id"] {
                    activeId = id
                    input.becomeFirstResponder()
                    
                    if let val = dict["val"] {
                        input.text = val
                    }
                } else {
                    activeId = nil
                }
            }
        }
        print(webView.url?.absoluteString)
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

    }
}


extension URL {
    
    var queryItemsDictionary: [String: String] {
        var queryItemsDictionary = [String: String]()
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else { return queryItemsDictionary }
        queryItems.forEach { queryItemsDictionary[$0.name] = $0.value }
        return queryItemsDictionary
    }
    
}
