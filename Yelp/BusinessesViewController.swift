//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,FilterViewControllerDelegate {
    
    var businesses: [Business]!
    var isMoreDataLoading = false
    var offset: Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        Business.searchWithTerm(term: "Thai", offset: 0, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
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
        print("^^^^^^^^^^^^^^", isMoreDataLoading)
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
        
        Business.searchWithTerm(term: "Thai", offset: offset, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.isMoreDataLoading = false
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
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        // In a storyboard-based application, you will often want to do a little preparation before navigation
       func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        let navigationController = segue.destination as! UINavigationController
        let filterViewController = navigationController.topViewController as! FiltersViewController
        filterViewController.delegate = self
     }
    
    func filterViewController(filterViewController: FiltersViewController, didUpdateFilter filters: [String : AnyObject]) {
        
        let categories = filters["categories"] as? [String]
        Business.searchWithTerm(term: "Restaurants", offset: 0, sort: nil, categories: categories, deals: nil) { (businesses: [Business]?, error: Error?) in
            print("$$$$$$$$$$$$$$", businesses?.count)
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
}
