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
    
    func configure(with viewModel: ClientViewModel) {
        photoImageView.image = viewModel.photoImage
        photoImageView.alpha = viewModel.isBlocked ? 0.6 : 1
        nameLabel.attributedText = viewModel.attributedNameText
        nameLabel.textColor = viewModel.isBlocked ? .gray : .label
    }
}
