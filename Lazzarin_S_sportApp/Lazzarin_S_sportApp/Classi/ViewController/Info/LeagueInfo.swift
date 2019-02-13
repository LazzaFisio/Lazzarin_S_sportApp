//
//  LeagueInfo.swift
//  Lazzarin_S_sportApp
//
//  Created by Leonardo Lazzarin on 01/02/2019.
//  Copyright © 2019 Leonardo Lazzarin. All rights reserved.
//

import UIKit

class LeagueInfo: UIViewController {
    
    @IBOutlet weak var nome: UILabel!
    
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var imgStella: UIButton!
    
    var infomazioni = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        caricaDati()
    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stella(_ sender: Any) {
        var immagine = "stellaPiena.png"
        if imgStella.backgroundImage(for: .normal) == UIImage(named: "stellaVuota.png"){
            Dati.aggiungiPreferiti(valore: infomazioni.value(forKey: "idLeague") as! String, opzione: "League")
        }else{
            Dati.cancellaPreferiti(valore: infomazioni.value(forKey: "idLeague") as! String, opzione: "League")
            immagine = "stellaVuota.png"
        }
        imgStella.setBackgroundImage(UIImage(named: immagine), for: .normal)
    }
    
    func caricaDati(){
        infomazioni = Dati.selezionato
        if Dati.informazioni.count > 0{
            infomazioni = Dati.informazioni
        }
        nome.text = infomazioni.value(forKey: "strLeague") as? String
        logo.image = Dati.immagine(chiave: infomazioni.value(forKey: "idLeague") as! String, url: infomazioni.value(forKey: Dati.codImm(ricerca: "League")) as? String ?? "")
        if !Dati.preferito(valore: infomazioni.value(forKey: "idLeague") as! String, opzione: "League"){
            imgStella.setBackgroundImage(UIImage(named: "stellaVuota.png"), for: .normal)
        }
        
    }
}
