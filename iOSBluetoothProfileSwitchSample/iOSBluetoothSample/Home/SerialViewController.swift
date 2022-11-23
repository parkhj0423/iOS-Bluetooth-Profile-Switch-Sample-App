//
//  ViewController.swift
//  BluetoothSwitch
//
//  Created by JHT on 19/05/2021.
//

import UIKit
import AVFAudio
import AVFoundation

class SerialViewController: UIViewController, BluetoothSerialDelegate,AVAudioRecorderDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // BluetoothSerial.swift 파일에 있는 Bluetooth Serial인 serial을 초기화합니다.
        serial = BluetoothSerial.init()
        serial.delegate = self
    }
    
    var audioPlayer : AVAudioPlayer!
    var progressTimer : Timer!
    /// scan 버튼이 클릭되면 호출되는 메서드입니다.
    
    let timePlayerSelector:Selector = #selector(SerialViewController.updatePlayTime)
    
    @IBOutlet weak var connectedPeripheral: UILabel!
    @IBOutlet weak var currentProfile: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    
    
    @IBAction func scanButton(_ sender: Any) {
        // 세그웨이를 호출하여 Scan 뷰를 로드합니다.
        performSegue(withIdentifier: "ScanViewController", sender: nil)
    }
    
    /// 주변기기에 데이터를 전송합니다.
    @IBAction func getCurrentProfile(_ sender: Any) {
        self.currentProfile.text = getCurrentOutPut().rawValue
        self.currentProfile.textColor = .blue
        print("##########################")
        print(getCurrentOutPut().rawValue)
        print("##########################")
    }
    
    //0.1초마다 호출되어 재생 시간 표시
    @objc func updatePlayTime() {
        if audioPlayer != nil {
            progressBar.progress = Float(audioPlayer.currentTime/audioPlayer.duration)
        }
    }
    
    
    @IBAction func playAudio(_ sender: Any) {
        let audioFile : URL = Bundle.main.url(forResource: "sample", withExtension: "mp3")!
        audioPlayer = try! AVAudioPlayer(contentsOf: audioFile)
        progressBar.progress = 0
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timePlayerSelector, userInfo: nil, repeats: true)
        audioPlayer.play()
    }
    
    @IBAction func pauseAudio(_ sender: Any) {
        if audioPlayer != nil {
            audioPlayer.pause()
        }
    }
    
    @IBAction func clearAudio(_ sender: Any) {
        audioPlayer = nil
    }
    
    @IBAction func changeProfileToHFP(_ sender: Any) {
        setAudioSessionToHFP()
    }
    
    @IBAction func changeProfileToA2DP(_ sender: Any) {
        setAudioSessionToA2DP()
    }
    
    public func getCurrentOutPut() -> AVAudioSession.Port {
        return AVAudioSession.sharedInstance().currentRoute.outputs[0].portType
    }
    
    public func setAudioSessionToHFP() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [.allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error transcibing audio: \(error.localizedDescription)")
        }
    }
    
    func setAudioSessionToA2DP() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .videoRecording, options: [.allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error transcibing audio: \(error.localizedDescription)")
        }
    }
    
    //MARK: 시리얼에서 호출되는 Delegate 함수들
    
    /// 데이터가 전송된 후 Peripheral로 부터 응답이 오면 호출되는 메서드입니다.
    func serialDidReceiveMessage(message : String)
    {
        //        // 시리얼의 delegate를 SerialViewController로 설정합니다.
        //        serial.delegate = self
        //        // msg를 설정하고 이를 연결된 Peripheral에 전송하는 메서드를 호출합니다.
        //        let msg = "1"
        //        serial.sendMessageToDevice(msg)
        //        // 라벨의 텍스트를 변경하여 데이터를 기다리는 중이라는 것을 표현합니다.
        connectedPeripheral.text = message
        // 응답으로 온 메시지를 라벨에 표시합니다.
    }
}

