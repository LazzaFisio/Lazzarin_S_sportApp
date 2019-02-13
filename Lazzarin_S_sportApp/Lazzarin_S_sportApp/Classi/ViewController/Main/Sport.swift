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
    
    @IBOutlet weak var titolo: UILabel!
    @IBOutlet weak var errore: UILabel!
    
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var info: UIButton!
    @IBOutlet weak var cerca: UIButton!
    
    @IBOutlet weak var contenitore: UICollectionView!
    
    var elementi = [NSDictionary]()
    var azioneBottone = #selector(azioneSport(sender:))
    static var ricerca = ""
    var timer = Timer()
    var secondi = 0, numCella = 0
    var bottoneSelezionato = UIButton()
    var viewInfo = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creaSport()
        attesa.isHidden = true
        Dati.caricaPreferiti()
        Dati.viewAttesa = ViewAttesa(view: view, valore: "Carico...", colore: attesa.backgroundColor!)
        contenitore.dataSource = self
        contenitore.delegate = self
        //UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Dati.viewAttesa.aggiungiAllaView(view: view)
    }
    
    @IBAction func indietro(_ sender: Any) {
        errore.isHidden = true
        if Sport.ricerca == "League"{
            creaSport()
            contenitore.reloadData()
        }else if Sport.ricerca == "Team"{
            let sport = Dati.selezionato.value(forKey: "strSport") as! String
            Sport.ricerca = "League"
            azioneBottone = #selector(azioneLeghe(sender:))
            cambiaView(query: "https://www.thesportsdb.com/api/v1/json/1/search_all_leagues.php?s=" + sport, titolo: sport.uppercased(), tag: -1, preferiti: false)
        }else{
            let team = Dati.selezionato.value(forKey: "strLeague") as! String
            let nome = team.replacingOccurrences(of: " ", with: "_")
            Sport.ricerca = "Team"
            azioneBottone = #selector(azioneTeam(sender:))
            cambiaView(query: "https://www.thesportsdb.com/api/v1/json/1/search_all_teams.php?l=" + nome, titolo: team.uppercased(), tag: -1, preferiti: false)
        }
    }
    
    @IBAction func infoAzione(_ sender: Any) {
        visualizzaView()
    }
    
    @IBAction func cerca(_ sender: Any) {
        viewInfo = (storyboard?.instantiateViewController(withIdentifier: "Cerca"))!
        controllaView()
        present(viewInfo, animated: true, completion: nil)
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
            Dati.informazioni = self.elementi[self.bottoneSelezionato.tag]
            self.visualizzaView()
        }
        let preferiti = UIAlertAction(title: "Aggiungi ai preferiti", style: .default) { (action) in
            Dati.informazioni = self.elementi[self.bottoneSelezionato.tag]
            Dati.aggiungiPreferiti(valore: Dati.informazioni.value(forKey: "id" + Sport.ricerca) as! String, opzione: Sport.ricerca)
            self.contenitore.reloadData()
        }
        let noPreferiti = UIAlertAction(title: "Rimuovi dai preferiti", style: .default) { (action) in
            Dati.informazioni = self.elementi[self.bottoneSelezionato.tag]
            Dati.cancellaPreferiti(valore: Dati.informazioni.value(forKey: "id" + Sport.ricerca) as! String, opzione: Sport.ricerca)
            self.contenitore.reloadData()
        }
        let cancella = UIAlertAction(title: "Annulla", style: .destructive, handler: nil)
        alert.addAction(info)
        if titolo.text != "TUTTI GLI SPORT", Dati.selezionato.value(forKey: "idTeam") as? String ?? "" == ""{
            let controlla = elementi[self.bottoneSelezionato.tag].value(forKey: "id" + Sport.ricerca) as! String
            if Dati.preferito(valore: controlla, opzione: Sport.ricerca){
                alert.addAction(noPreferiti)
            }else{
                alert.addAction(preferiti)
            }
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
            Sport.ricerca = "League"
            azioneBottone = #selector(azioneLeghe(sender:))
            cambiaView(query: "https://www.thesportsdb.com/api/v1/json/1/search_all_leagues.php?s=" + sport, titolo: sport.uppercased(), tag: sender.tag, preferiti: false)
        }
    }
    
    @objc func azioneLeghe(sender : UIButton!){
        if timer.isValid{
            timer.invalidate()
            var nome = elementi[sender.tag].value(forKey: "strLeague") as! String
            nome = nome.replacingOccurrences(of: " ", with: "_")
            Sport.ricerca = "Team"
            azioneBottone = #selector(azioneTeam(sender:))
            cambiaView(query: "https://www.thesportsdb.com/api/v1/json/1/search_all_teams.php?l=" + nome, titolo: (elementi[sender.tag].value(forKey: "strLeague") as! String).uppercased(), tag: sender.tag, preferiti: false)
            
        }
    }
    
    @objc func azioneTeam(sender : UIButton!){
        if timer.isValid{
            timer.invalidate()
            let team = elementi[sender.tag].value(forKey: "idTeam") as! String
            Sport.ricerca = "Player"
            azioneBottone = #selector(azionePlayer(sender:))
            cambiaView(query: "https://www.thesportsdb.com/api/v1/json/1/lookup_all_players.php?id=" + team, titolo: (elementi[sender.tag].value(forKey: "strTeam") as! String).uppercased(), tag: sender.tag, preferiti: false)
        }
    }
    
    @objc func azionePlayer(sender : UIButton!){
        
    }
    
    func creaSport(){
        elementi.removeAll()
        var app = NSMutableDictionary()
        app.setValue("Rugby", forKey: "nome")
        app.setValue("rugby.png", forKey: "imm")
        elementi.append(app)
        app = NSMutableDictionary()
        app.setValue("Motorsport", forKey: "nome")
        app.setValue("motorsport.png", forKey: "imm")
        elementi.append(app)
        azioneBottone = #selector(azioneSport(sender:))
        titolo.text = "TUTTI GLI SPORT"
        Sport.ricerca = ""
        back.isHidden = true
        info.isHidden = true
    }
    
    func cambiaView(query : String, titolo : String, tag : Int, preferiti : Bool){
        let thread  = DispatchQueue.global(qos: .background)
        thread.async {
            DispatchQueue.main.async {
                Dati.viewAttesa.avviaRotazione()
            }
            if tag != -1 && self.elementi.count > 0{
                Dati.selezionato = self.elementi[tag]
                Dati.informazioni = NSDictionary()
            }
            if query != ""{
                self.elementi = Dati.richiestraWeb(query: query)
            }
            if self.elementi.count > 0{
                DispatchQueue.main.async {
                    self.titolo.text = titolo
                    self.back.isHidden = false
                    self.info.isHidden = false
                }
            }else {
                self.elementi.removeAll()
                DispatchQueue.main.async {
                    self.titolo.text = titolo
                    self.errore.isHidden = false
                    self.back.isHidden = false
                }
            }
            DispatchQueue.main.async {
                self.contenitore.reloadData()
                Dati.viewAttesa.fermaRotazione()
            }
        }
    }
    
    func controllaView(){
        let thread = DispatchQueue.global(qos: .background)
        thread.async {
            while !self.viewInfo.isBeingDismissed{}
            DispatchQueue.main.async {
                if self.titolo.text != "TUTTI GLI SPORT"{
                    self.contenitore.reloadData()
                }
                Dati.viewAttesa.aggiungiAllaView(view: self.view)
            }
        }
    }
    
    func visualizzaView(){
        if Dati.informazioni.count == 0{
            if titolo.text != "TUTTI GLI SPORT"{
                Internet.richiesta = "https://www.google.com/search?q=" + (titolo.text?.lowercased())!
            }else{
                Internet.richiesta = "https://www.google.com/search?q=" + (Dati.informazioni.value(forKey: "nome") as! String)
            }
        }else{
            var daCercare = ""
            switch titolo.text{
                case "TUTTI GLI SPORT": daCercare = Dati.informazioni.value(forKey: "nome") as! String; break
                default: daCercare = Dati.informazioni.value(forKey: "str" + Sport.ricerca) as! String; break
            }
            Internet.richiesta =  "https://www.google.com/search?q=" + daCercare
        }
        present((storyboard?.instantiateViewController(withIdentifier: "Internet"))!, animated: true, completion: nil)
    }
    
}

