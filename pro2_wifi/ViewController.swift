import UIKit
import Foundation
import MediaPlayer

class ViewController: UIViewController , MPMediaPickerControllerDelegate,
UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var playMusic: UILabel!
    @IBOutlet weak var playArtist: UILabel!
    @IBOutlet weak var playAlbum: UILabel!
    @IBOutlet weak var Wifi_Switch: UISwitch!
    @IBOutlet var musictable:UITableView!
    
    @IBOutlet weak var playButton: UIButton!

    private let ESP8266ServerURL = "http://192.168.0.1"
    
    
    let MAX_GAIN: Float = 24.0
    let MIN_GAIN: Float = -96.0
    
    private var isScanning = false
    private var audio = Audio()
    var isplay = false
    var timer = Timer()
    var audioFile: AVAudioFile!
    
//    // section毎の画像配列
//    let imgArray: NSArray = [
//        "img0"]
//
//    let label2Array: NSArray = [
//        "2013/8/23/16:04"]
    
    override func viewDidLoad() {
 
        
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
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {_ in
//            print("Hello")
            if(self.Wifi_Switch.isOn){
                if let url = NSURL(string: self.ESP8266ServerURL){
                    let task = try! URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error in
                        if( data != nil){
                            let json = try! JSON(data: data!)
                            
                            if let BPM = json["BPM"].int {
                                self.audio.sliderSpeed(value: Float(BPM))
                            }
                            if let GAIN = json["GAIN"].int {
                                self.audio.sliderGain(value: Float(GAIN), num: 2)
                            }
                            if let DELAY = json["DELAY"].int {
                                self.audio.sliderDelayTimeChanged(value: Float(DELAY))
                            }
                            if let REVERB = json["REVERB"].int {
                                self.audio.sliderReverbChanged(value: Float(REVERB))
                            }
                            if let PITCH = json["PITCH"].int {
                                self.audio.sliderPitch(value: Float(PITCH))
                            }
                            if let VOLUME = json["VOLUME"].int {
                                self.audio.sliderVolumeChange(value: Float(VOLUME))
                            }
//                            if let WAW = json["WAW"].int {
//                                self.audio.sliderWaw(value: Float(WAW))
//                            }
                            if let EQ0 = json["EQ0"].int {
                                self.audio.sliderEq00(value: Float(EQ0))
                            }
                            if let EQ1 = json["EQ1"].int {
                                self.audio.sliderEq01(value: Float(EQ1))
                            }
                            if let EQ2 = json["EQ2"].int {
                                self.audio.sliderEq02(value: Float(EQ2))
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func change(){
//        tittle.text = audio.music[audio.number]
//        musician.text = audio.musician[audio.number]
//        img.image = audio.artwork[audio.number].image(at: audio.artwork[audio.number].bounds.size)
//        albumName.text = audio.album[audio.number]
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
            playButton.setTitle("PAUSE", for: .normal)
            isplay = true
        } else {
            audio.buttonPlayPressed(isPlay: true)
            playButton.setTitle("PLAY", for: .normal)
            isplay = false
        }
        print(audio.audioFile.count)
    }
    @IBAction func musicchange(sender: UIButton) {
        audio.musicChanged(isPlay: isplay)
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
//        albumName.text = audio.album[audio.number]
//        tittle.text = audio.music[audio.number]
//        musician.text = audio.musician[audio.number]
//        img.image = audio.artwork[audio.number].image(at: audio.artwork[audio.number].bounds.size)
        
        
        
//        playAlbum.text = audio.album[audio.number]
//        playImage.image = audio.artwork[audio.number].image(at: audio.artwork[audio.number].bounds.size)
//        playArtist.text = audio.musician[audio.number]
//        playMusic.text = audio.music[audio.number]
//
        musictable.reloadData()
    }
    
    //選択がキャンセルされた場合に呼ばれる
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // ピッカーを閉じ、破棄する
        dismiss(animated: true, completion: nil)
        musictable.reloadData()
    }
//
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return audio.audioFile.count
    }

    //各セルの要素を設定する
    func tableView(_ table: UITableView,
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
    func tableView(_ table: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

}



