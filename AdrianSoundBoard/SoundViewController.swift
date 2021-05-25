//
//  SoundViewController.swift
//  AdrianSoundBoard
//
//  Created by Mac 14 on 5/19/21.
//  Copyright © 2021 Mac 14. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var timer = Timer()
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var tiempoGrabacion: UILabel!
    
    @objc func duracionAudio(){
       tiempoGrabacion.text = grabarAudio?.currentTime.stringFromTimeInterval()
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            //detener la grabacion
            grabarAudio?.stop()
            //cambiar el texto del boton grabar
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            timer.invalidate()
        }else{
            //empezar la grabacion
            grabarAudio?.record()
            //cambiar el texto del boton grabar a detener
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            timer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector: #selector(SoundViewController.duracionAudio), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        }catch{}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    func configurarGrabacion(){
        do{
            //creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //creando direcciones para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponets = [basePath,"audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponets)!
            
            //Impresion de ruta donde se guardan los archivos
            print("************************")
            print(audioURL!)
            print("************************")
            
            //crear opciones para el grabador de audio
            var settings: [String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //Crear el objeto de grabacion de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
            
        }catch let error as NSError{
            print(error)
        }
    }

}

extension TimeInterval{

    func stringFromTimeInterval2() -> String {

        let time = NSInteger(self)

        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)

    }
}
