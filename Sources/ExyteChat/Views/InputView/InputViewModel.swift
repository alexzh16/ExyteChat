//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine
import AVFoundation
import UIKit

@MainActor
final class InputViewModel: ObservableObject {
<<<<<<< HEAD:Sources/ExyteChat/ChatView/InputView/InputViewModel.swift
   let logTAG = "InputViewModel"
   // MARK: - Published Properties
   @Published var attachments = InputViewAttachments()
   @Published var state: InputViewState = .empty
   @Published var documents: [URL] = []
   @Published var showPicker = false
   @Published var showOptionsBanner = false
   @Published var showDocumentPicker = false
   @Published var selectedImage: UIImage?
   @Published var mediaPickerMode = MediaPickerMode.photos
   @Published var showActivityIndicator = false
   
   // MARK: - Callbacks
   var didSendMessage: ((DraftMessage) -> Void)?

   // MARK: - Private Properties
   private let recorder = Recorder()
   var recordingPlayer: RecordingPlayer?
   private var subscriptions = Set<AnyCancellable>()
   private var recordPlayerSubscription: AnyCancellable?
=======

    @Published var text = ""
    @Published var attachments = InputViewAttachments()
    @Published var state: InputViewState = .empty

    @Published var showGiphyPicker = false
    @Published var showPicker = false
  
    @Published var mediaPickerMode = MediaPickerMode.photos

    @Published var showActivityIndicator = false

    var recordingPlayer: RecordingPlayer?
    var didSendMessage: ((DraftMessage) -> Void)?

    private var recorder = Recorder()

    private var saveEditingClosure: ((String) -> Void)?

    private var recordPlayerSubscription: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()
    
    func setRecorderSettings(recorderSettings: RecorderSettings = RecorderSettings()) {
        Task {
            await self.recorder.setRecorderSettings(recorderSettings)
        }
    }
>>>>>>> upstream/main:Sources/ExyteChat/Views/InputView/InputViewModel.swift

    // MARK: - Lifecycle
    func onStart() {
<<<<<<< HEAD:Sources/ExyteChat/ChatView/InputView/InputViewModel.swift
        subscribeToChanges()
    }
  
   func onStop() {
      subscriptions.removeAll()
   }
   
   func reset() {
      DispatchQueue.main.async { [weak self] in
         self?.attachments = InputViewAttachments()
         self?.showPicker = false
         self?.showDocumentPicker = false
         self?.documents = []
         self?.state = .empty
      }
   }
   
   func send() {
      recorder.stopRecording()
      recordingPlayer?.reset()
      sendMessage()
         .store(in: &subscriptions)
   }
   /****/
   func inputViewAction() -> (InputViewAction) -> Void {
      { [weak self] in
         self?.inputViewActionInternal($0)
      }
   }
   
   // MARK: - Action Handling
   private func inputViewActionInternal(_ action: InputViewAction) {
      switch action {
      case .photo:
         mediaPickerMode = .photos
         showPicker = true
      case .add, .camera:
         checkCameraAccess { [weak self] granted in
            DispatchQueue.main.async {
               if granted {
                  self?.mediaPickerMode = .photos
                  self?.showPicker = true
               } else {
                  self?.showError("Camera access denied")
               }
            }
         }
      case .send:
         send()
      case .recordAudioTap:
         handleAudioRecording(.isRecordingTap)
      case .recordAudioHold:
         handleAudioRecording(.isRecordingHold)
      case .recordAudioLock:
         state = .isRecordingTap
      case .stopRecordAudio:
         stopRecording()
      case .deleteRecord:
         deleteRecording()
      case .playRecord:
         playRecording()
      case .pauseRecord:
         pauseRecording()
      case .picker:
         showOptionsBanner.toggle()
      }
   }
   
   func handleAttachmentOptionSelected(option: AttachmentOption) {
      switch option {
      case .photo:
         mediaPickerMode = .photos
         showPicker = true
      case .camera:
         checkCameraAccess { [weak self] granted in
            DispatchQueue.main.async {
               if granted {
                  self?.mediaPickerMode = .photos
                  self?.showPicker = true
               } else {
                  self?.showError("Camera access denied")
               }
            }
         }
      case .file:
         checkFilePermissions { [weak self] granted in
            DispatchQueue.main.async {
               if granted {
                  self?.showDocumentPicker = true
               } else {
                  self?.showError("Access to files is denied")
               }
            }
         }
      }
   }
   
