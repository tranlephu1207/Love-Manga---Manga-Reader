//
//  ChapterListViewController.swift
//  LePhu-CollectionView
//
//  Created by Tran Le Phu on 12/26/15.
//  Copyright © 2015 LePhuTran. All rights reserved.
//

import UIKit
import iAd

class ChapterListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewShow: UIView!
    @IBOutlet weak var viewHide: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mangaNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var numOfTranslatorsLabel: UILabel!
    @IBOutlet weak var translatorsLabel: UILabel!
    @IBOutlet weak var numOfChapLabel: UILabel!
    @IBOutlet weak var numOfViewsLabel: UILabel!
    @IBOutlet weak var moreLessBtn: UIButton!
    @IBOutlet weak var mangaSummaryTextView: UITextView!
    @IBOutlet weak var theLoaiLabel: UILabel!
    
    var avatarPhoto:NSURL!
    var mangaPageLink:NSURL!
    var mangaName:String!
    var mangaStatusString:String!
    
    var jsonResult:NSDictionary!
    var authorString:String!
    var imageURL:NSURL!
    var numOfTranslators:String!
    var numOfChaps:String!
    var numOfViews:String!
    var mangTranslator:[String]!
    var mangCategory:[String]!
    var mangChapLinks:[String]!
    var mangaSummaryString:String!
    var chapNumContentDictionary:[NSDictionary]!
    
    var isDroppedDown:Bool! = false
    
    @IBAction func showViewHide(sender: AnyObject) {
        if isDroppedDown != true {
            moreLessBtn.setTitle("Less", forState: .Normal)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                let dropLength:CGFloat = self.viewHide.frame.height
                self.tableView.transform = CGAffineTransformTranslate(self.tableView.transform, 0 , dropLength)
            })
            isDroppedDown = true
        } else {
            moreLessBtn.setTitle("More", forState: .Normal)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                let rollLength:CGFloat = -self.viewHide.frame.height
                self.tableView.transform = CGAffineTransformTranslate(self.tableView.transform, 0 , rollLength)
            })
            isDroppedDown = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController?.hidesBarsOnTap = true
        
//        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, 0.01))
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        loadJson()

        // Do any additional setup after loading the view.
    }
    
    func loadJson() {
        
        let bodyData = "info=" + mangaPageLink.absoluteString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        print(bodyData)
        
        let url:NSURL = NSURL(string: "http://tlphu1989-001-site1.1tempurl.com/vnSharingVNChapterLink.php")!
        //let url:NSURL = NSURL(string: "http://localhost/laytintudong/vnSharingVNChapterLink.php")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if let urlData = data {
                do {
                    self.jsonResult = try NSJSONSerialization.JSONObjectWithData(urlData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    let jsonLoadedAmount = self.jsonResult.count
                    print(jsonLoadedAmount)
                    
                    if jsonLoadedAmount != 0 {
                        self.authorString = self.jsonResult["author"] as! String
                        self.mangTranslator = self.jsonResult["translator"] as! [String]
                        self.numOfTranslators = self.jsonResult["numOfTranslators"] as! String
                        self.numOfChaps = self.jsonResult["numOfChaps"] as! String
                        self.numOfViews = self.jsonResult["numOfViews"] as! String
                        self.mangaSummaryString = self.jsonResult["summary"] as! String
                        self.mangCategory = self.jsonResult["category"] as! [String]
                        self.chapNumContentDictionary = self.jsonResult["chapNumContent"] as! [NSDictionary]
                        for i in 0...self.chapNumContentDictionary.count-1 {
                            if i == 0 {
                                self.mangChapLinks = [String]()
                            }
                            self.mangChapLinks.append(self.chapNumContentDictionary[i]["chapLink"] as! String)
                        }
                    } else {
                        
                    }
                } catch {
                    
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.authorLabel.text = self.authorString
                self.numOfChapLabel.text = self.numOfChaps
                self.numOfViewsLabel.text = self.numOfViews
                self.numOfTranslatorsLabel.text = self.numOfTranslators
                self.mangaSummaryTextView.text = self.mangaSummaryString
                if self.mangaName != nil {
                    self.navigationItem.title = self.mangaName
                    self.mangaNameLabel.text = self.mangaName
                }
                
                if self.avatarPhoto != nil && self.avatarPhoto.absoluteString.isEmpty != true {
                    if let data:NSData = NSData(contentsOfURL: self.avatarPhoto)! {
                        self.imageView.image = UIImage(data: data)!
                    } else {
                        self.imageView.image = nil
                    }
                } else {
                    self.imageView.image = nil
                }
                
                if self.mangaStatusString != nil {
                    self.statusLabel.text = self.mangaStatusString
                }
                
                if self.mangCategory != nil {
                    if self.mangCategory.count != 0 {
                        var category = ""
                        for i in 0...self.mangCategory.count-1 {
                            if i == 0 {
                                category += "-"
                            }
                            category += self.mangCategory[i] + "-"
                        }
                        self.theLoaiLabel.text = category
                    }
                }
                
                if self.mangTranslator != nil {
                    if self.mangTranslator.count != 0 {
                        var translator = ""
                        for i in 0...self.mangTranslator.count-1 {
                            if i == 0 {
                                translator += "-"
                            }
                            translator += self.mangTranslator[i] + "-"
                        }
                        self.translatorsLabel.text = translator
                    }
                }
                self.tableView.reloadData()
            })
        }
        task.resume()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.chapNumContentDictionary == nil {
            return 0
        }
        
        return chapNumContentDictionary.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if self.chapNumContentDictionary != nil {
            cell.textLabel?.text = self.chapNumContentDictionary[indexPath.row]["chapTitle"] as? String
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            cell.textLabel?.font = UIFont.systemFontOfSize(12.0)
            cell.textLabel?.minimumScaleFactor = 0.1
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: animated)
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
//        self.navigationController?.setToolbarHidden(true, animated: true)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toChapContent" {
            let detailVC = segue.destinationViewController as! ChapContentViewController
            let selectedIndex = self.tableView.indexPathForCell(sender as! UITableViewCell)
            let row = selectedIndex?.row
            detailVC.mangChapLinks = self.mangChapLinks
            detailVC.chapPos = row
            detailVC.chapLinksDictionary = self.chapNumContentDictionary
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

}
