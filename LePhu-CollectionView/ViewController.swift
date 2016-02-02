//
//  ViewController.swift
//  LePhu-CollectionView
//
//  Created by Tran Le Phu on 12/9/15.
//  Copyright © 2015 LePhuTran. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var mangUrl:[NSURL]! = [NSURL]()
    var mangTitle:[String]! = [String]()
    var mangChapter:[String]! = [String]()
    var mangTeam:[String]! = [String]()
    var mangLink:[NSURL]! = [NSURL]()
    var cachedImages:NSMutableDictionary = NSMutableDictionary()
    var jsonResult:[NSDictionary]!
    var pageNum:Int! = 1
    
    var isLoadedFull:Bool! = false
    
    private let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        searchBar.frame.size = CGSize(width: self.view.frame.width, height: 10)
        
        loadJson()
    }
    
    func loadJson() {
//        if isLoadedFull != true {
            let bodyData = "info=" + String(pageNum)
            print(bodyData)
            
            let URL: NSURL = NSURL(string: "http://localhost/laytintudong/jsonVnSharingMoiCapNhatPOST.php")!
//             let URL: NSURL = NSURL(string: "http://tlphu1989-001-site1.1tempurl.com/jsonVnSharingVNMoiCapNhatPOST2.php")!
            //let URL: NSURL = NSURL(string: "http://tlphu1989-001-site1.1tempurl.com/jsonVnSharingMoiCapNhatPOST.php")!
            let request:NSMutableURLRequest = NSMutableURLRequest(URL:URL)
            request.HTTPMethod = "POST"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                
                if let urlData = data {
                    do {
                        self.jsonResult = try NSJSONSerialization.JSONObjectWithData(urlData, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                        let jsonLoadedAmount = self.jsonResult.count
                        //print(self.jsonResult)
                        print(jsonLoadedAmount)
                        
                        if jsonLoadedAmount != 0 {
                            for i in 0...jsonLoadedAmount-1 {
                                self.mangUrl.append(NSURL(string: self.jsonResult![i]["tenManga"] as! String)!)
                                self.mangTitle.append(self.jsonResult![i]["title"] as! String)
                                self.mangChapter.append(self.jsonResult![i]["chapter"] as! String)
                                self.mangTeam.append(self.jsonResult![i]["team"] as! String)
                                
                                var link:NSString = self.jsonResult![i]["link"] as! NSString
                                link = link.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
                                if let link = NSURL(string: String(link)) {
                                    self.mangLink.append(link)
                                } else {
                                    print(i)
                                }
                            }
                        }
                    } catch {
                        
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView!.reloadData()
                }
            })
            task.resume()
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if mangUrl.count == 0 {
            return 0
        }
        return mangUrl.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MangaCollectionViewCell
        
        // Configure the cell
        
        cell.imageView.image = nil
        cell.label.text = self.mangTitle[indexPath.item]
        cell.chapterLabel.text = self.mangChapter[indexPath.item]
        cell.teamLabel.text = self.mangTeam[indexPath.item]
        
        if let image:UIImage = cachedImages.objectForKey(mangUrl[indexPath.item].absoluteString) as? UIImage {
            cell.imageView.image = image
        } else {
            if let url:NSURL = mangUrl[indexPath.item] {
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
        return CGSize(width: self.view.frame.width/2 - 10, height: 200)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isLoadedFull != true {
            let offset:CGPoint = scrollView.contentOffset
            let bounds:CGRect = scrollView.bounds
            let size:CGSize = scrollView.contentSize
            let inset:UIEdgeInsets = scrollView.contentInset
            let y = offset.y + bounds.size.height - inset.bottom
            let h = size.height
            let reload_distance:CGFloat = 20
            if y > h + reload_distance {
                print("load more rows")
                pageNum = pageNum + 1
                loadJson()
            }
            if jsonResult.count == 0 {
                isLoadedFull = true
            }
        } else {
            print("Fully loaded!!!")
        }
        
    }
}

