//
//  TaskViewController.swift
//  ToDo
//
//  Created by Dan Koza on 12/17/23.
//

import UIKit

protocol TaskViewControllerDelegate: AnyObject {
    func taskDidChange(task: TaskModel)
    func create(taskText: String)
}

class TaskViewController: UIViewController {

    private var taskText: String
    private var originalTask: TaskModel?
    private var task: TaskModel?
    private weak var delegate: TaskViewControllerDelegate?
    private weak var textView: UITextView?
    private let showKeyboard: Bool

    init(edit task: TaskModel?, delegate: TaskViewControllerDelegate?) {
        self.originalTask = task
        self.task = task
        self.delegate = delegate
        showKeyboard = task == nil
        taskText = task?.text ?? ""
        super.init(nibName: nil, bundle: nil)
        presentationController?.delegate = self
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        let textView = UITextView()
        textView.text = task?.text
        textView.delegate = self
        textView.textColor = task?.isCompleted == true ? .systemRed : .label
        view = textView
        self.textView = textView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if showKeyboard {
            textView?.becomeFirstResponder()
        }
    }
}

extension TaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        task?.text = text
        taskText = text
    }
}

extension TaskViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let task = task, originalTask != task {
            delegate?.taskDidChange(task: task)
        } else if task == nil, !taskText.isEmpty {
            delegate?.create(taskText: taskText)
        }
    }
}