   // MARK: - Document Handling
   func handlePickedDocument(url: URL) {
      // Убедимся, что выбранный файл существует
      guard FileManager.default.fileExists(atPath: url.path) else {
         showError("Selected file does not exist")
         return
      }
      
      debugPrint("\(logTAG) \(#line) \(#function) Picked document: \(url)")
      
      // Попробуем переместить файл в директорию Documents
      do {
         let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(url.lastPathComponent)
         
         // Если файл уже существует по целевому пути, удалим его перед копированием
         if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
         }
         
         try FileManager.default.copyItem(at: url, to: destinationURL)
         documents.append(destinationURL)
         attachments.documents.append(destinationURL)
      } catch {
         showError("Failed to copy document: \(error.localizedDescription)")
      }
   }
   
   // MARK: - Private Helpers
   private func checkFilePermissions(completion: @escaping (Bool) -> Void) {
      // Request access to the user's documents
      completion(true)
   }
   
   private func checkCameraAccess(completion: @escaping (Bool) -> Void) {
      switch AVCaptureDevice.authorizationStatus(for: .video) {
      case .authorized:
         completion(true)
      case .notDetermined:
         AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
               completion(granted)
            }
         }
      default:
         completion(false)
      }
   }
   
   private func handleAudioRecording(_ recordingState: InputViewState) {
      state = recorder.isAllowedToRecordAudio ? recordingState : .waitingForRecordingPermission
      recordAudio()
   }
   
   private func showError(_ message: String) {
      // Implement error display, e.g., via notification or snackbar
      debugPrint("\(logTAG) \(#line) \(#function) Error: \(message)")
   }
   
   private func uploadFileToFirestore(destinationURL: URL) {
      // Загрузка файла в Firebase Storage с миниатюрой
      Task {
         let (fileURL, thumbnailURL) = await UploadingManager.uploadFileWithThumbnail(destinationURL)
         if let fileURL = fileURL {
           debugPrint("\(logTAG) \(#line) \(#function) Uploaded file URL: \(fileURL)")
         } else {
           debugPrint("\(logTAG) \(#line) \(#function) Failed to upload file.")
         }
         if let thumbnailURL = thumbnailURL {
           debugPrint("\(logTAG) \(#line) \(#function) Uploaded thumbnail URL: \(thumbnailURL)")
         } else {
           debugPrint("\(logTAG) \(#line) \(#function) Failed to upload thumbnail.")
         }
      }
   }
   
   private func stopRecording() {
      recorder.stopRecording()
      if attachments.recording != nil {
         state = .hasRecording
      }
      recordingPlayer?.reset()
   }
   
   private func deleteRecording() {
      unsubscribeRecordPlayer()
      recorder.stopRecording()
      attachments.recording = nil
      state = .empty
   }
   
   private func playRecording() {
      guard let recording = attachments.recording else { return }
      state = .playingRecording
      subscribeRecordPlayer()
      recordingPlayer?.play(recording)
   }
   
   private func pauseRecording() {
      state = .pausedRecording
      recordingPlayer?.pause()
   }
   
   func recordAudio() {
      if recorder.isRecording {
         return
      }
      Task { @MainActor in
         attachments.recording = Recording()
         let url = await recorder.startRecording { duration, samples in
            DispatchQueue.main.async { [weak self] in
               self?.attachments.recording?.duration = duration
               self?.attachments.recording?.waveformSamples = samples
            }
         }
         if state == .waitingForRecordingPermission {
            state = .isRecordingTap
         }
         attachments.recording?.url = url
      }
   }
