//
//  HomeViewController.swift
//  ToDo
//
//  Created by Dan Koza on 12/13/23.
//

import UIKit

class HomeViewController: UIViewController {

    private let tasksController: TasksController
    private weak var activityIndicator: UIActivityIndicatorView?
    private weak var taskTableView: TaskTableView?

    init(tasksController: TasksController) {
        self.tasksController = tasksController
        super.init(nibName: nil, bundle: nil)
        self.tasksController.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        let taskTableView = TaskTableView(userActionDelegate: self)
        view = taskTableView
        self.taskTableView = taskTableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        tasksController.loadTasks()
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
        tasksController.createTask()
    }
}

extension HomeViewController: TasksControllerDelegate {
    func startedGettingTasks() {
        activityIndicator?.startAnimating()
    }
    
    func getTasks(result: Result<[TaskModel], Error>) {
        activityIndicator?.stopAnimating()
        if case .success(let tasks) = result {
            taskTableView?.updateDataSource(tasks: tasks)
        }
    }

    func taskWasCreated(result: Result<TaskModel, Error>) {
        if case .success(let task) = result {
            taskTableView?.insert(new: task)
        }
    }

    func taskWasDeleted(result: Result<TaskModel, Error>) {}
}

extension HomeViewController: TaskTableViewDelegate {
    func userSwipedToDeleted(task: TaskModel) {
        tasksController.delete(task: task, skipDelegateCallback: true)
    }
}
