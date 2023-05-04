//
//  Media.swift
//
//
//  Created by Aditya Kumar Bodapati on 07/03/23.
//

import SwiftUI

public struct Media {
    public var images: [Image]
    public var videos: [URL]
    
    public init(images: [Image] = [], videos: [URL] = []) {
        self.images = images
        self.videos = videos
    }
}
