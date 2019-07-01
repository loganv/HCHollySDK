//
//  HCHollyRecord.swift
//  sdk
//
//  Created by holly_linlc on 2018/4/3.
//  Copyright © 2018年 xmsdk. All rights reserved.
//

import UIKit
import AVFoundation

typealias CallBack = ()->Void
typealias CallBack1 = (String)->Void
typealias CallBack2 = (Bool, String)->Void

public class HCHollyRecord: NSObject {
    public static let manager = { () -> HCHollyRecord in
        let ins = HCHollyRecord()
        
        return ins
    }()
    public static var showLog = true
    
    private var doStart: CallBack?
    private var doStop: CallBack?
    private var doCancel: CallBack?
    private var doUpload: CallBack2?
    private var doFailed: CallBack1?

    var timer: Timer!
    var recoder: AVAudioRecorder?
    var recordPath = ""
    
    override init() {
        super.init()
    }
    deinit {
        print("deinit", self.classForCoder)
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    public func onStart(back: @escaping ()->Void){
        self.doStart = back
    }
    public func onStop(back: @escaping ()->Void){
        self.doStop = back
    }
    public func onCancel(back: @escaping ()->Void){
        self.doCancel = back
    }
    public func onUpload(back: @escaping (Bool, String)->Void){
        self.doUpload = back
    }
    public func onFailed(back: @escaping (String)->Void){
        self.doFailed = back
    }
    
    public func start(){
        let fstr = "获取录音权限失败"
        let session = AVAudioSession.sharedInstance()
        var hasRecordAuth = true
        weak var wself = self
        session.requestRecordPermission { (iss) in
            DispatchQueue.main.async{
                if iss == false{
                    hasRecordAuth = iss
                    print(fstr)
                    wself?.doFailed?(fstr)
                }
                else{
                    wself?.startRecord()
                }
            }
        }
        if !hasRecordAuth {
            return
        }
    }
    func startRecord(){
        let fstr = "获取录音权限失败"
        do{
            let session = AVAudioSession.sharedInstance()
            if self.recoder != nil, self.recoder!.isRecording {
                dprint("正在录音中")
                return
            }
//            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setCategory(AVAudioSession.Category.playAndRecord)
            try session.setActive(true)
            
            let set = [
                AVSampleRateKey: NSNumber(value: 8000),
                AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
                AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.high.rawValue)
            ]
            self.recordPath = self.getFilePath()
            let url = URL(string: self.recordPath)
            dprint(recordPath)
            recoder = try AVAudioRecorder(url: url!, settings: set)
            recoder?.prepareToRecord()
            //            recoder?.record()
            recoder?.record(forDuration: 120)
            doStart?()
            dprint("开始录音")
            
            if timer != nil {
                self.timer.invalidate()
                self.timer = nil
            }
            //            self.timer = Timer(fireAt: Date(timeIntervalSinceNow: 10), interval: 5, target: self, selector: #selector(recordTimeLimit), userInfo: nil, repeats: false)
            
            let cpath = recordPath
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 60) {
                self.recordTimeLimit(onlyUrl: cpath)
            }
        }
        catch{
            dprint("录音初始化失败")
            self.doFailed?(fstr)
        }
    }
    public func stop(){
        if recoder == nil{
            dprint("还没开始录音，")
            return
        }
        if recoder!.isRecording {
            recoder?.stop()
            try? AVAudioSession.sharedInstance().setActive(false)
            recoder = nil
            doStop?()
            uploadRecord(filePath: recordPath)
            dprint("完成录音")
        }
//        if timer != nil {
//            timer.invalidate()
//            timer = nil
//        }
    }
    public func cancel(){
        dprint("录音，cancel")
        if recoder == nil{
            dprint("还没开始录音，")
            return
        }
        if recoder!.isRecording {
            
            recoder?.stop()
            try? AVAudioSession.sharedInstance().setActive(false)
            recoder = nil
            doCancel?()
            dprint("取消录音")
        }
//        if timer != nil {
//            timer.invalidate()
//            timer = nil
//        }
    }
    
    @objc func uploadRecord(filePath: String){
        let fName = (filePath as NSString).lastPathComponent
        let url = URL(fileURLWithPath: filePath)
        guard let fileData = try? Data(contentsOf: url) else{
            return
        }
//        print(fName)
        weak var wself = self
//        HCAliyunOss.share.putFile(fileName: fName, fileData: fileData, done: { (iss, downUrl) in
//            print("oss 上传 ", iss, downUrl)
//            DispatchQueue.main.async {
//                wself?.doUpload?(iss, downUrl)
//            }
//        })
        HCAliyunOss.share.uploadC5File(fileData: fileData) { (iss, downUrl) in
            dprint("oss 上传 ", iss, downUrl)
            DispatchQueue.main.async {
                wself?.doUpload?(iss, downUrl)
            }
        }
        
    }
    
    @objc func recordTimeLimit(onlyUrl: String){
        if onlyUrl != recordPath {
            print("定时器取消")
            return
        }
        if timer != nil && timer.isValid {
            timer.invalidate()
            timer = nil
        }
        print("录音::时间限制::")
        self.stop()
    }
    
    func getFilePath() -> String{
        let uuid = NSUUID().uuidString
//        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)[0] + "/"
//        let temp = cachePath + "record/\(uuid).wav"
        let cachePath = NSTemporaryDirectory()
        let temp = cachePath + "\(uuid).wav"
        return temp
    }
}

func dprint(_ items: Any...){
    if HCHollyRecord.showLog {
        print(items)
    }
}

class AliyunOss: NSObject {
    class func asdf(){
        
    }
}
