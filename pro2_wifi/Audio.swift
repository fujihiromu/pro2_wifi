                                                                                                                                                                                                                                                                                                                  
import UIKit
import AVFoundation
import MediaPlayer
                                                                                                                                                                                                                                                                                                                  
open class Audio: NSObject,MPMediaPickerControllerDelegate {
    let MAX_GAIN: Float = 24.0
    let MIN_GAIN: Float = -96.0
    
    var audioEngine: AVAudioEngine!
    var audioFilePlayer: AVAudioPlayerNode!
    var audioReverb: AVAudioUnitReverb!
    var audioDelay: AVAudioUnitDelay!
    var audioSpeed: AVAudioUnitTimePitch!
    var audioUnitEQ = AVAudioUnitEQ(numberOfBands: 9)
    var audioFilter = AVAudioUnitEQ(numberOfBands: 1)
    
    var audioFile = [AVAudioFile!]()
    var number = 0
    var musician = [String]()
    var music = [String]()
    var album = [String]()
    var artwork = [MPMediaItemArtwork]()
    
    override init(){ 
        // AudioEngineの生成
        audioEngine = AVAudioEngine()
        
        // AVPlayerNodeの生成
        audioFilePlayer = AVAudioPlayerNode()
        
//        // AVAudioFileの生成
//        audioFile = try! AVAudioFile(forReading: Bundle.main.url(forResource: "music", withExtension: "mp3")!)
        
        // ReverbNodeの生成
        audioReverb = AVAudioUnitReverb()
        audioReverb.loadFactoryPreset(.largeHall2)
        audioReverb.wetDryMix = 0
        
        // DelayNodeの生成
        audioDelay = AVAudioUnitDelay()
        audioDelay.delayTime = 0.5
        audioDelay.feedback = 70
        audioDelay.lowPassCutoff = 18000
        audioDelay.wetDryMix = 10
        
        // TimePitchの生成
        audioSpeed = AVAudioUnitTimePitch()
        audioSpeed.rate = 1
        
        //Eqの生成
       
        let FREQUENCY: [Float] = [32,64,90,500, 1000, 2500, 4000,8000,16000]
        
        for i in 0...8 {
            audioUnitEQ.bands[i].filterType = .parametric
            
            audioUnitEQ.bands[i].frequency = FREQUENCY[i]
            if(i < 2){
                audioUnitEQ.bands[i].bandwidth = 0.1// half an octave
            }else{
                audioUnitEQ.bands[i].bandwidth = 0.2// half an octave
            }
            audioUnitEQ.bands[i].gain = 0
            audioUnitEQ.bands[i].bypass = false
        }
        
        audioFilter.bands[0].filterType = .parametric
        audioFilter.bands[0].frequency = 400
        audioFilter.bands[0].bandwidth = 0.5// half an octave
        audioFilter.bands[0].gain = 0
        audioFilter.bands[0].bypass = false
        
        
        // AVPlayerNodeとReverbNodeとDelayNodeをAVAudioEngineへ追加
        audioEngine.attach(audioFilePlayer)
        audioEngine.attach(audioReverb)
        audioEngine.attach(audioDelay)
        audioEngine.attach(audioSpeed)
        audioEngine.attach(audioUnitEQ)
        audioEngine.attach(audioFilter)
        // AVPlayerNodeとReverbNodeとDelayNodeをAVAudioEngineへ接続
        for i in 0..<audioFile.count {
            // AVPlayerNodeとReverbNodeとDelayNodeをAVAudioEngineへ接続
            audioEngine.connect(audioFilePlayer, to: audioReverb, format: audioFile[i].processingFormat)
            audioEngine.connect(audioReverb, to: audioDelay, format: audioFile[i].processingFormat)
            audioEngine.connect(audioDelay, to: audioSpeed, format: audioFile[i].processingFormat)
            audioEngine.connect(audioSpeed, to: audioUnitEQ, format: audioFile[i].processingFormat)
            audioEngine.connect(audioUnitEQ, to: audioFilter, format: audioFile[i].processingFormat)
            audioEngine.connect(audioFilter, to: audioEngine.mainMixerNode, format: audioFile[i].processingFormat)
            
            // AVAudioEngineの開始
            try! audioEngine.start()
        }
        
        print(audioEngine.isRunning)
        
    }


    
    public func setPlaylist(mediaItem : MPMediaItemCollection){
        audioFile.removeAll()
        musician.removeAll()
        album.removeAll()
        music.removeAll()
        artwork.removeAll()
        
        audioEngine.stop()
        for i in 0 ..< mediaItem.items.count  {
            do{
                let URL = mediaItem.items[i].assetURL
                let audioFileURL = try! AVAudioFile.init(forReading: URL!)
                audioFile.append(audioFileURL)
                
                musician.append(mediaItem.items[i].artist!)
                album.append(mediaItem.items[i].albumTitle!)
                music.append(mediaItem.items[i].title!)
                
                let artworkView = mediaItem.items[i].artwork  // ジャケット
            
                if let artworkView = mediaItem.items[i].artwork  as? MPMediaItemArtwork {
                    artwork.append(artworkView)
                    // artworkImage に UIImage として保持されている
                }
                
            } catch {
                // エラー発生してプレイヤー作成失敗
                print("error")
                return
            }
 
        }
        
        for i in 0..<audioFile.count {
            audioEngine.connect(audioFilePlayer, to: audioReverb, format: audioFile[i].processingFormat)
            audioEngine.connect(audioReverb, to: audioDelay, format: audioFile[i].processingFormat)
            audioEngine.connect(audioDelay, to: audioSpeed, format: audioFile[i].processingFormat)
            audioEngine.connect(audioSpeed, to: audioUnitEQ, format: audioFile[i].processingFormat)
            audioEngine.connect(audioUnitEQ, to: audioEngine.mainMixerNode, format: audioFile[i].processingFormat)
        }
        // AVAudioEngineの開始
        try! audioEngine.start()
    }
    
    
    public func sliderReverbChanged(value : Float) {
        audioReverb.wetDryMix = value
    }
    
