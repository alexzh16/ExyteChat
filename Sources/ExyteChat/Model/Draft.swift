//
//  Created by Alex.M on 17.06.2022.
//

import Foundation
<<<<<<< HEAD
=======
import GiphyUISDK
import ExyteMediaPicker
>>>>>>> upstream/main

public struct DraftMessage: Sendable {
    public var id: String?
    public let text: String
<<<<<<< HEAD
=======
    public let medias: [Media]
    public let giphyMedia: GPHMedia?
>>>>>>> upstream/main
    public let recording: Recording?
    public let replyMessage: ReplyMessage?
    public var replyToMessageId: String?
    public let createdAt: Date
<<<<<<< HEAD
    public let medias: [Media]
    public let isReadMessage: Bool
    public var files: [FileAttachment]
=======
>>>>>>> upstream/main
    
    public init(id: String? = nil,
                text: String,
                medias: [Media],
<<<<<<< HEAD
                files: [FileAttachment],
=======
                giphyMedia: GPHMedia?,
>>>>>>> upstream/main
                recording: Recording?,
                replyMessage: ReplyMessage?,
                createdAt: Date,
                isReadMessage: Bool? = false,
                replyToMessageId: String? = nil
    ) {
        self.id = id
        self.text = text
        self.medias = medias
<<<<<<< HEAD
        self.files = files
=======
        self.giphyMedia = giphyMedia
>>>>>>> upstream/main
        self.recording = recording
        self.replyMessage = replyMessage
        self.createdAt = createdAt
        self.isReadMessage = isReadMessage ?? false
        self.replyToMessageId = replyToMessageId
    }
}

