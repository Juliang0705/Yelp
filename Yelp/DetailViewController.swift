//
//  DetailViewController.swift
//  Yelp
//
//  Created by Juliang Li on 1/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController,MKMapViewDelegate{

    
    var business:Business!
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var brief: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(business.name)
        navigationItem.title = business.name
        setupLabels()
        setupMap()
        setUpBackgroundImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupLabels(){
        if let businessName = business.name{
            name.text = "Name: " + businessName
        }
        if let phoneNumber = business.phoneNumber{
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            let underlineAttributedString = NSAttributedString(string:"TEL: " + phoneNumber, attributes: underlineAttribute)
            phone.attributedText = underlineAttributedString
        }
        if let fullAddress = business.fullAddress{
            address.text = "Address: " + fullAddress
        }
        if let briefMessage = business.brief{
            brief.text = "Brief:\n " + briefMessage
            brief.sizeToFit()
        }
    }
    
    func setupMap(){
        if let latitude = business.latitude?.doubleValue{
            if let longitude = business.longitude?.doubleValue{
                let location = CLLocation(latitude: latitude, longitude: longitude)
                let regionRadius: CLLocationDistance = 600
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                    regionRadius * 2.0, regionRadius * 2.0)
                map.setRegion(coordinateRegion,animated: true)
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                dropPin.title = business.name
                map.addAnnotation(dropPin)
            }
        }
        
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInView(self.view)
            if CGRectContainsPoint(phone.frame, location) {
                UIApplication.sharedApplication().openURL(NSURL(string: "tel://" + business.phoneNumber!)!)
            }
        }

    }
    func setUpBackgroundImage(){
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
