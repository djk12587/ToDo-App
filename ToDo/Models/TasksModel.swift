//
//  TasksModel.swift
//  ToDo
//
//  Created by Dan Koza on 1/21/24.
//

import Foundation

class TasksModel: ObservableObject {
    @Published private(set) var tasks: [TaskModel]
    @Published private(set) var error: (title: String, message: String, retryGetTasks: Bool)?

    private var _service: PersistedTaskServiceType?
    private var service: PersistedTaskServiceType {
        get async throws {
            if let service = _service {
                return service
            } else {
                let service = try await PersistedTaskService()
                _service = service
                return service
            }
        }
    }

    init(tasks: [TaskModel], service: PersistedTaskServiceType? = nil) {
        _service = service
        self.tasks = tasks
    }

    func getTasks() {
        Task(priority: .userInitiated) {
            do {
                tasks = try await service.getTasks()
            } catch {
                self.error = ("Failed to get tasks", error.localizedDescription, true)
            }
        }
    }

    func createTask(text: String) {
        Task(priority: .userInitiated) {
            do {
                let newTask = try await service.create(text: text)
                tasks.insert(newTask, at: 0)
            } catch {
                self.error = ("Failed to create task", error.localizedDescription, false)
            }
        }
    }

    func delete(task: TaskModel) {
        Task(priority: .userInitiated) {
            do {
                try await service.delete(taskModel: task)
                tasks.removeAll { $0.id == task.id }
            } catch {
                self.error = ("Failed to delete task", error.localizedDescription, false)
            }
        }
    }

    func update(task: TaskModel) {
        Task(priority: .userInitiated) {
            do {
                try await service.update(taskModel: task)
                guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
                tasks[index] = task
            } catch {
                self.error = ("Failed to update task", error.localizedDescription, false)
            }
        }
    }
}
