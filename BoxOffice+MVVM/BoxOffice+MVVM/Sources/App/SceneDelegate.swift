//
//  SceneDelegate.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/07/31.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.backgroundColor = .white
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
    }
}

