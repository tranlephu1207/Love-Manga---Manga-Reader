
//  ChapContentViewController.swift
//  LePhu-CollectionView
//
//  Created by Tran Le Phu on 1/1/16.
//  Copyright © 2016 LePhuTran. All rights reserved.
//

import UIKit
import iAd

class ChapContentViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, ADInterstitialAdDelegate {
    
    @IBOutlet weak var pageListShowBarBtn: UIBarButtonItem!
    @IBOutlet weak var prevChapBarBtn: UIBarButtonItem!
    @IBOutlet weak var nextChapBarBtn: UIBarButtonItem!
    @IBOutlet weak var pageIndicatorBarItem: UIBarButtonItem!
    var linkURL:String!
    var nexChapURL:String!
    var prevChapURL:String!
    var mangChapLinks:[String]!
    var chapLinksDictionary:[NSDictionary]!
    var chapPos:Int!

    var pageArray:NSMutableArray!
    var pageViewController:UIPageViewController!
    var pageControl:UIPageControl!
    var viewControllers:NSArray!
    var jsonResult:[NSDictionary]!
    
    var currentIndex:Int! = 0
    var nextIndex:Int!
    
    var numOfPages:Int!
    var label:UILabel!
    
    var isChangedChap:Bool! = false
    var isLoadingChap:Bool! = false
    
    var aView:UIView!
    var pickerView:UIPickerView!
    var selectedChapIndex:Int!
    var isShowPickerView:Bool! = false
    
    var loadingNewChapIndicator:UIActivityIndicatorView!
    
