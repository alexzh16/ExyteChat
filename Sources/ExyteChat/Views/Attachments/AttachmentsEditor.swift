//
//  AttachmentsEditor.swift
//  Chat
//
//  Created by Alex.M on 22.06.2022.
//

import SwiftUI
import ActivityIndicatorView

struct AttachmentsEditor<InputViewContent: View>: View {
<<<<<<< HEAD:Sources/ExyteChat/ChatView/Attachments/AttachmentsEditor.swift
   let logTAG = "AttachmentsEditor"
   
   typealias InputViewBuilderClosure = ChatView<EmptyView, InputViewContent>.InputViewBuilderClosure
   
   @Environment(\.chatTheme) var theme
   @Environment(\.mediaPickerTheme) var pickerTheme
   
   @EnvironmentObject private var keyboardState: KeyboardState
   @EnvironmentObject private var globalFocusState: GlobalFocusState
   
   @ObservedObject var inputViewModel: InputViewModel
   
   var inputViewBuilder: InputViewBuilderClosure?
   var chatTitle: String?
   var messageUseMarkdown: Bool
   var orientationHandler: MediaPickerOrientationHandler
   var mediaPickerSelectionParameters: MediaPickerParameters?
   var availableInput: AvailableInputType
   
   @State private var seleсtedMedias: [Media] = []
   @State private var currentFullscreenMedia: Media?
   @State private var showDocumentPicker: Bool = false
   
   var showingAlbums: Bool {
      inputViewModel.mediaPickerMode == .albums
   }
   
