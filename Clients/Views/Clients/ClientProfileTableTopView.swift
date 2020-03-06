//
//  ClientProfileTableTopView.swift
//  Clients
//
//  Created by Максим Голов on 16.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Заголовочное представление таблицы записей на экране профиля клиента
class ClientProfileTableTopView: UIView {

    // MARK: - IBOutlets

    /// Кнопка совершения звонка
    @IBOutlet weak var phoneNumberButton: UIButton!
    /// Кнопка перехода к профилю клиента в социальной сети
    @IBOutlet weak var vkUrlButton: UIButton!
    /// Блок номера телефона
    @IBOutlet weak var phoneView: UIView!
    /// Блок ссылки на профиль в соцсети
    @IBOutlet weak var vkView: UIView!
    /// Блок заметок
    @IBOutlet weak var notesView: UIView!
    /// Метка заметок
    @IBOutlet weak var notesLabel: UILabel!

    /// Высота блока номера телефона
    @IBOutlet weak var phoneViewHeight: NSLayoutConstraint!
    /// Высота блока ссылки на профиль в соцсети
    @IBOutlet weak var vkViewHeight: NSLayoutConstraint!
    /// Высота блока заметок
    @IBOutlet weak var notesViewHeight: NSLayoutConstraint!
    /// Высота разделителя над блоком ссылки на профиль в соцсети
    @IBOutlet weak var vkHairlineHeight: NSLayoutConstraint!
    /// Высота разделителя над блоком заметок
    @IBOutlet weak var notesHairlineHeight: NSLayoutConstraint!

    // MARK: -

    func configure(with viewModel: ClientViewModel) {
        phoneViewHeight.constant = viewModel.hasPhonenumber ? 55 : 0
        phoneView.isHidden = !viewModel.hasPhonenumber
        phoneNumberButton.setTitle(viewModel.phonenumberText, for: .normal)

        vkViewHeight.constant = viewModel.hasVkUrl ? 55 : 0
        vkView.isHidden = !viewModel.hasVkUrl
        vkHairlineHeight.constant = viewModel.hasPhonenumber ? 1.0 / UIScreen.main.scale : 0
        vkUrlButton.setTitle(viewModel.vkUrlText, for: .normal)

        notesViewHeight.constant = viewModel.hasNotes ? 65 : 0
        notesView.isHidden = !viewModel.hasNotes
        notesHairlineHeight.constant = (viewModel.hasPhonenumber || viewModel.hasVkUrl) ? 1.0 / UIScreen.main.scale : 0
        notesLabel.text = viewModel.notesText

        let height = phoneViewHeight.constant + vkViewHeight.constant + notesViewHeight.constant + 50
        frame = CGRect(x: 0, y: 0, width: frame.width, height: height)
    }
}
