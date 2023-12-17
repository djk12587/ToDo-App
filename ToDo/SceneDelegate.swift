//
//  SceneDelegate.swift
//  ToDo
//
//  Created by Dan Koza on 12/13/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        bootUp(in: window)
    }
}

extension SceneDelegate {
    private func bootUp(in window: UIWindow) {
        do {
            let persistedTaskService = try PersistedTaskService()
            let navigationController = UINavigationController(rootViewController: HomeViewController(taskViewModel: TasksController(persistedTaskServiceLayer: persistedTaskService)))
            navigationController.navigationBar.prefersLargeTitles = true
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        } catch {
            let blankViewController = UIViewController()
            window.rootViewController = blankViewController
            window.makeKeyAndVisible()
            let alertController = UIAlertController(title: "Something went wrong", message: error.localizedDescription, preferredStyle: .alert)
            let fatalAction = UIAlertAction(title: "ok", style: .destructive) { _ in
                fatalError(error.localizedDescription)
            }
            alertController.addAction(fatalAction)
            blankViewController.present(alertController, animated: true)
        }
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
