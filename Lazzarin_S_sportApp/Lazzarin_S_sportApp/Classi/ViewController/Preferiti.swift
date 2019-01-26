//
//  Preferiti.swift
//  Lazzarin_S_sportApp
//
//  Created by Leonardo Lazzarin on 24/01/2019.
//  Copyright © 2019 Leonardo Lazzarin. All rights reserved.
//

import UIKit

class Preferiti: UIViewController {

    @IBOutlet weak var infoPicker: UIPickerView!
    @IBOutlet weak var numRound: UIPickerView!
    @IBOutlet weak var numStagioni: UIPickerView!
    
    @IBOutlet weak var scelta: UISegmentedControl!
    
    @IBOutlet weak var contenitore: UICollectionView!
    
    var match = [NSDictionary]()
    var allTeam = [NSDictionary]()
    var league = [NSDictionary]()
    var team = [NSDictionary]()
    var elementoScelto = NSDictionary()
    var round : [String] = []
    var stagione : [String] = []
    var selezionato = "League"
    var viewCerca = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Dati.viewAttesa.aggiungiAllaView(view: view)
        infoPicker.delegate = self
        infoPicker.dataSource = self
        numRound.dataSource = self
        numRound.delegate = self
        numStagioni.delegate = self
        numStagioni.dataSource = self
        contenitore.delegate = self
        contenitore.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        league.removeAll()
        team.removeAll()
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                Dati.viewAttesa.avviaRotazione()
            }
            self.league = self.caricaValori(item: Dati.preferiti[0])
            self.team = self.caricaValori(item: Dati.preferiti[1])
            self.match.removeAll()
            if self.league.count > 0{
                self.elementoScelto = self.league[0]
                self.trovaStagione()
                self.trovaSqudre(row: 0)
            }
            DispatchQueue.main.async {
                self.infoPicker.reloadAllComponents()
                self.numRound.reloadAllComponents()
                self.contenitore.reloadData()
                Dati.viewAttesa.fermaRotazione()
            }
        }
    }
    
    @IBAction func cerca(_ sender: Any) {
        viewCerca = (storyboard?.instantiateViewController(withIdentifier: "Cerca"))!
        controllo()
        present(viewCerca, animated: true, completion: nil)
    }
    
    @IBAction func cambiaVisualizzazione(_ sender: Any) {
        selezionato = scelta.titleForSegment(at: scelta.selectedSegmentIndex)!
        infoPicker.reloadAllComponents()
        if infoPicker.numberOfRows(inComponent: 0) > 0{
            aggiorna(row: 0, tag: 0)
        }
    }
    
    func caricaValori(item : NSDictionary) -> [NSDictionary]{
        var elementi = [NSDictionary]()
        let nome = item.value(forKey: "nome") as! String
        var query = "https://www.thesportsdb.com/api/v1/json/1/lookupleague.php?id="
        if nome == "Team"{
            query = "https://www.thesportsdb.com/api/v1/json/1/lookupteam.php?id="
        }
        let dimensioni = item.value(forKey: "dimensione") as! Int
        if dimensioni > 0{
            for i in 1...dimensioni{
                let id = item.value(forKey: String(i) + nome) as! String
                elementi.append(Dati.esenzialiRicerca(condizioni: ["str" + nome, "id" + nome, Dati.codImm(ricerca: nome)], lista: Dati.richiestraWeb(query: query + id))[0])
                elementi[elementi.count - 1].setValue(nome, forKey: "nome")
            }
        }
        return elementi
    }
    
    func trovaSqudre(row : Int){
        match.removeAll()
        let id = elementoScelto.value(forKey: "id" + selezionato) as! String
        var query = ["https://www.thesportsdb.com/api/v1/json/1/eventsround.php?id=" + id, "https://www.thesportsdb.com/api/v1/json/1/lookup_all_teams.php?id=" + id]
        if round.count > 0{
            query[0] += "&r=" + round[row]
        }else{
            query[0] += "&r=0"
        }
        if selezionato == "Team"{
            query = ["https://www.thesportsdb.com/api/v1/json/1/eventslast.php?id=" + id, ""]
        }
        match = Dati.esenzialiRicerca(condizioni: ["idLeague", "strHomeTeam", "strAwayTeam", "intHomeScore", "intAwayScore", "dateEvent",  "strTime"], lista: Dati.richiestraWeb(query: query[0]))
        if query[1] != ""{
            allTeam = Dati.esenzialiRicerca(condizioni: ["idTeam", "strTeam", Dati.codImm(ricerca: "Team")], lista: Dati.richiestraWeb(query: query[1]))
        }
    }
    
    func trovaStagione(){
        stagione.removeAll()
        let query = "https://www.thesportsdb.com/api/v1/json/1/search_all_seasons.php?id=" + (elementoScelto.value(forKey: "id" + selezionato) as! String)
        
    }
    
    func aggiornaElementiRound(row : Int){
        round.removeAll()
        var query = "https://www.thesportsdb.com/api/v1/json/1/eventsseason.php?id="
        query += elementoScelto.value(forKey: "id" + selezionato) as! String + "&s=" + String(stagione[row].split(separator: ";")[0])
        let appoggio = Dati.esenzialiRicerca(condizioni: ["intRound"], lista: Dati.richiestraWeb(query: query))
        var dimensione = Int(appoggio[appoggio.count - 1].value(forKey: "intRound") as! String)!
        while dimensione > 0{
            round.append(String(dimensione))
            dimensione -= 1
        }
    }
    
    func aggiorna(row : Int, tag : Int){
        DispatchQueue.global(qos: .default).async{
            DispatchQueue.main.async {
                Dati.viewAttesa.avviaRotazione()
            }
            if tag == 0{
                self.aggiornaPrincipale(row: row)
            }else if tag == 1{
                self.aggiornaRound(row: row)
            }else{
                self.aggiornaStagioni(row: row)
            }
            DispatchQueue.main.async {
                self.contenitore.reloadData()
                Dati.viewAttesa.fermaRotazione()
            }
        }
    }
    
    func aggiornaPrincipale(row : Int){
        if selezionato == "League" && league.count > 0{
            elementoScelto = league[row]
        }else if team.count > 0{
            elementoScelto = team[row]
        }else{
            elementoScelto = NSDictionary()
        }
        if elementoScelto.count > 0{
            trovaStagione()
            trovaSqudre(row: 0)
        }
        DispatchQueue.main.async {
            self.numRound.reloadAllComponents()
        }
    }
    
    func aggiornaRound(row : Int){
        trovaSqudre(row: row)
        DispatchQueue.main.async {
            self.contenitore.reloadData()
        }
    }
    
    func aggiornaStagioni(row : Int){
        
    }
    
    func controllo(){
        DispatchQueue.global(qos: .default).async {
            while !self.viewCerca.isBeingDismissed{}
            self.viewWillAppear(true)
        }
    }

    func giraData(data : String) -> String{
        var reverse = ""
        let parti = Array(data.split(separator: "-"))
        var dimensione = 2
        while dimensione >= 0{
            if dimensione != 0{
                reverse += String(parti[dimensione]) + "-"
            }else{
                reverse += String(parti[dimensione])
            }
            dimensione -= 1
        }
        return reverse
    }
    
}

