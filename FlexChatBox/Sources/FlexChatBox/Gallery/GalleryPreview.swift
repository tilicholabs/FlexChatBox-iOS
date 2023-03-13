//
//  GalleryPreview.swift
//
//
//  Created by Aditya Kumar Bodapati on 09/03/23.
//

import SwiftUI
import AVKit

struct GalleryPreview: View {
    
    let media: Media
    @State private var index: Int = 0
    @State private var totalHeight = CGFloat(100)
    @State var images: [Image]
    @State var videos: [URL]
    var onCompletion: (Bool, Media?) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    
    init(media: Media, onCompletion: @escaping (Bool, Media?) -> Void) {
        self.media = media
        self.onCompletion = onCompletion
        _images = State(initialValue: media.images)
        _videos = State(initialValue: media.videos)
        index = media.images.count + media.videos.count
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Spacer()
                
                if images.count + videos.count > 1 {
                    Button(action: {
                        if index < images.count {
                            print(index)
                            images.remove(at: index)
                        } else {
                            print(index)
                            videos.remove(at: index - images.count)
                        }
                    }, label: {
                        Image(systemName: "xmark.bin")
                            .resizable()
                            .frame(width: 20, height: 20)
                    })
                }
                
                Button(action: {
                    onCompletion(false, nil)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                })
            }
            .padding(.trailing, 20)
            .padding(.top, 20)
            
            carouselView
            
            tabView
            
            Button(action: {
                onCompletion(true, Media(images: images, videos: videos))
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "photo.on.rectangle")
                    .resizable()
                    .frame(width: 30, height: 30)
            })
            .padding()
            
            HStack {
                Spacer()
                Button(action: {
                    onCompletion(false, Media(images: images, videos: videos))
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                })
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
    }
    
    @ViewBuilder
    private var carouselView: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer()
                    ForEach(0..<images.count, id: \.self) { index in
                        images[index]
                            .resizable()
                            .border(index == self.index ? Color(.tintColor): Color(.tintColor).opacity(0), width: 1)
                            .frame(width: index == self.index ? 60: 50, height: index == self.index ? 60: 50)
                            .onTapGesture {
                                DispatchQueue.main.async {
                                    self.index = index
                                }
                            }
                    }
                    
                    ForEach(images.count..<videos.count + images.count, id: \.self) { index in
                        thumbnail(from: videos[index - images.count])
                            .resizable()
                            .border(index == self.index ? Color(.tintColor): Color(.tintColor).opacity(0), width: 1)
                            .frame(width: index == self.index ? 60: 50, height: index == self.index ? 60: 50)
                            .onTapGesture {
                                DispatchQueue.main.async {
                                    self.index = index
                                }
                            }
                    }
                    Spacer()
                }
                .padding()
                .frame(width: geometry.size.width)
            }
            .background(GeometryReader { geometry -> Color in
                                DispatchQueue.main.async {
                                    self.totalHeight = geometry.size.height
                                }
                                return Color.clear
                            })
        }
        .frame(height: totalHeight)
    }
    
    @ViewBuilder
    private var tabView: some View {
        TabView(selection: $index) {
            ForEach(0..<images.count, id: \.self) { index in
                ZStack {
                    GeometryReader { geometry in
                        images[index]
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width)
                    }
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            Button(action: {
                                // delete image/video
                            }, label: {
                                Image(systemName: "xmark.bin")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            })
                            
                            Spacer()
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            
            ForEach(images.count..<videos.count + images.count, id: \.self) { index in
                ZStack {
                    GeometryReader { geometry in
                        VideoPlayer(player: AVPlayer(url: videos[index - images.count]))
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width)
                    }
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            Button(action: {
                                // delete image/video
                            }, label: {
                                Image(systemName: "xmark.bin")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            })
                            
                            Spacer()
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            
        }
        .padding()
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    func thumbnail(from url: URL) -> Image {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMake(value: 1, timescale: 2)
        guard let image = try? generator.copyCGImage(at: time, actualTime: nil) else {
            return Image(systemName: "play.fill")
        }
        return Image(image, scale: 1.0, label: Text("Thumbnail"))
    }
}
