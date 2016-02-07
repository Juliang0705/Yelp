//
//  DetailViewController.swift
//  Yelp
//
//  Created by Juliang Li on 1/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

@objc protocol DetaileViewControllerDelegate{
    func DetailViewControllerAddBusiness(name: String, business: Business)
    func DetailViewControllerRemoveBusiness(name: String)
    func DetailViewControllerHasFavoritedBusiness(name: String) -> Bool
    optional func DetailViewControllerUpdateFavorite()
}

class DetailViewController: UIViewController,MKMapViewDelegate, UITableViewDataSource,UITableViewDelegate{
    
    var business:Business!
    @IBOutlet weak var detailTable: UITableView!
    @IBOutlet weak var map: MKMapView!
    
    var businessDetailArray = [(String,String)]()

    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    var delegate:DetaileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDetailArray()
        detailTable.delegate = self
        detailTable.dataSource = self
        detailTable.estimatedRowHeight = 80
        detailTable.rowHeight = UITableViewAutomaticDimension
        navigationItem.title = business.name
        map.delegate = self
        toggleFavoriteButtonAppearance()
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
        if let _ = business.mobileUrl{
            businessDetailArray.append(("Website: ","Click Here"))
        }else{
            businessDetailArray.append(("Website: ","Not Available"))
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! DetailTableViewCell
        cell.titleLabel.text = businessDetailArray[indexPath.row].0
        //make it callable
        if businessDetailArray[indexPath.row].0 ==  "Phone Number: "{
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,NSUnderlineColorAttributeName: UIColor.blueColor()]
            let underlineAttributedString = NSAttributedString(string:"TEL: " + businessDetailArray[indexPath.row].1, attributes: underlineAttribute)
            cell.descriptionLabel.attributedText = underlineAttributedString
            cell.descriptionLabel.textColor = UIColor.blueColor();
            cell.descriptionLabel.userInteractionEnabled = true
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "phoneNumberLabelTap")
            cell.descriptionLabel.addGestureRecognizer(tapGesture)
            
        }//make it browsable
        else if businessDetailArray[indexPath.row].0 == "Website: "{
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,NSUnderlineColorAttributeName: UIColor.blueColor()]
            let underlineAttributedString = NSAttributedString(string: businessDetailArray[indexPath.row].1, attributes: underlineAttribute)
            cell.descriptionLabel.attributedText = underlineAttributedString
            cell.descriptionLabel.textColor = UIColor.blueColor();
            cell.descriptionLabel.userInteractionEnabled = true
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "urlLabelTap")
            cell.descriptionLabel.addGestureRecognizer(tapGesture)
        }
        else{
            cell.descriptionLabel.text = businessDetailArray[indexPath.row].1
        }
        return cell
        
    }
    func phoneNumberLabelTap() {
        let phoneUrl: NSURL = NSURL(string: "telprompt:\(business.phoneNumber!)")!
        if UIApplication.sharedApplication().canOpenURL(phoneUrl) {
            UIApplication.sharedApplication().openURL(phoneUrl)
        }
        else {
            let alert = UIAlertController(title: nil, message: "Call facility is not available", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
            self.presentViewController(alert,animated: true,completion: nil)
        }
    }
    
    func urlLabelTap(){
        UIApplication.sharedApplication().openURL(NSURL(string: business.mobileUrl!)!)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5;
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "locationImage"
        
        // custom image annotation
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        if (annotationView == nil) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        else {
            annotationView!.annotation = annotation
        }
        let imageView = UIImageView()
        if let imageUrl = business.imageURL{
            imageView.setImageWithURL(imageUrl)
        }
        if annotation.title! != "Current Location"{
            annotationView!.detailCalloutAccessoryView = imageView;
            annotationView!.becomeFirstResponder()
        }
        annotationView!.canShowCallout = true
        return annotationView
    }
    
    @IBAction func FavoriteButtonClicked(sender: UIBarButtonItem) {
        if delegate?.DetailViewControllerHasFavoritedBusiness(business.name!) == false {
            delegate?.DetailViewControllerAddBusiness(business.name!, business: business)
            favoriteButton.image = UIImage(named: "like")
        }else{
            // remove it
            delegate?.DetailViewControllerRemoveBusiness(business.name!)
            favoriteButton.image = UIImage(named: "unlike")
        }
        delegate?.DetailViewControllerUpdateFavorite?()
    }
    func toggleFavoriteButtonAppearance(){
       
        if delegate?.DetailViewControllerHasFavoritedBusiness(business.name!) == false {
            favoriteButton.image = UIImage(named: "unlike")
        }else{
            favoriteButton.image = UIImage(named: "like")
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