extension Preferiti: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0{
            if selezionato == "League" && league.count > 0{
                return league.count
            }else if team.count > 0{
                return team.count
            }
            return 1
        }else if pickerView.tag == 1{
            return round.count
        }
        return stagione.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if pickerView.tag == 0{
            return 70
        }
        return 20
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if pickerView.tag == 0{
            var elementi = league
            if selezionato == "Team"{
                elementi = team
            }
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 70))
            let testo = UILabel(frame: CGRect(x: 66, y: 0, width: 100, height: 70))
            testo.numberOfLines = 0
            testo.text = "Nessun dato trovato"
            testo.font = UIFont(name: testo.font.fontName, size: 14)
            if elementi.count > 0{
                let appoggio = elementi[row].value(forKey: "nome") as! String
                testo.text = elementi[row].value(forKey: "str" + appoggio) as? String ?? ""
                let immagine = UIImageView(frame: CGRect(x: 8, y: 10, width: 50, height: 50))
                let chiave = elementi[row].value(forKey: "id" + appoggio) as? String ?? ""
                immagine.image = Dati.immagine(chiave: chiave, url: "")
                view.addSubview(immagine)
            }
            view.addSubview(testo)
            return view
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 63, height: 20))
        let label = UILabel(frame: CGRect(x: 0, y: 2, width: 63, height: 15))
        if pickerView.tag == 1{
            label.text = round[row]
        }else{
            label.text = String(stagione[row].split(separator: ";")[0])
        }
        label.textAlignment = NSTextAlignment.center
        view.addSubview(label)
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        aggiorna(row: row, tag: pickerView.tag)
    }
}

extension Preferiti: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if match.count > 0{
            return match.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let appoggio = contenitore.dequeueReusableCell(withReuseIdentifier: "League", for: indexPath) as! League
        if selezionato == "League"{
            return caricaLeague(dizionario: match[indexPath.row], cella: appoggio)
        }
        return appoggio
    }
    
    func caricaLeague(dizionario : NSDictionary, cella : League) -> UICollectionViewCell{
        var idteamH = NSDictionary(), idTeamA = NSDictionary()
        for item in allTeam{
            let appoggio = item.value(forKey: "strTeam") as! String
            if appoggio == dizionario.value(forKey: "strHomeTeam") as! String{
                idTeamA = item
            }
            if appoggio == dizionario.value(forKey: "strAwayTeam") as! String{
                idteamH = item
            }
        }
        var time = dizionario.value(forKey: "strTime") as? String ?? ""
        if time != ""{
            time = String(time.split(separator: "+")[0])
        }
        cella.data.text = giraData(data: dizionario.value(forKey: "dateEvent") as? String ?? "") + " " + time
        cella.immSqr1.image = Dati.immagine(chiave: idteamH.value(forKey: "idTeam") as? String ?? "", url: idteamH.value(forKey: Dati.codImm(ricerca: "Team")) as? String ?? "")
        cella.immSqr2.image = Dati.immagine(chiave: idTeamA.value(forKey: "idTeam") as? String ?? "", url: idTeamA.value(forKey: Dati.codImm(ricerca: "Team")) as? String ?? "")
        cella.nomeSqr1.text = idteamH.value(forKey: "strTeam") as? String ?? ""
        cella.nomeSqr2.text = idTeamA.value(forKey: "strTeam") as? String ?? ""
        cella.puntSqr1.text = dizionario.value(forKey: "intHomeScore") as? String ?? ""
        cella.puntSqr2.text = dizionario.value(forKey: "intAwayScore") as? String ?? ""
        return cella
    }
    
}
