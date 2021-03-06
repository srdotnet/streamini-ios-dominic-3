//
//  CategoriesViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/9/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class DiscoverViewController:BaseTableViewController
{
    @IBOutlet var itemsTbl:UITableView?
    
    var allCategoriesArray=NSMutableArray()
    var recentStreamsArray=NSMutableArray()
    
    var menuItemTitlesArray=[]
    var menuItemIconsArray=[]
    var timer:NSTimer?
    
    override func viewDidLoad()
    {
        self.title=NSLocalizedString("Discover", comment:"")
        
        StreamConnector().categories(categoriesSuccess, failure:categoriesFailure)
        StreamConnector().homeStreams(successStreams, failure:categoriesFailure)
        
        timer=NSTimer(timeInterval:NSTimeInterval(2.0), target:self, selector:#selector(reload), userInfo:nil, repeats:true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode:NSRunLoopCommonModes)
    }
    
    func reload()
    {
        if(allCategoriesArray.count>0&&recentStreamsArray.count>0)
        {
            menuItemTitlesArray=["Charts", "New Releases", "Videos", "Podcasts", "Discover", "Concerts"]
            menuItemIconsArray=["user.png", "user.png", "user.png", "user.png", "user.png", "user.png"]
            
            itemsTbl?.reloadData()
            
            timer!.invalidate()
        }
    }
    
    override func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 3
    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if(section==0)
        {
            return 1
        }
        else if(section==1)
        {
            return 6
        }
        else
        {
            return allCategoriesArray.count
        }
    }
    
    override func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat
    {
        if(indexPath.section==0)
        {
            return 270
        }
        else if(indexPath.section==1)
        {
            return 50
        }
        else
        {
            return 210
        }
    }
    
    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        if(indexPath.section==0&&recentStreamsArray.count>0)
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("Recent") as! CategoryRow
            
            cell.oneCategoryItemsArray=recentStreamsArray[1] as! NSArray
            cell.navigationControllerReference=navigationController
            
            return cell
        }
        if(indexPath.section==1&&menuItemTitlesArray.count>0)
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("Menu") as! MenuCell
            
            cell.menuItemTitleLbl?.text=menuItemTitlesArray[indexPath.row] as? String
            cell.menuItemIconImageView?.image=UIImage(named:menuItemIconsArray[indexPath.row] as! String)
            
            return cell
        }
        if(indexPath.section==2)
        {
            let cell=tableView.dequeueReusableCellWithIdentifier("Category") as! AllCategoryRow
            
            cell.sectionItemsArray=allCategoriesArray[indexPath.row] as! NSArray
            cell.navigationControllerReference=navigationController
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:NSIndexPath)
    {
        if cell is AllCategoryRow
        {
            (cell as! AllCategoryRow).reloadCollectionView()
        }
    }
    
    func successStreams(data:NSDictionary)
    {
        let data=data["data"]!
        
        for i in 0 ..< data.count
        {
            let videos=data[i]["videos"] as! NSArray
            
            let oneCategoryItemsArray=NSMutableArray()
            
            for j in 0 ..< videos.count
            {
                let videoID=videos[j]["id"] as! String
                let videoTitle=videos[j]["title"] as! String
                let videoHash=videos[j]["hash"] as! String
                let lon=videos[j]["lon"]!.doubleValue
                let lat=videos[j]["lat"]!.doubleValue
                let city=videos[j]["city"] as! String
                let ended=videos[j]["ended"] as? String
                let viewers=videos[j]["viewers"] as! String
                let tviewers=videos[j]["tviewers"] as! String
                let rviewers=videos[j]["rviewers"] as! String
                let likes=videos[j]["likes"] as! String
                let rlikes=videos[j]["rlikes"] as! String
                let userID=videos[j]["user"]!["id"] as! String
                let userName=videos[j]["user"]!["name"] as! String
                let userAvatar=videos[j]["user"]!["avatar"] as? String
                
                let user=User()
                user.id=UInt(userID)!
                user.name=userName
                user.avatar=userAvatar
                
                let video=Stream()
                video.id=UInt(videoID)!
                video.title=videoTitle
                video.streamHash=videoHash
                video.lon=lon
                video.lat=lat
                video.city=city
                
                if let e=ended
                {
                    video.ended=NSDate(timeIntervalSince1970:Double(e)!)
                }
                
                video.viewers=UInt(viewers)!
                video.tviewers=UInt(tviewers)!
                video.rviewers=UInt(rviewers)!
                video.likes=UInt(likes)!
                video.rlikes=UInt(rlikes)!
                video.user=user
                
                oneCategoryItemsArray.addObject(video)
            }
            
            recentStreamsArray.addObject(oneCategoryItemsArray)
        }
    }
    
    func categoriesSuccess(cats:[Category])
    {
        var sectionItemsArray=NSMutableArray()
        var count=0
        
        for i in 0 ..< cats.count
        {
            sectionItemsArray.addObject(cats[i])
            
            count+=1
            
            if(count==2||(count==1&&i==cats.count-1))
            {
                count=0
                allCategoriesArray.addObject(sectionItemsArray)
                sectionItemsArray=NSMutableArray()
            }
        }
    }
    
    func categoriesFailure(error:NSError)
    {
        handleError(error)
    }
}
