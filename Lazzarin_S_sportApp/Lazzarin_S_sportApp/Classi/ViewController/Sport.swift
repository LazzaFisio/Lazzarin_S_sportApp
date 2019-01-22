//
//  Sport.swift
//  Lazzarin_S_sportApp
//
//  Created by Leonardo Lazzarin on 16/01/2019.
//  Copyright © 2019 Leonardo Lazzarin. All rights reserved.
//

import UIKit

class Sport: UIViewController {
    
    @IBOutlet weak var attesa: UIView!
    
    @IBOutlet weak var contenitore: UIScrollView!
    
    @IBOutlet weak var titolo: UILabel!
    @IBOutlet weak var errore: UILabel!
    
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var info: UIButton!
    @IBOutlet weak var cerca: UIButton!
    
    @IBOutlet weak var immCarico: UIImageView!
    
    var timer = Timer()
    var secondi = 0
    var bottoneSelezionato = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creaSport()
        attesa.isHidden = true
        //let domain = Bundle.main.bundleIdentifier!
        //UserDefaults.standard.removePersistentDomain(forName: domain)
        // Do any additional setup after loading the view.
    }
    
    func creaSport(){
        var view = UIView()
        contenitore.contentSize = CGSize(width: view.frame.width, height: view.frame.height - 104)
        var dimensioni = arrayDimensioni(view: CGRect(x: 30, y: Int(contenitore.frame.height / 2) - 84, width: 148, height: 168), testo: "rugby", stella: false)
        var immagine = UIImage(named: "rugby.png")
        view = Dati.creaView(dimensioni: dimensioni, imm: immagine!, testo: "Rugby", stella: [false], tag: 0)
        aggiungiAzione(azione: #selector(azioneSport(sender:)), view: view)
        contenitore.addSubview(view)
        dimensioni = arrayDimensioni(view: CGRect(x: Int(self.view.frame.width) - (30 + 148), y: Int(contenitore.frame.height / 2) - 84, width: 148, height: 168), testo: "rugby", stella: false)
        immagine = UIImage(named: "motorsport.png")
        view = Dati.creaView(dimensioni: dimensioni, imm: immagine!, testo: "Motorsport", stella: [false], tag: 1)
        aggiungiAzione(azione: #selector(azioneSport(sender:)), view: view)
        contenitore.addSubview(view)
        titolo.text = "TUTTI GLI SPORT"
        Dati.ricerca = ""
        back.isHidden = true
        info.isHidden = true
        cerca.isHidden = true
    }
    
    func crea(strTitolo : String, immagini : [UIImage], nomeTitolo : String, azione : Selector){
        var i = 0
        var height = 0
        var view = UIView()
        var stelle : [Bool] = []
        while i < Dati.json.count{
            var testo = Dati.elementi(key: nomeTitolo)[i]
            if Dati.preferito(valore: Dati.elementi(key: "id" + Dati.ricerca)[i], opzione: Dati.ricerca){
                stelle = [true, true]
            }else{ stelle = [false]}
            var dimensioni = arrayDimensioni(view: CGRect(x: 30, y: height, width: 148, height: 168), testo: testo, stella: stelle[0])
            view = Dati.creaView(dimensioni: dimensioni, imm: immagini[i], testo: testo, stella: stelle, tag: i)
            aggiungiAzione(azione: azione, view: view)
            contenitore.addSubview(view)
            i += 1
            if i < Dati.json.count{
                testo = Dati.elementi(key: nomeTitolo)[i]
                if Dati.preferito(valore: Dati.elementi(key: "id" + Dati.ricerca)[i], opzione: Dati.ricerca){
                    stelle = [true, true]
                }else{ stelle = [false]}
                dimensioni = arrayDimensioni(view: CGRect(x: Int(self.view.frame.width) - (30 + 148), y: height, width: 148, height: 168), testo: testo, stella: stelle[0])
                view = Dati.creaView(dimensioni: dimensioni, imm: immagini[i], testo: Dati.elementi(key: nomeTitolo)[i], stella: stelle, tag: i)
                aggiungiAzione(azione: azione, view: view)
                contenitore.addSubview(view)
            }
            i += 1
            height += 200
        }
        titolo.text = strTitolo
        back.isHidden = false
        info.isHidden = false
        cerca.isHidden = false
    }
    
    func cancellaUIView(){
        for subviews in contenitore.subviews{
            if subviews.subviews.count > 0{
                subviews.removeFromSuperview()
            }
        }
    }
    
    func arrayDimensioni(view : CGRect, testo : String, stella : Bool) -> [CGRect]{
        var dimensioni : [CGRect] = []
        dimensioni.append(view)
        dimensioni.append(CGRect(x: 20, y: 20, width: 100, height: 100))
        dimensioni.append(CGRect(x: 12, y: 127, width: 116, height: 40))
        if testo.count > 13{
            dimensioni[2] = CGRect(x: 12, y: 127, width: 116, height: 70)
        }
        dimensioni.append(CGRect(x: 40, y: 40, width: 60, height: 60))
        if stella{
            dimensioni.append(CGRect(x: 100, y: 0, width: 40, height: 40))
        }
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
        errore.isHidden = true
        if Dati.ricerca == "League"{
            cancellaUIView()
            contenitore.contentSize = CGSize(width: view.frame.width, height: view.frame.height - 104)
            creaSport()
        }else if Dati.ricerca == "Team"{
            let sport = Dati.selezionato.value(forKey: "strSport") as! String
            cambiaView(infomazioni: ["https://www.thesportsdb.com/api/v1/json/1/search_all_leagues.php?s=" + sport, "League", "strBadge", "strLeague"], titolo: sport.uppercased(), tag: -1, azione: #selector(azioneLeghe(sender:)))
        }else{
            let team = Dati.selezionato.value(forKey: "strLeague") as! String
            let nome = team.replacingOccurrences(of: " ", with: "_")
            cambiaView(infomazioni: ["https://www.thesportsdb.com/api/v1/json/1/search_all_teams.php?l=" + nome, "Team", "strTeamBadge", "strTeam"], titolo: team.uppercased(), tag: -1, azione: #selector(azioneTeam(sender:)))
        }
    }
    
    @IBAction func infoAzione(_ sender: Any) {
        present((storyboard?.instantiateViewController(withIdentifier: "Informazioni"))!, animated: true, completion: nil)
    }
    
    @objc func avviaTimer(sender : UIButton!){
        bottoneSelezionato = sender
        secondi = 500
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let info = UIAlertAction(title: "Info", style: .default) { (action) in
            Dati.aggiungiSelezionatoInformazioni(tag: self.bottoneSelezionato.tag)
            self.present((self.storyboard?.instantiateViewController(withIdentifier: "Informazioni"))!, animated: true, completion: nil)
        }
        let preferiti = UIAlertAction(title: "Aggiungi ai preferiti", style: .default) { (action) in
            Dati.aggiungiSelezionatoInformazioni(tag: self.bottoneSelezionato.tag)
            Dati.aggiungiPreferiti(valore: Dati.informazioni.value(forKey: "id" + Dati.ricerca) as! String, opzione: Dati.ricerca)
            self.aggiornaStelle()
        }
        let noPreferiti = UIAlertAction(title: "Rimuovi dai preferiti", style: .default) { (action) in
            Dati.aggiungiSelezionatoInformazioni(tag: self.bottoneSelezionato.tag)
            Dati.cancellaPreferiti(valore: Dati.informazioni.value(forKey: "id" + Dati.ricerca) as! String, opzione: Dati.ricerca)
            self.aggiornaStelle()
        }
        let cancella = UIAlertAction(title: "Annulla", style: .destructive, handler: nil)
        alert.addAction(info)
        if titolo.text != "TUTTI GLI SPORT", Dati.selezionato.value(forKey: "idTeam") as? String ?? "" == ""{
            let controlla = Dati.elementi(key: "id" + Dati.ricerca)[self.bottoneSelezionato.tag]
            if Dati.preferito(valore: controlla, opzione: Dati.ricerca){
                alert.addAction(noPreferiti)
            }else{
                alert.addAction(preferiti)
            }
        }
        alert.addAction(cancella)
        present(alert, animated: true, completion: nil)
    }
    
    func aggiornaStelle(){
        var informazioni : [String] = []
        var azione = #selector(azioneLeghe(sender:))
        if Dati.ricerca == "League"{
            informazioni = ["", "", "strBadge", "strLeague"]
            azione = #selector(azioneLeghe(sender:))
        }else{
            informazioni = ["", "", "strTeamBadge", "strTeam"]
            azione = #selector(azioneTeam(sender:))
        }
        cambiaView(infomazioni: informazioni, titolo: titolo.text!, tag: -1, azione: azione)
    }
    
    @objc func azioneSport(sender : UIButton!){
        if timer.isValid{
            timer.invalidate()
            var sport = ""
            switch sender.tag {
            case 1: sport = "Motorsport"; break
            default: sport = "Rugby"; break
            }
            cambiaView(infomazioni: ["https://www.thesportsdb.com/api/v1/json/1/search_all_leagues.php?s=" + sport, "League", "strBadge", "strLeague"], titolo: sport.uppercased(), tag: sender.tag, azione: #selector(azioneLeghe(sender:)))
        }
    }
    
    @objc func azioneLeghe(sender : UIButton!){
        if timer.isValid{
            timer.invalidate()
            var nome = Dati.elementi(key: "strLeague")[sender.tag]
            nome = nome.replacingOccurrences(of: " ", with: "_")
            cambiaView(infomazioni: ["https://www.thesportsdb.com/api/v1/json/1/search_all_teams.php?l=" + nome, "Team", "strTeamBadge", "strTeam"], titolo: Dati.elementi(key: "strLeague")[sender.tag].uppercased(), tag: sender.tag, azione: #selector(azioneTeam(sender:)))
            
        }
    }
    
    @objc func azioneTeam(sender : UIButton!){
        if timer.isValid{
            timer.invalidate()
            let team = Dati.elementi(key: "idTeam")[sender.tag]
            cambiaView(infomazioni: ["https://www.thesportsdb.com/api/v1/json/1/lookup_all_players.php?id=" + team, "Player", "strCutout", "strPlayer"], titolo: Dati.elementi(key: "strTeam")[sender.tag].uppercased(), tag: sender.tag, azione: #selector(azionePlayer(sender:)))
        }
    }
    
    @objc func azionePlayer(sender : UIButton!){
        
    }
    
    func funcRotazione(){
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear, animations: {
            self.immCarico.transform = self.immCarico.transform.rotated(by: CGFloat(Double.pi))
        }) { (success) in
            if !self.attesa.isHidden{
                self.funcRotazione()
            }
        }
    }
    
    func cambiaView(infomazioni : [String], titolo : String, tag : Int, azione : Selector){
        let thread  = DispatchQueue.global(qos: .background)
        thread.async {
            DispatchQueue.main.async {
                self.attesa.isHidden = false
                self.funcRotazione()
            }
            if tag != -1 && Dati.json.count > 0{
                Dati.aggiungiSelezionato(tag: tag)
            }
            if infomazioni[0] != ""{
                Dati.caricaJson(query: infomazioni[0], ricerca: infomazioni[1])
            }
            if Dati.json.count > 0{
                var immagini : [UIImage] = []
                for i in 0...Dati.json.count - 1{
                    immagini.append(Dati.immagine(stringa: Dati.elementi(key: infomazioni[2])[i]))
                }
                DispatchQueue.main.async {
                    self.cancellaUIView()
                    self.contenitore.contentSize = CGSize(width: Int(self.view.frame.width), height: (200 * Dati.json.count / 2) + 84)
                    self.crea(strTitolo: titolo, immagini: immagini, nomeTitolo: infomazioni[3], azione: azione)
                    self.contenitore.setContentOffset(CGPoint(x: 0, y: self.contenitore.contentInset.top), animated: true)
                }
            }else {
                DispatchQueue.main.async {
                    self.cancellaUIView()
                    self.contenitore.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
                    self.titolo.text = titolo
                    self.errore.isHidden = false
                    self.back.isHidden = false
                }
            }
            DispatchQueue.main.async {
                self.attesa.isHidden = true
            }
        }
    }
}
