//
//  CrashReport.swift
//  TestingCrashReport
//
//  Created by Yoman on 8/29/16.
//  Copyright © 2016 yoman. All rights reserved.
//

import UIKit
import Foundation
import CoreTelephony

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}

class CrashReport  {
    
    required init(){
        
        let tabledata = NSUserDefaults.standardUserDefaults().dictionaryForKey("CrashReport")
        
        print("---> \(tabledata)")
        
        //=======if save data is exist send to bug server
        if(tabledata?.count > 0 ){
            let url = NSURL(string: "http://smart.webcashfit.co.kr:5001/test/jsontest.php")!
            let session = NSURLSession.sharedSession()
            let request = NSMutableURLRequest(URL: url)
            
            do {
                let auth = try NSJSONSerialization.dataWithJSONObject(tabledata!, options: .PrettyPrinted)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.HTTPMethod = "POST"
                request.HTTPBody = auth
                
                let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                    
                    let jsonString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Crash Server Res ---- \(jsonString!)")
                    
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("CrashReport")
                })
                task.resume()
            } catch {
                print("Error")
            }
        }else{
            //==== The exceptin it's be to happen
            NSSetUncaughtExceptionHandler { exception in
                
                let ver = UIDevice.currentDevice()
                
                let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
                let version = nsObject as! String
                
                let networkInfo = CTTelephonyNetworkInfo()
                let carrier = networkInfo.subscriberCellularProvider
                
                let app_id = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? NSString
                
                let app_name = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
                
                var strNetwork = ""
                let reachability: Reachability = Reachability.reachabilityForInternetConnection()
                let networkStatus = reachability.currentReachabilityStatus().rawValue
                switch networkStatus {
                case (NotReachable.rawValue):
                    strNetwork = "Unknown"
                    break;
                case (ReachableViaWiFi.rawValue):
                    strNetwork = "use Wifi"
                    break;
                case (ReachableViaWWAN.rawValue):
                    strNetwork = "use Carrier"
                    break;
                default:
                    break;
                }
                
                let finalData = ["data":[
                    ["ERR_MSG"              :"\(exception) - \(exception.callStackSymbols) ",
                        "VERSION.SDK_INT"   :"",
                        "app_version"       :"\(version)",
                        "BOARD"             :"MSM8974",
                        "PRODUCT"           :"\(ver.model)_\(carrier!.carrierName!)_\(carrier!.isoCountryCode!)",
                        "network"           :"\(strNetwork)",
                        "DEVICE"            :"\(ver.model)",
                        "getNetworkCountryIso":"",
                        "MODEL"             :"\(UIDevice.currentDevice().modelName)",
                        "ERR_DATE"          :"\(NSDate())",
                        "VERSION.RELEASE"   :"\(ver.systemVersion)",
                        "BRAND"             :"",
                        "app_id"            :"\(app_id!)",
                        "app_nm"            :"\(app_name)",
                        "os"                :"iPhone"
                    ]]
                ]
                
                //=====Save Exception data
                NSUserDefaults.standardUserDefaults().setObject(finalData, forKey: "CrashReport")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    

}
