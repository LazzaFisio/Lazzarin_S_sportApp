//
//  Informazioni.swift
//  Lazzarin_S_sportApp
//
//  Created by Leonardo Lazzarin on 19/01/2019.
//  Copyright © 2019 Leonardo Lazzarin. All rights reserved.
//

import UIKit

class Informazioni: UIViewController {

    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var titolo: UILabel!
    
    @IBOutlet weak var preferiti: UIButton!
    
    var dizionario = NSDictionary()
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Dati.informazioni.count == 0{
            dizionario = Dati.selezionato
            switch Dati.ricerca{
                case "Team": caricaInfoLeague(); break
                case "Player": caricaInfoTeam(); break
                default: caricaInfoSport(); break
            }
        }else{
            dizionario = Dati.informazioni
            switch Dati.ricerca{
                case "League": caricaInfoLeague(); break
                case "Team": caricaInfoTeam(); break
                case "Player": caricaInfoPlayer(); break
                default: caricaInfoSport(); break
            }
        }
        
    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func azionePreferiti(_ sender: Any) {
        let bottone = sender as! UIButton
        switch bottone.tag{
            case 1: cambiaPreferito(valore: dizionario.value(forKey: "idLeague") as! String, opzione: "League", cancella: false, tag: 1); break
            default: cambiaPreferito(valore: dizionario.value(forKey: "idLeague") as! String, opzione: "League", cancella: true, tag: 0); break
        }
    }
    
    func cambiaPreferito(valore : String, opzione : String, cancella : Bool, tag : Int){
        if cancella{
            Dati.cancellaPreferiti(valore: valore, opzione: opzione)
            preferiti.setBackgroundImage(UIImage(named: "stellaVuota.png"), for: .normal)
            if tag == 0{
                preferiti.tag = 1
            }
        }else{
            Dati.aggiungiPreferiti(valore: valore, opzione: opzione)
            preferiti.setBackgroundImage(UIImage(named: "stellaPiena.png"), for: .normal)
            if tag == 1{
                preferiti.tag = 0
            }
        }
    }
    
    func caricaInfoSport(){
        preferiti.isHidden = true
        switch dizionario.value(forKey: "strSport") as! String{
        case "Rugby":
            logo.image = UIImage(named: "rugby.png")
            titolo.text = "Rugby"
            break
        default:
            logo.image = UIImage(named: "motorsport.png")
            titolo.text = "Motorsport"
            break
        }
    }
    
    func caricaInfoLeague(){
        logo.image = Dati.immagine(stringa: dizionario.value(forKey: "strBadge") as! String)
        titolo.text = dizionario.value(forKey: "strLeague") as? String ?? ""
        if Dati.preferito(valore: dizionario.value(forKey: "idLeague") as! String, opzione: "League"){
            preferiti.setBackgroundImage(UIImage(named: "stellaPiena.png"), for: .normal)
            preferiti.tag = 0
        }else{
            preferiti.setBackgroundImage(UIImage(named: "stellaVuota.png"), for: .normal)
            preferiti.tag = 1
        }
    }
    
    func caricaInfoTeam(){
        
    }
    
    func caricaInfoPlayer(){
        preferiti.isHidden = true
    }
}
