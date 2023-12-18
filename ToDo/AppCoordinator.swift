//
//  AppCoordinator.swift
//  ToDo
//
//  Created by Dan Koza on 12/17/23.
//

import UIKit

class AppCoordinator {

    private let mainWindow: UIWindow
    private let persistedTaskService: PersistedTaskServiceLayer
    private weak var tasksViewController: TasksViewController?

    init(persistedTaskService: PersistedTaskServiceLayer? = nil, mainWindow: UIWindow) throws {
        self.persistedTaskService = try (persistedTaskService ?? PersistedTaskService())
        self.mainWindow = mainWindow
    }

    func showTasksViewController() {
        let tasksViewController = TasksViewController(delegate: self)
        self.tasksViewController = tasksViewController
        let navigationController = UINavigationController(rootViewController: tasksViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        mainWindow.rootViewController = navigationController
        mainWindow.makeKeyAndVisible()
    }
}

extension AppCoordinator: TasksViewControllerDelegate {

    func userTapped(task: TaskModel) {
        let taskViewController = TaskViewController(edit: task, delegate: self)
        tasksViewController?.present(taskViewController, animated: true)
    }

    func getTasks() {
        Task(priority: .userInitiated) {
            do {
                let tasks = try await persistedTaskService.getTasks()
                await tasksViewController?.show(tasks: tasks)
            } catch {
                if let tasksViewController = tasksViewController {
                    await MainActor.run {
                        let alertController = UIAlertController(title: "Failed to get tasks", message: error.localizedDescription, preferredStyle: .alert)
                        let tryAgainAction = UIAlertAction(title: "try again", style: .default) { _ in
                            tasksViewController.getTasks()
                        }
                        alertController.addAction(tryAgainAction)
                        tasksViewController.present(alertController, animated: true)
                    }
                }
            }
        }
    }

    func userWantsToCreateTask() {
        Task(priority: .userInitiated) {
            do {
                let task = try await persistedTaskService.create()
                await tasksViewController?.add(new: task)
            } catch {
                if let tasksViewController = tasksViewController {
                    await MainActor.run {
                        let alertController = UIAlertController(title: "Failed to create task", message: error.localizedDescription, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "ok", style: .default))
                        tasksViewController.present(alertController, animated: true)
                    }
                }
            }
        }
    }

    func userDeleted(task: TaskModel) {
        Task(priority: .userInitiated) {
            do {
                try await persistedTaskService.delete(taskModel: task)
                await tasksViewController?.delete(task: task)
            } catch {
                if let tasksViewController = tasksViewController {
                    await MainActor.run {
                        let alertController = UIAlertController(title: "Failed to delete task", message: error.localizedDescription, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "ok", style: .default))
                        tasksViewController.present(alertController, animated: true)
                    }
                }
            }
        }
    }

    func userUpdated(task: TaskModel) {
        Task(priority: .userInitiated) {
            do {
                try await persistedTaskService.update(taskModel: task)
                await tasksViewController?.update(task: task)
            } catch {
                if let tasksViewController = tasksViewController {
                    await MainActor.run {
                        let alertController = UIAlertController(title: "Failed to update task", message: error.localizedDescription, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "ok", style: .default))
                        tasksViewController.present(alertController, animated: true)
                    }
                }
            }
        }
    }
}

extension AppCoordinator: TaskViewControllerDelegate {
    func taskDidChange(task: TaskModel) {
        Task(priority: .userInitiated) {
            do {
                try await persistedTaskService.update(taskModel: task)
                await tasksViewController?.update(task: task)
            } catch {
                if let tasksViewController = tasksViewController {
                    await MainActor.run {
                        let alertController = UIAlertController(title: "Failed to update task", message: error.localizedDescription, preferredStyle: .alert)
                        tasksViewController.present(alertController, animated: true)
                    }
                }
            }
        }
    }
}
