//
//  SceneDelegate.swift
//  ToDo
//
//  Created by Dan Koza on 12/13/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let appCoordinator = AppCoordinator()
        self.appCoordinator = appCoordinator
        appCoordinator.showTasksViewController(in: window)
    }
}
