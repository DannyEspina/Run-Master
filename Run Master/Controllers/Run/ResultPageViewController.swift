//
//  ResultPageViewController.swift
//  Run Master
//
//  Created by Danny Espina on 11/14/17.
//  Copyright © 2017 LegendarySilverback. All rights reserved.
//

import UIKit
import Mapbox
import MapboxStatic

class ResultPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var coordNE: CLLocationCoordinate2D!
    var coordSW: CLLocationCoordinate2D!
    var snapshot: Snapshot!
    var workout: RunMasterWorkout!

    var mapViewController: MapViewController!
    
    
    lazy var VCArray: [UIViewController] = {
        return [self.VCInstance(name: "statsVC"),
                self.VCInstance(name: "elevationVC"),
                self.VCInstance(name: "paceVC")]
    }()
    
    private func VCInstance(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self

        let statsVC = VCArray.first as! StatsViewController
       
        statsVC.workout = workout

        if let firstVC = VCArray.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArray.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard VCArray.count > previousIndex else {
            return nil
        }
        
        return VCArray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArray.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < VCArray.count else {
            return nil
        }
        
        guard VCArray.count > nextIndex else {
            return nil
        }
        
        return VCArray[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return VCArray.count
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = VCArray.index(of: firstViewController) else {
                return 0
        }
        return firstViewControllerIndex
    }
}
