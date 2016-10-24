//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate,FilterViewControllerDelegate {
    
    var businesses: [Business]!
    var isMoreDataLoading = false
    var offset: Int = 0
    var filteredData: [Business]!
    
    var categories = [String]()
    var radius = Int()
    var sortMode = Int()
    var deal = Bool()
    
    var yelpModel = Yelp()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        Business.searchWithTerm(term: "Restaurants", offset: 0, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if businesses != nil {
                return businesses.count
            }else {
                return 0
            }
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
            
            cell.business = businesses[indexPath.row]
            return cell
        }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                offset = offset + 20
                loadMoreData(offset: offset)
            }
        }
    }
    
    func loadMoreData(offset:Int) {
         print("OFFSET-------->", offset, "RADIUS------->", radius, "categories----->", categories, "SORT BY--->", sortMode)
        Business.searchWithTerm(term: "Restaurants", offset: offset, radius: radius, sort: sortMode, categories: categories, deals: deal) { (businesses: [Business]?, error: Error?) in
            
            self.isMoreDataLoading = false
            self.businesses = businesses
            self.tableView.reloadData()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        let navigationController = segue.destination as! UINavigationController
        let filterViewController = navigationController.topViewController as! FiltersViewController
        filterViewController.delegate = self
     }
    
    func filterViewController(filterViewController: FiltersViewController, didUpdateFilter filters: Dictionary<String,[String]>) {
    
        for keyFilter in filters {
            if(keyFilter.key == "deals") {
                if(filters["deals"]?.first! == "true") {
                    //deal = true
                    self.yelpModel.deals = true
                    deal = true
                }
            }
            if(keyFilter.key == "categories") {
                 self.yelpModel.categories = filters["categories"]!
                 categories = filters["categories"]!
            }
            if(keyFilter.key == "distance") {
                 self.yelpModel.radius = Int((filters["distance"]?.first)!)!
                 radius = Int((filters["distance"]?.first)!)!
                
            }
            if(keyFilter.key == "sort") {
                print("-->",(filters["sort"]),"<--")
                 self.yelpModel.sort = Int((filters["sort"]?.first)!)!
                 sortMode = Int((filters["sort"]?.first)!)!
            }
        }
        Business.searchWithTerm(term: "Restaurants", offset: 0, radius: radius, sort: sortMode, categories: categories, deals: deal) { (businesses: [Business]?, error: Error?) in
            print("$$$$$$$$$$$$$$", businesses?.count)
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
}
