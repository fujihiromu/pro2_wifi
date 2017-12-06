import UIKit
import Foundation
import MediaPlayer

class ViewController: UIViewController , MPMediaPickerControllerDelegate{
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var tittle: UILabel!
    @IBOutlet weak var musician: UILabel!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var Wifi_Switch: UISwitch!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var SDRReverb: UISlider!

    @IBOutlet weak var SDRWetDryMix: UISlider!
    @IBOutlet weak var SDRSpeed: UISlider!
    @IBOutlet weak var SDRPitch: UISlider!
    @IBOutlet weak var SDRVolume: UISlider!
    
    @IBOutlet weak var EQ00: UISlider!
    @IBOutlet weak var EQ01: UISlider!
    @IBOutlet weak var EQ02: UISlider!
    
    private let ESP8266ServerURL = "http://192.168.0.1"
    
    
    let MAX_GAIN: Float = 24.0
    let MIN_GAIN: Float = -96.0
    
    private var isScanning = false
    var image1: UIImage!
    var image2: UIImage!
    var musicNum = true
    private var audio = Audio()
    var isplay = false
    var timer = Timer()
    var audioFile: AVAudioFile!
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        image1 = UIImage(named:"sakanaction.jpeg")
        image2 = UIImage(named:"alexandoros.jpg")
        EQ00.transform = CGAffineTransform(rotationAngle: CGFloat((-90.0 * M_PI) / 180.0))
        EQ01.transform = CGAffineTransform(rotationAngle: CGFloat((-90.0 * M_PI) / 180.0))
        EQ02.transform = CGAffineTransform(rotationAngle: CGFloat((-90.0 * M_PI) / 180.0))
        SDRReverb.transform = CGAffineTransform(rotationAngle: CGFloat((-90.0 * M_PI) / 180.0))
        SDRPitch.transform = CGAffineTransform(rotationAngle: CGFloat((-90.0 * M_PI) / 180.0))
        SDRSpeed.transform = CGAffineTransform(rotationAngle: CGFloat((-90.0 * M_PI) / 180.0))
        SDRWetDryMix.transform = CGAffineTransform(rotationAngle: CGFloat((-90.0 * M_PI) / 180.0))
        SDRVolume.transform = CGAffineTransform(rotationAngle: CGFloat((-90.0 * M_PI) / 180.0))
        
