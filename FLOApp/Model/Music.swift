//
//  Music.swift
//  FLOApp
//
//  Created by yc on 2022/01/25.
//

import UIKit

struct Music: Decodable {
    let singer: String
    let album: String
    let title: String
    let duration: Int
    let image: String
    let file: String
    let lyrics: String
    
    var imageURL: URL? {
        return URL(string: image)
    }
    var musicFile: URL? {
        return URL(string: file)
    }
}
