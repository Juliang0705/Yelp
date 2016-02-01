//
//  DetailViewController.swift
//  Yelp
//
//  Created by Juliang Li on 1/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController,MKMapViewDelegate, UITableViewDataSource,UITableViewDelegate{
    
    var business:Business!
    @IBOutlet weak var detailTable: UITableView!
    @IBOutlet weak var map: MKMapView!
    
    var businessDetailArray = [(String,String)]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(business.name)
        setUpDetailArray()
        detailTable.delegate = self
        detailTable.dataSource = self
        detailTable.estimatedRowHeight = 80
        detailTable.rowHeight = UITableViewAutomaticDimension
        navigationItem.title = business.name
        setupMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func setUpDetailArray(){
        if let name = business.name{
            businessDetailArray.append(("Name: ",name))
        }else{
            businessDetailArray.append(("Name: ","Not Available"))
        }
        if let phoneNumber = business.phoneNumber{
            businessDetailArray.append(("Phone Number: ",phoneNumber))
        }else{
            businessDetailArray.append(("Phone Number: ","Not Available"))
        }
        if let fullAddress = business.fullAddress{
            businessDetailArray.append(("Address: ",fullAddress))
        }else{
            businessDetailArray.append(("Address: ","Not Available"))
        }
        if let briefMessage = business.brief{
            businessDetailArray.append(("Brief: ",briefMessage))
        }else{
            businessDetailArray.append(("Brief: ", "Not Available"))
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! DetailTableViewCell
        cell.titleLabel.text = businessDetailArray[indexPath.row].0
        if cell.titleLabel.text ==  "Phone Number: "{
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,NSUnderlineColorAttributeName: UIColor.blueColor()]
            let underlineAttributedString = NSAttributedString(string:"TEL: " + businessDetailArray[indexPath.row].1, attributes: underlineAttribute)
            cell.descriptionLabel.attributedText = underlineAttributedString
            cell.descriptionLabel.textColor = UIColor.blueColor();
        }else{
            cell.descriptionLabel.text = businessDetailArray[indexPath.row].1
        }
        return cell
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInView(self.detailTable)
            if CGRectContainsPoint(detailTable.cellForRowAtIndexPath(NSIndexPath(index: 1))!.frame, location) {
                UIApplication.sharedApplication().openURL(NSURL(string: "tel://" + business.phoneNumber!)!)
            }
        }
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
