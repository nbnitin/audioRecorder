import UIKit
import AVFoundation
 
class ViewController: UIViewController {
    var recorder:AVAudioRecorder!
    var audioPlayer : AVAudioPlayer = AVAudioPlayer()
    var url : NSURL!
    
    @IBOutlet weak var btnButtonActionToggle: UIButton!
    
    @IBOutlet weak var waveFormView: SCSiriWaveFormViewSwift!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnButtonActionToggle.setTitle("Record", for: .normal)

       
        waveFormView.waveColor = UIColor.white
        waveFormView.primaryWaveLineWidth = 3.0
        waveFormView.secondaryWaveLineWidth = 1.0
        
        
        // build the file url
        
        let documents : AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as! AnyObject
        let str:String = documents.appendingPathComponent("recordTest.caf")
        url = NSURL.fileURL(withPath: str) as NSURL
        
        let settings:NSDictionary = [
            AVFormatIDKey: kAudioFormatAppleIMA4,
            AVSampleRateKey: 44100.0,
            //AVFormatIDKey: kAudioFormatAppleLossless,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
            AVEncoderBitRateKey: 12800,
            AVLinearPCMBitDepthKey: 16
        ]
        
        
        recorder = try? AVAudioRecorder(url: url as URL, settings: settings as! [String : Any])
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        
        
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        //recorder.record()
        
        let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(self.updateMeters))
        displayLink.add(to: RunLoop.current, forMode: .common)
    }
    
    @objc func updateMeters() {
        
        var normalizedValue : CGFloat = 0.0
        //updation after recording stopped and recording start playing back
        if ( audioPlayer.isPlaying ) {
            audioPlayer.updateMeters()
            normalizedValue = pow(10, CGFloat(audioPlayer.averagePower(forChannel: 0))/20)
        } else {
            recorder.updateMeters()
            normalizedValue = pow(10, CGFloat(recorder.averagePower(forChannel: 0))/20)
        }
        waveFormView.update(withLevel: normalizedValue)
    }
    
    
    @IBAction func btnActionToggle(_ sender: Any) {
        toggleRecording()
    }
    
    func toggleRecording() {
        if let recorder = recorder {
            if (recorder.isRecording) {
                btnButtonActionToggle.setTitle("Record", for: .normal)
                recorder.stop()
                audioPlayer = try! AVAudioPlayer(contentsOf: url as URL, fileTypeHint: "caf")
                audioPlayer.isMeteringEnabled = true
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
            } else {
                recorder.record()
                btnButtonActionToggle.setTitle("Stop And Play", for: .normal)
            }
        } else {
            print("unable to toggle recorder, audioRecorder is nil")
        }
    }
}