        ///update 処理
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            if(self.Wifi_Switch.isOn){
                let url = NSURL(string: self.ESP8266ServerURL)!
                let task = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error in
                    let json = try! JSON(data: data!)
                    if let time = json["Time"].int {
                        print(time)
                    }
                    
                })
                task.resume()
            }
            
        })
      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onUpdate(timer : Timer){
        
        if(Wifi_Switch.isOn){
            let url = NSURL(string: self.ESP8266ServerURL)!
            let task = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error in
                let json = try! JSON(data: data!)
                if let time = json["Time"].int {
                    print(time)
                }
                
            })
            task.resume()
        }
    }
    
    func change(){
        
        tittle.text = audio.music[audio.number]
        musician.text = audio.musician[audio.number]
        img.image = audio.artwork[audio.number].image(at: audio.artwork[audio.number].bounds.size)
        
//            var str : String = "0"
//            if(str == "00" ){
//                if (!isplay){
//                    audio.buttonPlayPressed(isPlay: false)
//                    playButton.setTitle("PAUSE", for: .normal)
//                    isplay = true
//                } else {
//                    audio.buttonPlayPressed(isPlay: true)
//                    playButton.setTitle("PLAY", for: .normal)
//                    isplay = false
//                }
//            }else if(str == "01"){
//                audio.musicChanged(isPlay: isplay)
//                if(musicNum){
//                    img.image = image2
//                    tittle.text = "ムーンソング"
//                    musician.text = "[Alexandros]"
//                    albumName.text = "- EXIST! -"
//                    musicNum = !musicNum
//                }else{
//                    img.image = image1
//                    tittle.text = "ミュージック"
//                    musician.text = "サカナクション"
//                    albumName.text = "- sakanaction -"
//                    musicNum = !musicNum
//                }
//            }

    }

    
    @IBAction func scanBtnTapp(sender: UISwitch) {
        if sender.isOn{
         
            let url = NSURL(string: self.ESP8266ServerURL)!
            let task = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error in
                let json = try! JSON(data: data!)
                if let time = json["Time"].int {
                    print(time)
                }
                
            })
            task.resume()
            
        } else {
            
       
        }
    }
    @IBAction func PlayPressed(sender: UIButton) {
        
        if (!isplay){
            audio.buttonPlayPressed(isPlay: false)
            playButton.setTitle("PAUSE", for: .normal)
            isplay = true
        } else {
            audio.buttonPlayPressed(isPlay: true)
            playButton.setTitle("PLAY", for: .normal)
            isplay = false
        }
    }
    @IBAction func musicchange(sender: UIButton) {
        audio.musicChanged(isPlay: isplay)
        
        if(musicNum){
            img.image = image2
            tittle.text = "ムーンソング"
            musician.text = "[Alexandros]"
            albumName.text = "- EXIST! -"
            musicNum = !musicNum
        }else{
            img.image = image1
            tittle.text = "ミュージック"
            musician.text = "サカナクション"
            albumName.text = "- sakanaction -"
            musicNum = !musicNum
        }
        
    }
    
    @IBAction func ReverbChanged(sender: UISlider) {
        audio.sliderReverbChanged(value: SDRReverb.value)
    }
    
    @IBAction func WetDryMix(sender: UISlider) {
        audio.sliderWetDryMix(value: SDRWetDryMix.value)
    }
    @IBAction func Speed(sender: UISlider) {
        audio.sliderSpeed(value: SDRSpeed.value)
    }
    @IBAction func Pitch(sender: UISlider) {
        audio.sliderPitch(value: SDRPitch.value)
    }
    
    @IBAction func Gain_00(sender: UISlider) {
        audio.sliderGain(value: sender.value, num: 0)
    }
    @IBAction func Gain_01(sender: UISlider) {
        audio.sliderGain(value: sender.value, num: 1)
    }
    @IBAction func Gain_02(sender: UISlider) {
        audio.sliderGain(value: sender.value, num: 2)
    }
    @IBAction func Gain_03(sender: UISlider) {
        audio.sliderGain(value: sender.value, num: 3)
    }
    @IBAction func Gain_04(sender: UISlider) {
        audio.sliderGain(value: sender.value, num: 4)
    }
    @IBAction func VolumeChange(_ sender: Any) {
        audio.sliderVolumeChange(value : SDRVolume.value)
    }
    @IBAction func EQChange00(_ sender: Any) {
        audio.sliderEq00(value: EQ00.value)
    }
    @IBAction func EQChange01(_ sender: Any) {
        audio.sliderEq01(value: EQ01.value)
    }
    @IBAction func EQChange02(_ sender: Any) {
        audio.sliderEq02(value: EQ02.value)
    }
    
    
    @IBAction func choicePick(sender: AnyObject) {
        // MPMediaPickerControllerのインスタンスを作成
        let picker = MPMediaPickerController()
        // ピッカーのデリゲートを設定
        picker.delegate = self
        // 複数選択を不可にする。（trueにすると、複数選択できる）
        picker.allowsPickingMultipleItems = true
        // ピッカーを表示する
        present(picker, animated: true, completion: nil)
        
    }
    
    // メディアアイテムピッカーでアイテムを選択完了したときに呼び出される
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        // このfunctionを抜ける際にピッカーを閉じ、破棄する
        // (defer文はfunctionを抜ける際に実行される)
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        
        // 選択した曲情報がmediaItemCollectionに入っている
        // mediaItemCollection.itemsから入っているMPMediaItemの配列を取得できる
        let items = mediaItemCollection.items
        
        if items.isEmpty {
            // itemが一つもなかったので戻る
            return
        }
        
        audio.setPlaylist(mediaItem: mediaItemCollection)
//        // 先頭のMPMediaItemを取得し、そのassetURLからプレイヤーを作成する
    }
    
    //選択がキャンセルされた場合に呼ばれる
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // ピッカーを閉じ、破棄する
        dismiss(animated: true, completion: nil)
    }
    
}