    var bannerView:UIView! = UIView()
    var interstitialAd:ADInterstitialAd!
    var closeButton:UIButton! = UIButton(type: .System)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.redColor(), NSFontAttributeName : UIFont.boldSystemFontOfSize(13)]

        
        setBannerView()
        createToolbarItems()
        
        numOfPages = 0
        
        if let link:NSString = (self.chapLinksDictionary[chapPos]["chapLink"] as! NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! {
            print(link)
            linkURL = link as String
        }
        
        self.pageArray = NSMutableArray()
        print(self.pageArray.count)
        
        loadJson(linkURL)
    }
    
    override func viewDidLayoutSubviews() {
        self.navigationItem.title = self.chapLinksDictionary[chapPos]["chapTitle"] as? String
        if self.aView != nil {
            self.view.bringSubviewToFront(aView)
        }
        if interstitialAd != nil {
            self.view.bringSubviewToFront(bannerView)
        }
    }
    
    func setBannerView() {
        interstitialAd = ADInterstitialAd()
        interstitialAd.delegate = self
        
        closeButton.frame = CGRectMake(20, 20, 70, 44)
        closeButton.layer.cornerRadius = 10
        // Give the close button some coloring layout:
        closeButton.backgroundColor = UIColor.whiteColor()
        closeButton.layer.borderColor = UIColor.blueColor().CGColor
        closeButton.layer.borderWidth = 1
        closeButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        // Wire up the closeAd function when the user taps the button
        closeButton.addTarget(self, action: "closeAd:", forControlEvents: UIControlEvents.TouchDown)
        // Some funkiness to get the title to display correctly every time:
        closeButton.enabled = false
        closeButton.setTitle("skip", forState: UIControlState.Normal)
        closeButton.enabled = true
        closeButton.setNeedsLayout()
        
    }
    
    func closeAd(sender: UIButton) {
        adFinished()
    }
    
    func adFinished() {
        closeButton.removeFromSuperview()
        bannerView.removeFromSuperview()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func interstitialAdWillLoad(interstitialAd: ADInterstitialAd!) {
        
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        bannerView = UIView()
        bannerView.frame = self.view.bounds
        view.addSubview(bannerView)

        interstitialAd.presentInView(bannerView)
        UIViewController.prepareInterstitialAds()

        bannerView.addSubview(closeButton)
    }
    
    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
        bannerView.removeFromSuperview()
    }
    
    func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        bannerView.removeFromSuperview()
    }
    
    func createPageViewController() {
        if isChangedChap == false {
            self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MyPageViewController") as! UIPageViewController
            
            self.pageViewController.dataSource = self
            self.pageViewController.delegate = self
            let initialContentViewController = self.pageAtIndex(0) as PageContentHolderViewController
            self.viewControllers = NSArray(object: initialContentViewController)
            self.pageViewController.setViewControllers(self.viewControllers as! [PageContentHolderViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
            self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            self.addChildViewController(self.pageViewController)
            self.view.addSubview(self.pageViewController.view)
            self.pageViewController.didMoveToParentViewController(self)
        } else {
            
            self.setBannerView()
            checkBarItemsEnabled()
            self.pageViewController.dataSource = nil
            self.pageViewController.dataSource = self
            let initialContentViewController = self.pageAtIndex(0) as PageContentHolderViewController
            self.viewControllers = NSArray(object: initialContentViewController)
            self.pageViewController.setViewControllers(self.viewControllers as! [PageContentHolderViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
            
            currentIndex = 0
            if self.isChangedChap == true {
                self.isChangedChap = false
            }
            
        }
    }

    
    func loadJson(link:String) {
        
        let bodyData = "info=" + String(link)
        print(bodyData)
        
        let url:NSURL = NSURL(string: "http://tlphu1989-001-site1.1tempurl.com/vnSharingVNLoadPhoto.php")!
//        let url:NSURL = NSURL(string: "http://localhost/laytintudong/vnSharingVNLoadPhoto.php")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if let urlData = data {
                do {
                    self.jsonResult = try NSJSONSerialization.JSONObjectWithData(urlData, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                    self.numOfPages = self.jsonResult.count
                    print(self.numOfPages)
                    
                    if self.isChangedChap == false {
                        for i in 0...self.numOfPages-1 {
                            if self.isChangedChap == false {
                                self.pageArray.insertObject("photo1", atIndex: i)
                            }
                        }
                    } else {
                        self.pageArray.removeAllObjects()
                        print(self.pageArray.count)
                        for i in 0...self.numOfPages-1 {
                            self.pageArray.insertObject("photo1", atIndex: i)
                        }
                    }
                    
                    if self.numOfPages != 0 {
                        for i in 0...self.numOfPages-1 {
                            let link:NSString = (self.jsonResult[i]["photo"] as! NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                            if let url:NSURL = NSURL(string: link as String)! {
                                self.pageArray.replaceObjectAtIndex(i, withObject: url)
                            } else {
                                print("avatarPhoto nil")
                            }
                        }
                    } else {
                        
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        print(self.pageArray.count)
                        self.createPageViewController()
                        self.label.text = "1/\(self.numOfPages)"
                        if self.isLoadingChap == true {
                            self.isLoadingChap = false
                        }
                        if self.loadingNewChapIndicator.isAnimating() {
                            self.loadingNewChapIndicator.stopAnimating()
                        }
                    })
                } catch {
                    
                }
            }
        }
        task.resume()
        
        
    }
    
    
    func createToolbarItems() {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
        label.textAlignment = .Left
        label.text = "0/0"
        label.font.fontWithSize(11)
        label.textColor = UIColor.redColor()
        label.backgroundColor = UIColor.clearColor()
        pageIndicatorBarItem.customView = label
        pageIndicatorBarItem.imageInsets = UIEdgeInsets(top: 0, left: -25, bottom: 0, right: 0)
        
        nextChapBarBtn.action = "loadNextChap"
        nextChapBarBtn.target = self
        
        prevChapBarBtn.action = "loadPrevChap"
        prevChapBarBtn.target = self
    
        let searchChapBarItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "showChapterPickerView")
        
        loadingNewChapIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadingNewChapIndicator.frame = CGRectMake(0, 0, 30, 30)
        loadingNewChapIndicator.startAnimating()
        let loadingNewChapBarItem:UIBarButtonItem = UIBarButtonItem(customView: loadingNewChapIndicator)
        self.navigationItem.rightBarButtonItems = [searchChapBarItem, loadingNewChapBarItem]
        
        checkBarItemsEnabled()
    }
    
    func showChapterPickerView() {

        isShowPickerView = true
        checkBarItemsAfterPickerView()
        
        aView = UIView(frame: self.view.frame)
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/2))
        pickerView.center = self.view.center
        pickerView.backgroundColor = UIColor.whiteColor()
        aView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        aView.addSubview(pickerView)
        self.view.addSubview(aView)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerView.selectRow(chapPos, inComponent: 0, animated: false)
        selectedChapIndex = chapPos
        
        let okBtn:UIButton = UIButton(type: .System)
        okBtn.frame = CGRectMake(pickerView.frame.midX + 20, pickerView.frame.maxY + 10, 100, 50)
        okBtn.layer.cornerRadius = 10
        // Give the close button some coloring layout:
        okBtn.backgroundColor = UIColor.whiteColor()
        okBtn.layer.borderColor = UIColor.blueColor().CGColor
        okBtn.layer.borderWidth = 1
        okBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        // Wire up the closeAd function when the user taps the button
        okBtn.addTarget(self, action: "moveToChap", forControlEvents: UIControlEvents.TouchDown)
        // Some funkiness to get the title to display correctly every time:
        okBtn.enabled = false
        okBtn.setTitle("Okay", forState: UIControlState.Normal)
        okBtn.enabled = true
        okBtn.setNeedsLayout()
        aView.addSubview(okBtn)
        
        let cancelBtn:UIButton = UIButton(type: .System)
        cancelBtn.frame = CGRectMake(pickerView.frame.midX - 120, pickerView.frame.maxY + 10, 100, 50)
        cancelBtn.layer.cornerRadius = 10
        // Give the close button some coloring layout:
        cancelBtn.backgroundColor = UIColor.whiteColor()
        cancelBtn.layer.borderColor = UIColor.blueColor().CGColor
        cancelBtn.layer.borderWidth = 1
        cancelBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        // Wire up the closeAd function when the user taps the button
        cancelBtn.addTarget(self, action: "cancelPickerView", forControlEvents: UIControlEvents.TouchDown)
        // Some funkiness to get the title to display correctly every time:
        cancelBtn.enabled = false
        cancelBtn.setTitle("Cancel", forState: UIControlState.Normal)
        cancelBtn.enabled = true
        cancelBtn.setNeedsLayout()
        aView.addSubview(cancelBtn)
    }
    
    func checkBarItemsAfterPickerView() {
        if isShowPickerView == true {
            self.navigationItem.rightBarButtonItems![0].enabled = false
            nextChapBarBtn.enabled = false
            prevChapBarBtn.enabled = false
            pageListShowBarBtn.enabled = false
        } else {
            self.navigationItem.rightBarButtonItems![0].enabled = true
            nextChapBarBtn.enabled = true
            prevChapBarBtn.enabled = true
            pageListShowBarBtn.enabled = true
        }
    }
    
    func moveToChap() {
        if isLoadingChap != true && chapPos != selectedChapIndex {
            isShowPickerView = false
            checkBarItemsAfterPickerView()
            loadingNewChapIndicator.startAnimating()
            isLoadingChap = true
            chapPos = selectedChapIndex
            if let link:NSString = (self.chapLinksDictionary[chapPos]["chapLink"] as! NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! {
                print(link)
                self.nexChapURL = link as String
            }
            if self.nexChapURL != nil {
                isChangedChap = true
                aView.removeFromSuperview()
                loadJson(self.nexChapURL)
            }
        } else if isLoadingChap != true && chapPos == selectedChapIndex {
            cancelPickerView()
        }
    }
    
    func cancelPickerView() {
        isShowPickerView = false
        checkBarItemsAfterPickerView()
        aView.removeFromSuperview()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.chapLinksDictionary.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.chapLinksDictionary[row]["chapTitle"] as? String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedChapIndex = row
    }
    
    func checkBarItemsEnabled() {
//        print(self.chapPos)
//        print(self.mangChapLinks.count-1)
        if chapPos == 0 {
            if self.mangChapLinks.count != 1 {
                nextChapBarBtn.enabled = false
            } else if self.mangChapLinks.count == 1 {
                nextChapBarBtn.enabled = false
                prevChapBarBtn.enabled = false
            }
        } else if chapPos == self.mangChapLinks.count-1 {
            prevChapBarBtn.enabled = false
        } else {
            nextChapBarBtn.enabled = true
            prevChapBarBtn.enabled = true
        }
    }
    
    func loadNextChap() {
        if isLoadingChap != true {
            loadingNewChapIndicator.startAnimating()
            isLoadingChap = true
            if self.chapPos > 0 {
                self.chapPos = self.chapPos - 1
            }
            if let link:NSString = (self.chapLinksDictionary[chapPos]["chapLink"] as! NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! {
                print(link)
                self.nexChapURL = link as String
            }
            if self.nexChapURL != nil {
                isChangedChap = true
                loadJson(self.nexChapURL)
            }
        }
    }
    
    func loadPrevChap() {
        if isLoadingChap != true {
            loadingNewChapIndicator.startAnimating()
            isLoadingChap = true
            if self.chapPos < self.mangChapLinks.count-1 {
                self.chapPos = self.chapPos + 1
            }

            if let link:NSString = (self.chapLinksDictionary[chapPos]["chapLink"] as! NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! {
                print(link)
                self.prevChapURL = link as String
            }
            if self.prevChapURL != nil {
                isChangedChap = true
                loadJson(self.prevChapURL)
            }
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//        self.navigationController?.setToolbarHidden(true, animated: animated)
//        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.hidesBarsOnSwipe = true

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            currentIndex = nextIndex
            print(currentIndex)
            label.text = "\(currentIndex+1)/\(self.numOfPages)"
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if let pageContentHolderViewController:PageContentHolderViewController = pendingViewControllers[0] as? PageContentHolderViewController {
            nextIndex = pageContentHolderViewController.pageIndex
        }
    }
    
    func pageAtIndex(index: Int) -> PageContentHolderViewController {
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentHolderViewController") as! PageContentHolderViewController
        
        if let link = pageArray[index] as? NSURL {
            pageContentViewController.imageFileName = link
            
            var image:UIImage!
            
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: link)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                
                if let urlData = data {
                    image = UIImage(data: urlData)!
                    self.pageArray.replaceObjectAtIndex(index, withObject: image)
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    pageContentViewController.imageView.image = image
                    if pageContentViewController.loadingIndicator.isAnimating() {
                        pageContentViewController.loadingIndicator.stopAnimating()
                    }
                })

            }
            task.resume()
        }
        else if let image = pageArray[index] as? UIImage {
            pageContentViewController.image = image
        }

        pageContentViewController.pageIndex = index
        
        return pageContentViewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as! PageContentHolderViewController
        var index = viewController.pageIndex as Int
        
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        
        index--
        
        return self.pageAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as! PageContentHolderViewController
        var index = viewController.pageIndex as Int
        
        if (index == NSNotFound) {
            return nil
        }
        
        index++

        if(index == pageArray.count) {
            return nil
        }
        
        return self.pageAtIndex(index)
    }
    
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageArray.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.currentIndex
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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


//Extension for UIImageView cover all UIPageViewController - PageControl becomes transparent
extension UIPageViewController {
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let subViews: NSArray = view.subviews
        var scrollView: UIScrollView? = nil
        var pageControl: UIPageControl? = nil
        
        for view in subViews {
            if view.isKindOfClass(UIScrollView) {
                scrollView = view as? UIScrollView
            }
            else if view.isKindOfClass(UIPageControl) {
                pageControl = view as? UIPageControl
            }
        }
        
        if (scrollView != nil && pageControl != nil) {
            scrollView?.frame = view.bounds
            view.bringSubviewToFront(pageControl!)
        }
    }
}