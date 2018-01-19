import UIKit
import Foundation
import MediaPlayer

open class ViewController: UIViewController , MPMediaPickerControllerDelegate,
UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var playMusic: UILabel!
    @IBOutlet weak var playArtist: UILabel!
    @IBOutlet weak var playAlbum: UILabel!
    @IBOutlet weak var Wifi_Switch: UISwitch!
    @IBOutlet var musictable:UITableView!
    
    @IBOutlet weak var ProgressView: UIProgressView!
    
//    @IBOutlet weak var playButton: UIButton!

    private let ESP8266ServerURL = "http://192.168.0.1"
    
    
    let MAX_GAIN: Float = 24.0
    let MIN_GAIN: Float = -96.0
    
    private var isScanning = false
     var audio = Audio()
    var isplay = false
    var timer = Timer()
    var audioFile: AVAudioFile!
    

    override open func viewDidLoad() {
 
        super.viewDidLoad()
    
    }

    
    func timerUpdate() {
        print("update")
//        var isJson = false
//        var val_reverb : Float = 0.0
//        if(Wifi_Switch.isOn){
//            let url = NSURL(string: self.ESP8266ServerURL)!
//            let task = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error in
//                let json = try! JSON(data: data!)
//                if let time = json["Time"].int {
//                    print(time)
//                    isJson = true
//                    val_reverb = Float(time)
//                }
//                
//            })
//            task.resume()
//            if isJson {
//                audio.sliderReverbChanged(value: val_reverb)
//                SDRReverb.value = val_reverb
//            }
//        }
    }
    
    func timerBegin(){
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) {_ in
//            print("Hello")
            if(self.Wifi_Switch.isOn){
                if let url = NSURL(string: self.ESP8266ServerURL){
                    let task = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error in
                        if( data != nil){
                            let json = try! JSON(data: data!)
                        
                            if let FILTER = json["FILTER"].int {
                                let in_GAIN = FILTER * 24 / 950
                                self.audio.sliderFilter(value: Float(in_GAIN))
                            }
                            if let DELAY = json["DELAY"].float {
                                let in_DELAY = DELAY * 50.0 / 950
                                self.audio.sliderDelayTimeChanged(value: Float(in_DELAY))
                            }
                            if let REVERB = json["REVERB"].int {
                                let in_REVERB = REVERB * 100 / 950
                                self.audio.sliderReverbChanged(value: Float(in_REVERB))
                            }
                            if let BPM = json["BPM"].int {
                                var in_BPM = BPM - 548
                                if(in_BPM < 0){
                                    in_BPM  = in_BPM * 1 / 548 + 1
                                }else{
                                    in_BPM  = in_BPM * 1 / 400 + 1
                                }
                               
                                self.audio.sliderSpeed(value: Float(in_BPM))
                            }
                            if let PITCH = json["PITCH"].int {
//                                let in_PITCH = PITCH * 2400 / 1064 - 1200
                                var in_PITCH = PITCH - 548
                                if(in_PITCH < 0){
                                    in_PITCH  = in_PITCH * 950 / 548
                                }else{
                                    in_PITCH  = in_PITCH * 950 / 400
                                }
                                
                                self.audio.sliderPitch(value: Float(in_PITCH))
                            }
                            if let VOLUME = json["VOLUME"].float {
                                let in_VOLUME = VOLUME * 1.0 / 950
                                self.audio.sliderVolumeChange(value: Float(in_VOLUME))
                                print(in_VOLUME)
                            }
//                            if let WAW = json["WAW"].int {
//                                self.audio.sliderWaw(value: Float(WAW))
//                            }
                            if let EQ0 = json["EQ0"].int {
                                var in_EQ0 = EQ0 - 548
                                if(in_EQ0 < 0){
                                    in_EQ0  = in_EQ0 * 24 / 548
                                }else{
                                    in_EQ0  = in_EQ0 * 24 / 400
                                }
                    
                                self.audio.sliderEq00(value: Float(in_EQ0))
                            }
                            if let EQ1 = json["EQ1"].int {
                                var in_EQ1 = EQ1 - 300
                                if(in_EQ1 < 0){
                                    in_EQ1 = in_EQ1 * 24 / 300
                                }else{
                                    in_EQ1  = in_EQ1 * 24 / 650
                                }
                                self.audio.sliderEq01(value: Float(in_EQ1))
                            }
                            if let EQ2 = json["EQ2"].int {
                                var in_EQ2 = EQ2 - 300
                                if(in_EQ2 < 0){
                                    in_EQ2  = in_EQ2 * 24 / 300
                                }else{
                                    in_EQ2  = in_EQ2 * 24 / 900
                                }
                                self.audio.sliderEq02(value: Float(in_EQ2))
                            }
                            if let BUTTON = json["BUTTON"].int {
                                if(BUTTON == 1){
                                    self.musicPlayPause()
                                }else if(BUTTON == 2){
                                    self.musicNext()
                                }else if(BUTTON == 3){
                                    self.musicBack()
                                }
                            }
                        }else{
                            print("nodata")
                        }
                    })
                    task.resume()
                  
                }
            }
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func change(){
//        tittle.text = audio.music[audio.number]
//        musician.text = audio.musician[audio.number]
//        img.image = audio.artwork[audio.number].image(at: audio.artwork[audio.number].bounds.size)
//        albumName.text = audio.album[audio.number]
    }
    func musicPlayPause() {
        
        if (!isplay){
            audio.buttonPlayPressed(isPlay: false)
//            playButton.setTitle("PAUSE", for: .normal)
            isplay = true
        } else {
            audio.buttonPlayPressed(isPlay: true)
//            playButton.setTitle("PLAY", for: .normal)
            isplay = false
        }
        
        
    }
   func musicNext() {
        audio.musicNext(isPlay: isplay)
        if(audio.audioFile.count > 0){
            playAlbum.text = audio.album[audio.number]
            playImage.image = audio.artwork[audio.number].image(at: audio.artwork[audio.number].bounds.size)
            playArtist.text = audio.musician[audio.number]
            playMusic.text = audio.music[audio.number]
        }
    }
    func musicBack() {
        audio.musicBack(isPlay: isplay)
        if(audio.audioFile.count > 0){
            playAlbum.text = audio.album[audio.number]
            playImage.image = audio.artwork[audio.number].image(at: audio.artwork[audio.number].bounds.size)
            playArtist.text = audio.musician[audio.number]
            playMusic.text = audio.music[audio.number]
        }
    }
 
    
    @IBAction func scanBtnTapp(sender: UISwitch) {
        if sender.isOn{
            timerBegin()
        } else {
            
       
        }
    }
    @IBAction func PlayPressed(sender: UIButton) {
        
        if (!isplay){
            audio.buttonPlayPressed(isPlay: false)
//            playButton.setTitle("PAUSE", for: .normal)
            isplay = true
        } else {
            audio.buttonPlayPressed(isPlay: true)
//            playButton.setTitle("PLAY", for: .normal)
            isplay = false
        }
      

    }
    @IBAction func musicchange(sender: UIButton) {
        audio.musicNext(isPlay: isplay)
        if(audio.audioFile.count > 0){
            playAlbum.text = audio.album[audio.number]
            playImage.image = audio.artwork[audio.number].image(at: audio.artwork[audio.number].bounds.size)
            playArtist.text = audio.musician[audio.number]
            playMusic.text = audio.music[audio.number]
        }
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
    public func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
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

        print("this")
        print(mediaItemCollection.items.count)

        playAlbum.text = audio.album[audio.number]
        playImage.image = audio.artwork[audio.number].image(at: audio.artwork[audio.number].bounds.size)
        playArtist.text = audio.musician[audio.number]
        playMusic.text = audio.music[audio.number]
//
        musictable.reloadData()
        
        ProgressView.alpha = 1.0
        // 1.0
        setProgress(progress: 0.1, animated: true)
    }
    
    //選択がキャンセルされた場合に呼ばれる
    public func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // ピッカーを閉じ、破棄する
        dismiss(animated: true, completion: nil)
        musictable.reloadData()
    }
