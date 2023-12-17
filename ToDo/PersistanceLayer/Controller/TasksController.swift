//
//  TasksController.swift
//  ToDo
//
//  Created by Dan Koza on 12/16/23.
//

import Foundation

protocol TasksControllerDelegate: AnyObject {
    @MainActor func startedGettingTasks()
    @MainActor func getTasks(result: Result<[TaskModel], Error>)
    @MainActor func taskWasCreated(result: Result<TaskModel, Error>)
    @MainActor func taskWasDeleted(result: Result<TaskModel, Error>)
}

class TasksController {
    private let persistedTaskServiceLayer: PersistedTaskServiceLayer
    weak var delegate: TasksControllerDelegate?

    init(persistedTaskServiceLayer: PersistedTaskServiceLayer) {
        self.persistedTaskServiceLayer = persistedTaskServiceLayer
    }

    func loadTasks() {
        Task(priority: .userInitiated) {
            await delegate?.startedGettingTasks()

            do {
                let tasks = try await persistedTaskServiceLayer.getTasks()
                await delegate?.getTasks(result: .success(tasks))
            } catch {
                await delegate?.getTasks(result: .failure(error))
            }
        }
    }

    func createTask() {
        Task(priority: .userInitiated) {
            do {
                let newTask = try await persistedTaskServiceLayer.create()
                await delegate?.taskWasCreated(result: .success(newTask))
            } catch {
                await delegate?.taskWasCreated(result: .failure(error))
            }
        }
    }

    func delete(task: TaskModel, skipDelegateCallback: Bool) {
        Task(priority: .userInitiated) {
            do {
                try await persistedTaskServiceLayer.delete(taskModel: task)
                if !skipDelegateCallback {
                    await delegate?.taskWasDeleted(result: .success(task))
                }
            } catch {
                if !skipDelegateCallback {
                    await delegate?.taskWasDeleted(result: .failure(error))
                }
            }
        }
    }
}
