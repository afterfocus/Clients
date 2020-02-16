//
//  UIImageExtension.swift
//  Clients
//
//  Created by Максим Голов on 17.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

extension UIImage {
    /// Масштабирует изобрежение до заданного размера `size * size`
    func resize(toWidthAndHeight size: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: size, height: size))
        draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
