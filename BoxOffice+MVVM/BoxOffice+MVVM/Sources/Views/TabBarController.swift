//
//  ViewController.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/12/25.
//

import UIKit

final class TabBarController: UITabBarController {
    
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
        delegate = self
        
        let movieListViewModel = MovieListViewModel()
        let tableViewController = TableViewController(viewModel: movieListViewModel)
        let collectionViewController = CollectionViewController(viewModel: movieListViewModel)
        
        tableViewController.tabBarItem = tableTabBarItem
        collectionViewController.tabBarItem = collectionTabBarItem
        
        let tableNavigationController = UINavigationController(rootViewController: tableViewController)
        let collectionNavigationController = UINavigationController(rootViewController: collectionViewController)
        
        viewControllers = [tableNavigationController, collectionNavigationController]
    }
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "Collection" {
            guard let navigationController = viewControllers?[1] as? UINavigationController else { return }
            navigationController.popToRootViewController(animated: false)
        } else {
            guard let navigationController = viewControllers?[0] as? UINavigationController else { return }
            navigationController.popToRootViewController(animated: false)
        }
    }
}

