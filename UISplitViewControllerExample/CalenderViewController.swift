
//
//  CalenderViewController.swift
//  TodayBehavior
//
//  Created by Mahesh Kumar on 2/25/16.
//  Copyright © 2016 Senthil Kumar. All rights reserved.
//

import UIKit
import CoreData

class CalenderViewController: UIViewController,UITableViewDelegate {
    // MARK: - Properties
    
    @IBOutlet weak var seg_Btn: UISegmentedControl!
    let appDelegate:AppDelegate = AppDelegate()
    var filterArray:NSArray! = NSArray()
    var gitHubUsersArray:NSMutableArray! //global variable

    @IBOutlet weak var labelError: UILabel!


    @IBOutlet weak var segmentClass: UISegmentedControl!
    @IBOutlet weak var tblUsers: UITableView!

    @IBOutlet weak var loadingIndicaotor: UIActivityIndicatorView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var monthLabel: UILabel!

    var refreshControl = UIRefreshControl()
    var shouldShowDaysOut = true
    var animationFinished = true
    var selectedDay:DayView!

    var checkDateBool : Bool = false
  @IBOutlet weak var searchBar: UISearchBar!
        var searchActive : Bool = false
    // MARK: - Life cycle
    
    override func viewDidLoad()
    {
       super.viewDidLoad()
       self.title = "Schedule"
       gitHubUsersArray = NSMutableArray()
       self.searchView.alpha = 0
       self.labelError.hidden = true
       let rightSearchBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "searchTapped:")
       self.navigationItem.setRightBarButtonItem(rightSearchBarButtonItem, animated: true)

