//
//  ClientTableCell.swift
//  Clients
//
//  Created by Максим Голов on 15.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Ячейка клиента
class ClientTableCell: UITableViewCell {
    
    static let identifier = "ClientTableCell"
    
    // MARK: - IBOutlets
    
    /// Фотография клиента
    @IBOutlet weak var photoImageView: UIImageView!
    /// Метка имени и фамилии клиента
    @IBOutlet weak var nameLabel: UILabel!
    
    
    // MARK: -
    
    /**
    Заполнить ячейку данными
    - Parameter client: Клиент для отображения в ячейке
    */
    func configure(with client: Client) {
        // Выделить жирным шрифтом фамилию
        let attributedText = NSMutableAttributedString(string: "\(client)")
        attributedText.addAttributes([.font : UIFont.systemFont(ofSize: 17, weight: .semibold)], range: NSRange(location: client.name.count + 1, length: client.surname.count))
        nameLabel.attributedText = attributedText
        nameLabel.textColor = client.isBlocked ? .gray : .label
        photoImageView.image = client.photo ?? UIImage(named: "default_photo")
        photoImageView.alpha = client.isBlocked ? 0.6 : 1
    }
}
