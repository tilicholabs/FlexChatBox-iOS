//
//  ImagePicker.swift
//
//  Created by Aditya Kumar Bodapati on 02/03/23.
//

import SwiftUI
import PhotosUI

struct Movie: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: UUID().uuidString + FlexHelper.videoExtension)

            if FileManager.default.fileExists(atPath: copy.path()) {
                try FileManager.default.removeItem(at: copy)
            }

            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self.init(url: copy)
        }
    }
}

@MainActor
class ImagePicker: ObservableObject {
    @Published var media = Media()
    @Published var onCompletion: ((Media) -> Void)?
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            Task {
                if !imageSelections.isEmpty {
                    try await loadTransferable(from: imageSelections)
                }
            }
        }
    }
    
    func loadTransferable(from imageSelections: [PhotosPickerItem]) async throws {
        media.images.removeAll()
        media.videos.removeAll()
        for imageSelection in imageSelections {
            if let contentType = imageSelection.supportedContentTypes.first,
               contentType.isSubtype(of: .movie) {
                do {
                    if let movie = try await imageSelection.loadTransferable(type: Movie.self) {
                        media.videos.append(movie.url)
                    }
                } catch {}
            } else {
                do {
                    if let data = try await imageSelection.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            media.images.append(Image(uiImage: uiImage))
                        }
                    }
                } catch {}
            }
        }
        onCompletion?(media)
    }
}