        if appDelegate.isNetworkAvailable()
        {
            loadGitHubRequest()
            
        }else
        {
            loadDatas()

            
        }
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: Selector("refreshData"), forControlEvents: UIControlEvents.ValueChanged)
        self.tblUsers.addSubview(refreshControl)
        
    }
    // MARK: - Pull To Refresh

    func refreshData()
    {
        if appDelegate.isNetworkAvailable()
        {
            loadGitHubRequest()
            
        }else
        {
            loadDatas()
            
        }
        self.loadingIndicaotor .startAnimating()

    }
    
    
    // MARK: - Load Datas Online
    func loadGitHubRequest()
    {
        
        self.loadingIndicaotor .startAnimating()

        let url_ = NSURL(string: "https://api.github.com/search/repositories?q=IOS")
        let request_ = NSURLRequest(URL: url_!)
        NSURLConnection.sendAsynchronousRequest(request_, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) in
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                self.gitHubUsersArray = dict.valueForKey("items") as! NSMutableArray
                let moc = self.appDelegate.managedObjectContext
                let duplicate = self.checkCount()
                
                if duplicate < self.gitHubUsersArray.count
                {
                    for var i = 0; i < self.gitHubUsersArray.count; i++
                    {
                        let entity = NSEntityDescription.insertNewObjectForEntityForName("Entity", inManagedObjectContext: moc) as! Entity
                        entity.setValue(self.gitHubUsersArray.valueForKey("full_name").objectAtIndex(i), forKey: "full_name")
                        
                        entity.setValue(self.gitHubUsersArray.valueForKey("name").objectAtIndex(i), forKey: "name")
                        entity.setValue(self.gitHubUsersArray.valueForKey("default_branch").objectAtIndex(i), forKey: "default_branch")
                        
                        if let latestValue = self.gitHubUsersArray.valueForKey("language").objectAtIndex(i) as? String
                        {
                            entity.setValue(latestValue, forKey: "default_branch")
                        }
                        else
                        {
                              entity.setValue("No Data", forKey: "default_branch")
                        }
        
                    }
                    do {
                        try moc.save()
                        print("Saved")
                        
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
                self.checkDateBool = true

                self.loadingIndicaotor .stopAnimating()
                self.tblUsers.reloadData()
                
            } catch {
                print("Something went wrong")
            }
        }
        
        
        
        
        
    }
    // MARK: - Load Datas Offline

    func loadDatas()
    {
        self.loadingIndicaotor .startAnimating()

        do
        {
            let request  = NSFetchRequest(entityName: "Entity")
            let results = try appDelegate.managedObjectContext.executeFetchRequest(request)
            if results.count > 0
            {
                for item in results as![NSManagedObject]
                {
                    
                    self.gitHubUsersArray .addObject(item)

                }
                self.tblUsers.reloadData()
                self.loadingIndicaotor .stopAnimating()

                
            }
        }
        catch
        {
            
        }
        
    }
    
    
    // MARK: - Tableview Delegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        switch segmentClass.selectedSegmentIndex
        {
        case 0:
            return 1

        case 1:
            return 3

        default:
            return 0
        }
        
        
    }
  
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let label = UILabel()
        label.frame = CGRectMake(80, 5, self.tblUsers.frame.size.width, 25)
      
        label.textAlignment = NSTextAlignment.Left
        label.backgroundColor = UIColor.darkGrayColor()
        label.textColor = UIColor.whiteColor()
            switch (section) {
            case 0:
                label.text = "Today 7.00pm"
            case 1:
                label.text =  "Friday 4th 7.00pm"
            case 2:
                label.text =  "Monday 4th 6.00pm"
            default:
                label.text = nil;
            }
        return label
    }
        
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gitHubUsersArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        
        let object = self.gitHubUsersArray[indexPath.row]
        
        (cell.contentView.viewWithTag(1) as! UILabel).text = object.valueForKey("full_name") as? String
        (cell.contentView.viewWithTag(2) as! UILabel).text = object.valueForKey("name") as? String
        (cell.contentView.viewWithTag(3) as! UILabel).text = object.valueForKey("default_branch") as? String
        
        if let latestValue = object.valueForKey("language") as? String {
            (cell.contentView.viewWithTag(4) as! UILabel).text = latestValue
        }else
        {
            (cell.contentView.viewWithTag(4) as! UILabel).text = "No Data"
        }
        
        
   
        return cell
    }
     func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
     func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Cannot Attend"
    }
    
    // MARK: - Check data count
    func checkCount()-> Int
    {
        var count:Int!
        let moc = appDelegate.managedObjectContext
        let personFetch = NSFetchRequest(entityName: "Entity")
        do {
            let fetchedPerson = try moc.executeFetchRequest(personFetch) as! [Entity]
            count = fetchedPerson.count
            //  fet = fetchedPerson
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        
        return count
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
    // MARK: - Load Month and Year

    @IBAction func sementChange(sender: AnyObject) {
        switch seg_Btn.selectedSegmentIndex
        {
        case 0:
            calendarView.changeMode(.MonthView)

            break
        case 1:
            calendarView.changeMode(.WeekView)

                break
        default:
            break;
        }
    }
    
    // MARK: - Load Classes data

    @IBAction func segClasses(sender: AnyObject)
    {
        self.tblUsers .reloadData()
    }
}



// MARK: - CVCalendarViewDelegate & CVCalendarMenuViewDelegate

extension CalenderViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
      
        
        
        if  checkDateBool == true
         {
            
            switch segmentClass.selectedSegmentIndex
            {
            case 0:
                let indexPath = NSIndexPath(forRow: 10, inSection: 0)
                self.tblUsers.scrollToRowAtIndexPath(indexPath,
                    atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
                break
            case 1:
                let indexPath = NSIndexPath(forRow: 20, inSection: 2)
                self.tblUsers.scrollToRowAtIndexPath(indexPath,
                    atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                break
                
            default:
               break
            }
        }
    }
    
    func presentedDateUpdated(date: CVDate) {
        if monthLabel.text != date.globalDescription && self.animationFinished
        {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
            updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.animationFinished = false
                self.monthLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
                self.monthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransformIdentity
                
                }) { _ in
                    
                    self.animationFinished = true
                    self.monthLabel.frame = updatedMonthLabel.frame
                    self.monthLabel.text = updatedMonthLabel.text
                    self.monthLabel.transform = CGAffineTransformIdentity
                    self.monthLabel.alpha = 1
                    updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        let day = dayView.date.day
        let randomDay = Int(arc4random_uniform(31))
        if day == randomDay {
            return true
        }
        
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        
        let red = CGFloat(arc4random_uniform(600) / 255)
        let green = CGFloat(arc4random_uniform(600) / 255)
        let blue = CGFloat(arc4random_uniform(600) / 255)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)

        let numberOfDots = Int(arc4random_uniform(3) + 1)
        switch(numberOfDots) {
        case 2:
            return [color, color]
        case 3:
            return [color, color, color]
        default:
            return [color] // return 1 dot
        }
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }

    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 13
    }

    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .Short
    }

    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        circleView.fillColor = .colorFromCode(0xCCCCCC)
        return circleView
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (dayView.isCurrentDay) {
            return true
        }
        return false
    }
    
    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        let π = M_PI
        
        let ringSpacing: CGFloat = 3.0
        let ringInsetWidth: CGFloat = 1.0
        let ringVerticalOffset: CGFloat = 1.0
        var ringLayer: CAShapeLayer!
        let ringLineWidth: CGFloat = 4.0
        let ringLineColour: UIColor = .blueColor()
        
        let newView = UIView(frame: dayView.bounds)
        
        let diameter: CGFloat = (newView.bounds.width) - ringSpacing
        let radius: CGFloat = diameter / 2.0
        
        let rect = CGRectMake(newView.frame.midX-radius, newView.frame.midY-radius-ringVerticalOffset, diameter, diameter)
        
        ringLayer = CAShapeLayer()
        newView.layer.addSublayer(ringLayer)
        
        ringLayer.fillColor = nil
        ringLayer.lineWidth = ringLineWidth
        ringLayer.strokeColor = ringLineColour.CGColor
        
        let ringLineWidthInset: CGFloat = CGFloat(ringLineWidth/2.0) + ringInsetWidth
        let ringRect: CGRect = CGRectInset(rect, ringLineWidthInset, ringLineWidthInset)
        let centrePoint: CGPoint = CGPointMake(ringRect.midX, ringRect.midY)
        let startAngle: CGFloat = CGFloat(-π/2.0)
        let endAngle: CGFloat = CGFloat(π * 2.0) + startAngle
        let ringPath: UIBezierPath = UIBezierPath(arcCenter: centrePoint, radius: ringRect.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        ringLayer.path = ringPath.CGPath
        ringLayer.frame = newView.layer.bounds
        
        return newView
    }
    
}


