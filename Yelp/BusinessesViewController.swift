//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var businesses: [Business]!
    var searchBar: UISearchBar!
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView!
    var locationGetter:Location = Location()
    var defaultSearch = "Chinese"
    var currentLimit = 10
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        setupSearchBar()
        setupActivityView()
        search(defaultSearch)

/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
*/
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
    func setupSearchBar(){
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchDisplayController?.displaysSearchBarInNavigationBar = true
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
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let business = businesses![indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.business = business
    }
    

}
