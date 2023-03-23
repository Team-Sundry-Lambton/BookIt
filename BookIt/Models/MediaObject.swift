//
//  MediaObject.swift
//  BookIt
//
//  Created by Bao Trieu Thai on 2023-03-23.
//

import Foundation

class MediaObject: NSObject {
    var mediaContent: String?
    var mediaName: String?
    var mediaPath: String?
    
    init(mediaContent: String?, mediaName: String?, mediaPath: String?) {
        self.mediaContent = mediaContent
        self.mediaName = mediaName
        self.mediaPath = mediaPath
    }
}
