//
//  HCHollyWebView.swift
//  sdk
//
//  Created by holly_linlc on 2018/4/3.
//  Copyright © 2018年 xmsdk. All rights reserved.
//
/*
 修改 HCAliyunOss.swift 配置信息
 修改 initializtion 方法的 urlPath
*/

import UIKit
import WebKit

public typealias CallBackHy = (Bool, String)->Void

@objc public class HCHollyWebView: NSObject {
    @objc public static var showlog = true {
        didSet{
            HCHollyRecord.showLog = showlog
        }
    }
    
    // chatid: 5ef88f25-8130-4ad3-92b0-3470bca0c46e, account: N000000009304 ,{}
    @objc public class func initializtion(account: String, chatId: String, param: [String: Any], cb: @escaping CallBackHy){
        var pars = ""
//        if let tt = try? JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.prettyPrinted){
//            if let aa = NSString(data: tt, encoding: String.Encoding.utf8.rawValue){
//                let aaa = aa.replacingOccurrences(of: "\n", with: "")
//                pars = aaa
//            }
//        }
        for (k,v) in param {
            pars = pars + "\(k)=\(v)&"
        }
//        let urlPath = "http://123.56.20.159:3000/commonInte?md5=81f0e1f0-32df-11e3-a2e6-1d21429e5f46&flag=401&accountId=\(account)&chatId=\(chatId)"
        let urlPath = "http://a1.7x24cc.com/commonInte?md5=81f0e1f0-32df-11e3-a2e6-1d21429e5f46&flag=401&accountId=\(account)&chatId=\(chatId)"
        
        let url = URL(string: urlPath)!
        let task1 = URLSession.shared.dataTask(with: url) { (data, resp, err) in
            if err != nil {
                print("初始化失败，请检查网络，或重新初始化")
                cb(false, "初始化失败，请检查网络，或重新初始化")
            }
            else{
//                let str = String(data: data!, encoding: String.Encoding.utf8)
                if let resu = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]{
//                    print(resu)
                    if let succ = resu!["success"] as? Int, succ == 1 {
                        if let url = resu!["interface"] as? String {
                            if url.contains("?"){
                                HCHollyWebView.c6Url = url + "&" + pars
                            }
                            else{
                                HCHollyWebView.c6Url = url + "?" + pars
                            }
                        }
                    }
                }
//                print("初始化成功-commonInte")
                cb(true, "初始化成功")
            }
//            print(data)
//            print(resp)
        }
        task1.resume()
    }
    
//    "http://llcv.pw/hollycrm/sdk.html"
    static var c6Url = ""
    
    var webview: WKWebView!
    var progress = UIProgressView()

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            if let prog = change?[NSKeyValueChangeKey.newKey] as? Float {
                if prog >= 1 {
                    progress.isHidden = true
                }
                else{
                    progress.isHidden = false
                }
                progress.setProgress(prog, animated: true)
            }
        }
    }
    
    deinit {
        if #available(iOS 11.0, *) {
            self.webview.removeObserver(self, forKeyPath: "estimatedProgress")
        } else {
            
        }
        
        print(self.classForCoder, "--->", #line, #function)
    }
    
    
    @objc public func getC6WebView(frame: CGRect) -> WKWebView{
        let conf = WKWebViewConfiguration()
        webview = WKWebView(frame: frame, configuration: conf)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        addHandler()
        
        self.progress.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 20)
        //        self.progress.tintColor = UIColor(red: 0.05, green: 0.5, blue: 0.96, alpha: 1.0)
        self.progress.progressTintColor = UIColor.green
        self.webview.addSubview(progress)
        
        if #available(iOS 11.0, *) {
            self.webview.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        } else {
            
        }
        
        
//        print(HCHollyWebView.c6Url)
        self.loadUrl(HCHollyWebView.c6Url)

        return webview
    }
    public func addHandler(){
        webview.configuration.userContentController.add(self, name: "recordStart")
        webview.configuration.userContentController.add(self, name: "recordStop")
        webview.configuration.userContentController.add(self, name: "recordCancel")
        webview.configuration.userContentController.add(self, name: "getLocation")
    }
    @objc public func removeHandler(){
        
        webview.configuration.userContentController.removeScriptMessageHandler(forName: "recordStart")
        webview.configuration.userContentController.removeScriptMessageHandler(forName: "recordStop")
        webview.configuration.userContentController.removeScriptMessageHandler(forName: "recordCancel")
        webview.configuration.userContentController.removeScriptMessageHandler(forName: "getLocation")
    }
    func loadUrl(_ sss: String){
        let url = URL(string: sss)
        if url != nil {
//            let request = NSMutableURLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
//            let cookies = HTTPCookieStorage.shared.cookies(for: url!)
//            if cookies != nil {
//                let dicCookies = HTTPCookie.requestHeaderFields(with: cookies!)
//                let strCookies = dicCookies["Cookie"]
//                request.setValue(strCookies, forHTTPHeaderField: "Cookie")
//            }
            
            webview.load(URLRequest(url: url!))
            
            initRecord()
        }
    }
    
    func initRecord(){
        weak var wself = self
        HCHollyRecord.manager.onStart {
//            print("on start")
            let jstr = "hollyRecordStart()"
            wself?.webview.evaluateJavaScript(jstr, completionHandler: { (obj, err) in
                
            })
        }
        
        HCHollyRecord.manager.onCancel {
            print("holly record on cancel")
            let jstr = "hollyRecordCancel()"
            wself?.webview.evaluateJavaScript(jstr, completionHandler: { (obj, err) in
                
            })
        }
        HCHollyRecord.manager.onFailed { resu in
//            print("on failed")
            let jstr = "hollyRecordFailed('\(resu)')"
            wself?.webview.evaluateJavaScript(jstr, completionHandler: { (obj, err) in
                
            })
        }
        
        HCHollyRecord.manager.onStop {
//            print("on stop")
            let jstr = "hollyRecordStop()"
            wself?.webview.evaluateJavaScript(jstr, completionHandler: { (obj, err) in
                
            })
        }
        
        HCHollyRecord.manager.onUpload { (iss, downUrl) in
//            print("on upload")
            var jstr = "hollyRecordUpload('\(downUrl)')"
            if !iss {
                jstr = "hollyRecordFailed()"
            }
            wself?.webview.evaluateJavaScript(jstr, completionHandler: { (obj, err) in
                
            })
        }
    }
}


extension HCHollyWebView: WKScriptMessageHandler{
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "recordStart":
            HCHollyRecord.manager.start()
            
        case "recordStop":
            HCHollyRecord.manager.stop()
            
        case "recordCancel":
            HCHollyRecord.manager.cancel()
            
            
        case "getLocation":
            weak var wself = self

            let loc = HCHollyLocation.share
            loc.getLocation(back: { (loc) in
                if loc == nil {return}
                let jstr = "hollyGetLocation('\(loc!.coordinate.latitude)','\(loc!.coordinate.longitude)')"
                wself?.webview.evaluateJavaScript(jstr, completionHandler: { (obj, err) in
//                    print(obj)
//                    print(err)
                })
            }, failed: { err in
                let jstr = "hollyGetLocationFailed('\(err.localizedDescription)')"
                wself?.webview.evaluateJavaScript(jstr, completionHandler: { (obj, err) in
//                    print(obj)
//                    print(err)
                })
            })
        default:
            print("没有匹配到")
        }
    }
    
    
}

extension HCHollyWebView: WKUIDelegate, WKNavigationDelegate{
    
}

