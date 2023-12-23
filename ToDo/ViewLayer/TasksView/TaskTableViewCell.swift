//
//  TaskTableViewCell.swift
//  ToDo
//
//  Created by Dan Koza on 12/17/23.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    private weak var label: UILabel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        contentView.addSubview(label)
        self.label = label
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(for task: TaskModel) {
        label?.textColor = task.isCompleted ? .systemRed : .label

        var prefixedTaskText = String(task.text.prefix(140))
        if task.text.count > 140 {
            prefixedTaskText.append("...")
        }
        label?.text = prefixedTaskText
    }
}
