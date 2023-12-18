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

        let appCoordinator = AppCoordinator(mainWindow: window)
        self.appCoordinator = appCoordinator
        appCoordinator.showTasksViewController()
    }
}

private extension UIWindow {
    func transition(to newRootViewController: UIViewController, completion: (() -> Void)? = nil) {
        rootViewController = newRootViewController
        UIView.transition(with: self,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil) { _ in
            completion?()
        }
    }
}
