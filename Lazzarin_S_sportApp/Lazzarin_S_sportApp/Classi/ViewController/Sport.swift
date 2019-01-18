//
//  Sport.swift
//  Lazzarin_S_sportApp
//
//  Created by Leonardo Lazzarin on 16/01/2019.
//  Copyright © 2019 Leonardo Lazzarin. All rights reserved.
//

import UIKit

class Sport: UIViewController {

    @IBOutlet weak var contenitore: UIScrollView!
    
    @IBOutlet weak var titolo: UILabel!
    
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var info: UIButton!
    
    var timer = Timer()
    var secondi = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creaSport()
        // Do any additional setup after loading the view.
    }
    
    func creaSport(){
        var view = UIView()
        contenitore.contentSize = CGSize(width: view.frame.width, height: view.frame.height - 104)
        var dimensioni = arrayDimensioni(view: CGRect(x: 30, y: Int(contenitore.frame.height / 2) - 84, width: 148, height: 168))
        var immagine = UIImage(named: "rugby.png")
        view = Info.creaView(dimensioni: dimensioni, imm: immagine!, testo: "Rugby", stella: [false], tag: 0)
        aggiungiAzione(azione: #selector(azioneSport(sender:)), view: view)
        contenitore.addSubview(view)
        dimensioni[0] = CGRect(x: Int(self.view.frame.width) - (30 + 148), y: Int(contenitore.frame.height / 2) - 84, width: 148, height: 168)
        immagine = UIImage(named: "motorsport.png")
        view = Info.creaView(dimensioni: dimensioni, imm: immagine!, testo: "Motorsport", stella: [false], tag: 1)
        aggiungiAzione(azione: #selector(azioneSport(sender:)), view: view)
        contenitore.addSubview(view)
        titolo.text = "TUTTI GLI SPORT"
        back.isHidden = true
        info.isHidden = true
    }
    
    func crea(strTitolo : String, nomeImmagine : String, nomeTitolo : String){
        var i = 0
        var height = 0
        var view = UIView()
        while i < Info.json.count{
            var dimensioni = arrayDimensioni(view: CGRect(x: 30, y: height, width: 148, height: 168))
            dimensioni.append(CGRect(x: 92, y: 0, width: 48, height: 48))
            var immagine = Info.immagine(url: Info.elementi(key: nomeImmagine)[i])
            view = Info.creaView(dimensioni: dimensioni, imm: immagine, testo: Info.elementi(key: nomeTitolo)[i], stella: [true, false], tag: i)
            aggiungiAzione(azione: #selector(azioneLeghe(sender:)), view: view)
            contenitore.addSubview(view)
            i += 1
            if i < Info.json.count - 1{
                dimensioni[0] = CGRect(x: Int(self.view.frame.width) - (30 + 148), y: height, width: 148, height: 168)
                immagine = Info.immagine(url: Info.elementi(key: nomeImmagine)[i])
                view = Info.creaView(dimensioni: dimensioni, imm: immagine, testo: Info.elementi(key: nomeTitolo)[i], stella: [true, false], tag: i)
                aggiungiAzione(azione: #selector(azioneLeghe(sender:)), view: view)
                contenitore.addSubview(view)
            }
            i += 1
            height += 200
        }
        titolo.text = strTitolo
        back.isHidden = false
        info.isHidden = false
    }
    
    func cancellaUIView(){
        for subviews in contenitore.subviews{
            if subviews.subviews.count > 0{
                subviews.removeFromSuperview()
            }
        }
    }
    
    func arrayDimensioni(view : CGRect) -> [CGRect]{
        var dimensioni : [CGRect] = []
        dimensioni.append(view)
        dimensioni.append(CGRect(x: 20, y: 20, width: 100, height: 100))
        dimensioni.append(CGRect(x: 12, y: 127, width: 116, height: 20))
        dimensioni.append(CGRect(x: 40, y: 40, width: 60, height: 60))
        return dimensioni
    }
    
    func aggiungiAzione(azione : Selector, view : UIView){
        var bottone = UIButton()
        for item in view.subviews{
            if let bot = item as? UIButton{
                bottone = bot
            }
        }
        bottone.addTarget(self, action: azione, for: .touchUpInside)
        bottone.addTarget(self, action: #selector(avviaTimer(sender:)), for: .touchDown)
    }
    
    @IBAction func indietro(_ sender: Any) {
        if Info.ricerca == "leghe"{
            cancellaUIView()
            contenitore.contentSize = CGSize(width: view.frame.width, height: view.frame.height - 104)
            creaSport()
        }else if Info.ricerca == "team"{
            let sport = Info.selezionato.value(forKey: "strSport") as! String
            cambiaView(infomazioni: ["https://www.thesportsdb.com/api/v1/json/1/search_all_leagues.php?s=" + sport, "leghe", "strBadge", "strLeague"], titolo: sport.uppercased(), tag: -1)
        }
    }
    
    @IBAction func infoAzione(_ sender: Any) {
        
    }
    
    @objc func avviaTimer(sender : UIButton!){
        secondi = 800
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(azioneTimer), userInfo: nil, repeats: true)
    }
    
    @objc func azioneTimer(){
        secondi -= 1
        if secondi == 0{
            timer.invalidate()
            messaggio()
        }
    }
    
    @objc func messaggio(){
        timer.invalidate()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let info = UIAlertAction(title: "INFO", style: .default) { (action) in
            
        }
        let preferiti = UIAlertAction(title: "Aggiungi ai preferiti", style: .default) { (action) in
            
        }
        let cancella = UIAlertAction(title: "Annulla", style: .destructive, handler: nil)
        alert.addAction(info)
        if titolo.text != "TUTTI GLI SPORT"{
            alert.addAction(preferiti)
        }
        alert.addAction(cancella)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func azioneSport(sender : UIButton!){
        if timer.isValid{
            timer.invalidate()
            var sport = ""
            switch sender.tag {
            case 1: sport = "Motorsport"; break
            default: sport = "Rugby"; break
            }
            cambiaView(infomazioni: ["https://www.thesportsdb.com/api/v1/json/1/search_all_leagues.php?s=" + sport, "leghe", "strBadge", "strLeague"], titolo: sport.uppercased(), tag: sender.tag)
        }
    }
    
    @objc func azioneLeghe(sender : UIButton!){
        if timer.isValid{
            timer.invalidate()
            var nome = Info.elementi(key: "strLeague")[sender.tag]
            nome = nome.replacingOccurrences(of: " ", with: "_")
            cambiaView(infomazioni: ["https://www.thesportsdb.com/api/v1/json/1/search_all_teams.php?l=" + nome, "team", "strTeamBadge", "strTeam"], titolo: Info.elementi(key: "strLeague")[sender.tag].uppercased(), tag: sender.tag)
            
        }
    }
    
    func cambiaView(infomazioni : [String], titolo : String, tag : Int){
        if tag != -1 && Info.json.count > 0{
            Info.aggiungiSelezionato(tag: tag)
        }
        Info.caricaJson(query: infomazioni[0], ricerca: infomazioni[1])
        cancellaUIView()
        contenitore.contentSize = CGSize(width: Int(view.frame.width), height: (200 * Info.json.count / 2) + 84)
        crea(strTitolo: titolo, nomeImmagine: infomazioni[2], nomeTitolo: infomazioni[3])
    }
}
