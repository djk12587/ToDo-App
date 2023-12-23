//
//  TaskViewController.swift
//  ToDo
//
//  Created by Dan Koza on 12/17/23.
//

import UIKit

protocol TaskViewControllerDelegate: AnyObject {
    func taskDidChange(task: TaskModel)
    func createTask(text: String)
}

class TaskViewController: UIViewController {

    private weak var textView: UITextView?
    private var viewModel: TaskViewModel
    private weak var delegate: TaskViewControllerDelegate?

    init(viewModel: TaskViewModel, delegate: TaskViewControllerDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        presentationController?.delegate = self
        self.viewModel.viewDelegate = self
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        let textView = UITextView()
        textView.text = viewModel.text
        textView.delegate = self
        textView.textColor = viewModel.taskIsComplete ? .systemRed : .label
        view = textView
        self.textView = textView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if viewModel.showKeyboard {
            textView?.becomeFirstResponder()
        }
    }
}

extension TaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.textDidChange(to: textView.text ?? "")
    }
}

extension TaskViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.viewDidDismiss()
    }
}

extension TaskViewController: TaskViewModelViewDelegate {
    func taskDidChange(task: TaskModel) {
        delegate?.taskDidChange(task: task)
    }
    
    func createTask(text: String) {
        delegate?.createTask(text: text)
    }
}
