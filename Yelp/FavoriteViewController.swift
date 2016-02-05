//
//  FavoriteViewController.swift
//  Yelp
//
//  Created by Juliang Li on 2/4/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

protocol FavoriteViewControllerDelegate{
    func FavoriteViewControllerAddBusiness(name: String, business: Business)
    func FavoriteViewControllerRemoveBusiness(name: String)
    func FavoriteViewControllerHasFavoritedBusiness(name: String) -> Bool
    func FavoiteViewControllerGetBusinesses() -> [String:Business]
}

class FavoriteViewController: UIViewController,DetaileViewControllerDelegate,UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    var delegate: FavoriteViewControllerDelegate?
    var businesses:[Business]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
        businesses = delegate?.FavoiteViewControllerGetBusinesses().values.reverse()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func DetailViewControllerAddBusiness(name: String, business: Business){
        delegate?.FavoriteViewControllerAddBusiness(name, business: business)
    }
    func DetailViewControllerRemoveBusiness(name: String){
        delegate?.FavoriteViewControllerRemoveBusiness(name)
    }
    func DetailViewControllerHasFavoritedBusiness(name: String) -> Bool{
        return (delegate?.FavoriteViewControllerHasFavoritedBusiness(name))!
    }
    func DetailViewControllerUpdateFavorite(){
        businesses = delegate?.FavoiteViewControllerGetBusinesses().values.reverse()
        collectionView.reloadData()
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  businesses.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FavoriteCell", forIndexPath: indexPath) as! FavoriteCollectionViewCell
        if let url = businesses[indexPath.row].imageURL{
            cell.locationImageView.setImageWithURL(url)
        }
        cell.locationName.text = businesses[indexPath.row].name
        return cell
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as? UICollectionViewCell
        if cell != nil {
            let indexPath = collectionView.indexPathForCell(cell!)
            let business = businesses![indexPath!.row]
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.business = business
            detailViewController.delegate = self
        }
    }

}