//
    //Table Viewのセルの数を指定
    public func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return audio.audioFile.count
    }

    //各セルの要素を設定する
    public func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = musictable.dequeueReusableCell(withIdentifier: "musicCell",
                                             for: indexPath)

        
//        let img = UIImage(named: imgArray[indexPath.row] as! String)

        // Tag番号 1 で UIImageView インスタンスの生成
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = audio.artwork[indexPath.row].image(at: audio.artwork[indexPath.row].bounds.size)

        // Tag番号 ２ で UILabel インスタンスの生成
        let label1 = cell.viewWithTag(2) as! UILabel
        label1.text = audio.music[indexPath.row]

        // Tag番号 ３ で UILabel インスタンスの生成
        let label2 = cell.viewWithTag(3) as! UILabel
        label2.text = audio.musician[indexPath.row]


        return cell
    }
    // Cell の高さを１２０にする
    public func tableView(_ table: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        musictable.alpha = 1.0;
        if(audio.audioFile.count == 0){
            return 300.0
        }else{
            return 80.0
        }
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        audio.musicSelect(isPlay: isplay,num: indexPath.row )
        if(audio.audioFile.count > 0){
            playAlbum.text = audio.album[audio.number]
            playImage.image = audio.artwork[audio.number].image(at: audio.artwork[audio.number].bounds.size)
            playArtist.text = audio.musician[audio.number]
            playMusic.text = audio.music[audio.number]
        }
    }

    
    private func setProgress(progress: Float, animated: Bool) {
        CATransaction.setCompletionBlock {
            NSLog("finish animation")
        }
        ProgressView.setProgress(progress, animated: true)
        NSLog("begin animation")
    }

    // セグエ遷移用に追加 ↓↓↓
    @IBAction func goNextBySegue(_ sender:UIButton) {
       self.performSegue(withIdentifier: "toPlayList", sender: nil)
    }
    

}



