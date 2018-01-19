//
//  secoundViewController.swift
//  sample2
//
//  Created by Satoshi Komatsu on 2017/10/27.
//  Copyright © 2017年 Satoshi Komatsu. All rights reserved.
//

import UIKit


class secoundViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    

    //    var date: Date!
    //    var formatter: DateFormatter!
    @IBOutlet var playlisttable:UITableView!
    @IBOutlet weak var playImage: UIImageView!

    private var controller = ViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    @IBAction func toback(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        playlisttable.reloadData()
        print("pppppp")
    }
   
    
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return controller.audio.audioFile.count
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = playlisttable.dequeueReusableCell(withIdentifier: "playListCell",
                                                  for: indexPath)
        
        
        //        let img = UIImage(named: imgArray[indexPath.row] as! String)
        
        // Tag番号 1 で UIImageView インスタンスの生成
        let imageView = cell.viewWithTag(4) as! UIImageView
        imageView.image = controller.audio.artwork[indexPath.row].image(at: controller.audio.artwork[indexPath.row].bounds.size)
        
        // Tag番号 ２ で UILabel インスタンスの生成
        let label1 = cell.viewWithTag(5) as! UILabel
        label1.text = controller.audio.music[indexPath.row]
        
        // Tag番号 ３ で UILabel インスタンスの生成
        let label2 = cell.viewWithTag(6) as! UILabel
        label2.text = controller.audio.musician[indexPath.row]
        print("ttttttt")
        
        return cell
    }
    // Cell の高さを１２０にする
    func tableView(_ table: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        playlisttable.alpha = 1.0;
        return 200
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
//        
//        audio.musicSelect(isPlay: isplay,num: indexPath.row )
//        if(audio.audioFile.count > 0){
//            playAlbum.text = audio.album[audio.number]
//            playImage.image = audio.artwork[audio.number].image(at: audio.artwork[audio.number].bounds.size)
//            playArtist.text = audio.musician[audio.number]
//            playMusic.text = audio.music[audio.number]
//        }
    }
}

