//
//  HCAliyunOss.swift
//  HCHollySDK
//
//  Created by holly_linlc on 2018/4/4.
//  Copyright © 2018年 xmsdk. All rights reserved.
//

import UIKit
import AliyunOSSiOS

let AccessKeyId = "FdVWP06c3sXkztIK"
let AccessKeySecret = "xbtDJWp1INSjJGXd35W9UZB6Scmgtl"
let BucketName = "loganv"
//let OSS_STSTOKEN_URL = "http://30.40.38.17:3015/sts/getsts"
//let SecurityToken = ""
let endpoint = "https://oss-cn-qingdao.aliyuncs.com"
let downloadPrefix = "https://loganv.oss-cn-qingdao.aliyuncs.com/"

//let uploadAudioUrl = "http://test01.hollycrm.com:8016/open_platform/uploadVoiceFile"
let uploadAudioUrl = "http://im.7x24cc.com/open_platform/uploadVoiceFile"

public class HCAliyunOss: NSObject {
    
    var beginTime: TimeInterval = 0
    
    static let share = { () -> HCAliyunOss in
        let ins = HCAliyunOss()
        return ins
    }()
    
    var client: OSSClient!
    
    private override init() {
        super.init()
        
        self.beginTime = self.beginTime - 7*24*60*60
        
        //        let cred = OSSStsTokenCredentialProvider(accessKeyId: AccessKeyId, secretKeyId: AccessKeySecret, securityToken: SecurityToken)
        
        let pro = OSSCustomSignerCredentialProvider { (contentToSign, err) -> String? in
            //            print(err ?? "err or")
            //            print(contentToSign)
            //            let signature = OSSUtil.calBase64Sha1(withData: contentToSign, withSecret: AccessKeySecret)
            //            return signature
            let tToken = OSSFederationToken()
            tToken.tAccessKey = AccessKeyId
            tToken.tSecretKey = AccessKeySecret
            
            return OSSUtil.sign(contentToSign, with: tToken)
        }
        //        print(pro)
        
        let c = OSSClient(endpoint: endpoint, credentialProvider: pro!)
        client = c
    }
    
    func putFile(fileName: String, fileData: Data, done: @escaping ((_ iss: Bool, _ url: String)->Void)){
        let downUrl = downloadPrefix + fileName
        let put = OSSPutObjectRequest()
        put.bucketName = BucketName
        put.objectKey = fileName
        put.uploadingData = fileData
        put.uploadProgress = { (sent: Int64, totleSent: Int64, expectedSent: Int64) -> Void in
            print(sent, totleSent, expectedSent)
        }
        let putTask = client.putObject(put)
        
        putTask.continue ({ (ossTask: OSSTask) -> Any? in
            if ossTask.error != nil {
                print("upload failed")
                print(ossTask.error)
                done(false, "")
            }
            else{
                print("upload success")
                done(true, downUrl)
            }
            return nil
        })
        
    }
    
    func uploadC5File(fileData: Data, done: @escaping ((_ iss: Bool, _ resu: String)->Void)){
        let body = fileData
        let url = URL(string: uploadAudioUrl)!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = body
        let task = URLSession.shared.dataTask(with: req) { (obj, resp, err) in
            if err != nil || obj == nil{
                print(err)
                done(false, "")
                return
            }
//            print(err)
//            print(obj)
//            print(resp)
            let dStr = String(data: obj!, encoding: String.Encoding.utf8)
//            print(dStr)
//            if let dc = try? JSONSerialization.jsonObject(with: obj!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : Any]{
                done(true, dStr!)
//            }
//            else{
//                done(false, ["VoiceTimelength":"0","VoiceUrl":"结果转化异常"])
//            }
            
        }
        task.resume()
    }
}
