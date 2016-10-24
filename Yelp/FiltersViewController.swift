//
//  FilterViewController.swift
//  Yelp
//
//  Created by Neha Samant on 10/20/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FilterViewControllerDelegate {
@objc optional func filterViewController(filterViewController: FiltersViewController, didUpdateFilter filters: Dictionary<String,[String]>)
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FilterViewControllerDelegate?
    
    var yelpModel = Yelp()
    var categories = [[String:String]]()
    var categoryNames = [String]()
    var switchSectionRow = Dictionary<Int, Bool>()
    var switchStatesDictionary = [Int:Dictionary<Int, Bool>]()
    
    @IBAction func onCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearch(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
        var filters = Dictionary<String,[String]>()
        var selectedCategories = [String]()
        var localSwitchStates = [Int: Bool]()
        for section in switchStatesDictionary {
            localSwitchStates = switchStatesDictionary[section.key]!
    
            if(section.key == 0){
                filters["deals"] = ["true"]
            }
            
            if(section.key == 1) {
                for(row, isSelected) in localSwitchStates {
                    if isSelected {
                        filters["distance"] = [yelpModel.distanceValues[row]["radius_filter"]!]
                    }
                }
            }
            if(section.key == 2){
                for(row, isSelected) in localSwitchStates {
                    if isSelected {
                        filters["sort"] = [yelpModel.sortValues[row]["value"]!]
                    }
                }
            }
            if(section.key == 3) {
                for(row, isSelected) in localSwitchStates {
                    if isSelected {
                        selectedCategories.append(categories[row]["code"]!)
                    }
                  }
            }
            
        if (selectedCategories.count) > 0 {
            filters["categories"] = selectedCategories
        }
    }
        delegate?.filterViewController?(filterViewController: self, didUpdateFilter: filters)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        categories = yelpModel.yelpCategories()
        categoryNames = getCategoryNames()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSection(section: section).noOfRows
    }
    
    func getSection(section: Int) -> (noOfRows:Int,sectionLabel: String, rows: [String]) {
        var sectionInfo:(Int, String, [String])?
        switch section {
        case 0:
            sectionInfo = (1,"Deal", ["Offering a Deal"])
        case 1:
            sectionInfo = (4,"Distance",["5 miles", "10 miles","15 miles","25 miles"])
        case 2:
            sectionInfo = (3,"Sort By",["Best Match", "Distance", "Highest Rated"])
        case 3:
            sectionInfo = (categoryNames.count,"Category",categoryNames)
        default:
            break
        }
        return sectionInfo!
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getSection(section: section).sectionLabel
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        cell.categoryLabel?.text = getSection(section: indexPath.section).rows[indexPath.row]
        cell.onSwitch.isOn = false
        cell.delegate = self
       
        for sectionInDict in switchStatesDictionary {
            if sectionInDict.key == indexPath.section {
                for (keyInDict, flag) in sectionInDict.value {
                    if (keyInDict == indexPath.row) {
                        if(flag) {
                            cell.onSwitch.isOn = true
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue name: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)
        var switchCellStates = [Int:Bool]()
        if ((switchStatesDictionary[(indexPath?.section)!]) != nil) {
            switchCellStates = switchStatesDictionary[(indexPath?.section)!]!
            switchCellStates[(indexPath?.row)!] = name
        } else {
            switchCellStates[(indexPath?.row)!] = name
        }
        switchStatesDictionary[(indexPath?.section)!] = switchCellStates
    }
    
    func getCategoryNames() -> [String] {
        for index in 0...categories.count-1 {
            categoryNames.append(categories[index]["name"]!)
        }
        return categoryNames
    }
}
