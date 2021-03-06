//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class Business: NSObject,NSCoding{
    let name: String?
    let address: String?
    let imageURL: NSURL?
    let categories: String?
    let distance: String?
    let ratingImageURL: NSURL?
    let reviewCount: NSNumber?
    //modified
    let phoneNumber: String?
    var latitude:NSNumber? = nil
    var longitude:NSNumber? = nil
    let fullAddress:String?
    let brief:String?
    let mobileUrl:String?
    
    var jsonData:NSDictionary
    init(dictionary: NSDictionary) {
        jsonData = dictionary
        name = dictionary["name"] as? String
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            imageURL = NSURL(string: imageURLString!)!
        } else {
            imageURL = nil
        }
        mobileUrl = dictionary["mobile_url"] as? String
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        var fullAddress = " "
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            let fullAddressArray = location!["display_address"] as? NSArray
            if fullAddressArray != nil && fullAddressArray!.count > 0 {
                if fullAddress != " "{
                    fullAddress += ", "
                }
                for s in fullAddressArray!{
                    fullAddress += (s as! String + "\n")
                }
            }
            fullAddress.removeAtIndex(fullAddress.endIndex.predecessor())
            let neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
            let coordinate = location!["coordinate"] as? NSDictionary
            if coordinate != nil{
                self.latitude = coordinate!["latitude"] as? NSNumber
                self.longitude = coordinate!["longitude"] as? NSNumber
            }
        }
        self.address = address
        self.fullAddress = fullAddress
        
        let categoriesArray = dictionary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = categoryNames.joinWithSeparator(", ")
        } else {
            categories = nil
        }
        
        let distanceMeters = dictionary["distance"] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        } else {
            distance = nil
        }
        
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = NSURL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        reviewCount = dictionary["review_count"] as? NSNumber
        
        //my additions
        phoneNumber = dictionary["display_phone"] as? String
        brief = dictionary["snippet_text"] as? String
       // print(phoneNumber,latitude, longitude, fullAddress, brief )
        
    }
    class func businesses(array array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
    
    class func searchWithTerm(term: String, completion: ([Business]!, NSError!) -> Void) {
        YelpClient.sharedInstance.searchWithTerm(term, completion: completion)
    }
    
    class func searchWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, location:String? ,limit: Int?, completion: ([Business]!, NSError!) -> Void) -> Void {
        YelpClient.sharedInstance.searchWithTerm(term, sort: sort, categories: categories, deals: deals, location: location,limit: limit, completion: completion)
    }
    required convenience init(coder aDecoder: NSCoder) {
        let data = aDecoder.decodeObjectForKey("data") as! NSDictionary
        self.init(dictionary: data)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(jsonData, forKey: "data")
    }
    
    
    
}
