//
//  TaskViewController.swift
//  ToDo
//
//  Created by Dan Koza on 12/17/23.
//

import UIKit

protocol TaskViewControllerDelegate: AnyObject {
    func taskDidChange(task: TaskModel)
    func createTask()
}

class TaskViewController: UIViewController {

    private var originalTask: TaskModel?
    private var task: TaskModel?
    private weak var delegate: TaskViewControllerDelegate?
    private weak var textView: UITextView?
    private weak var activityIndicator: UIActivityIndicatorView?

    init(edit task: TaskModel?, delegate: TaskViewControllerDelegate?) {
        self.originalTask = task
        self.task = task
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        presentationController?.delegate = self
        delegate?.createTask()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        let textView = UITextView()
        textView.text = task?.text
        textView.delegate = self
        view = textView
        self.textView = textView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        if task == nil {
            activityIndicator?.startAnimating()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView?.becomeFirstResponder()
    }

    private func setupUI() {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        self.activityIndicator = activityIndicatorView
        NSLayoutConstraint.activate([
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// Public functions
extension TaskViewController {
    func set(task: TaskModel) {
        activityIndicator?.stopAnimating()
        self.task = task
        originalTask = task
    }
}

extension TaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        task?.text = textView.text
    }
}

extension TaskViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        if let task = task, originalTask != task {
            delegate?.taskDidChange(task: task)
        }
    }
}
