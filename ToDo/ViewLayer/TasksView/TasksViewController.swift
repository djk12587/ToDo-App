//
//  TasksViewController.swift
//  ToDo
//
//  Created by Dan Koza on 12/13/23.
//

import UIKit

class TasksViewController: UIViewController {

    private weak var activityIndicator: UIActivityIndicatorView?
    private weak var tasksTableView: TasksTableView?
    private let viewModel: TasksViewModel

    init(viewModel: TasksViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.viewDelegate = self
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        let tasksTableView = TasksTableView(userActionDelegate: self)
        view = tasksTableView
        self.tasksTableView = tasksTableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        getTasks()
    }

    private func setupUI() {
        title = "ToDo"
        view.backgroundColor = .systemBackground

        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        self.activityIndicator = activityIndicatorView
        NSLayoutConstraint.activate([
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        navigationController?.navigationBar.topItem?.setRightBarButton(UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"),
                                                                                       style: .plain,
                                                                                       target: self,
                                                                                       action: #selector(createTaskButtonWasPressed)),
                                                                       animated: false)
    }

    @objc private func createTaskButtonWasPressed() {
        viewModel.showCreateNewTaskScreen(presentOn: self)
    }

    private func getTasks() {
        activityIndicator?.startAnimating()
        viewModel.getTasks()
    }
}

extension TasksViewController: TasksTableViewDelegate {

    func userTapped(task: TaskModel) {
        viewModel.open(task, presentOn: self)
    }

    func userSwipedToDeleted(task: TaskModel) {
        viewModel.delete(task)
    }
    
    func userUpdated(task: TaskModel) {
        viewModel.update(task)
    }
}

extension TasksViewController: TasksViewModelViewDelegate {

    func userCreated(result: Result<TaskModel, Error>) {
        switch result {
            case .success(let task):
                tasksTableView?.insert(new: task)
            case .failure(let error):
                let alertController = UIAlertController(title: "Failed to create task", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "ok", style: .default))
                present(alertController, animated: true)
        }
    }

    func retrievedTasks(result: Result<[TaskModel], Error>) {
        activityIndicator?.stopAnimating()

        switch result {
            case .success(let tasks):
                tasksTableView?.updateDataSource(tasks: tasks)
            case .failure(let error):
                let alertController = UIAlertController(title: "Failed to get tasks", message: error.localizedDescription, preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "ok", style: .default) { [weak self] _ in
                    self?.getTasks()
                }
                alertController.addAction(retryAction)
                present(alertController, animated: true)
        }
    }

    func userDeleted(result: Result<TaskModel, Error>) {
        switch result {
            case .success(let task):
                tasksTableView?.delete(task: task)
            case .failure(let error):
                let alertController = UIAlertController(title: "Failed to delete task", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "ok", style: .default))
                present(alertController, animated: true)
        }
    }

    func userUpdated(result: Result<TaskModel, Error>) {
        switch result {
            case .success(let task):
                tasksTableView?.update(task: task)
            case .failure(let error):
                let alertController = UIAlertController(title: "Failed to update task", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "ok", style: .default))
                present(alertController, animated: true)
        }
    }
}

extension TasksViewController: TaskViewControllerDelegate {
    func taskDidChange(task: TaskModel) {
        viewModel.update(task)
    }
    
    func createTask(text: String) {
        viewModel.createTask(text: text)
    }
}
