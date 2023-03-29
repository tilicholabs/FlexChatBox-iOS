//
//  ContentView.swift
//  TestSwiftUI
//
//  Created by Aditya Kumar Bodapati on 24/02/23.
//

import SwiftUI
import AVKit
import FlexChatBox
import AVFoundation
import MapKit

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var flexMessages = [FlexOutput]()
    
    @StateObject var audioPlayer = AudioPlayer()
    @State private var isAudioPlaying = false
    @State var flexType: FlexType = .camera
    
    private var themeColor: Color {
        colorScheme == .dark ? .white: .black
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .trailing) {
                        ForEach(0..<flexMessages.count, id: \.self) { index in
                            let message = flexMessages[index]
                            switch message {
                            case .text(let text):
                                textView(text: text)
                            case .camera(let image):
                                imageView(image: image)
                            case .gallery(let media):
                                let images = media.images
                                ForEach(0..<images.count, id: \.self) { index in
                                    imageView(image: images[index])
                                }
                                
                                let videos = media.videos
                                ForEach(0..<videos.count, id: \.self) { index in
                                    videoView(url: videos[index])
                                }
                            case .mic(let audioURL):
                                AudioView(url: audioURL)
                                    .environmentObject(AudioPlayer())
                            case .custom(let string):
                                Text(string)
                            case .location(let location):
                                locationView(location: location)
                            case .contacts(let contacts):
                                contactsView(contacts: contacts)
                            case .files(let filesURLs):
                                ForEach(0..<filesURLs.count, id: \.self) { index in
                                    documentView(url: filesURLs[index])
                                }
                            case .video(let videoURL):
                                videoView(url: videoURL)
                            }
                        }
                    }
                    .rotationEffect(.radians(.pi))
                    .scaleEffect(x: -1, y: 1, anchor: .center)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .rotationEffect(.radians(.pi))
                .scaleEffect(x: -1, y: 1, anchor: .center)
                .animation(.easeInOut(duration: 1), value: flexMessages.count)
                .ignoresSafeArea()
                
                FlexChatBox(flexType: flexType) { self.flexMessages.append($0) }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Image("ironMan")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .cornerRadius(20)
                        
                        Text("Tony Stark")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu(flexType.icon + " \u{276F}") {
                        Button(action: { flexType = .camera }, label: { Text("Camera") })
                        Button(action: { flexType = .gallery }, label: { Text("Gallery") })
                        Button(action: { flexType = .mic }, label: { Text("Mic") })
                        Button(action: { flexType = .location }, label: { Text("Location") })
                        Button(action: { flexType = .contacts }, label: { Text("Contacts") })
                        Button(action: { flexType = .files }, label: { Text("Files") })
                    }
                    .menuStyle(.automatic)
                }
            }
        }
    }
    
    private func textView(text: String) -> some View {
        Text(text)
            .padding(8)
            .flexBackground()
            .flexRoundedCorner()
            .frame(maxWidth: 3 * (UIWindow().bounds.width) / 4, alignment: .trailing)
    }
    
    private func imageView(image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 250)
            .flexRoundedCorner()
    }
    
    private func videoView(url: URL) -> some View {
        let player = AVPlayer(url: url)
        return VideoPlayer(player: player)
            .frame(width: 250, height: 300)
            .flexRoundedCorner()
    }
    
    private func locationView(location: Location) -> some View {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 300,
                                        longitudinalMeters: 300)
        let map = Map(coordinateRegion: .constant(region),
                      annotationItems: [location.coordinate]) { MapMarker(coordinate: $0) }
        
        return Link(destination: location.url) {
            VStack(alignment: .leading) {
                HStack {
                    map
                        .frame(width: 80, height: 80)
                        .cornerRadius(4)
                        .disabled(true)
                    
                    
                    Text("\(location.coordinate.latitude), \(location.coordinate.longitude)")
                        .foregroundColor(themeColor)
                }
                
                Divider()
                
                Text(location.url.absoluteString)
                    .underline()
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(8)
        .flexBackground()
        .flexRoundedCorner()
        .frame(width: 300)
    }
    
    private func documentView(url: URL) -> some View {
        HStack {
            Image(systemName: "doc")
            VStack(alignment: .leading) {
                Text(url.lastPathComponent)
                    .foregroundColor(themeColor)
                Text("\(url.fileSizeString)")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .flexBackground()
        .flexRoundedCorner()
    }
    
    private func contactsView(contacts: [Contact]) -> some View {
        HStack {
            let isSingleContact = contacts.count == 1
            Image(systemName: isSingleContact ? "person.fill": "person.2.fill")
            VStack(alignment: .leading) {
                Text(contacts[0].firstName + contacts[0].lastName)
                    .foregroundColor(themeColor)
                Text(isSingleContact ? contacts[0].phoneNumbers[0]: "and \(contacts.count - 1) other contact" + (contacts.count == 2 ? "": "s"))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .flexBackground()
        .flexRoundedCorner()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
