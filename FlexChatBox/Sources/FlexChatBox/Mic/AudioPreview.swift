//
//  AudioPreview.swift
//  FlexChatBox
//
//  Created by Aditya Kumar Bodapati on 30/03/23.
//

import SwiftUI
import AVFoundation

struct AudioPreview: View {
    @EnvironmentObject var player: AudioPlayer
    @State private var timer: Timer?
    @State private var isPlaying = false
    @State private var elapsedTime: Double = 0
    
    let completion: ((Bool) -> Void)
    
    var body: some View {
        HStack {
            Button {
                if player.isPlaying {
                    player.stopPlaying()
                    stopTimer()
                } else {
                    player.startPlaying()
                    startTimer()
                }
            } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill").font(.title)
                    .flexIconFrame()
                    .padding()
                    .foregroundColor(Color.white)
                    .background(.black.opacity(0.75))
                    .flexIconCornerRadius()
            }
            
            VStack {
                Slider(value: $elapsedTime, in: 0...player.duration) { isBegin in
                    DispatchQueue.main.async {
                        guard !isBegin else {
                            self.isPlaying = self.player.isPlaying
                            return
                        }
                        self.player.play(at: elapsedTime)
                        if self.isPlaying {
                            self.player.startPlaying()
                            self.stopTimer()
                            self.startTimer()
                        } else {
                            self.player.stopPlaying()
                            self.stopTimer()
                        }
                    }
                }
                
                HStack {
                    Text(formatTime(at: elapsedTime))
                    Spacer()
                    Text(formatTime(at: player.duration))
                }
            }
            
            Button {
                completion(false)
                player.stopPlaying()
                stopTimer()
            } label: {
                Image(systemName: FlexHelper.xmarkbin)
                    .flexIconFrame()
                    .padding()
                    .foregroundColor(Color.white)
                    .background(Color(hex: FlexHelper.deleteAudioHexColor).opacity(0.75))
                    .flexIconCornerRadius()
            }
            
            Button {
                completion(true)
            } label: {
                Image(systemName: FlexHelper.sendButtonImageName)
                    .flexIconFrame()
                    .padding()
                    .foregroundColor(Color.white)
                    .flexBackground(hex: FlexHelper.sendAudioHexColor)
                    .flexIconCornerRadius()
            }

        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if elapsedTime < player.duration {
                elapsedTime += 1
            } else {
                stopTimer()
                elapsedTime = 0
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(at time: Double) -> String {
        let time = Int(time)
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
