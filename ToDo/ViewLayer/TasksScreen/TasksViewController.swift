//
//  TasksViewController.swift
//  ToDo
//
//  Created by Dan Koza on 12/13/23.
//

import UIKit

protocol TasksViewControllerDelegate: AnyObject {
    func getTasks()
    func userWantsToCreateTask()
    func userDeleted(task: TaskModel)
    func userUpdated(task: TaskModel)
    func userTapped(task: TaskModel)
}

class TasksViewController: UIViewController {

    private weak var delegate: TasksViewControllerDelegate?
    private weak var activityIndicator: UIActivityIndicatorView?
    private weak var taskTableView: TaskTableView?

    init(delegate: TasksViewControllerDelegate?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
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
        delegate?.userWantsToCreateTask()
    }
}

// Public functions
extension TasksViewController {
    func getTasks() {
        activityIndicator?.startAnimating()
        delegate?.getTasks()
    }

    func delete(task: TaskModel) {
        taskTableView?.delete(task: task)
    }

    func update(task: TaskModel) {
        taskTableView?.update(task: task)
    }

    func show(tasks: [TaskModel]) {
        activityIndicator?.stopAnimating()
        taskTableView?.updateDataSource(tasks: tasks)
    }

    func add(new task: TaskModel) {
        taskTableView?.insert(new: task)
    }
}

extension TasksViewController: TaskTableViewDelegate {

    func userTapped(task: TaskModel) {
        delegate?.userTapped(task: task)
    }

    func userSwipedToDeleted(task: TaskModel) {
        delegate?.userDeleted(task: task)
    }

    func userUpdated(task: TaskModel) {
        delegate?.userUpdated(task: task)
    }
}