// MARK: - CVCalendarViewAppearanceDelegate

extension CalenderViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - IB Actions

extension CalenderViewController {
   
    
    @IBAction func loadPrevious(sender: AnyObject) {
        calendarView.loadPreviousView()
    }
    
    
    @IBAction func loadNext(sender: AnyObject) {
        calendarView.loadNextView()
        
       
    }
}

// MARK: - Convenience API Demo

extension CalenderViewController {
    func toggleMonthViewWithMonthOffset(offset: Int) {
        let calendar = NSCalendar.currentCalendar()
//        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(NSDate()) // from today
        
        components.month += offset
        
        let resultDate = calendar.dateFromComponents(components)!
        
        self.calendarView.toggleViewWithDate(resultDate)
    }
    
    func didShowNextMonthView(date: NSDate)
    {
//        let calendar = NSCalendar.currentCalendar()
//        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(date) // from today
        
        print("Showing Month: \(components.month)")
    }
    
    
    func didShowPreviousMonthView(date: NSDate)
    {
//        let calendar = NSCalendar.currentCalendar()
//        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(date) // from today
        
        print("Showing Month: \(components.month)")
    }
   
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
    }
    ///
    
    // MARK: - Search View Delegates
    func searchTapped(sender:UIButton) {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.searchView.alpha = 1.0
            self.searchBar.text = ""
        })
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
 
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.searchView.alpha = 0
        })
        
        if appDelegate.isNetworkAvailable()
        {
            loadGitHubRequest()
            
        }else
        {
            loadDatas()
            
        }
        showHideTable()

        labelError.hidden = true
        tblUsers.hidden = false
        
        self.searchBar .resignFirstResponder()
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        let resultPredicate = NSPredicate(format: "full_name contains[c] %@", searchBar.text!)
        self.filterArray = self.gitHubUsersArray.filteredArrayUsingPredicate(resultPredicate)
         gitHubUsersArray = NSMutableArray()
        gitHubUsersArray .addObjectsFromArray(self.filterArray as [AnyObject])
        showHideTable()
        self.tblUsers.reloadData()
    }
    
    func showHideTable()
    {
        if(self.gitHubUsersArray.count > 0)
        {
            labelError.hidden = true
            tblUsers.hidden = false
            
        }
        else
        {
            labelError.hidden = false
            tblUsers.hidden = true
            
        }

    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    

        showHideTable()

    
    }
}