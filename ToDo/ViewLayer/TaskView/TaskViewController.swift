//
//  TaskViewController.swift
//  ToDo
//
//  Created by Dan Koza on 12/17/23.
//

import UIKit

class TaskViewController: UIViewController {

    private weak var textView: UITextView?
    private var viewModel: TaskViewModel

    init(viewModel: TaskViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        presentationController?.delegate = self
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
