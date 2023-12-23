//
//  TaskViewModel.swift
//  ToDo
//
//  Created by Dan Koza on 12/22/23.
//

import Foundation

protocol TaskViewModelViewDelegate: AnyObject {
    func taskDidChange(task: TaskModel)
    func createTask(text: String)
}

class TaskViewModel {

    weak var viewDelegate: TaskViewModelViewDelegate?
    private var originalTask: TaskModel?
    private var task: TaskModel?

    private(set) var text: String
    let showKeyboard: Bool
    let taskIsComplete: Bool

    init(edit task: TaskModel?, viewDelegate: TaskViewModelViewDelegate? = nil) {
        self.originalTask = task
        self.task = task
        self.viewDelegate = viewDelegate
        showKeyboard = task == nil
        text = task?.text ?? ""
        taskIsComplete = task?.isCompleted == true
    }

    func textDidChange(to text: String) {
        task?.text = text
        self.text = text
    }

    func viewDidDismiss() {
        if let task = task, originalTask != task {
            viewDelegate?.taskDidChange(task: task)
        } else if task == nil, !text.isEmpty {
            viewDelegate?.createTask(text: text)
        }
    }
}