=======
        subscribeValidation()
        subscribePicker()
        subscribeGiphyPicker()
    }

    func onStop() {
        subscriptions.removeAll()
    }

    func reset() {
        DispatchQueue.main.async { [weak self] in
            self?.showPicker = false
            self?.showGiphyPicker = false
            self?.text = ""
            self?.saveEditingClosure = nil
            self?.attachments = InputViewAttachments()
            self?.subscribeValidation()
            self?.state = .empty
        }
    }

    func send() {
        Task {
            await recorder.stopRecording()
            await recordingPlayer?.reset()
            sendMessage()
        }
    }

    func edit(_ closure: @escaping (String) -> Void) {
        saveEditingClosure = closure
        state = .editing
    }

    func inputViewAction() -> (InputViewAction) -> Void {
        { [weak self] in
            self?.inputViewActionInternal($0)
        }
    }
    
    private func inputViewActionInternal(_ action: InputViewAction) {
        switch action {
        case .giphy:
            showGiphyPicker = true
        case .photo:
            mediaPickerMode = .photos
            showPicker = true
        case .add:
            mediaPickerMode = .camera
        case .camera:
            mediaPickerMode = .camera
            showPicker = true
        case .send:
            send()
        case .recordAudioTap:
            Task {
                state = await recorder.isAllowedToRecordAudio ? .isRecordingTap : .waitingForRecordingPermission
                recordAudio()
            }
        case .recordAudioHold:
            Task {
                state = await recorder.isAllowedToRecordAudio ? .isRecordingHold : .waitingForRecordingPermission
                recordAudio()
            }
        case .recordAudioLock:
            state = .isRecordingTap
        case .stopRecordAudio:
            Task {
                await recorder.stopRecording()
                if let _ = attachments.recording {
                    state = .hasRecording
                }
                await recordingPlayer?.reset()
            }
        case .deleteRecord:
            Task {
                unsubscribeRecordPlayer()
                await recorder.stopRecording()
                attachments.recording = nil
            }
        case .playRecord:
            state = .playingRecording
            if let recording = attachments.recording {
                Task {
                    subscribeRecordPlayer()
                    await recordingPlayer?.play(recording)
                }
            }
        case .pauseRecord:
            state = .pausedRecording
            Task {
                await recordingPlayer?.pause()
            }
        case .saveEdit:
            saveEditingClosure?(text)
            reset()
        case .cancelEdit:
            reset()
        }
    }

    private func recordAudio() {
        Task {
            if await recorder.isRecording { return }
        }
        Task { @MainActor [recorder] in
            attachments.recording = Recording()
            let url = await recorder.startRecording { duration, samples in
                DispatchQueue.main.async { [weak self] in
                    self?.attachments.recording?.duration = duration
                    self?.attachments.recording?.waveformSamples = samples
                }
            }
            if state == .waitingForRecordingPermission {
                state = .isRecordingTap
            }
            attachments.recording?.url = url
        }
    }
>>>>>>> upstream/main:Sources/ExyteChat/Views/InputView/InputViewModel.swift
}

private extension InputViewModel {
   
   func validateDraft() {
      DispatchQueue.main.async { [weak self] in
         guard let self = self else { return }
         if !self.attachments.text.isEmpty || !self.attachments.medias.isEmpty {
            self.state = .hasTextOrMedia
         } else if self.attachments.text.isEmpty,
                   self.attachments.medias.isEmpty,
                   self.attachments.recording == nil {
            self.state = .empty
         }
      }
   }
   
   func subscribeRecordPlayer() {
      recordPlayerSubscription = recordingPlayer?.didPlayTillEnd
         .sink { [weak self] in
            self?.state = .hasRecording
         }
   }
   
   func unsubscribeRecordPlayer() {
      recordPlayerSubscription = nil
   }

<<<<<<< HEAD:Sources/ExyteChat/ChatView/InputView/InputViewModel.swift
   private func subscribeToChanges() {
        $attachments
            .sink { [weak self] _ in
                self?.validateDraft()
=======
    func validateDraft() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard state != .editing else { return } // special case
            if !self.text.isEmpty || !self.attachments.medias.isEmpty {
                self.state = .hasTextOrMedia
            } else if self.text.isEmpty,
                      self.attachments.medias.isEmpty,
                      self.attachments.recording == nil {
                self.state = .empty
>>>>>>> upstream/main:Sources/ExyteChat/Views/InputView/InputViewModel.swift
            }
            .store(in: &subscriptions)

<<<<<<< HEAD:Sources/ExyteChat/ChatView/InputView/InputViewModel.swift
=======
    func subscribeValidation() {
        $attachments.sink { [weak self] _ in
            self?.validateDraft()
        }
        .store(in: &subscriptions)

        $text.sink { [weak self] _ in
            self?.validateDraft()
        }
        .store(in: &subscriptions)
    }

    func subscribeGiphyPicker() {
        $showGiphyPicker
            .sink { [weak self] value in
                if !value {
                  self?.attachments.giphyMedia = nil
                }
            }
            .store(in: &subscriptions)
    }
  
    func subscribePicker() {
>>>>>>> upstream/main:Sources/ExyteChat/Views/InputView/InputViewModel.swift
        $showPicker
            .sink { [weak self] value in
                if !value {
                    self?.attachments.medias = []
                }
            }
            .store(in: &subscriptions)

<<<<<<< HEAD:Sources/ExyteChat/ChatView/InputView/InputViewModel.swift
        $documents
            .receive(on: DispatchQueue.global())
            .sink { [weak self] _ in
                self?.validateDraft()
            }
            .store(in: &subscriptions)

        $selectedImage
            .sink { [weak self] image in
                guard let self, let image else { return }
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    let url = self.saveImageToTemporaryDirectory(imageData)
                    let attachment = Attachment(id: UUID().uuidString, url: url, type: .image)
                    self.attachments.attachments.append(attachment)
                    self.send()
                }
            }
            .store(in: &subscriptions)
    }
   
   private func saveImageToTemporaryDirectory(_ data: Data) -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        try? data.write(to: fileURL)
        return fileURL
    }
   
