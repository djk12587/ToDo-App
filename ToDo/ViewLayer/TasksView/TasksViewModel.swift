//
//  TasksViewModel.swift
//  ToDo
//
//  Created by Dan Koza on 12/22/23.
//

import Foundation
import UIKit
import Combine

protocol TasksViewModelCoordinatorDelegate: AnyObject {
    func userWantsToCreateTask(presentOn tasksViewController: UIViewController, tasksModel: TasksModel)
    func userTapped(task: TaskModel, presentOn tasksViewController: UIViewController, tasksModel: TasksModel)
}

protocol TasksViewModelViewDelegate: AnyObject {
    func tasksDidUpdate(tasks: [TaskModel])
    func handleError(title: String, message: String, retryGetTasks: Bool)
}

class TasksViewModel {

    private weak var coordinatorDelegate: TasksViewModelCoordinatorDelegate?
    weak var viewDelegate: TasksViewModelViewDelegate?

    private var model: TasksModel
    private var bag: Set<AnyCancellable> = []

    init(coordinatorDelegate: TasksViewModelCoordinatorDelegate,
         viewDelegate: TasksViewModelViewDelegate? = nil,
         service: PersistedTaskServiceType? = nil) {
        self.coordinatorDelegate = coordinatorDelegate
        self.viewDelegate = viewDelegate
        model = TasksModel(tasks: [], service: service)
        setupObserveable()
    }

    private func setupObserveable() {
        model.$tasks.receive(on: DispatchQueue.main).sink { [weak self] tasks in
            self?.viewDelegate?.tasksDidUpdate(tasks: tasks)
        }.store(in: &bag)

        model.$error.receive(on: DispatchQueue.main).sink { [weak self] errorDetails in
            guard let (title, message, retryGetTasks) = errorDetails else { return }
            self?.viewDelegate?.handleError(title: title, message: message, retryGetTasks: retryGetTasks)
        }.store(in: &bag)
    }

    func showCreateNewTaskScreen(presentOn tasksViewController: UIViewController) {
        coordinatorDelegate?.userWantsToCreateTask(presentOn: tasksViewController, tasksModel: model)
    }

    func open(_ task: TaskModel, presentOn tasksViewController: UIViewController) {
        coordinatorDelegate?.userTapped(task: task, presentOn: tasksViewController, tasksModel: model)
    }

    func getTasks() {
        model.getTasks()
    }

    func createTask(text: String) {
        model.createTask(text: text)
    }

    func delete(_ task: TaskModel) {
        model.delete(task: task)
    }

    func update(_ task: TaskModel) {
        model.update(task: task)
    }
}
