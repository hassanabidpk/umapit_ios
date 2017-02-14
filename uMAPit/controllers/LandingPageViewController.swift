//
//  LandingPageViewController.swift
//  uMAPit
//
//  Created by Hassan Abid on 11/02/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import UIKit

class LandingPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    
    @IBOutlet weak var pageControl: UIPageControl!
    
    // The UIPageViewController
    var pageContainer: UIPageViewController!
    
    // The pages it contains
    var pages = [UIViewController]()
    
    // Track the current index
    var currentIndex: Int?
    private var pendingIndex: Int?
    
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPageViewControllers()
        
       
    }
    
    // MARK: - UI
    
    func setupPageViewControllers() {
        
        
        // Setup the pages
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let landingViewController: UIViewController! = storyboard.instantiateViewController(withIdentifier: "landing")
        let loginViewController: UIViewController! = storyboard.instantiateViewController(withIdentifier: "login")
        
        landingViewController.view.backgroundColor = UIColor(red: 77/255, green: 195/255, blue: 58/255, alpha: 1.0)
        loginViewController.view.backgroundColor = UIColor(red: 77/255, green: 195/255, blue: 58/255, alpha: 1.0)
        
        pages.append(landingViewController)
        pages.append(loginViewController)
        
        
        // Create the page container
        pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageContainer.delegate = self
        pageContainer.dataSource = self
        pageContainer.setViewControllers([landingViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        // Add it to the view
        view.addSubview(pageContainer.view)
        
        // Configure our custom pageControl
        view.bringSubview(toFront: pageControl)
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0

    
    }
    


    // MARK: UIPageViewController delegates
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == 0 {
            return nil
        }
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        let currentIndex = pages.index(of: viewController)!
        if currentIndex == pages.count-1 {
            return nil
        }
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        pendingIndex = pages.index(of: pendingViewControllers.first!)
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            currentIndex = pendingIndex
            if let index = currentIndex {
                
                print("Current Index : \(index)")
                pageControl.currentPage = index
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK - helpers 
    

}
