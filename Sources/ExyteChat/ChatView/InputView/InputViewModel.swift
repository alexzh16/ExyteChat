//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine

final class InputViewModel: ObservableObject {
    
    @Published var attachments = InputViewAttachments()
    @Published var state: InputViewState = .empty
    @Published var documents: [URL] = []
    
    @Published var showPicker = false
    @Published var showOptionsBanner: Bool = false
    @Published var showDocumentPicker: Bool = false
    @Published var mediaPickerMode = MediaPickerMode.photos
    
    @Published var showActivityIndicator = false
    
    var recordingPlayer: RecordingPlayer?
    var didSendMessage: ((DraftMessage) -> Void)?
    
    private var recorder = Recorder()
    
    private var recordPlayerSubscription: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()
    
    func onStart() {
        subscribeValidation()
        subscribePicker()
        subscribeDocuments()
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
    
    func inputViewActionInternal(_ action: InputViewAction) {
        switch action {
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
            state = recorder.isAllowedToRecordAudio ? .isRecordingTap : .waitingForRecordingPermission
            recordAudio()
        case .recordAudioHold:
            state = recorder.isAllowedToRecordAudio ? .isRecordingHold : .waitingForRecordingPermission
            recordAudio()
        case .recordAudioLock:
            state = .isRecordingTap
        case .stopRecordAudio:
            recorder.stopRecording()
            if let _ = attachments.recording {
                state = .hasRecording
            }
            recordingPlayer?.reset()
        case .deleteRecord:
            unsubscribeRecordPlayer()
            recorder.stopRecording()
            attachments.recording = nil
        case .playRecord:
            state = .playingRecording
            if let recording = attachments.recording {
                subscribeRecordPlayer()
                recordingPlayer?.play(recording)
            }
        case .pauseRecord:
            state = .pausedRecording
            recordingPlayer?.pause()
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
            mediaPickerMode = .camera
            showPicker = true
        case .file:
            checkFilePermissions { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.showDocumentPicker = true
                    } else {
                        print( "Access to files is denied.")
                    }
                }
            }
            break
        }
    }
        
    private func checkFilePermissions(completion: @escaping (Bool) -> Void) {
        // Request access to the user's documents
        completion(true)
    }

    func handlePickedDocument(url: URL) {
        // Убедимся, что выбранный файл существует
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Selected file does not exist.")
            return
        }
        print("Picked document: \(url)")
        
        // Попробуем переместить файл в директорию Documents
        do {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
            
            // Если файл уже существует по целевому пути, удалим его перед копированием
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.copyItem(at: url, to: destinationURL)
            documents.append(destinationURL)
            attachments.documents.append(destinationURL)
//            uploadFileToFirestore(destinationURL: destinationURL)
            print("File copied to: \(destinationURL)")
        } catch {
            print("Failed to copy document: \(error)")
        }
    }

    private func uploadFileToFirestore(destinationURL: URL) {
        // Загрузка файла в Firebase Storage с миниатюрой
        Task {
            let (fileURL, thumbnailURL) = await UploadingManager.uploadFileWithThumbnail(destinationURL)
            if let fileURL = fileURL {
                print("Uploaded file URL: \(fileURL)")
            } else {
                print("Failed to upload file.")
            }
            if let thumbnailURL = thumbnailURL {
                print("Uploaded thumbnail URL: \(thumbnailURL)")
            } else {
                print("Failed to upload thumbnail.")
            }
        }
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
    
    func subscribeValidation() {
        $attachments.sink { [weak self] _ in
            self?.validateDraft()
        }
        .store(in: &subscriptions)
    }
    
    func subscribePicker() {
        $showPicker
            .sink { [weak self] value in
                if !value {
                    self?.attachments.medias = []
                }
            }
            .store(in: &subscriptions)
    }    
    
    func subscribeDocuments() {
        $documents
            .receive(on: DispatchQueue.global())
            .sink { [weak self] _ in
                self?.validateDraft()
            }
            .store(in: &subscriptions)
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
}

private extension InputViewModel {
    
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
}
