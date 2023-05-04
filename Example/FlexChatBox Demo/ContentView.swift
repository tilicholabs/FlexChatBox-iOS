//
//  ContentView.swift
//  TestSwiftUI
//
//  Created by Aditya Kumar Bodapati on 24/02/23.
//

import SwiftUI
import MapKit
import AVKit
import AVFoundation
import FlexChatBox

struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .trailing) {
                        ForEach(0..<viewModel.messages.count, id: \.self) { index in
                            let message = viewModel.messages[index]
                            switch message {
                            case .images(let images):
                                ForEach(0..<images.count, id: \.self) { index in
                                    imageView(image: images[index])
                                }
                            case .videos(let videoURLs):
                                ForEach(0..<videoURLs.count, id: \.self) { index in
                                    videoView(url: videoURLs[index])
                                }
                            case .mic(let audioURL):
                                AudioView()
                                    .environmentObject(AudioPlayer(url: audioURL))
                            case .location(let location):
                                locationView(location: location)
                            case .contacts(let contacts):
                                contactsView(contacts: contacts)
                            case .files(let fileURLs):
                                ForEach(0..<fileURLs.count, id: \.self) { index in
                                    documentView(url: fileURLs[index])
                                }
                            case .text(let text):
                                textView(text: text)
                            }
                        }
                    }
                    .rotationEffect(.radians(.pi))
                    .scaleEffect(x: -1, y: 1, anchor: .center)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .rotationEffect(.radians(.pi))
                .scaleEffect(x: -1, y: 1, anchor: .center)
                .animation(.easeInOut(duration: 1), value: viewModel.messages.count)
                .ignoresSafeArea()
                
                FlexChatBox(flexType: viewModel.flexType) {
                    viewModel.messages.append(.text($0))
                }
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
                    Menu(viewModel.flexType.icon + " \u{276F}") {
                        ForEach(0..<viewModel.listOfFlexTypes.count, id: \.self) { index in
                            Button {
                                viewModel.flexType = viewModel.listOfFlexTypes[index].0
                            } label: { Text(viewModel.listOfFlexTypes[index].1) }
                        }
                    }
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
                        .foregroundColor(.primary)
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
                    .foregroundColor(.primary)
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
                    .foregroundColor(.primary)
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
