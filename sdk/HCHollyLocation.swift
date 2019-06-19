//
//  HCHollyLocation.swift
//  HCHollySDK
//
//  Created by holly_linlc on 2018/4/3.
//  Copyright © 2018年 xmsdk. All rights reserved.
//

import UIKit
import CoreLocation

public typealias CallBackLoc = (CLLocation?)->Void
public typealias CallBackLocFailed = (Error)->Void

public class HCHollyLocation: NSObject, CLLocationManagerDelegate {

    public static let share = { () -> HCHollyLocation in
        let ins = HCHollyLocation()
        ins.manager.delegate = ins
        ins.manager.desiredAccuracy = kCLLocationAccuracyBest
        ins.reqAuth()
        return ins
    }()
    private override init() {
        super.init()
    }
    
    var manager = CLLocationManager()
    
    private var locationDone: CallBackLoc?
    private var locationFail: CallBackLocFailed?

    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("didDetermineState")
    }
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization")
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            
        }
        else{
            print("未授权定位")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations)
        locationDone?(locations.first)
        manager.stopUpdatingLocation()
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError--->")
        print(error)
        print(error.localizedDescription)
        locationFail?(error)
        print("未授权定位。。。")
    }
    
    public func getLocation(back: @escaping CallBackLoc, failed: @escaping CallBackLocFailed){
        self.reqAuth()
        self.locationDone = back
        self.locationFail = failed
        manager.startUpdatingLocation()
    }
    
    func reqAuth(){
        manager.requestWhenInUseAuthorization()
    }
    
}
