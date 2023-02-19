//
//  ViewController.swift
//  Musings
//
//  Created by Srihita on 2/18/23.
//

import UIKit
import Speech
import NaturalLanguage
class ViewController: UIViewController {
    @IBOutlet weak var btn_start: UIButton!
    @IBOutlet weak var lb_speech: UILabel!
    var final = ""
    // Local Properties
    let audioEngine = AVAudioEngine()
    let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task : SFSpeechRecognitionTask!
    var isStart : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        requestPermission()
    }

    @IBAction func btn_start_stop(_ sender: Any) {
        isStart = !isStart
        
        if isStart {
            startSpeechRecognization()
            btn_start.setTitle("STOP", for: .normal)
            btn_start.backgroundColor = .systemGreen
        }
        else{
            cancelSpeechRecognization()
            btn_start.setTitle("START", for: .normal)
            btn_start.backgroundColor = .systemOrange
        }
    }
    
    func requestPermission(){
        self.btn_start.isEnabled = false
        SFSpeechRecognizer.requestAuthorization {(authState) in
            OperationQueue.main.addOperation{
                if authState == .authorized{
                    print("ACCEPTED")
                    self.btn_start.isEnabled = true
                }
                else if authState == .denied{
                    //self.alertView(message: "User denied the permission")
                }
                else if authState == .notDetermined {
                    //self.alertView(message: "In User phone, there is no speech recognization ")
                }
                else if authState == .restricted {
                    //self.alertView(message: "User has been restricted for using the speech")
                }
            }
        }
    }
    
    func startSpeechRecognization(){
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus : 0, bufferSize: 1024, format: recordingFormat){
            (buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        }
        catch let error {
            //alertView(message: "Error comes here for starting the audio listener = \(error.localizedDescription)")
        }
        guard let myRecognization = SFSpeechRecognizer() else{
            //self.alertView(message: "Recognization is not allowed on your local")
            return
        }
        if !myRecognization.isAvailable {
            //self.alertView(message: "Recognition is free right now. Please try again after some time")
        }
                           
                           task = speechRecognizer?.recognitionTask(with: request, resultHandler: { (response,error) in
                guard let response = response else {
                    if error != nil {
                        //self.alertView(message: error.debugDescription)
                    }
                    else{
                        //self.alertView(message: "Problem in giving the response")
                    }
                    return
                }
                            let message = response.bestTranscription.formattedString
                               //print("Message : \(message)")
                               self.lb_speech.text = message
                               self.final = message
                          
            })
    }
    
    func cancelSpeechRecognization() {
        task.finish()
        task.cancel()
        task = nil
        request.endAudio()
        audioEngine.stop()
        
        audioEngine.inputNode.removeTap(onBus: 0)
        print(final)
        rating(text: final)
    }
    
    func rating(text: String){

        let tagger = NLTagger(tagSchemes: [.tokenType, .sentimentScore])
        tagger.string = text

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .paragraph,
                             scheme: .sentimentScore, options: []) { sentiment, _ in
            
            if let sentimentScore = sentiment {
                print(sentimentScore.rawValue)
            }
            
            return true
        }
    }
    
    
}

