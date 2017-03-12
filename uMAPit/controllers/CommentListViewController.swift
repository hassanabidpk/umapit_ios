//
//  CommentListViewController.swift
//  uMAPit
//
//  Created by Hassan Abid on 04/03/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift
import Kingfisher
import Alamofire
import SlackTextViewController

#if DEBUG
let COMMENTS_LIST_URL = "http://localhost:8000/place/api/v1/comments/"
#else
let COMMENTS_LIST_URL = "https://umapit.azurewebsites.net/place/api/v1/comments/"
#endif

class CommentListViewController: SLKTextViewController {

    
    //MARK : - Propeties
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    var realm: Realm!
    var commentsResult: Results<Comment>?
    
    var notificationToken: NotificationToken?
    
    var commentPlace: Place?
    
    var pipWindow: UIWindow?
    
    override var tableView: UITableView {
        get {
            return super.tableView!
        }
    }

    // MARK: - Initialisation
    
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        
        return .plain
    }
    
    func commonInit() {
        
        NotificationCenter.default.addObserver(self.tableView, selector: #selector(UITableView.reloadData), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        NotificationCenter.default.addObserver(self,  selector: #selector(CommentListViewController.textInputbarDidMove(_:)), name: NSNotification.Name.SLKTextInputbarDidMove, object: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.commonInit()
        
        setUI()
        
        realm = try! Realm()
        
        // Set realm notification block
        notificationToken = realm.addNotificationBlock { [unowned self] note, realm in
            self.tableView.reloadData()
        }
        
        getPlaceComments()
    }
    
    func setUI() {
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.tableView.backgroundView = activityIndicatorView
        
        
        // SLKTVC's configuration
        self.bounces = true
        self.shakeToClearEnabled = true
        self.isKeyboardPanningEnabled = true
        self.shouldScrollToBottomAfterKeyboardShows = false
        self.isInverted = false
        
        self.leftButton.setImage(UIImage(named: "icn_upload"), for: UIControlState())
        self.leftButton.tintColor = UIColor.gray
        
        self.rightButton.setTitle(NSLocalizedString("Send", comment: ""), for: UIControlState())
        
        self.textInputbar.autoHideRightButton = true
        self.textInputbar.maxCharCount = 256
        self.textInputbar.counterStyle = .split
        self.textInputbar.counterPosition = .top
        
        self.textInputbar.editorTitle.textColor = UIColor.darkGray
        self.textInputbar.editorLeftButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        self.textInputbar.editorRightButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        
        
        self.tableView.separatorStyle = .none
        
        self.tableView.register(MessageTableViewCell.classForCoder(), forCellReuseIdentifier: CommentCellIdentifier)
        
        self.autoCompletionView.register(MessageTableViewCell.classForCoder(), forCellReuseIdentifier: AutoCompletionCellIdentifier)
        self.registerPrefixes(forAutoCompletion: ["@",  "#", ":", "+:", "/"])
        
        self.textView.placeholder = "Add a comment...";
        
        self.textView.registerMarkdownFormattingSymbol("*", withTitle: "Bold")
        self.textView.registerMarkdownFormattingSymbol("_", withTitle: "Italics")
        self.textView.registerMarkdownFormattingSymbol("~", withTitle: "Strike")
        self.textView.registerMarkdownFormattingSymbol("`", withTitle: "Code")
        self.textView.registerMarkdownFormattingSymbol("```", withTitle: "Preformatted")
        self.textView.registerMarkdownFormattingSymbol(">", withTitle: "Quote")
        
    }

    
    // MARK: - UITableViewDataSource Methods
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return self.commentCellForRowAtIndexPath(indexPath)

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let result = commentsResult {
            return result.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if tableView == self.tableView {
            
                if let result = commentsResult  {
                    let comment = result[indexPath.row]
            
                let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineBreakMode = .byWordWrapping
                    paragraphStyle.alignment = .left
            
                let pointSize = MessageTableViewCell.defaultFontSize()
            
                let attributes = [
                NSFontAttributeName : UIFont.systemFont(ofSize: pointSize),
                NSParagraphStyleAttributeName : paragraphStyle
            ]
            
                var width = tableView.frame.width-kMessageTableViewCellAvatarHeight
            width -= 25.0
            
                let titleBounds = ("\(comment.user!.first_name) \(comment.user!.last_name)" as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                let bodyBounds = (comment.text as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
                if comment.text.characters.count == 0 {
                    return 0
                }
            
                var height = titleBounds.height
                height += bodyBounds.height
                height += 40
            
                if height < kMessageTableViewCellMinimumHeight {
                    height = kMessageTableViewCellMinimumHeight
                }
            
                return height
            }
            else {
                return kMessageTableViewCellMinimumHeight
            }
        } else {
            return kMessageTableViewCellMinimumHeight
        }

    }
    
    
    
    //MARK: - Helper methods 
    
    func commentCellForRowAtIndexPath(_ indexPath: IndexPath) -> MessageTableViewCell {
        
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: CommentCellIdentifier, for: indexPath) as! MessageTableViewCell
        
        if let result = commentsResult  {
            
            
            let object = result[indexPath.row]
            
            if let first_name = object.user?.first_name, let last_name = object.user?.last_name {
                cell.titleLabel.text = "\(first_name) \(last_name)"
            }
            cell.bodyLabel.text = object.text
            
            cell.indexPath = indexPath
            cell.usedForMessage = true
            
            // Cells must inherit the table view's transform
            // This is very important, since the main table view may be inverted
            cell.transform = self.tableView.transform
            
            
            
            let hash = object.user?.email.md5
            
            cell.thumbnailView.kf.setImage(with: URL(string: "\(ProfileViewController.GRAVATAR_IMAGE_URL)\(hash!)?s=150")!,
                                              placeholder: nil,
                                              options: [.transition(.fade(1))],
                                              progressBlock: nil,
                                              completionHandler: nil)
            
        }
        
        
            return cell

        
    }
    
    func togglePIPWindow(_ sender: AnyObject) {
        
        if self.pipWindow == nil {
            self.showPIPWindow(sender)
        }
        else {
            self.hidePIPWindow(sender)
        }
    }
    
    func showPIPWindow(_ sender: AnyObject) {
        
        var frame = CGRect(x: self.view.frame.width - 60.0, y: 0.0, width: 50.0, height: 50.0)
        frame.origin.y = self.textInputbar.frame.minY - 60.0
        
        self.pipWindow = UIWindow(frame: frame)
        self.pipWindow?.backgroundColor = UIColor.black
        self.pipWindow?.layer.cornerRadius = 10
        self.pipWindow?.layer.masksToBounds = true
        self.pipWindow?.isHidden = false
        self.pipWindow?.alpha = 0.0
        
        UIApplication.shared.keyWindow?.addSubview(self.pipWindow!)
        
        UIView.animate(withDuration: 0.25, animations: { [unowned self] () -> Void in
            self.pipWindow?.alpha = 1.0
        })
    }
    
    func hidePIPWindow(_ sender: AnyObject) {
        
        UIView.animate(withDuration: 0.3, animations: { [unowned self] () -> Void in
            self.pipWindow?.alpha = 0.0
            }, completion: { [unowned self] (finished) -> Void in
                self.pipWindow?.isHidden = true
                self.pipWindow = nil
        })
    }
    
    func textInputbarDidMove(_ note: Notification) {
        
        guard let pipWindow = self.pipWindow else {
            return
        }
        
        guard let userInfo = (note as NSNotification).userInfo else {
            return
        }
        
        guard let value = userInfo["origin"] as? NSValue else {
            return
        }
        
        var frame = pipWindow.frame
        frame.origin.y = value.cgPointValue.y - 60.0
        
        pipWindow.frame = frame
    }
    
    
    func getPlaceComments() {
        
        activityIndicatorView.startAnimating()
        
        if let place = commentPlace {
            
            //            let predicate = NSPredicate(format: "place = %@", "\(place)")
            
            commentsResult = realm.objects(Comment.self).filter("place == %@", place)
            
            if ((commentsResult?.count)! > 0 ) {
                
                print("comments Result found in DB");
                self.activityIndicatorView.stopAnimating()
                
            } else {
                
                let userDefaults = UserDefaults.standard
                
                let strToken = userDefaults.value(forKey: "userToken")
                let authToken = "Token \(strToken!)"
                
                print("authToken : \(authToken)")
                
                let headers = [
                    "Authorization": authToken
                ]
                
                Alamofire.request("\(COMMENTS_LIST_URL)\(place.id)", parameters: nil, encoding: JSONEncoding.default,
                                  headers: headers)
                    .responseJSON  { response in
                        
                        debugPrint(response)
                        if  response.result.isSuccess {
                            
                            if let comments_raw = response.result.value {
                                let json = JSON(comments_raw)
                                print("json: \(json)")
                                if let error = json["detail"].string {
                                    
                                    print("couldn't fetch places : \(error)")
                                    
                                } else {
                                    
                                    if(json.count > 0 ) {
                                        
                                        self.addCommentsinBackground(JSON(comments_raw).array)
                                        
                                    } else {
                                        
                                        print("No comments added yet")
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            
                        }
                        
                        self.activityIndicatorView.stopAnimating()
                        
                }
                
            }
            
            
        }
        
    }
    
    func addCommentsinBackground(_ data : Array<JSON>!) {
        
        DispatchQueue.global().async {
            
            print("writing new comments to REALM db")
            let realm = try! Realm()
            realm.beginWrite()
            
            for subJson in data {
                
                let comment = realm.create(Comment.self, value: ["text": subJson["text"].stringValue,
                                                                 "created_at": self.dateFromStringConverter(date: subJson["created_at"].stringValue)!,
                                                                 "id": subJson["id"].int!,
                                                                 "approved_comment": subJson["approved_comment"].bool!])
                
                
                let user = subJson["user"]
                
                let existing_user = try! Realm().objects(User.self).filter("id = \(user["id"].int!)")
                
                if(existing_user.count < 1) {
                    
                    let place_user = realm.create(User.self, value : ["id" : user["id"].int!,
                                                                      "username": user["username"].stringValue,
                                                                      "first_name": user["first_name"].stringValue,
                                                                      "last_name": user["last_name"].stringValue,
                                                                      "email": user["email"].stringValue] )
                    
                    comment.user = place_user
                    
                } else {
                    
                    comment.user = existing_user[0]
                    
                }
                
                let place_id = subJson["place"].int!
                let existing_place = try! Realm().objects(Place.self).filter("id = \(place_id)")
                
//                if let place = self.commentPlace {
                
                    comment.place = existing_place[0]
//                }
            }
            
            try! realm.commitWrite()
        }
        
    }
    
    
    
    
    
    func dateFromStringConverter(date: String)-> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" //or you can use "yyyy-MM-dd'T'HH:mm:ssX"
        
        return dateFormatter.date(from: date)
    }
    

    // MARK - Overriden methods
    
    override func didPressRightButton(_ sender: Any?) {
        
        print("send button pressed")
    }
    
    


}