   var body: some View {
      ZStack {
         if inputViewModel.showDocumentPicker {
            documentPicker
         } else {
=======
    
    typealias InputViewBuilderClosure = ChatView<EmptyView, InputViewContent, DefaultMessageMenuAction>.InputViewBuilderClosure
    
    @Environment(\.chatTheme) var theme
    @Environment(\.mediaPickerTheme) var mediaPickerTheme
    @Environment(\.mediaPickerThemeIsOverridden) var mediaPickerThemeIsOverridden

    @EnvironmentObject private var keyboardState: KeyboardState
    @EnvironmentObject private var globalFocusState: GlobalFocusState

    @ObservedObject var inputViewModel: InputViewModel

    var inputViewBuilder: InputViewBuilderClosure?
    var chatTitle: String?
    var messageStyler: (String) -> AttributedString
    var orientationHandler: MediaPickerOrientationHandler
    var mediaPickerSelectionParameters: MediaPickerParameters?
    var availableInputs: [AvailableInputType]
    var localization: ChatLocalization

    @State private var seleсtedMedias: [Media] = []
    @State private var currentFullscreenMedia: Media?

    var showingAlbums: Bool {
        inputViewModel.mediaPickerMode == .albums
    }

    var body: some View {
        ZStack {
>>>>>>> upstream/main:Sources/ExyteChat/Views/Attachments/AttachmentsEditor.swift
            mediaPicker
         }
         
         if inputViewModel.showActivityIndicator {
            ActivityIndicator()
         }
      }
   }
   
   var documentPicker: some View {
      DocumentPickerView(isPresented: $showDocumentPicker) { url in
         inputViewModel.handlePickedDocument(url: url)
         showDocumentPicker = false
         assembleSelectedMedia()
      }
      .onAppear {
         showDocumentPicker = true
      }
      .onChange(of: showDocumentPicker) { newValue, _ in
         assembleSelectedMedia()
      }
      .onChange(of: inputViewModel.showDocumentPicker) {
         debugPrint("\(logTAG) \(#line) \(#function) showDocumentPicker")
      }
   }
   
   
   var mediaPicker: some View {
      GeometryReader { g in
         MediaPicker(isPresented: $inputViewModel.showPicker) {
            seleсtedMedias = $0
            assembleSelectedMedia()
         } albumSelectionBuilder: { _, albumSelectionView, _ in
            VStack {
               albumSelectionHeaderView
                  .padding(.top, g.safeAreaInsets.top)
               albumSelectionView
               Spacer()
               inputView
                  .padding(.bottom, g.safeAreaInsets.bottom)
            }
<<<<<<< HEAD:Sources/ExyteChat/ChatView/Attachments/AttachmentsEditor.swift
            .background(pickerTheme.main.albumSelectionBackground)
            .ignoresSafeArea()
         } cameraSelectionBuilder: { _, cancelClosure, cameraSelectionView in
            VStack {
               cameraSelectionHeaderView(cancelClosure: cancelClosure)
                  .padding(.top, g.safeAreaInsets.top)
               cameraSelectionView
               Spacer()
               inputView
                  .padding(.bottom, g.safeAreaInsets.bottom)
            }
            .ignoresSafeArea()
         }
         .didPressCancelCamera {
            inputViewModel.showPicker = false
         }
         .currentFullscreenMedia($currentFullscreenMedia)
         .showLiveCameraCell()
         .setSelectionParameters(mediaPickerSelectionParameters)
         .pickerMode($inputViewModel.mediaPickerMode)
         .orientationHandler(orientationHandler)
         .padding(.top)
         .background(pickerTheme.main.albumSelectionBackground)
         .ignoresSafeArea(.all)
         .onChange(of: currentFullscreenMedia) { newValue, _ in
            assembleSelectedMedia()
         }
         .onChange(of: inputViewModel.showPicker) {
            let showFullscreenPreview = mediaPickerSelectionParameters?.showFullscreenPreview ?? true
            let selectionLimit = mediaPickerSelectionParameters?.selectionLimit ?? 1
            
            if selectionLimit == 1 && !showFullscreenPreview {
               assembleSelectedMedia()
               inputViewModel.send()
            }
         }
      }
   }
   
   func assembleSelectedMedia() {
      if !seleсtedMedias.isEmpty {
         inputViewModel.attachments.medias = seleсtedMedias
      } else if let media = currentFullscreenMedia {
         inputViewModel.attachments.medias = [media]
      } else if let selectedDocument = inputViewModel.attachments.documents.first {
         // Assuming documents are of type Media. Adjust this if documents should be treated separately.
         inputViewModel.attachments.medias = [ExyteChatMedia(source: URLMediaModel(url: selectedDocument))]
         inputViewModel.send()
      }
      else {
         inputViewModel.attachments.medias = []
      }
   }
   
   @ViewBuilder
   var inputView: some View {
      Group {
         if let inputViewBuilder = inputViewBuilder {
            inputViewBuilder($inputViewModel.attachments.text, inputViewModel.attachments, inputViewModel.state, .signature, inputViewModel.inputViewAction()) {
               globalFocusState.focus = nil
            }
         } else {
            InputView(
               viewModel: inputViewModel,
               inputFieldId: UUID(),
               style: .signature,
               availableInput: availableInput,
               messageUseMarkdown: messageUseMarkdown
            )
         }
      }
   }
   
   var albumSelectionHeaderView: some View {
      ZStack {
         HStack {
            Button {
               seleсtedMedias = []
               inputViewModel.showPicker = false
            } label: {
               Text("Cancel")
                  .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
         }
         
         HStack {
            Text("Recents")
            Image(systemName: "chevron.down")
               .rotationEffect(Angle(radians: showingAlbums ? .pi : 0))
         }
         .foregroundColor(.white)
         .onTapGesture {
            withAnimation {
               inputViewModel.mediaPickerMode = showingAlbums ? .photos : .albums
            }
         }
         .frame(maxWidth: .infinity)
      }
      .padding(.horizontal)
      .padding(.bottom, 5)
   }
   
   func cameraSelectionHeaderView(cancelClosure: @escaping ()->()) -> some View {
      HStack {
         Button {
            cancelClosure()
         } label: {
            theme.images.mediaPicker.cross
         }
         .padding(.trailing, 30)
         
         if let chatTitle = chatTitle {
            theme.images.mediaPicker.chevronRight
            Text(chatTitle)
               .font(.title3)
               .foregroundColor(theme.colors.textMediaPicker)
         }
         
         Spacer()
      }
      .padding(.horizontal)
      .padding(.bottom, 10)
   }
=======
        }
    }

    var mediaPicker: some View {
        GeometryReader { g in
            MediaPicker(isPresented: $inputViewModel.showPicker) {
                seleсtedMedias = $0
                assembleSelectedMedia()
            } albumSelectionBuilder: { _, albumSelectionView, _ in
                VStack {
                    albumSelectionHeaderView
                        .padding(.top, g.safeAreaInsets.top)
                    albumSelectionView
                    Spacer()
                    inputView
                        .padding(.bottom, g.safeAreaInsets.bottom)
                }
                .background(mediaPickerTheme.main.pickerBackground.ignoresSafeArea())
            } cameraSelectionBuilder: { _, cancelClosure, cameraSelectionView in
                VStack {
                    cameraSelectionView
                        .overlay(alignment: .top) {
                            cameraSelectionHeaderView(cancelClosure: cancelClosure)
                                .padding(.top, 12)
                        }
                        .padding(.top, g.safeAreaInsets.top)
                    Spacer()
                    inputView
                        .padding(.bottom, g.safeAreaInsets.bottom)
                }
                .background(mediaPickerTheme.main.pickerBackground.ignoresSafeArea())
            }
            .didPressCancelCamera {
                inputViewModel.showPicker = false
            }
            .currentFullscreenMedia($currentFullscreenMedia)
            .liveCameraCell(.small)
            .setSelectionParameters(mediaPickerSelectionParameters)
            .pickerMode($inputViewModel.mediaPickerMode)
            .orientationHandler(orientationHandler)
            .padding(.top)
            .background(theme.colors.mainBG)
            .ignoresSafeArea(.all)
            .onChange(of: currentFullscreenMedia) {
                assembleSelectedMedia()
            }
            .onChange(of: inputViewModel.showPicker) {
                let showFullscreenPreview = mediaPickerSelectionParameters?.showFullscreenPreview ?? true
                let selectionLimit = mediaPickerSelectionParameters?.selectionLimit ?? 1

                if selectionLimit == 1 && !showFullscreenPreview {
                    assembleSelectedMedia()
                    inputViewModel.send()
                }
            }
            .applyIf(!mediaPickerThemeIsOverridden) {
                $0.mediaPickerTheme(
                    main: .init(
                        pickerText: theme.colors.mainText,
                        pickerBackground: theme.colors.mainBG,
                        fullscreenPhotoBackground: theme.colors.mainBG
                    ),
                    selection: .init(
                        accent: theme.colors.sendButtonBackground
                    )
                )
            }
        }
    }

    func assembleSelectedMedia() {
        if !seleсtedMedias.isEmpty {
            inputViewModel.attachments.medias = seleсtedMedias
        } else if let media = currentFullscreenMedia {
            inputViewModel.attachments.medias = [media]
        } else {
            inputViewModel.attachments.medias = []
        }
    }

    @ViewBuilder
    var inputView: some View {
        Group {
            if let inputViewBuilder = inputViewBuilder {
                inputViewBuilder(
                    $inputViewModel.text, inputViewModel.attachments, inputViewModel.state,
                    .signature, inputViewModel.inputViewAction()
                ) {
                    globalFocusState.focus = nil
                }
            } else {
                InputView(
                    viewModel: inputViewModel,
                    inputFieldId: UUID(),
                    style: .signature,
                    availableInputs: availableInputs,
                    messageStyler: messageStyler,
                    localization: localization
                )
            }
        }
    }

    var albumSelectionHeaderView: some View {
        ZStack {
            HStack {
                Button {
                    seleсtedMedias = []
                    inputViewModel.showPicker = false
                } label: {
                    Text(localization.cancelButtonText)
                }

                Spacer()
            }

            HStack {
                Text(localization.recentToggleText)
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(radians: showingAlbums ? .pi : 0))
            }
            .onTapGesture {
                withAnimation {
                    inputViewModel.mediaPickerMode = showingAlbums ? .photos : .albums
                }
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundColor(mediaPickerTheme.main.pickerText)
        .padding(.horizontal)
        .padding(.bottom, 5)
    }

    func cameraSelectionHeaderView(cancelClosure: @escaping ()->()) -> some View {
        HStack {
            Button(action: cancelClosure) {
                theme.images.mediaPicker.cross
                    .imageScale(.large)
            }
            .tint(mediaPickerTheme.main.pickerText)
            .padding(.trailing, 30)

            if let chatTitle = chatTitle {
                theme.images.mediaPicker.chevronRight
                Text(chatTitle)
                    .font(.title3)
                    .foregroundColor(mediaPickerTheme.main.pickerText)
            }

            Spacer()
        }
        .padding(.horizontal)
    }
>>>>>>> upstream/main:Sources/ExyteChat/Views/Attachments/AttachmentsEditor.swift
}
