//
//  TaskViewModel.swift
//  ToDo
//
//  Created by Dan Koza on 12/22/23.
//

import Foundation

class TaskViewModel {

    private var originalTask: TaskModel?
    private var task: TaskModel?

    private(set) var text: String
    let showKeyboard: Bool
    let taskIsComplete: Bool
    private let model: TasksModel

    init(edit task: TaskModel?, model: TasksModel) {
        self.originalTask = task
        self.task = task
        showKeyboard = task == nil
        text = task?.text ?? ""
        taskIsComplete = task?.isCompleted == true
        self.model = model
    }

    func textDidChange(to text: String) {
        task?.text = text
        self.text = text
    }

    func viewDidDismiss() {
        if let task = task, originalTask != task {
            model.update(task: task)
        } else if task == nil, !text.isEmpty {
            model.createTask(text: text)
        }
    }
}
