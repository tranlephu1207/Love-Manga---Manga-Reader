//
//  PageContentHolderViewController.swift
//  LePhu-CollectionView
//
//  Created by Tran Le Phu on 1/1/16.
//  Copyright © 2016 LePhuTran. All rights reserved.
//

import UIKit

class PageContentHolderViewController: UIViewController, UIScrollViewDelegate {

    var scrollView: UIScrollView!
    var imageView:UIImageView!
    var imageFileName:NSURL!
    var pageIndex:Int!
    
    var image:UIImage!
    var loadingIndicator:UIActivityIndicatorView!
    
//    var isLoadedImage:Bool! = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        print(pageIndex)
        setScrollView()
        createLoadingIndicator()
        
        print(pageIndex)
        if image == nil {
//            if imageFileName != nil {
//                let request:NSMutableURLRequest = NSMutableURLRequest(URL: imageFileName)
//                let session = NSURLSession.sharedSession()
//                let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
//                    
//                    if let urlData:NSData = data {
//                        self.image = UIImage(data: urlData)!
//                    }
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        self.imageView.image = self.image
//                        if self.loadingIndicator.isAnimating() {
//                            self.loadingIndicator.stopAnimating()
//                        }
//                    })
//                }
//                task.resume()
//            }
        } else if image != nil {
            imageView.image = image
            if self.loadingIndicator.isAnimating() {
                self.loadingIndicator.stopAnimating()
            }
        }
    }
    
    func setScrollView() {
        scrollView = UIScrollView(frame: view.bounds)
//        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50))
        imageView = UIImageView(frame: CGRectMake(0, 0, scrollView.frame.width, scrollView.frame.height))
        imageView.contentMode = .ScaleAspectFit
        
        scrollView.backgroundColor = UIColor.clearColor()
//        scrollView.contentSize = imageView.frame.size
        scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.automaticallyAdjustsScrollViewInsets = false
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        scrollView.delegate = self
        setZoomScale()
        setupGestureRecognizer()
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
    
    override func viewWillLayoutSubviews() {
//        if image != nil {
//            imageView.image = image
////            self.view.reloadInputViews()
////            if imageView != nil {
////                imageView.image = image
////            } else {
////                imageView = UIImageView(image: image)
////            }
////            self.reloadInputViews()
//            setZoomScale()
//        }
        scrollView.contentSize = imageView.frame.size
        setZoomScale()
    }
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        let zoomScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = zoomScale
        scrollView.maximumZoomScale = 1.5
        scrollView.zoomScale = zoomScale
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