   // MARK: - Message Sending
   func mapAttachmentsForSend() -> AnyPublisher<[Attachment], Never> {
      attachments.medias.publisher
         .receive(on: DispatchQueue.global())
         .asyncMap { media in
            guard let thumbnailURL = await media.getThumbnailURL() else {
               return nil
            }
            
            switch media.type {
            case .image:
               return Attachment(id: UUID().uuidString, url: thumbnailURL, type: .image)
            case .files:
               return Attachment(id: UUID().uuidString, url: thumbnailURL, type: .files)
            case .video:
               guard let fullURL = await media.getURL() else {
                  return nil
               }
               return Attachment(id: UUID().uuidString, thumbnail: thumbnailURL, full: fullURL, type: .video)
            }
            
         }
         .compactMap {
            $0
         }
         .collect()
         .eraseToAnyPublisher()
   }
   
   func mapDocumentsForSend() -> AnyPublisher<[FileAttachment], Never> {
      documents.publisher
         .receive(on: DispatchQueue.global())
         .asyncMap { document in
            // Assume document attachment just requires URL
            FileAttachment(id: UUID().uuidString, url: document, type: .document)
         }
         .collect()
         .eraseToAnyPublisher()
   }
   
   func sendMessage() -> AnyCancellable {
      showActivityIndicator = true
      return Publishers.Zip(mapAttachmentsForSend(), mapDocumentsForSend())
         .compactMap { [attachments] mediaAttachments, documentAttachments in
            DraftMessage(
               text: attachments.text,
               medias: attachments.medias,
               files: documentAttachments,
               recording: attachments.recording,
               replyMessage: attachments.replyMessage,
               createdAt: Date()
            )
         }
         .sink { [weak self] draft in
            DispatchQueue.main.async { [self, draft] in
               self?.showActivityIndicator = false
               self?.didSendMessage?(draft)
               self?.reset()
            }
         }
   }
}

extension Publisher {
   func asyncMap<T>(
      _ transform: @escaping (Output) async -> T
   ) -> Publishers.FlatMap<Future<T, Never>, Self> {
      flatMap { value in
         Future { promise in
            Task {
               let output = await transform(value)
               promise(.success(output))
            }
         }
      }
   }
=======
    func subscribeRecordPlayer() {
        Task { @MainActor in
            if let recordingPlayer {
                recordPlayerSubscription = recordingPlayer.didPlayTillEnd
                    .sink { [weak self] in
                        self?.state = .hasRecording
                    }
            }
        }
    }

    func unsubscribeRecordPlayer() {
        recordPlayerSubscription = nil
    }
}

private extension InputViewModel {

    func sendMessage() {
        showActivityIndicator = true
        let draft = DraftMessage(
            text: self.text,
            medias: attachments.medias,
            giphyMedia: attachments.giphyMedia,
            recording: attachments.recording,
            replyMessage: attachments.replyMessage,
            createdAt: Date()
        )
        didSendMessage?(draft)
        DispatchQueue.main.async { [weak self] in
            self?.showActivityIndicator = false
            self?.reset()
        }
    }
>>>>>>> upstream/main:Sources/ExyteChat/Views/InputView/InputViewModel.swift
}
