//
//  TrackPlayer.swift
//  lyre-app
//
//  Created by Denis Hackett on 04/07/2023.
//

import AVFoundation
import UIKit

class TrackPlayer {
    var audioEngine: AVAudioEngine
    var audioPlayerNodes: [AVAudioPlayerNode]
    var audioFiles: [AVAudioFile]
    
    var isPlaying: Bool = false
    

    
    init(tracks: [TrackList]) {
        audioEngine = AVAudioEngine()
        audioPlayerNodes = []
        audioFiles = []
        
        print(tracks)
        for i in 0..<tracks.count {
            
            let playerNode1 = AVAudioPlayerNode()
            let playerNode2 = AVAudioPlayerNode()
            let playerNode3 = AVAudioPlayerNode()
                
            guard let trackURL1 = Bundle.main.url(forResource: tracks[i].baseSample, withExtension: "mp3") else{
                print("audio file not found \(tracks[i].baseSample)" )
                return
            }

                let audioFile1 = try! AVAudioFile(forReading: trackURL1)
                audioPlayerNodes.append(playerNode1)
                audioFiles.append(audioFile1)

            
            guard let trackURL2 = Bundle.main.url(forResource: tracks[i].secondarySample, withExtension: "mp3") else {
                print("audio file not found \(tracks[i].secondarySample)" )
                return
            }

                let audioFile2 = try! AVAudioFile(forReading: trackURL2)
                audioPlayerNodes.append(playerNode2)
                audioFiles.append(audioFile2)

            
            guard let trackURL3 = Bundle.main.url(forResource: tracks[i].thirdSample, withExtension: "mp3") else {
                print("audio file not found \(tracks[i].thirdSample)" )
                return
            }

                let audioFile3 = try! AVAudioFile(forReading: trackURL3)
                audioPlayerNodes.append(playerNode3)
                audioFiles.append(audioFile3)


        }
        
        setupAudioEngine()
    }
    
    func setupAudioEngine() {
        let mixer = audioEngine.mainMixerNode
        
        for (index, playerNode) in audioPlayerNodes.enumerated() {
            let audioFile = audioFiles[index]
            
            audioEngine.attach(playerNode)
            audioEngine.connect(playerNode, to: mixer, format: audioFile.processingFormat)
        }
    }
    
    func startPlayback() {
        do {
            try audioEngine.start()
            
            for (index, playerNode) in audioPlayerNodes.enumerated() {
                let audioFile = audioFiles[index]
                
                playerNode.scheduleFile(audioFile, at: nil)
//                playerNode.play()
            }
            
            isPlaying = true
        } catch {
            print("Failed to start playback: \(error)")
        }
        
        playOrPause()
    }
    
    func playOrPause(){
        
        isPlaying.toggle()
        
        if(isPlaying){
            for (_, playerNode) in audioPlayerNodes.enumerated() {
                playerNode.pause()
            }
            print("is paused")
        }
        else {
            
            let offset = 5000000
            guard let hostTime = audioEngine.outputNode.lastRenderTime?.hostTime else {
                print("host time not rendered")
                return
            }
            let scheduleTime = AVAudioTime(hostTime: (hostTime + UInt64(offset)))
            
            
            for (index, playerNode) in audioPlayerNodes.enumerated() {
                
                playerNode.scheduleFile(audioFiles[index], at: scheduleTime, completionHandler: nil)
                playerNode.play(at: scheduleTime)
                //playerNode.play()
            }
            print("is playing")
        }
        
        
    }
    
    func stopPlayback() {
        for playerNode in audioPlayerNodes {
            playerNode.stop()
        }
        
        audioEngine.stop()
        audioEngine.reset()
        
    }
    
    func getPlaybackProgress() -> Float {
        let totalDuration: Float = 100.0 // Set the total duration based on your needs
        var currentTime: Float = 0.0
        
//        for (index, playerNode) in audioPlayerNodes.enumerated() {
            if audioPlayerNodes[0].isPlaying {
                let audioFile = audioFiles[0]
                let sampleRate = Float(audioFile.fileFormat.sampleRate)
                let framePosition = audioPlayerNodes[0].playerTime(forNodeTime: audioPlayerNodes[0].lastRenderTime!)?.sampleTime ?? 0
                currentTime = Float(framePosition) / sampleRate
//                break
            }
//        }
        
        let progress = currentTime / totalDuration
        return progress
    }
    
    func setPlaybackPosition(_ position: Float) {
            guard let audioFile = audioFiles.first else {
                return
            }
            
            let totalFrames = audioFile.length
            let sampleRate = audioFile.fileFormat.sampleRate
            let targetFrame = AVAudioFramePosition(Float(totalFrames) * position)
            let targetTime = Double(targetFrame) / Double(sampleRate)
            
            for playerNode in audioPlayerNodes {
                playerNode.stop()
                playerNode.scheduleSegment(audioFile, startingFrame: targetFrame, frameCount: AVAudioFrameCount(totalFrames), at: nil, completionHandler: nil)
                playerNode.play()
            }
        }
    
    func connectTap(index: Int, completion: @escaping (Float) -> Void) {
        
        var meterLevel: Float = 0
        
        let bufferSize = 1024
        let buffer = AVAudioPCMBuffer(pcmFormat: audioPlayerNodes[index].outputFormat(forBus: 0), frameCapacity: AVAudioFrameCount(bufferSize))!
        
        audioPlayerNodes[index].outputFormat(forBus: 0)
        audioPlayerNodes[index].installTap(onBus: 0,
                                        bufferSize: AVAudioFrameCount(bufferSize),
                                        format: audioPlayerNodes[index].outputFormat(forBus: 0)
        ) { buffer, _ in
            // 3
            guard let channelData = buffer.floatChannelData else {
                return
            }
            let channelDataValue = channelData.pointee
            // 4
            let channelDataValueArray = stride(
                from: 0,
                to: Int(buffer.frameLength),
                by: buffer.stride)
                .map { channelDataValue[$0] }
            
            // 5
            let rms = sqrt(channelDataValueArray.map {
                return $0 * $0
            }
                .reduce(0, +) / Float(buffer.frameLength))
            
            let avgPower = 20 * log10(rms)
            
            meterLevel = self.scaledPower(power: avgPower)
            
            completion(meterLevel)
            
        }
    }
        
    private func scaledPower(power: Float) -> Float {
          guard power.isFinite else {
            return 0.0
          }

          let minDb: Float = -80

          if power < minDb {
            return 0.0
          } else if power >= 1.0 {
            return 1.0
          } else {
            return (abs(minDb) - abs(power)) / abs(minDb)
          }
        }

}
