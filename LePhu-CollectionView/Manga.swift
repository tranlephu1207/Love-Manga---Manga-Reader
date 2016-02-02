//
//  Manga.swift
//  LePhu-CollectionView
//
//  Created by Tran Le Phu on 12/28/15.
//  Copyright © 2015 LePhuTran. All rights reserved.
//

import UIKit

class Manga: NSObject {
    
    var name:String
    var chapter:String
    var photoURL:NSURL
    var mangaLink:NSURL
    var status:String!
    
    init(photo : NSURL, title : String, chapNum : String, link : NSURL, aTeam : String) {
        self.photoURL = photo
        self.chapter = chapNum
        self.name = title
        self.mangaLink = link
        self.status = aTeam
        super.init()
    }
    
    override init() {
        self.name = ""
        self.chapter = ""
        self.status = ""
        self.photoURL = NSURL()
        self.mangaLink = NSURL()
        super.init()
    }
    

}
