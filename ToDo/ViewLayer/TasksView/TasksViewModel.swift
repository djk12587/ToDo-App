//
//  TasksViewModel.swift
//  ToDo
//
//  Created by Dan Koza on 12/22/23.
//

import Foundation
import UIKit

protocol TasksViewModelCoordinatorDelegate: AnyObject {
    func userWantsToCreateTask(presentOn tasksViewController: UIViewController & TaskViewControllerDelegate)
    func userTapped(task: TaskModel, presentOn tasksViewController: UIViewController & TaskViewControllerDelegate)
}

protocol TasksViewModelViewDelegate: AnyObject {
    @MainActor func retrievedTasks(result: Result<[TaskModel], Error>)
    @MainActor func userCreated(result: Result<TaskModel, Error>)
    @MainActor func userDeleted(result: Result<TaskModel, Error>)
    @MainActor func userUpdated(result: Result<TaskModel, Error>)
}

class TasksViewModel {

    private weak var coordinatorDelegate: TasksViewModelCoordinatorDelegate?
    weak var viewDelegate: TasksViewModelViewDelegate?

    private var _service: PersistedTaskServiceType?
    private var service: PersistedTaskServiceType {
        get async throws {
            if let service = _service {
                return service
            } else {
                let service = try await PersistedTaskService()
                _service = service
                return service
            }
        }
    }

    init(coordinatorDelegate: TasksViewModelCoordinatorDelegate,
         viewDelegate: TasksViewModelViewDelegate? = nil,
         service: PersistedTaskServiceType? = nil) {
        _service = service
        self.coordinatorDelegate = coordinatorDelegate
        self.viewDelegate = viewDelegate
    }

    func showCreateNewTaskScreen(presentOn tasksViewController: UIViewController & TaskViewControllerDelegate) {
        coordinatorDelegate?.userWantsToCreateTask(presentOn: tasksViewController)
    }

    func open(_ task: TaskModel, presentOn tasksViewController: UIViewController & TaskViewControllerDelegate) {
        coordinatorDelegate?.userTapped(task: task, presentOn: tasksViewController)
    }

    func getTasks() {
        Task(priority: .userInitiated) {
            do {
                let tasks = try await service.getTasks()
                await viewDelegate?.retrievedTasks(result: .success(tasks))
            } catch {
                await viewDelegate?.retrievedTasks(result: .failure(error))
            }
        }
    }

    func createTask(text: String) {
        Task(priority: .userInitiated) {
            do {
                let task = try await service.create(text: text)
                await viewDelegate?.userCreated(result: .success(task))
            } catch {
                await viewDelegate?.userCreated(result: .failure(error))
            }
        }
    }

    func delete(_ task: TaskModel) {
        Task(priority: .userInitiated) {
            do {
                try await service.delete(taskModel: task)
                await viewDelegate?.userDeleted(result: .success(task))
            } catch {
                await viewDelegate?.userDeleted(result: .failure(error))
            }
        }
    }

    func update(_ task: TaskModel) {
        Task(priority: .userInitiated) {
            do {
                try await service.update(taskModel: task)
                await viewDelegate?.userUpdated(result: .success(task))
            } catch {
                await viewDelegate?.userUpdated(result: .failure(error))
            }
        }
    }
}
