# FlexChatBox - iOS

## Synopsis
`FlexChatBox` is an iOS SDK using `SwiftUI` framework developed to reduce developer's effort to build chat functionality into their applications. Developers can integrate this SDK into any new or existing applications and use many features to share media content like sending text messages and sharing images from the device gallery, captured photos and videos, audio recording clips, sharing current location, mobile contacts and any other files.

## Repo contents
- This repo contains the source for the SDK and demo app to help integrate the SDK easily.
- Demo app <Add demo app url> module can be used as-is if your requirement exactly fits.

## Installation
To integrate the `FlexChatBox` SDK into your iOS applications, you have to install `Xcode 14.1 or later` on your mac and need `iOS 16 or later` to build and run the application on a simulator or a real device.

### Swift Package Manager
The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the Swift compiler. You can set up the `FlexChatBox` SDK and start building a new project, or you can integrate the SDK in an existing project.

### Steps to install
1. Open your project in Xcode
2. Go to File > Swift Packages > Add Package Dependency...
3. In the field Enter package repository URL, enter "https://github.com/tilicholabs/FlexChatBox-iOS"
4. Pick the latest version and click Next.
5. Choose the packages required for your project and click Finish

## Developer instructions
- A developer can only integrate one `FlexType` at a time from this SDK.
- A developer can place `FlexChatBox View` anywhere on the screen.
- Xcode project should contain info.plist file with Permissions for which flexType you are using. Refer [this](https://www.iosdev.recipes/info-plist/permissions/) for Permission Usage Description Keys.
    * Eg: For the camera, You need to add a key `"NSCameraUsageDescription"` with description in the info.plist file.

## Demo App Features
The feature set includes: 
- Text messages and an integrated type of media message can be obtained from the SDK. We have integrated the various types of media messages required for a chat conversation.
    ### Media message types:
    - TextField
        - A user can send a single line or multiple lines of a text message
        - ![TextFiled](https://user-images.githubusercontent.com/108006729/231765163-9faa99b3-ef79-4cfc-8e72-4d244cee9b50.gif)

    - Camera
        - User can send captured photo or video from this flex type at once
        - In this feature we have the default device preview for captured image and video

                Add "NSCameraUsageDescription" key in info.plist file before using the camera.
        - ![Camera](https://user-images.githubusercontent.com/108006729/231759929-40e95791-269d-4ce4-9906-c243bc2d2db4.gif)
    
    - Gallery
        - User can send single or multiple media (images or videos) from gallery at once
        - A maximum of 30 items can be selected from the gallery
        - ![Gallery](https://user-images.githubusercontent.com/108006729/231942802-f67fb35e-6911-443c-89ec-1e9894b5d245.gif)

    - Audio memo
        - It starts audio recording when the user performs a long press gesture
        - By swiping left, the user can delete the recorded audio clip.
        - There is also a recorded audio preview. In this preview user can decide whether to send or delete
        - A left swipe gesture allows the user to end the recording

                Add "NSMicrophoneUsageDescription" key in info.plist file before using the camera.
        - ![Audio clip](https://user-images.githubusercontent.com/108006729/231943840-4b3c9245-4ebc-4d7c-8bc8-960b5acb6531.gif)

    - Current location
        - User can send his current location.
        - The SDK provides a location object that contains information about the latitude, longitude and google maps url.
        - A preview is shown before sending the user's current location.

                Add "NSLocationAlwaysAndWhenInUseUsageDescription" key in info.plist file before using the camera.
        - ![Location](https://user-images.githubusercontent.com/108006729/231957786-8035cbe7-38aa-4165-8e71-4e71d609ef4e.gif)

    - Contacts
        - User can send single or multiple contacts at once.
        - In this feature we have implemented custom contacts preview.

                Add "NSContactsUsageDescription" key in info.plist file before using the camera.
        - ![Contacts](https://user-images.githubusercontent.com/108006729/231958724-fa0c2178-aa38-438c-9b22-af26f031bc47.gif)

    - Files
        - The user can send single or multiple file items at once. 
        - ![Files](https://user-images.githubusercontent.com/108006729/231960205-4c977878-2da6-4121-82f8-2d6a381388fe.gif)

## Usage
The ChatBox function accepts following enum.

```swift
enum FlexType {
    case camera
    case gallery
    case mic
    case location
    case contacts
    case files
    case custom
}
```
The default flexType is `Camera`.

The developer can expect the flexCompletion which gives and enum called `FlexOutput`. Based on the given flexType, flexOutput holds respective type of the data. For example, if the flexType is camera than flexOutput holds either an Image or a video url.

```swift
import FlexChatBox

# returns "FlexChatBox view"
FlexChatBox(flexType: .camera, 
            placeholder: "Type your text message",
            flexCompletion: { flexOutput in
                switch flexOutput {
                    case .text(let string):
                        // Send textMessage
                    case .camera(let image):
                        // Send image
                    default:
                        return
                }
            })
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

## Roadmap
- `Multi Media Support:` 
    * Currently we only support one media type to be shared from the SDK to the host app. This needs to be defined at the time of SDK initialisation itself. With this feature, developers can just select source type as Multi and the users will be prompted in the app which type of media they would like to share.

- `Custom UI:`
    * With this feature we allow the developers to customise the ChatBox UI to a great extent. Currently we support only colour customisation.

## License
Licensed under the [MIT License](https://github.com/tilicholabs/FlexChatBox-iOS/blob/main/LICENSE).