extension Sport : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numCella = 0
        return elementi.count / 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cella = contenitore.dequeueReusableCell(withReuseIdentifier: "Visualizza", for: indexPath) as! elementoSport
        if numCella < elementi.count{
            let appoggio1 = elementi[numCella]
            var appoggio2 = NSDictionary()
            numCella += 1
            if numCella < elementi.count{
                appoggio2 = elementi[numCella]
            }
            numCella += 1
            if Sport.ricerca == ""{
                caricaSport(appoggio: appoggio1, cella: cella, num: 0, tag: numCella - 2)
                caricaSport(appoggio: appoggio2, cella: cella, num: 1, tag: numCella - 1)
            }else{
                caricaResto(appoggio: appoggio1, cella: cella, num: 0, tag: numCella - 2)
                if appoggio2.count > 0{
                    cella.destra.isHidden = false
                    caricaResto(appoggio: appoggio2, cella: cella, num: 1, tag: numCella - 1)
                }else if numCella - 1 < elementi.count{
                    cella.destra.isHidden = true
                }
            }
        }
        return cella
    }
    
    func caricaSport(appoggio : NSDictionary, cella : elementoSport, num : Int, tag : Int){
        cella.immagini[num].image = UIImage(named: appoggio.value(forKey: "imm") as! String)
        cella.nomi[num].text = appoggio.value(forKey: "nome") as? String
        cella.bottoni[num].tag = tag
        cella.bottoni[num].removeTarget(nil, action: nil, for: .allEvents)
        cella.bottoni[num].addTarget(self, action: azioneBottone, for: .touchUpInside)
        cella.bottoni[num].addTarget(self, action: #selector(avviaTimer(sender:)), for: .touchDown)
        cella.bottoni[num + 2].isHidden = true
    }
    
    func caricaResto(appoggio : NSDictionary, cella : elementoSport, num : Int, tag : Int){
        cella.immagini[num].image = Dati.immagine(chiave: appoggio.value(forKey: "id" + Sport.ricerca) as! String, url: appoggio.value(forKey: Dati.codImm(ricerca: Sport.ricerca)) as? String ?? "")
        cella.nomi[num].text = appoggio.value(forKey: "str" + Sport.ricerca) as? String
        cella.bottoni[num].tag = tag
        cella.bottoni[num].removeTarget(nil, action: nil, for: .allEvents)
        cella.bottoni[num].addTarget(self, action: azioneBottone, for: .touchUpInside)
        cella.bottoni[num].addTarget(self, action: #selector(avviaTimer(sender:)), for: .touchDown)
        cella.bottoni[num + 2].isHidden = true
        if Sport.ricerca == "League" || Sport.ricerca == "Team"{
            cella.bottoni[num + 2].isHidden = false
            var nomeImm = "stellaVuota.png"
            if Dati.preferito(valore: appoggio.value(forKey: "id" + Sport.ricerca) as! String, opzione: Sport.ricerca){
                nomeImm = "stellaPiena.png"
            }
            cella.bottoni[num + 2].setBackgroundImage(UIImage(named: nomeImm), for: .normal)
        }
    }
    
}
