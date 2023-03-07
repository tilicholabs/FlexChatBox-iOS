//
//  CaptureImage.swift
//
//  Created by Damerla Bhanu Prakash on 28/02/23.
//

import UIKit
import SwiftUI

struct CaptureImage: UIViewControllerRepresentable {
    
    @Binding var capturedImage: Image?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureImage>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<CaptureImage>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CaptureImage
        
        init(_ parent: CaptureImage) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.capturedImage = Image(uiImage: image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

