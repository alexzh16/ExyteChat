//
//  Created by Alex.M on 07.07.2022.
//

import SwiftUI

<<<<<<<< HEAD:Sources/ExyteChat/Views/MessageView/ExyteChatAvatarView.swift
struct ExyteChatAvatarView: View {
========
struct AvatarImageView: View {
>>>>>>>> upstream/main:Sources/ExyteChat/Views/MessageView/AvatarImageView.swift

    let url: URL?
    let avatarSize: CGFloat
    var avatarCacheKey: String? = nil

    var body: some View {
        CachedAsyncImage(url: url, cacheKey: avatarCacheKey) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle().fill(Color.gray)
        }
        .viewSize(avatarSize)
        .clipShape(Circle())
    }
}

<<<<<<<< HEAD:Sources/ExyteChat/Views/MessageView/ExyteChatAvatarView.swift
struct ExyteChatAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        ExyteChatAvatarView(
========
struct AvatarImageView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarImageView(
>>>>>>>> upstream/main:Sources/ExyteChat/Views/MessageView/AvatarImageView.swift
            url: URL(string: "https://placeimg.com/640/480/sepia"),
            avatarSize: 32
        )
    }
}
