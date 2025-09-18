//
//  Created by Alex.M on 16.06.2022.
//

import Foundation

public enum AttachmentType: String, Codable, Sendable {
    case image
    case video
    case files
    
    public var title: String {
        switch self {
        case .image:
            return "Image"
        case .video:
            return "Video"
        default:
            return "Files"
        }
    }

    public init(mediaType: MediaType) {
        switch mediaType {
        case .image:
            self = .image
        case .video:
            self = .video
        case .files:
            self = .files
        }
    }
}

public struct Attachment: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let thumbnail: URL
    public let full: URL
    public let type: AttachmentType
    public let thumbnailCacheKey: String?
    public let fullCacheKey: String?

    public init(id: String, thumbnail: URL, full: URL, type: AttachmentType, thumbnailCacheKey: String? = nil, fullCacheKey: String? = nil) {
        self.id = id
        self.thumbnail = thumbnail
        self.full = full
        self.type = type
        self.thumbnailCacheKey = thumbnailCacheKey
        self.fullCacheKey = fullCacheKey
    }

    public init(id: String, url: URL, type: AttachmentType, cacheKey: String? = nil) {
        self.init(id: id, thumbnail: url, full: url, type: type, thumbnailCacheKey: cacheKey, fullCacheKey: cacheKey)
    }
}
/*
// Новый enum, включающий новый кейс .files
public enum ExtendedMediaType: String, Codable {
    case image
    case video
    case files
    
    public init(mediaType: MediaType) {
        switch mediaType {
        case .image:
            self = .image
        case .video:
            self = .video
        case .files:
            self = .files
        }
    }
    
    public init(mediaType: MediaType?, defaultType: ExtendedMediaType = .files) {
        if let mediaType = mediaType {
            self.init(mediaType: mediaType)
        } else {
            self = defaultType
        }
    }
}

// Расширение для Media, добавляющее свойство extendedType
public extension Media {
    var extendedType: ExtendedMediaType {
        return ExtendedMediaType(mediaType: self.type)
    }
}
*/
