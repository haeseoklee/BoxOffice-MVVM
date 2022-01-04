//
//  ViewController.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/12/25.
//

import UIKit

final class BoxOfficeTabBarController: UITabBarController {
    
    // MARK: - Views
    private let tableTabBarItem: UITabBarItem = {
        let tabBarItem = UITabBarItem()
        tabBarItem.image = UIImage(named: "ic_table")
        tabBarItem.title = "Table"
        return tabBarItem
    }()
    
    private let collectionTabBarItem: UITabBarItem = {
        let tabBarItem = UITabBarItem()
        tabBarItem.image = UIImage(named: "ic_collection")
        tabBarItem.title = "Collection"
        return tabBarItem
    }()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    // MARK: - Functions
    private func initViews() {
        let boxOfficeTableViewController = BoxOfficeTableViewController()
        let boxOfficeCollectionViewController = BoxOfficeCollectionViewController()
        
        boxOfficeTableViewController.tabBarItem = tableTabBarItem
        boxOfficeCollectionViewController.tabBarItem = collectionTabBarItem
        
        let tableNavigationController = UINavigationController(rootViewController: boxOfficeTableViewController)
        let collectionNavigationController = UINavigationController(rootViewController: boxOfficeCollectionViewController)
        
        viewControllers = [tableNavigationController, collectionNavigationController]
    }
}
