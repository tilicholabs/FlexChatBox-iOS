//
//  FlexType.swift
//
//
//  Created by Aditya Kumar Bodapati on 01/03/23.
//

import SwiftUI

public typealias CameraCallback = ((image: Image?, videoURL: URL?)) -> Void
public enum FlexType {
    case camera(CameraCallback)
    case gallery((Media) -> Void)
    case mic((URL) -> Void)
    case location((Location) -> Void)
    case contacts(([Contact]) -> Void)
    case files(([URL]) -> Void)
    case custom((String) -> Void)
    
    func onCompletion<T>(value: T) {
        switch self {
        case .camera(let completion):
            if let image = value as? Image {
                completion((image, nil))
            } else if let videoURL = value as? URL {
                completion((nil, videoURL))
            }
        case .gallery(let completion):
            if let media = value as? Media {
                completion(media)
            }
        case .mic(let completion):
            if let url = value as? URL {
                completion(url)
            }
        case .location(let completion):
            if let location = value as? Location {
                completion(location)
            }
        case .contacts(let completion):
            if let contacts = value as? [Contact] {
                completion(contacts)
            }
        case .files(let completion):
            if let urls = value as? [URL] {
                completion(urls)
            }
        case .custom(let completion):
            if let text = value as? String {
                completion(text)
            }
        }
    }
}

public extension FlexType {
    var icon: String {
        switch self {
        case .camera:
            return FlexHelper.cameraButtonImageName
        case .gallery:
            return FlexHelper.galleryButtonImageName
        case .mic:
            return FlexHelper.micButtonImageName
        case .custom:
            return FlexHelper.customButtonImageName
        case .location:
            return FlexHelper.locationButtonImageName
        case .contacts:
            return FlexHelper.contactsButtonImageName
        case .files:
            return FlexHelper.filesButtonImageName
        }
    }
}

public enum FlexTypeFactory {
    public static func flexCamera(_ onSuccess: @escaping (Image?, URL?) -> Void) -> FlexType {
        .camera { onSuccess($0, $1) }
    }
    
    public static func flexGallery(_ onSuccess: @escaping (Media) -> Void) -> FlexType {
        .gallery { onSuccess($0) }
    }
    
    public static func flexMic(_ onSuccess: @escaping (URL) -> Void) -> FlexType {
        .mic { onSuccess($0) }
    }
    
    public static func flexLocation(_ onSuccess: @escaping (Location) -> Void) -> FlexType {
        .location { onSuccess($0) }
    }
    
    public static func flexContacts(_ onSuccess: @escaping ([Contact]) -> Void) -> FlexType {
        .contacts { onSuccess($0) }
    }
    
    public static func flexFiles(_ onSuccess: @escaping ([URL]) -> Void) -> FlexType {
        .files { onSuccess($0) }
    }
    
    public static func flexCustom(_ onSuccess: @escaping (String) -> Void) -> FlexType {
        .custom { onSuccess($0) }
    }
}
