//
//  ClientProfileTopView.swift
//  Clients
//
//  Created by Максим Голов on 16.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Представление в верхней части профиля, содержащее фотографию клиента, его имя и фамилию, а так же кнопки для связи и создания записи
@IBDesignable class ClientProfileTopView: UIView {
    
    // MARK: - IBOutlets
    
    /// Фотография клиента
    @IBOutlet weak var photoImageView: UIImageView!
    /// Метка имени и фамилии
    @IBOutlet weak var nameLabel: UILabel!
    /// Кнопка отправки SMS-сообщения
    @IBOutlet weak var messageButton: UIButton!
    /// Метка кнопки отправки SMS-сообщения
    @IBOutlet weak var messageButtonLabel: UIButton!
    /// Кнопка совершения звонка
    @IBOutlet weak var phoneButton: UIButton!
    /// Метка кнопки совершения звонка
    @IBOutlet weak var phoneButtonLabel: UIButton!
    /// Кнопка перехода к профилю в соцсети
    @IBOutlet weak var vkButton: UIButton!
    /// Метка кнопки перехода к профилю в соцсети
    @IBOutlet weak var vkButtonLabel: UIButton!
    /// Предупреждение о том, что клиент находится в черном списке
    @IBOutlet weak var blacklistView: UIView!
    
    /// Высота представления
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    /// Высота фотографии
    @IBOutlet weak var photoHeight: NSLayoutConstraint!
    
    /// Минимальная высота представления
    @IBInspectable var minHeight: CGFloat = 0
    /// Максимальная высота представления
    @IBInspectable var maxHeight: CGFloat = 0

    // MARK: -
    
    /**
     Обновить высоту представления в соответствии со смещением (`offset`) таблицы списка записей
     - Parameter tableOffset: Смещение таблицы списка записей
     
     Изменяет высоту представления в зависимоти от текущего положения списка записей. Высота фотографии клиента так же изменяется в зависимости от высоты представления.
     */
    func updateHeight(tableOffset: CGFloat) {
        viewHeight.constant = max(-tableOffset, minHeight)
        // 45 - минимальная высота фотографии
        // Коэффициенты масштабирования определены эмпирическим путём...
        photoHeight.constant = max(viewHeight.constant * 0.6364 - 22, 45)
        photoImageView.layer.cornerRadius = photoHeight.constant / 2
    }
    
    /// Заполнить представление данными о клиенте
    func configure(with client: Client) {
        photoImageView.image = client.photo ?? UIImage(named: "default_photo")
        nameLabel.text = "\(client)"
        
        messageButton.isEnabled = !client.phonenumber.isEmpty
        phoneButton.isEnabled = !client.phonenumber.isEmpty
        vkButton.isEnabled = !client.vk.isEmpty
        messageButtonLabel.alpha = client.phonenumber.isEmpty ? 0.45 : 1
        phoneButtonLabel.alpha = client.phonenumber.isEmpty ? 0.45 : 1
        vkButtonLabel.alpha = client.vk.isEmpty ? 0.45 : 1
        blacklistView.isHidden = !client.isBlocked
    }
}
