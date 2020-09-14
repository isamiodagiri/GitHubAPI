//
//  SceneDelegate.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/12.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: scene)
        let navigationController = UINavigationController(rootViewController: UserListViewController())
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
}

