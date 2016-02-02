//
//  MangaCollectionViewController.swift
//  LePhu-CollectionView
//
//  Created by Tran Le Phu on 12/9/15.
//  Copyright © 2015 LePhuTran. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MangaCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var width:CGFloat!
    var height:CGFloat!
    
    var loadingIndicator:UIActivityIndicatorView!
    
    var mangPhotoUrl:[NSURL]! = [NSURL]()
    var mangTitle:[String]! = [String]()
    var mangChapter:[String]! = [String]()
    var mangTeam:[String]! = [String]()
    var mangLink:[NSURL]! = [NSURL]()
    var cachedImages:NSMutableDictionary = NSMutableDictionary()
    var jsonResult:NSDictionary!
    var pageNum:Int! = 1
    
    var isLoadedFull:Bool! = false
    var isLoading:Bool! = false
    
    var mangManga:[Manga]! = [Manga]()
    
    private let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)

    @IBAction func searchBarBtn(sender: AnyObject) {
        
//        self.navigationItem.rightBarButtonItem = nil
//        var searchDispCont = UISearchDisplayController(searchBar: searchBar, contentsController: nil)
//        var searchDispCont = UISearchDisplayController(searchBar: searchBar, contentsController: <#T##UIViewController#>)
//
//        self.navigationController?.navigationBar.addSubview(searchDispCont.searchBar)
//        
//        searchDispCont.searchBar.showsCancelButton = true
//        searchDispCont.searchBar.tintColor = UIColor.lightGrayColor()
//        searchDispCont.displaysSearchBarInNavigationBar = true
//        searchDispCont.searchBar.becomeFirstResponder()
//        searchDispCont.setActive(true, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkDeviceType()
    
        createLoadingIndicator()
        
        loadJson()
        
    }
    
    func checkDeviceType() {
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Phone:
            width = self.view.frame.width/2 - 10
            height = width * 1.2
            break
            
        case .Pad:
            width = self.view.frame.width/3 - 10
            height = width * 1.2
            break
            
        case .Unspecified:
            width = self.view.frame.width/2 - 10
            height = width * 1.2
            break
            
        default:
            
            break
        }
    }
    
    func createLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        loadingIndicator.center = self.view.center
        loadingIndicator.startAnimating()
        loadingIndicator.frame.size = CGSize(width: 100, height: 100)
        loadingIndicator.center = self.view.center
        loadingIndicator.layer.backgroundColor = UIColor.grayColor().CGColor
        loadingIndicator.layer.cornerRadius = 8.0
        loadingIndicator.clipsToBounds = true
        
        self.view.addSubview(loadingIndicator)
    }
    
    func loadJson() {
        if isLoadedFull != true {
            let bodyData = "info=" + String(pageNum)
            print(bodyData)
            
            let URL: NSURL = NSURL(string: "http://tlphu1989-001-site1.1tempurl.com/jsonVnSharingVNMoiCapNhatPOST2.php")!
//            let URL: NSURL = NSURL(string: "http://localhost/laytintudong/jsonVnSharingVNMoiCapNhatPOST2.php")!
            let request:NSMutableURLRequest = NSMutableURLRequest(URL:URL)
            request.HTTPMethod = "POST"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                
                if let urlData = data {
                    do {
                        self.jsonResult = try NSJSONSerialization.JSONObjectWithData(urlData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        
                        let jsonResult2 = self.jsonResult["aManga"]! as! [NSDictionary]
                        let jsonLoadedAmount = jsonResult2.count
                        print(jsonLoadedAmount)

                        if jsonLoadedAmount != 0 {
                            for i in 0...jsonLoadedAmount-1 {
                                let title = jsonResult2[i]["title"] as! String
                                let chapter = jsonResult2[i]["chapter"] as! String
                                let team = jsonResult2[i]["status"] as! String
                                let link:NSString = (jsonResult2[i]["link"] as! NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                                if let linkURL = NSURL(string: String(link)) {
                                    let photoLink:NSString = (jsonResult2[i]["photoURL"] as! NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                                    if let photoURL = NSURL(string: String(photoLink)) {
                                        
                                        self.mangManga.append(Manga(photo: photoURL, title: title, chapNum: chapter, link: linkURL, aTeam: team))
                                        
                                    } else {
                                        print("photoURL error")
                                    }
                                } else {
                                    print("linkURL error")
                                }
                                
                                
                            }
                        } else {
                            self.isLoadedFull = true
                        }
                    } catch {
                        
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView!.reloadData()
                    self.navigationController?.navigationBarHidden = false
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.removeFromSuperview()
                    if self.isLoading == true {
                        self.isLoading = false
                    }
                }
            })
            task.resume()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        if mangManga.count == 0 {
            return 0
        } else if mangManga.count % 2 == 1 {
            return mangManga.count - 1
        }
        
        return mangManga.count
        
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MangaCollectionViewCell
        
        // Configure the cell
        
//        cell.view.frame.size = CGSize(width: cell.view.frame.width, height: cell.view.frame.height/2)
        
        cell.loadingIndicator.hidesWhenStopped = true
        cell.loadingIndicator.startAnimating()
        
        cell.imageView.image = nil

        cell.label.text = self.mangManga[indexPath.item].name
        cell.chapterLabel.text = self.mangManga[indexPath.item].chapter
        cell.teamLabel.text = self.mangManga[indexPath.item].status
        
        if let image:UIImage = cachedImages.objectForKey(mangManga[indexPath.item].photoURL.absoluteString) as? UIImage {
            cell.imageView.image = image
            cell.loadingIndicator.stopAnimating()
        } else {
            if let url:NSURL = mangManga[indexPath.item].photoURL {
                let request:NSURLRequest = NSURLRequest(URL: url)
                
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                    
                    if data != nil {
                        if let image = UIImage(data: data!) {
                            let width =  cell.imageView.frame.size.width / image.size.width
                            let height =  cell.imageView.frame.size.height / image.size.height
                            let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(width, height))
                            let hasAlpha = false
                            let scale:CGFloat = 0.0
                            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
                            image.drawInRect(CGRect(origin: CGPointZero, size: size))
                            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                            self.cachedImages.setObject(scaledImage, forKey: url.absoluteString)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                if let updateCell:MangaCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as? MangaCollectionViewCell {
                                    updateCell.imageView.image = scaledImage
                                    cell.loadingIndicator.stopAnimating()
                                }
                            })
                        }
                    }
                })
                task.resume()
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSize(width: self.view.frame.width/2 - 10, height: self.view.frame.height/3)
        return CGSize(width: width, height: height)
//        return CGSize(width: self.view.frame.width, height: self.view.frame.height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset:CGPoint = scrollView.contentOffset
        let bounds:CGRect = scrollView.bounds
        let size:CGSize = scrollView.contentSize
        let inset:UIEdgeInsets = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        let reload_distance:CGFloat = 20
        if y > h + reload_distance {
            if isLoading != true {
                isLoading = true
                print("load more rows")
                pageNum = pageNum + 1
                loadJson()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toChapterList" {
            let detailVC = segue.destinationViewController as! ChapterListViewController
            let selectedIndex = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell)
            let itemNum = selectedIndex?.item
            detailVC.mangaName = self.mangManga[itemNum!].name
            detailVC.mangaPageLink = self.mangManga[itemNum!].mangaLink
            if let photo:NSURL = self.mangManga[itemNum!].photoURL {
                print(photo)
                detailVC.avatarPhoto = photo
            } else {
                print("error")
            }
            detailVC.mangaStatusString = self.mangManga[itemNum!].status
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
//        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.hidesBarsOnSwipe = false

        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
