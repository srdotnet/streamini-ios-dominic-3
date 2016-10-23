//
//  UserViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 30/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

protocol UserSelecting: class {
    func userDidSelected(user: User)
}

protocol StreamSelecting: class {
    func streamDidSelected(stream: Stream)
}

protocol UserStatisticsDelegate: class {
    func recentStreamsDidSelected(userId: UInt)
    func followersDidSelected(userId: UInt)
    func followingDidSelected(userId: UInt)
}

protocol UserStatusDelegate: class {
    func followStatusDidChange(status: Bool, user: User)
    func blockStatusDidChange(status: Bool, user: User)
}

class UserViewController: BaseViewController, ProfileDelegate
{
    @IBOutlet var userHeaderView:UserHeaderView!
    @IBOutlet var recentCountLabel:UILabel!
    @IBOutlet var recentLabel:UILabel!
    @IBOutlet var followersCountLabel:UILabel!
    @IBOutlet var followersLabel:UILabel!
    @IBOutlet var followingCountLabel:UILabel!
    @IBOutlet var followingLabel:UILabel!
    @IBOutlet var followButton:UIButton!
    @IBOutlet var blockButton:UIButton!
    @IBOutlet var activityIndicator:UIActivityIndicatorView!
    
    var user:User?
    var userStatisticsDelegate:UserStatisticsDelegate?
    var userStatusDelegate:UserStatusDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configureView()
        update(user!.id)
    }
    
    func configureView()
    {
        let recentLabelText=NSLocalizedString("user_card_recent", comment:"")
        recentLabel.text=recentLabelText
        
        let followersLabelText=NSLocalizedString("user_card_followers", comment:"")
        followersLabel.text=followersLabelText
        
        let followingLabelText=NSLocalizedString("user_card_following", comment:"")
        followingLabel.text=followingLabelText
        
        followButton.hidden=UserContainer.shared.logged().id==user!.id
        blockButton.hidden=UserContainer.shared.logged().id==user!.id
    }

    @IBAction func recentButtonPressed()
    {
        if let del=userStatisticsDelegate
        {
            del.recentStreamsDidSelected(user!.id)
        }
    }
    
    @IBAction func followersButtonPressed()
    {
        if let del=userStatisticsDelegate
        {
            del.followersDidSelected(user!.id)
        }
    }
    
    @IBAction func followingButtonPressed()
    {
        if let del=userStatisticsDelegate
        {
            del.followingDidSelected(user!.id)
        }
    }
    
    @IBAction func followButtonPressed()
    {
        followButton.enabled=false
        
        if user!.isFollowed
        {
            SocialConnector().unfollow(user!.id, success:unfollowSuccess, failure:unfollowFailure)
        }
        else
        {
            SocialConnector().follow(user!.id, success:followSuccess, failure:followFailure)
        }
    }
    
    @IBAction func blockButtonPressed()
    {
        blockButton.enabled=false
        
        if user!.isBlocked
        {
            SocialConnector().unblock(user!.id, success:unblockSuccess, failure:unblockFailure)
        }
        else
        {
            SocialConnector().block(user!.id, success:blockSuccess, failure:blockFailure)
        }
    }
    
    func reload()
    {
        update(user!.id)
    }
    
    func close()
    {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let sid = segue.identifier {
            if sid == "UserToLinkedUsers" {
                let controller = segue.destinationViewController as! LinkedUsersViewController
                controller.profileDelegate = self
                self.userStatisticsDelegate = controller
            }
        }
    }
    
    func followSuccess()
    {
        followButton.enabled=true
        user!.isFollowed=true
        
        let buttonTitle=NSLocalizedString("user_card_unfollow", comment:"")
        followButton.setTitle(buttonTitle, forState:.Normal)
        
        if let delegate=userStatusDelegate
        {
            delegate.followStatusDidChange(true, user:user!)
        }
        
        update(user!.id)
    }
    
    func followFailure(error:NSError)
    {
        handleError(error)
        followButton.enabled=true
    }
    
    func unfollowSuccess()
    {
        followButton.enabled=true
        user!.isFollowed=false
        
        let buttonTitle=NSLocalizedString("user_card_follow", comment:"")
        followButton.setTitle(buttonTitle, forState:.Normal)
        
        if let delegate=userStatusDelegate
        {
            delegate.followStatusDidChange(false, user:user!)
        }
        
        update(user!.id)
    }
    
    func unfollowFailure(error:NSError)
    {
        handleError(error)
        followButton.enabled=true
    }
    
    func blockSuccess()
    {
        blockButton.enabled=true
        user!.isBlocked=true
        
        let buttonTitle=NSLocalizedString("user_card_unblock", comment:"")
        blockButton.setTitle(buttonTitle, forState:.Normal)
        
        if let delegate=userStatusDelegate
        {
            delegate.blockStatusDidChange(true, user:user!)
        }
    }
    
    func blockFailure(error:NSError)
    {
        handleError(error)
        blockButton.enabled=true
    }
    
    func unblockSuccess()
    {
        blockButton.enabled=true
        user!.isBlocked=false
        
        let buttonTitle=NSLocalizedString("user_card_block", comment:"")
        blockButton.setTitle(buttonTitle, forState:.Normal)
        
        if let delegate=userStatusDelegate
        {
            delegate.blockStatusDidChange(false, user:user!)
        }
    }
    
    func unblockFailure(error:NSError)
    {
        handleError(error)
        blockButton.enabled=true
    }
    
    func getUserSuccess(user:User)
    {
        self.user=user
        
        userHeaderView.update(user)
        recentCountLabel.text="\(user.recent)"
        followersCountLabel.text="\(user.followers)"
        followingCountLabel.text="\(user.following)"
        
        if user.isFollowed
        {
            let buttonTitle=NSLocalizedString("user_card_unfollow", comment:"")
            followButton.setTitle(buttonTitle, forState:.Normal)
        }
        else
        {
            let buttonTitle=NSLocalizedString("user_card_follow", comment:"")
            followButton.setTitle(buttonTitle, forState:.Normal)
        }
        
        if user.isBlocked
        {
            let buttonTitle=NSLocalizedString("user_card_unblock", comment:"")
            blockButton.setTitle(buttonTitle, forState:.Normal)
        }
        else
        {
            let buttonTitle=NSLocalizedString("user_card_block", comment:"")
            blockButton.setTitle(buttonTitle, forState:.Normal)
        }
        
        activityIndicator.stopAnimating()
    }
    
    func getUserFailure(error:NSError)
    {
        handleError(error)
        activityIndicator.stopAnimating()
    }
    
    func update(userId:UInt)
    {
        activityIndicator.startAnimating()
        UserConnector().get(userId, success:getUserSuccess, failure:getUserFailure)
    }
}
