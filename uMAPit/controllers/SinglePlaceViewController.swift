//
//  SinglePlaceViewController.swift
//  uMAPit
//
//  Created by Hassan Abid on 18/02/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import UIKit
import ImageSlideshow

class SinglePlaceViewController: UIViewController {
    
    var singlePlace: Place?
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var placeImageSlideShow: ImageSlideshow!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var flagLabel: UILabel!
    
    @IBOutlet weak var commentButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        configureActionItems()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    // MARK: - UI
    
    func setUI()  {
        
        
        if let place = singlePlace {
        
            if let fname = place.user?.first_name, let lname = place.user?.last_name {
                
                userLabel.text = ("\(fname) \(lname) MAPPED")
                
            }
            placeNameLabel.text = place.name
            createdAtLabel.text = getFormattedDateForUI(place.created_at)
            
            likeLabel.text = "\(place.like_count)"
            flagLabel.text = "\(place.flag_count)"
            
        
            placeImageSlideShow.backgroundColor = UIColor.white
            placeImageSlideShow.slideshowInterval = 5.0
            placeImageSlideShow.pageControlPosition = PageControlPosition.underScrollView
            placeImageSlideShow.pageControl.currentPageIndicatorTintColor = UIColor.lightGray;
            placeImageSlideShow.pageControl.pageIndicatorTintColor = UIColor.black;
            placeImageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
            
            let kingfisherSource = [KingfisherSource(urlString: "\(IMAGE_BASE_URL)\(place.image_1)")!,
                                    KingfisherSource(urlString: "\(IMAGE_BASE_URL)\(place.image_2)")!,
                                    KingfisherSource(urlString: "\(IMAGE_BASE_URL)\(place.image_3)")!,
                                    KingfisherSource(urlString: "\(IMAGE_BASE_URL)\(place.image_4)")!]
            
        
            
            // try out other sources such as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
            placeImageSlideShow.setImageInputs(kingfisherSource)
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(SinglePlaceViewController.didTap))
            placeImageSlideShow.addGestureRecognizer(recognizer)
        }
    
    }
    
    func configureActionItems() {
    
        let mapItem = UIBarButtonItem(image: UIImage(named: "ic_map_white_36pt"), style: .plain, target: self, action: #selector(SinglePlaceViewController.showMapView(_:)))
        
        self.navigationItem.rightBarButtonItem = mapItem
    }
    
   func getFormattedDateForUI(_ date: Date?) -> String {
        
        if let release_date = date {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: release_date)
        }
        
        return ""
    }
    
    
    func didTap() {
        
        placeImageSlideShow.presentFullScreenController(from: self)
    }
    
    // MARK: - IBAction
    
    @IBAction func didClickComment(_ sender: UIButton) {
        
        navigationItem.title = nil
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let commentViewController = storyboard.instantiateViewController(withIdentifier: "commentslistvc") as! CommentListViewController
        
        commentViewController.commentPlace = singlePlace
        commentViewController.navigationItem.leftItemsSupplementBackButton = true
        commentViewController.title = "uMAPit"
        
        self.navigationController?.navigationBar.tintColor = Constants.tintColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Constants.tintColor]
        
        self.navigationController?.pushViewController(commentViewController, animated: true)
        
    }
    
    
    // MARK: - Action Methods
    
    func showMapView(_ sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mapViewController = storyboard.instantiateViewController(withIdentifier: "singlemapvc") as! SingleMapViewController
        
        
        mapViewController.singlePlace = self.singlePlace!
        
        mapViewController.navigationItem.leftItemsSupplementBackButton = true
        mapViewController.title = "uMAPit"
        
        self.navigationController?.navigationBar.tintColor = Constants.tintColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Constants.tintColor]
        
        self.navigationController?.pushViewController(mapViewController, animated: true)
        
        
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
