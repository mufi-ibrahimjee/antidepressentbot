

import UIKit
import ApiAI
import AVFoundation
import NRSpeechToText
import SwiftyJSON

class FaithViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var logo: UIImageView!
    var query = ""
    @IBOutlet weak var labelText: UILabel!
    @objc func longTap(_ sender: UILongPressGestureRecognizer) {
        if(sender.state == .began) {
            animate()
            NRSpeechToText.shared.authorizePermission { (authorize) in
                if authorize {
                    if !NRSpeechToText.shared.isRunning {
                        print("start")
                        self.startRecording(completion: { (result) in
                            self.query = result
                            self.processQuery(completion: { (text) in
                                
                            })
                            
                        })
                    }
                }
            }
        }
        else if(sender.state == .ended) {
            print("end")
            stopAnimation()
            
            NRSpeechToText.shared.stop()
        }
    }
    
    func processQuery(completion : @escaping(String) -> ()) {
        let request = ApiAI.shared().textRequest()
        request?.query = [query]
        var speech = ""
        
                request?.setMappedCompletionBlockSuccess({ (request, response) in
                    let response = response as! AIResponse
                    let resp = response.result.fulfillment.messages[0]
                    speech = resp["speech"] as? String ?? ""
                    print(speech)
                    completion(speech)
                }, failure: { (request, error) in
                    print(error)
                })
        
        ApiAI.shared().enqueue(request)
    }
    
    var preferences : [MyPreferences] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        textToSpeech(text: "Hi! I am Faith. I am here to help")
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        longGesture.minimumPressDuration = 0.3
        logo.addGestureRecognizer(longGesture)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tapped() {
        
    }
    
    func startRecording(completion : @escaping(String) -> ()) {
        var x = 0
        NRSpeechToText.shared.startRecording {(result: String?, isFinal: Bool, error: Error?) in
            if error == nil {
                self.labelText.text = result
            }
            if(isFinal && x == 0) {
                x=1
                completion(result!)
            }
        }
    }
    
    func animate() {
        
    }
    
    func stopAnimation() {
        self.logo.layer.removeAllAnimations()
        self.logo.layoutIfNeeded()
    }
    
    func textToSpeech(text : String) {
        let speechSynthesizer = AVSpeechSynthesizer()
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.2
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterance)
    }
}

