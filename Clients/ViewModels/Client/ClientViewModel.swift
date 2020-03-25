//
//  ClientViewModel.swift
//  Clients
//
//  Created by Максим Голов on 06.03.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

class ClientViewModel {
    private let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    var photoImage: UIImage {
        if let photoData = client.photoData {
            return UIImage(data: photoData)!
        } else {
            return UIImage(named: "default_photo")!
        }
    }
    
    var nameText: String {
        return "\(client)"
    }
    
    var attributedNameText: NSMutableAttributedString {
        // Выделить жирным шрифтом фамилию
        let attributedText = NSMutableAttributedString(string: "\(client)")
        attributedText.addAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .semibold)],
                                     range: NSRange(location: client.name.count + 1, length: client.surname.count))
        return attributedText
    }
    
    var phonenumberText: String {
        return client.phonenumber.formattedPhoneNumber
    }
    
    var vkUrlText: String {
        return client.vk
    }
    
    var notesText: String {
        return client.notes.isEmpty ? "" : "«\(client.notes)»"
    }
    
    var hasPhonenumber: Bool {
        return !client.phonenumber.isEmpty
    }
    
    var hasVkUrl: Bool {
        return !client.vk.isEmpty
    }
    
    var hasNotes: Bool {
        return !client.notes.isEmpty
    }
    
    var isBlocked: Bool {
        return client.isBlocked
    }
}
