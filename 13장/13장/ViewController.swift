//
//  ViewController.swift
//  13장
//
//  Created by 203a21 on 2022/05/20.
//

import UIKit
import AVFoundation
class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    var audioPlayer : AVAudioPlayer!    //AVAudioPlayer 인스턴스 변수
    var audioFile : URL!    // 재생할 오디오의 파일명 변수
    let MAX_VOLUME : Float = 10.0   // 최대 볼륨, 실수형 상수
    var progressTimer : Timer!  // 타이머를 위한 변수
    
    let timePlayerSelector:Selector = #selector(ViewController.updatePlayTime)
    let timeRecordSelector:Selector = #selector(ViewController.updateRecordTime)
    
    @IBOutlet var pvProgressPlay: UIProgressView!
    @IBOutlet var lblCurrentTime: UILabel!
    @IBOutlet var lblEndTime: UILabel!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnPause: UIButton!
    @IBOutlet var btnStop: UIButton!
    @IBOutlet var slVolume: UISlider!
    
    
    @IBOutlet var btnRecord: UIButton!
    @IBOutlet var lblRecordTime: UILabel!
    
    var audioRecorder : AVAudioRecorder!    // audioRecorder 인스턴스를 추가합니다.
    var isRecordMode = false    // "녹음 모드"라는 것을 나타낼 isRecordMode를 추가합니다. 기본값은 false로 하여 처음 시뮬레이터를 구동했을 때 "녹음 모드"가 아닌 "재생 모드"가 나타나게 합니다.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        selectAudioFile()
        if !isRecordMode    {
            initPlay()
            btnRecord.isEnabled = false
            lblRecordTime.isEnabled = false
        }   else    {
            initRecord()
        }
    }
    
    // selectAudioFile 함수를 작성합니다.
    func selectAudioFile()  {
        if !isRecordMode    {
            audioFile = Bundle.main.url(forResource: "Real Love", withExtension: "mp3") // 재생 모드일때는 오디오 파일인 오마이걸의 "Real Love"가 선택됩니다.
    }  else    {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]   // 녹음 모드알때는 녹음 파일인 "recordFile.m4a"가 생성됩니다.
        audioFile = documentDirectory.appendingPathComponent("recordFile.m4a")
    }
}
    // initRecord 함수를 작성합니다.
    func initRecord()   {
        let recordSettings  =   [
            AVFormatIDKey : NSNumber(value: kAudioFormatAppleLossless as UInt32),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey : 2,
            AVSampleRateKey : 44100.0] as [String : Any]
        do  {
            audioRecorder = try AVAudioRecorder(url: audioFile, settings: recordSettings)
        }   catch let error as NSError  {
            print("Error-initRecord : \(error)")
        }
        audioRecorder.delegate = self   // audioRecorder의 델리게이트를 self로 설정합니다.
        slVolume.value = 1.0    // 볼륨 슬라이더 값을 1.0으로 설정합니다.
        audioPlayer.volume = slVolume.value // audioPlayer의 볼륨도 슬라이더 값과 동일하게 1.0으로 설정합니다.
        lblEndTime.text = convertNSTimeInterval2string(0)   // 총 재생시간을 0으로 바꿉니다.
        lblCurrentTime.text = convertNSTimeInterval2string(0)   // 현재 재생시간을 0으로 바꿉니다
        setPlayButtons(false, pause: false, stop: false)    // 모든 버튼을 비활성화합니다.
        
        let session = AVAudioSession.sharedInstance()
        do  {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        }   catch let error as NSError  {
            print(" Error-setCategory : \(error)")
        }
        do  {
            try session.setActive(true)
        }   catch let error as NSError  {
            print(" Error-setActive : \(error)")
        }
    }
    // initPlay 함수를 작성합니다.
    func initPlay() {
        do  {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
        }   catch let error as NSError  {
            print("Error-initPlay : \(error)")
        }
        slVolume.maximumValue = MAX_VOLUME  // 슬라이더의 최대 볼륨을 상수 MAX_VOLUME인 10.0으로 초기화합니다.
        slVolume.value = 1.0    // 슬라이더의 볼륨을 1.0으로 초기화합니다.
        pvProgressPlay.progress = 0 // 진행바의 진행값을 0으로 초기화합니다.
    
        audioPlayer.delegate = self // audioplayer의 delegate를 self로 합니다.
        audioPlayer.prepareToPlay() // prepareToPlay를 실행합니다.
        audioPlayer.volume = slVolume.value // audioPlayer의 볼륨을 방금 앞에서 초기화한 슬라이더의 볼륨 값 1.0으로 초기화합니다.
        
        lblEndTime.text = convertNSTimeInterval2string(audioPlayer.duration)
        lblCurrentTime.text = convertNSTimeInterval2string(0)
        setPlayButtons(true, pause: false, stop: false)
        btnPlay.isEnabled = true
        btnPause.isEnabled = false
        btnStop.isEnabled = false
    }
    
    // setPlayButtons 함수를 작성합니다.
    func setPlayButtons(_ play:Bool, pause:Bool, stop:Bool) {
        btnPlay.isEnabled = play
        btnPause.isEnabled = pause
        btnStop.isEnabled = stop
    }
    
    // convertNSTimeInterval2string 함수를 작성합니다.
    func convertNSTimeInterval2string(_ time:TimeInterval) -> String {
        let min = Int(time/60)  // time 값을 60으로 나눈 몫을 정수형으로 변환하여 상수 min값에 초기화합니다.
        let sec = Int(time.truncatingRemainder(dividingBy: 60)) // time을 60으로 나눈 나머지 값을 정수형으로 변환하여 상수 sec값에 초기화합니다.
        let strTime = String(format: "%02d:%02d", min, sec) // 두 값을 활용해 문자열 표시 형태를 지정하고 문자열 형태로 변환하여 상수 strTime에 초기화합니다.
        return strTime  // strTime값을 return 시킨다.
    }
    
    @IBAction func btnPlayAudio(_ sender: UIButton) {
        audioPlayer.play()  // 함수를 실행해 오디오를 재생합니다.
        setPlayButtons(false, pause: true, stop: true)  // play버튼 비활성화, 나머지 두 버튼은 활성화합니다.
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timePlayerSelector, userInfo: nil, repeats: true)
    }
    
    // 오브젝티브 C에서 인식하기 위해서 @objc를 붙여주고 updatePlayTime 함수를 작성합니다.
    @objc func updatePlayTime()   {
        lblCurrentTime.text = convertNSTimeInterval2string(audioPlayer.currentTime) // 재생시간을 레이블에 나타냅니다.
        pvProgressPlay.progress = Float(audioPlayer.currentTime/audioPlayer.duration)
    }

    @IBAction func btnPauseAudio(_ sender: UIButton) {
        audioPlayer.pause()
        setPlayButtons(true, pause: false, stop: true)
    }
    
    @IBAction func btnStopAudio(_ sender: UIButton) {
        audioPlayer.stop()
        audioPlayer.currentTime = 0 // 오디오를 정지하고 다시 재생하면 처음부터 재생해야하므로 audioPlayer.currentTime 값을 0으로 초기화합니다.
        lblCurrentTime.text = convertNSTimeInterval2string(0)   // 재생시간도 초기화합니다.
        setPlayButtons(true, pause: false, stop: false)
        progressTimer.invalidate()  // 타이머를 무효화합니다.
    }
    
    @IBAction func slChangeVolume(_ sender: UISlider) {
        audioPlayer.volume = slVolume.value
    }
    
    // audioPlayerDidFinishPlaying 함수를 작성합니다.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        progressTimer.invalidate()  // 타이머를 무효화합니다.
        setPlayButtons(true, pause: false, stop: false) // play버튼 활성화, 나머지 두 버튼은 비활성화합니다.
    }
    
    @IBAction func swRecordMode(_ sender: UISwitch) {
        if sender.isOn  {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
            lblRecordTime!.text = convertNSTimeInterval2string(0)
            isRecordMode = true
            btnRecord.isEnabled = true
            lblRecordTime.isEnabled = true
        }   else    {
            isRecordMode = false
            btnRecord.isEnabled = false
            lblRecordTime.isEnabled = false
            lblRecordTime.text = convertNSTimeInterval2string(0)
        }
        selectAudioFile()   //  모드에 따라 오디오 파일을 선택함
        if !isRecordMode    {   // 녹음코드가 아닐 때(재생모드인 경우)
            initPlay()
        }   else    {   // 녹음모드일때
            initRecord()
        }
    }
    
    @IBAction func btnRecord(_ sender: UIButton) {
        // 버튼이 "Record"일 때 녹음을 중지합니다.
        if (sender as AnyObject).titleLabel?.text == "Record"   {
            audioRecorder.record()
            (sender as AnyObject).setTitle("Stop", for: UIControl.State())
            progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timeRecordSelector, userInfo: nil, repeats: true)
        }   else    {   // 버튼이 "Stop"일 때 녹음을 위한 초기화를 수행합니다.
            audioRecorder.stop()
            progressTimer.invalidate()
            (sender as AnyObject).setTitle("Record", for: UIControl.State())
            btnPlay.isEnabled = true
            initPlay()
        }
    }
    
    // 오브젝티브 C에서 인식하기 위해서 @objc를 붙여주고 updateRecordTime 함수를 작성합니다.
    // 0.1초마다 호출되며 녹음 시간을 표시하는 기능을 수행합니다.
    @objc func updateRecordTime()   {
        lblRecordTime.text = convertNSTimeInterval2string(audioRecorder.currentTime)
    }
    
}

