//
//  CaptureImage.swift
//
//  Created by Damerla Bhanu Prakash on 28/02/23.
//

import UIKit
import SwiftUI

struct CaptureImage: UIViewControllerRepresentable {
    
    @Binding var capturedImage: Image?
    @Binding var videoURL: URL?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureImage>) -> UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        imagePicker.videoQuality = .typeHigh
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CaptureImage
        
        init(_ parent: CaptureImage) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let mediaType = info[.mediaType] as? String,
               mediaType == ("public.movie"),
               let url = info[.mediaURL] as? URL {
                parent.videoURL = url
            } else if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = Image(uiImage: image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

