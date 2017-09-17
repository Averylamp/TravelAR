//
//  AzureAPIManager.swift
//  TrvlAR
//
//  Created by Avery Lamp on 9/16/17.
//  Copyright © 2017 Avery Lamp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AzureAPIManager: NSObject {
    var azureURL: URL {
        return URL(string: "http://trvlar.azurewebsites.net/")!
    }
    let session = URLSession.shared
    
    static var sharedInstance: AzureAPIManager = {
        let apiManager = AzureAPIManager()
        
        return apiManager
        
    }()
    
    class func shared() -> AzureAPIManager {
        return sharedInstance
    }
    
    func getPictures(location:String, completionHandler: @escaping ([(UIImage, String)?])-> ()){
        
        Alamofire.request(azureURL.appendingPathComponent("get_pictures?location=\(location)")).responseJSON { (response) in
            if let json = response.data {
                let data = JSON(data: json)
                
                print(data)
                if var fullJSONArray = data.array {
                    if fullJSONArray.count > 9 {
                        fullJSONArray.removeLast(fullJSONArray.count - 9)
                    }
                    var resultingArray:[(URL, String, Int)] = []
                    for item in fullJSONArray{
                        if let itemDict = item.dictionary {
                            if let caption = itemDict["name"]?.string, let imageURLStr = itemDict["url"]?.string, let imageURL = URL(string: imageURLStr){
                                resultingArray.append((imageURL, caption, resultingArray.count))
                            }
                        }
                    }
                    var count = resultingArray.count
                    var finalResults: [(UIImage, String)?] = Array<(UIImage, String)?>(repeating: nil, count: count)
                    for item in resultingArray{
                        print("Retrieving Image \(item.2)")
                        self.retrievePicture(search: item, completionHandler: { (imageResult) in
                            print("\(count) Images left to retrieve")
                            count -= 1
                            if imageResult != nil{
                                var caption = imageResult!.1
                                if caption.contains(location + " "){
                                    caption = caption.replacingOccurrences(of: location + " ", with: "")
                                }
                                finalResults[imageResult!.2] = (imageResult!.0, caption)
                                if count == 0{
                                    print("All images retrieved")
                                    completionHandler(finalResults)
                                }
                            }else{
                                print("FAILED GETTING IMAGE")
                                
                            }
                        })
                    }
                    //                    self.retrieveAllPictures(results: resultingArray, completionHandler: completionHandler)
                }else{
                    print("FAILED TO RETRIEVE IMAGES")
                    completionHandler([])
                }
            }
        }
    }
    
    func retrievePicture(search: (URL, String, Int),  completionHandler: @escaping ((UIImage, String, Int)?)-> ()){
        let imageURL = search.0
        getDataFromUrl(url: imageURL) { (data, response, error)  in
            guard let data = data, error == nil else {
                completionHandler(nil)
                return
            }
            print("Download Finished")
            if let image =  UIImage(data: data){
                completionHandler((image, search.1, search.2))
            }
        }
    }
    
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    
    
    
}
