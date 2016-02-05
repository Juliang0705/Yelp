//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit


class BusinessesViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate,SideBarDelegate,DetaileViewControllerDelegate,FavoriteViewControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    var businesses: [Business]!
    var searchBar: UISearchBar = UISearchBar()
    var searchStatus = false
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView!
    var locationGetter:Location = Location()
    var defaultSearch = "Steak"
    var currentLimit = 10
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
    let categories = ["Restaurants","Food","Shopping","NightLife","Coffee & Tea","Home Services","Automotive","Active Life","Beauty & Spas", "Financial Services","Pets","Religious Organizations","Education","Hotels & Travel","Health & Medical","Local Servives","Real Estate","Arts & Entertainment"]
    var sideBar:SideBar?
    let userData = NSUserDefaults.standardUserDefaults()
    var favorites:[String:Business] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.rootViewController = self
        navigationItem.title = "Yelp"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        searchBar.delegate = self
        self.view.sendSubviewToBack(errorView)
        setupActivityView()
        if let recentSearch = userData.objectForKey("recentSearch") as? String{
            search(recentSearch)
            defaultSearch = recentSearch
        }else {
            search(defaultSearch)
        }
        //get saved favorite
        if let decoded  = userData.objectForKey("favorites") as? NSData{
            let savedFavorites = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! [String:Business]
            favorites = savedFavorites
        }
        sideBar = SideBar(sourceView:self.view,menuItems:categories)
        sideBar!.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil{
            return businesses.count
        }else {
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    @IBAction func seachBarClicked(sender: UIButton) {
        if searchStatus == false {
            navigationItem.titleView = searchBar
            searchStatus = true
            searchBar.becomeFirstResponder()
        }
        else {
            searchBar.text = ""
            searchBar.resignFirstResponder()
            navigationItem.titleView = nil
            searchStatus = false
            searchBar.resignFirstResponder()
        }
    }
   func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        search(searchBar.text!)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func setupActivityView(){
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView.hidden = true
        tableView.addSubview(loadingMoreView)
        tableView.bringSubviewToFront(loadingMoreView)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                
                    // Code to load more results
                isMoreDataLoading = true
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView.frame = frame
                loadingMoreView.startAnimating()
                
                loadMoreData()
                
            }
                
        }
    }
    
    func loadMoreData(){
        currentLimit += 10
        Business.searchWithTerm(defaultSearch, sort:YelpSortMode.Distance , categories: nil, deals: nil,location: locationGetter.getCurrentLocationAsString(),limit: currentLimit) {  (businesses: [Business]!, error: NSError!) -> Void in
            if (businesses == nil){
                if !self.searchBar.text!.isEmpty {
                    self.search(self.searchBar.text!)
                }else{
                    self.search(self.defaultSearch)
                }
            }else {
                self.businesses = businesses
                self.tableView.reloadData()
            }
            self.loadingMoreView.stopAnimating()
            self.isMoreDataLoading = false
        }
    }
    
    func search(s:String){
        currentLimit = 10
        Business.searchWithTerm(s, sort:YelpSortMode.Distance , categories: nil, deals: nil,location: locationGetter.getCurrentLocationAsString(),limit: currentLimit) {  (businesses: [Business]!, error: NSError!) -> Void in
            if (businesses.count == 0 || error != nil){
                self.view.bringSubviewToFront(self.errorView)
            }else {
                self.businesses = businesses
                self.view.sendSubviewToBack(self.errorView)
                self.tableView.reloadData()
                self.userData.setObject(s, forKey: "recentSearch")
                self.userData.synchronize()
                self.defaultSearch = s
            }
        }
    }
    
    func sideBarDidSelectButtonAtIndex(index: Int) {
        print (categories[index])
        search(categories[index])
    }
    
    func DetailViewControllerAddBusiness(name: String, business: Business){
        favorites.updateValue(business, forKey: name) // add it
    }
    func DetailViewControllerRemoveBusiness(name: String){
        favorites.removeValueForKey(name)
    }
    func DetailViewControllerHasFavoritedBusiness(name: String) -> Bool{
        return favorites[name] != nil
    }
    func FavoriteViewControllerAddBusiness(name: String, business: Business){
        favorites.updateValue(business, forKey: name) // add it
    }
    func FavoriteViewControllerRemoveBusiness(name: String){
        favorites.removeValueForKey(name)
    }
    func FavoriteViewControllerHasFavoritedBusiness(name: String) -> Bool{
        return favorites[name] != nil
    }
    func FavoiteViewControllerGetBusinesses() -> [String:Business]{
        return favorites
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as? UITableViewCell
        if cell != nil {
            let indexPath = tableView.indexPathForCell(cell!)
            let business = businesses![indexPath!.row]
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.business = business
            detailViewController.delegate = self
        }else{
            let favoriteViewController = segue.destinationViewController as! FavoriteViewController
            favoriteViewController.delegate = self
        }
    }
    

}
