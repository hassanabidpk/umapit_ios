//
//  FeedViewController.swift
//  uMAPit
//
//  Created by Hassan Abid on 12/02/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import Kingfisher
import SwiftyJSON

#if DEBUG
    let PLACES_LIST_URL = "http://localhost:8000/place/api/v1/list/"
    let PLACE_URL = "http://localhost:8000/place/api/v1/single/"
    let IMAGE_BASE_URL = "http://localhost:8000"
#else
    let PLACES_LIST_URL = "https://umapit.azurewebsites.net/place/api/v1/list/"
    let PLACE_URL = "https://umapit.azurewebsites.net/place/api/v1/single/"
    let IMAGE_BASE_URL = "https://umapit.azurewebsites.net"
#endif
    

class FeedViewController: UITableViewController {
    
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    let realm = try! Realm()
    let results = try! Realm().objects(Place.self)
    var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        
        self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        self.tableView.addSubview(self.refreshControl!)
        
       
    }
    
    // MARK : - UI 
    
    func setUI() {
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 77/255, green: 195/255, blue: 58/255, alpha: 1.0)
        
        
        // Set results notification block
        self.notificationToken = results.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.endUpdates()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.tableView.backgroundView = activityIndicatorView
        
        if(results.count == 0) {
            self.getPlacesList()
        }

    
    }
    
    // MARK : - Helpers
    
    func getPlacesList() {
        
        activityIndicatorView.startAnimating()
    
        let strToken = UserDefaults.standard.value(forKey: "userToken")
        let authToken = "Token \(strToken!)"
        print("authToken : \(authToken)")
        
        let headers = [
            "Authorization": authToken
        ]
        
        Alamofire.request(PLACES_LIST_URL, parameters: nil, encoding: JSONEncoding.default,
                          headers: headers)
            .responseJSON  { response in
                
                debugPrint(response)
                
                if  response.result.isSuccess {
                
                    if let places_raw = response.result.value {
                        let json = JSON(places_raw)
                         print("json: \(json)")
                        if let error = json["detail"].string {
                            
                            print("couldn't fetch places : \(error)")
                        
                        } else {
                            
                            if(json.count > 0 ) {
                                
                                self.addPlacesinBackground(JSON(places_raw).array)
                                
                            } else {
                                
                                print("No places added yet")
                                
                            }
                            
                        }
                        
                    }

                    
                }
                
                self.activityIndicatorView.stopAnimating()
                    
            }
        
    }
    
    
    func addPlacesinBackground(_ data : Array<JSON>!) {
        
        DispatchQueue.global().async {
            
            print("writing new places to REALM db")
            let realm = try! Realm()
            realm.beginWrite()
            
            for subJson in data {
                
                let places_tags = subJson["place_tags"].array
                
                let tags = List<Tag>()
                
                for tag in places_tags! {
                    
                    
                    let existing_tag = try! Realm().objects(Tag.self).filter("id = \(tag["id"].int!)")
            
                    if(existing_tag.count < 1) {
                
                       let new_tag = realm.create(Tag.self, value: ["title": tag["title"].stringValue,
                                                                 "id": tag["id"].int!,
                                                                 "slug": tag["slug"].stringValue])
                         tags.append(new_tag)
                        
                    } else {
                        
                         tags.append(existing_tag[0])
                    }
                    
                   
                }
                

                
                let place = realm.create(Place.self, value: ["name": subJson["name"].stringValue,
                                                 "description_place": subJson["description"].stringValue,
                                                 "created_at": self.dateFromStringConverter(date: subJson["created_at"].stringValue),
                                                 "updated_at": self.dateFromStringConverter(date: subJson["updated_at"].stringValue),
                                                 "id": subJson["id"].int!,
                                                 "image_1": subJson["image_1"].stringValue,
                                                 "image_2": subJson["image_2"].stringValue,
                                                 "image_3": subJson["image_3"].stringValue,
                                                 "image_4": subJson["image_4"].stringValue,
                                                 "slug": subJson["slug"].stringValue,
                                                 "like_count": subJson["likes"].array?.count,
                                                 "flag_count": subJson["flags"].array?.count])
                
                
                let location = subJson["location"]
                
                let existing_location = try! Realm().objects(Location.self).filter("id = \(location["id"].int!)")
                
                
                if(existing_location.count < 1) {
                    
                    let new_location = realm.create(Location.self, value : ["id" : location["id"].int!,
                                                                            "latitude": Double(location["latitude"].stringValue),
                                                                            "longitude": Double(location["longitude"].stringValue),
                                                                            "address": location["address"].stringValue] )
                     place.location = new_location
                    
                } else {
                
                    place.location = existing_location[0]
                }
                
                let user = subJson["user"]
                
                
                let existing_user = try! Realm().objects(User.self).filter("id = \(user["id"].int!)")
                
                if(existing_user.count < 1) {
                    
                let place_user = realm.create(User.self, value : ["id" : user["id"].int!,
                                                                  "username": user["username"].stringValue,
                                                                  "first_name": user["first_name"].stringValue,
                                                                  "last_name": user["last_name"].stringValue,
                                                                  "email": user["email"].stringValue] )
                    
                    place.user = place_user

                } else {
                    
                    place.user = existing_user[0]

                
                }
                
               
                
                place.place_tags.append(objectsIn: tags)
                
                
                
            
            }
            
            try! realm.commitWrite()
        }
    
    }
    
    
    func dateFromStringConverter(date: String)-> Date? {
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" //or you can use "yyyy-MM-dd'T'HH:mm:ssX"
        
        return dateFormatter.date(from: date)
    }
    
    func getFormattedDateForUI(_ date: Date?) -> String {
        
        if let release_date = date {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: release_date)
        }
        
        return ""
    }
    
    func deletePlaces() {
        
        try! realm.write {
            realm.delete(results)
            let locs = try! Realm().objects(Location.self)
            realm.delete(locs)
            print("deleted location")
            let tags = try! Realm().objects(Tag.self)
            realm.delete(tags)
            print("deleted tags")
            
            let username = UserDefaults.standard.value(forKey: "username") as! String
            
            let users = try! Realm().objects(User.self)
            
            let NUsers = users
            
            for user in NUsers {
                if user.username != username {
                    realm.delete(user)
                }
                print("deleted user")
            }
        }
    }
    
    
    func refresh(_ sender: AnyObject) {
        
        print("refresh list")
        
        self.deletePlaces()
        
        self.getPlacesList()
        
        self.refreshControl?.endRefreshing()
    
    }
    
    // MARK: - tableview delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return results.count
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cellIdentifier = "placecell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PlaceTableViewCell
        
        let object = results[indexPath.row]
        cell.placeNameLabel?.text = object.name
        let formatted_date = getFormattedDateForUI(object.created_at)
        cell.createdAtLabel.text = "\(formatted_date)"
        
        if let first_name = object.user?.first_name, let last_name = object.user?.last_name {
            
            cell.placeUser.text = "\(first_name) \(last_name) MAPPED"
        }
        
        cell.likeLabel.text = "\(object.like_count)"
        cell.flagLabel.text = "\(object.flag_count)"
        
    
        cell.placeImage.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        cell.placeImage.contentMode = .scaleAspectFill
        cell.placeImage.clipsToBounds = true
        
        
        cell.placeImage.kf.setImage(with: URL(string: "\(IMAGE_BASE_URL)\(object.image_1)")!,
                                             placeholder: nil,
                                             options: [.transition(.fade(1))],
                                             progressBlock: nil,
                                             completionHandler: nil)

        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    

    // MARK: - IBAction 
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
