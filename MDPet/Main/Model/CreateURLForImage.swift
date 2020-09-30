//
//  CreateURLForImage.swift
//  MDPet
//
//  Created by Philippe on 16/09/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import UIKit

class CreateURLForImage {
    static let shared = CreateURLForImage()

    func writeImage(image: UIImage) -> URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentURL.appendingPathComponent("tempImage.jpg")
        if let imageData = image.pngData() {
            do {
                let _: () = try imageData.write(to: fileURL, options: [.atomic])
            } catch {
                print(error)
            }
        }
        return fileURL
    }
}
