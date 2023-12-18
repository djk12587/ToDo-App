//
//  TaskViewController.swift
//  ToDo
//
//  Created by Dan Koza on 12/17/23.
//

import UIKit

protocol TaskViewControllerDelegate: AnyObject {
    func taskDidChange(task: TaskModel)
}

class TaskViewController: UIViewController {

    private var originalTask: TaskModel
    private var task: TaskModel
    private weak var delegate: TaskViewControllerDelegate?
    private weak var textView: UITextView?

    init(edit task: TaskModel, delegate: TaskViewControllerDelegate?) {
        self.originalTask = task
        self.task = task
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        presentationController?.delegate = self
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        let textView = UITextView()
        textView.text = task.text
        textView.delegate = self
        view = textView
        self.textView = textView
    }
}

extension TaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        task.text = textView.text
    }
}

extension TaskViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        if originalTask != task {
            delegate?.taskDidChange(task: task)
        }
    }
}
