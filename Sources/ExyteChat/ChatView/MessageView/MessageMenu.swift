//
//  MessageMenu.swift
//  
//
//  Created by Alisa Mylnikova on 20.03.2023.
//

import SwiftUI
import FloatingButton
import enum FloatingButton.Alignment
import UIKit // Required for UIPasteboard

enum MessageMenuAction {
    case reply
    case copy
}

struct MessageMenu<MainButton: View>: View {

    @Environment(\.chatTheme) private var theme

    @Binding var isShowingMenu: Bool
    @Binding var menuButtonsSize: CGSize
    var alignment: Alignment
    var leadingPadding: CGFloat
    var trailingPadding: CGFloat
    var mainButton: () -> MainButton
    var onAction: (MessageMenuAction) -> ()
    var messageText: String
    var messageImageURL: URL?

    var body: some View {
        FloatingButton(mainButtonView: mainButton().allowsHitTesting(false), buttons: [
            menuButton(title: "Reply", icon: theme.images.messageMenu.reply, action: .reply),
            menuButton(title: "Copy", icon: Image(systemName: "doc.on.doc"), action: .copy)
        ], isOpen: $isShowingMenu)
        .straight()
        //.mainZStackAlignment(.top)
        .initialOpacity(0)
        .direction(.bottom)
        .alignment(alignment)
        .spacing(2)
        .animation(.linear(duration: 0.2))
        .menuButtonsSize($menuButtonsSize)
    }

    func menuButton(title: String, icon: Image, action: MessageMenuAction) -> some View {
        HStack(spacing: 0) {
            if alignment == .left {
                Color.clear.viewSize(leadingPadding)
            }

            ZStack {
                theme.colors.friendMessage
                    .background(.ultraThinMaterial)
                    .environment(\.colorScheme, .light)
                    .opacity(0.5)
                    .cornerRadius(12)
                HStack {
                    Text(title)
                        .foregroundColor(theme.colors.textLightContext)
                    Spacer()
                    icon
                }
                .padding(.vertical, 11)
                .padding(.horizontal, 12)
            }
            .frame(width: 208)
            .fixedSize()
            .onTapGesture {
                onAction(action)
                if action == .copy {
                    if let url = messageImageURL, let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                        UIPasteboard.general.image = image
                    } else {
                        UIPasteboard.general.string = messageText
                    }
                }
            }

            if alignment == .right {
                Color.clear.viewSize(trailingPadding)
            }
        }
    }
}
