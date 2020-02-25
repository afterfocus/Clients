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

    /// Заполнить представление данными о клиенте
    func configure(with client: Client) {
        phoneViewHeight.constant = client.phonenumber.isEmpty ? 0 : 55
        phoneView.isHidden = client.phonenumber.isEmpty
        phoneNumberButton.setTitle(client.phonenumber.formattedPhoneNumber, for: .normal)

        vkViewHeight.constant = client.vk.isEmpty ? 0 : 55
        vkView.isHidden = client.vk.isEmpty
        vkHairlineHeight.constant = client.phonenumber.isEmpty ? 0 : 1.0 / UIScreen.main.scale
        vkUrlButton.setTitle(client.vk, for: .normal)

        notesViewHeight.constant = client.notes.isEmpty ? 0 : 65
        notesView.isHidden = client.notes.isEmpty
        notesHairlineHeight.constant = (client.phonenumber.isEmpty && client.vk.isEmpty) ? 0 : 1.0 / UIScreen.main.scale
        notesLabel.text = client.notes.isEmpty ? "" : "«\(client.notes)»"

        frame = CGRect(x: 0,
                       y: 0,
                       width: frame.width,
                       height: phoneViewHeight.constant + vkViewHeight.constant + notesViewHeight.constant + 50)
    }
}
