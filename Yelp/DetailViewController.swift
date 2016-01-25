//
//  DetailViewController.swift
//  Yelp
//
//  Created by Juliang Li on 1/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {

    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupLabels(){
        if let businessName = business.name{
            name.text = "name: " + businessName
        }
        if let phoneNumber = business.phoneNumber{
            phone.text = "TEL: " + phoneNumber
        }
        if let fullAddress = business.fullAddress{
            address.text = "Address : " + fullAddress
        }
        if let briefMessage = business.brief{
            brief.text = "brief: " + briefMessage
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
