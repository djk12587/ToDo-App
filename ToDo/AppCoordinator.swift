//
//  AppCoordinator.swift
//  ToDo
//
//  Created by Dan Koza on 12/17/23.
//

import UIKit

class AppCoordinator {
    func showTasksViewController(in mainWindow: UIWindow) {
        let tasksViewController = TasksViewController(viewModel: TasksViewModel(coordinatorDelegate: self))
        let navigationController = UINavigationController(rootViewController: tasksViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        mainWindow.rootViewController = navigationController
        mainWindow.makeKeyAndVisible()
    }
}

extension AppCoordinator: TasksViewModelCoordinatorDelegate {
    func userWantsToCreateTask(presentOn tasksViewController: UIViewController & TaskViewControllerDelegate) {
        let taskViewController = TaskViewController(viewModel: TaskViewModel(edit: nil),
                                                    delegate: tasksViewController)
        tasksViewController.present(taskViewController, animated: true)
    }

    func userTapped(task: TaskModel, presentOn tasksViewController: UIViewController & TaskViewControllerDelegate) {
        let taskViewController = TaskViewController(viewModel: TaskViewModel(edit: task),
                                                    delegate: tasksViewController)
        tasksViewController.present(taskViewController, animated: true)
    }
}