    public func sliderDelayTimeChanged(value : Float){
        audioDelay.delayTime = TimeInterval(value)
    }
    
    public func sliderFeedbackChanged(value : Float){
        audioDelay.feedback = value
    }
    
    public func sliderLowPassCutOff(value : Float) {
        audioDelay.lowPassCutoff = value
    }
    
    public func sliderWetDryMix(value : Float){
        audioDelay.wetDryMix = value
    }
    public func sliderSpeed(value : Float) {
        audioSpeed.rate = value
    }
    
    
    public func buttonPlayPressed(isPlay : Bool) {
        if(audioFile.count > 0){
            if (isPlay) {
                audioFilePlayer.pause()
                
            } else {
                audioFilePlayer.scheduleFile(audioFile[number], at: nil, completionHandler: nil)
                audioFilePlayer.play()
                
            }
        }
    }
    
    public func musicNext(isPlay : Bool){
        if number < audioFile.count - 1 {
            number += 1
        }else{
            number = 0
        }
        if(audioFile.count > 0){
            audioFilePlayer.stop()
            audioFilePlayer.scheduleFile(audioFile[number], at: nil, completionHandler: nil)
            
            if(isPlay){
                audioFilePlayer.play()
            }
        }
    }
    public func musicSelect(isPlay : Bool,num : Int){
        number = num
        if(audioFile.count > 0){
            audioFilePlayer.stop()
            audioFilePlayer.scheduleFile(audioFile[number], at: nil, completionHandler: nil)
            
            if(isPlay){
                audioFilePlayer.play()
            }
        }
    }
    
    public func musicBack(isPlay : Bool){
        if number > 0{
            number -= 1
        }else{
            number = audioFile.count - 1
        }
        if(audioFile.count > 0){
            audioFilePlayer.stop()
            audioFilePlayer.scheduleFile(audioFile[number], at: nil, completionHandler: nil)
            
            if(isPlay){
                audioFilePlayer.play()
            }
        }
    }
    
    public func sliderPitch(value : Float){
        audioSpeed.pitch = value
    }
    

    public func sliderVolumeChange(value : Float){
         audioFilePlayer.volume = value
    }
    
    public func sliderEq00(value : Float){
        
        audioUnitEQ.bands[0].gain = value
        audioUnitEQ.bands[1].gain = value
        //        audioUnitEQ.bands[2].gain = value;
    }
    public func sliderEq01(value : Float){
        audioUnitEQ.bands[3].gain = value
        audioUnitEQ.bands[4].gain = value
        audioUnitEQ.bands[5].gain = value
        print("!!!!")
        print(value)
    }
    public func sliderEq02(value : Float){
        audioUnitEQ.bands[6].gain = value
        audioUnitEQ.bands[7].gain = value
        audioUnitEQ.bands[8].gain = value
    }
    public func sliderFilter(value : Float){
        audioFilter.bands[0].gain = value
    }
    
}
                                                                                                                                                                                                                                                                                                                  
