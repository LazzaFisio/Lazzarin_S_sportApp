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
    
    var allMatch = [NSDictionary]()
    var allTeam = [NSDictionary]()
    var league = [NSDictionary]()
    var team = [NSDictionary]()
    var match = [NSDictionary]()
    var elementoScelto = NSDictionary()
    var round : [String] = []
    var stagione : [String] = []
    var selezionato = "League"
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        Dati.viewAttesa.fermaRotazione()
        Dati.viewAttesa.aggiungiAllaView(view: view)
        league.removeAll()
        self.league = self.caricaValori(item: Dati.preferiti[0])
        self.team = self.caricaValori(item: Dati.preferiti[1])
        threadCarica()
    }
    
    @IBAction func cerca(_ sender: Any) {
        present((storyboard?.instantiateViewController(withIdentifier: "Cerca"))!, animated: true, completion: nil)
    }
    
    @IBAction func cambiaVisualizzazione(_ sender: Any) {
        selezionato = scelta.titleForSegment(at: scelta.selectedSegmentIndex)!
        infoPicker.reloadAllComponents()
        threadCarica()
        infoPicker.selectRow(0, inComponent: 0, animated: true)
        numStagioni.selectRow(0, inComponent: 0, animated: true)
    }
    
    func threadCarica(){
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                Dati.viewAttesa.avviaRotazione()
            }
            self.allMatch.removeAll()
            var dimensione = 0
            if self.league.count > 0 && self.selezionato == "League"{
                self.elementoScelto = self.league[0]
            }else if self.team.count > 0 && self.selezionato == "Team"{
                self.elementoScelto = self.team[0]
            }else{
                self.elementoScelto = NSDictionary()
            }
            if self.elementoScelto.count > 0{
                self.trovaStagione()
                if self.stagione.count > 0{
                    self.trovaSqudre(row: 0)
                    if self.sportLeague(id: self.elementoScelto.value(forKey: "idLeague") as! String) == "Rugby" {
                        dimensione = self.selezionaRoundAttuale(row: 0)
                        self.trovaMatchRound(round: dimensione)
                    }
                }
            }else{
                self.cancellaTutto()
            }
            DispatchQueue.main.async {
                self.infoPicker.reloadAllComponents()
                self.numRound.reloadAllComponents()
                self.numStagioni.reloadAllComponents()
                self.contenitore.reloadData()
                self.numRound.selectRow(dimensione, inComponent: 0, animated: true)
                Dati.viewAttesa.fermaRotazione()
            }
        }
    }
    
    func cancellaTutto(){
        self.stagione.removeAll()
        self.round.removeAll()
        self.match.removeAll()
        self.allMatch.removeAll()
        self.allTeam.removeAll()
        DispatchQueue.main.async {
            self.infoPicker.reloadAllComponents()
            self.numRound.reloadAllComponents()
            self.numStagioni.reloadAllComponents()
            self.contenitore.reloadData()
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
                var appoggio = ["str" + nome, "id" + nome, Dati.codImm(ricerca: nome)]
                if nome == "Team"{
                    appoggio.append("idLeague")
                }
                let array = Dati.esenzialiRicerca(condizioni: appoggio, lista: Dati.richiestraWeb(query: query + id))
                if array.count > 0{
                    elementi.append(array[0])
                    elementi[elementi.count - 1].setValue(nome, forKey: "nome")
                }
            }
        }
        return elementi
    }
    
    func trovaSqudre(row : Int){
        allMatch.removeAll()
        let id = elementoScelto.value(forKey: "idLeague") as! String
        let query = ["https://www.thesportsdb.com/api/v1/json/1/eventsseason.php?id=" + id + "&s=" + String(stagione[row].split(separator: ";")[0]), "https://www.thesportsdb.com/api/v1/json/1/lookup_all_teams.php?id=" + id]
        allMatch = Dati.esenzialiRicerca(condizioni: ["idLeague", "strHomeTeam", "strAwayTeam", "intHomeScore", "intAwayScore", "dateEvent",  "strTime", "intRound"], lista: Dati.richiestraWeb(query: query[0]))
        allTeam = Dati.esenzialiRicerca(condizioni: ["idTeam", "strTeam", Dati.codImm(ricerca: "Team")], lista: Dati.richiestraWeb(query: query[1]))
        DispatchQueue.main.async {
            self.numRound.isHidden = false
        }
        if selezionato == "Team"{
            DispatchQueue.main.async {
                self.numRound.isHidden = true
            }
            round.removeAll()
        }
        let appoggio = allMatch[0].value(forKey: "intRound") as? String ?? ""
        if appoggio == "" || appoggio == "0"{
            round.removeAll()
            var roundAttuale = 1
            for i in 0...allMatch.count - 1{
                if i != 0 && incrementaRound(round: i){
                    roundAttuale += 1
                }
                allMatch[i].setValue(String(roundAttuale), forKey: "intRound")
                if !round.contains(String(roundAttuale)){
                    round.append(String(roundAttuale))
                }
            }
            round.reverse()
        }
        controllaDuplicati()
        controllaNomeSquadre()
    }
    
    func incrementaRound(round : Int) -> Bool{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let data1 = formatter.date(from: allMatch[round - 1].value(forKey: "dateEvent") as! String)!
        let data2 = formatter.date(from: allMatch[round].value(forKey: "dateEvent") as! String)!
        let appoggio = Calendar.current.dateComponents([.day], from: data1, to: data2).day ?? 0
        if appoggio > 4{
            return true
        }
        return false
    }
    
    func controllaDuplicati(){
        var index = 0
        while index < allMatch.count - 1{
            var condizione = false
            let squadre = [allMatch[index].value(forKey: "strHomeTeam") as? String ?? "", allMatch[index].value(forKey: "strAwayTeam") as? String ?? "", allMatch[index].value(forKey: "intRound") as? String ?? ""]
            let punteggio = [allMatch[index].value(forKey: "intHomeScore") as? String ?? "", allMatch[index].value(forKey: "intAwayeScore") as? String ?? ""]
            if punteggio[0] == "" && punteggio[1] == "" {
                for i in 0...allMatch.count - 1{
                    let squadre2 = [allMatch[i].value(forKey: "strHomeTeam") as? String ?? "", allMatch[i].value(forKey: "strAwayTeam") as? String ?? "", allMatch[i].value(forKey: "intRound") as? String ?? ""]
                    if index != i && squadre[0] == squadre2[0] && squadre[1] == squadre2[1] && squadre[2] == squadre2[2] {
                        condizione = true
                    }
                }
                if condizione{
                    allMatch.remove(at: index)
                    index -= 1
                }
            }
            index += 1
        }
    }
    
    func controllaNomeSquadre(){
        for item in allMatch{
            var squadra1 = item.value(forKey: "strHomeTeam") as! String
            var squadra2 = item.value(forKey: "strAwayTeam") as! String
            if squadra1 == "Benneton"{
                squadra1 = "Benetton"
            }else if squadra2 == "Benneton"{
                squadra2 = "Benetton"
            }
            item.setValue(squadra1, forKey: "strHomeTeam")
            item.setValue(squadra2, forKey: "strAwayTeam")
        }
    }
    
    func trovaMatchRound(round : Int){
        var condizione = false
        DispatchQueue.main.sync {
            if !self.numRound.isHidden{
                condizione = true
            }
        }
        if condizione{
            let appoggio = self.round[round]
            match.removeAll()
            for item in allMatch{
                if item.value(forKey: "intRound") as! String == appoggio{
                    match.append(item)
                }
            }
        }else{
            match.removeAll()
            let appoggio = elementoScelto.value(forKey: "strTeam") as! String
            for item in allMatch{
                if (item.value(forKey: "strHomeTeam") as! String).contains(appoggio){
                    match.append(item)
                }else if (item.value(forKey: "strAwayTeam") as! String).contains(appoggio){
                    match.append(item)
                }
            }
        }
    }
    
    func trovaStagione(){
        let query = "https://www.thesportsdb.com/api/v1/json/1/search_all_seasons.php?id=" + (elementoScelto.value(forKey: "idLeague") as! String)
        let risultato = Dati.richiestraWeb(query: query)
        self.stagione.removeAll()
        if risultato.count > 0{
            for i in 0...risultato.count - 1{
                let stagione = risultato[i].value(forKey: "strSeason") as! String
                self.stagione.append(stagione + ";")
                aggiornaElementiRound(row: i, caricaStagione: true, caricaRound: false)
            }
            stagione.reverse()
            aggiornaElementiRound(row: 0, caricaStagione: false, caricaRound: true)
        }
    }
    
    func selezionaRoundAttuale(row : Int) -> Int{
        if round.count > 0{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-gg"
            let data = formatter.string(from: Date())
            var dimensione = allMatch.count - 1
            while dimensione >= 0{
                if (allMatch[dimensione].value(forKey: "dateEvent") as! String).compare(data) == ComparisonResult.orderedAscending{
                    if dimensione < allMatch.count - 1{
                        dimensione += 1
                    }
                    for num in 0...round.count - 1{
                        if round[num] == allMatch[dimensione].value(forKey: "intRound") as! String{
                            return num
                        }
                    }
                }
                dimensione -= 1
            }
        }
        return -1
    }
    
    func aggiornaElementiRound(row : Int, caricaStagione : Bool, caricaRound : Bool){
        var query = "https://www.thesportsdb.com/api/v1/json/1/eventsseason.php?id="
        query += elementoScelto.value(forKey: "idLeague") as! String + "&s=" + String(stagione[row].split(separator: ";")[0])
        let appoggio = Dati.esenzialiRicerca(condizioni: ["intRound", "dateEvent"], lista: Dati.richiestraWeb(query: query))
        if caricaRound{
            round.removeAll()
            var dimensione = Int(appoggio[appoggio.count - 1].value(forKey: "intRound") as? String ?? "0") ?? 0
            while dimensione > 0{
                round.append(String(dimensione))
                dimensione -= 1
            }
        }
        if caricaStagione{
            let dataInizio = String((appoggio[0].value(forKey: "dateEvent") as! String).split(separator: "-")[0])
            let dataFine = String((Int(dataInizio) ?? 0) + 1)
            stagione[row] += dataInizio + "-" + dataFine
        }
    }
    
    func aggiorna(row : Int, tag : Int){
        DispatchQueue.global(qos: .default).async{
            var condizione = false
            DispatchQueue.main.async {
                Dati.viewAttesa.avviaRotazione()
                condizione = self.numRound.isHidden
            }
            if tag == 0{
                self.aggiornaPrincipale(row: row)
            }else if tag == 1 && !condizione{
                self.aggiornaRound(row: row)
            }else{
                self.aggiornaStagioni(row: row)
            }
            DispatchQueue.main.async {
                self.contenitore.reloadData()
                self.contenitore.selectItem(at: IndexPath.init(row: 0, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
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
            if stagione.count > 0{
                trovaSqudre(row: 0)
                if sportLeague(id: elementoScelto.value(forKey: "idLeague") as! String) == "Rugby"{
                    trovaMatchRound(round: selezionaRoundAttuale(row: 0))
                }
            }else{
                stagione.removeAll()
                round.removeAll()
                match.removeAll()
            }
        }
        DispatchQueue.main.async {
            self.numStagioni.selectRow(0, inComponent: 0, animated: true)
            self.numRound.reloadAllComponents()
            self.numStagioni.reloadAllComponents()
        }
    }
    
    func aggiornaRound(row : Int){
        trovaMatchRound(round: row)
        DispatchQueue.main.async {
            self.contenitore.reloadData()
        }
    }
    
    func aggiornaStagioni(row : Int){
        aggiornaElementiRound(row: row, caricaStagione: false, caricaRound: true)
        trovaSqudre(row: row)
        let dimensione = selezionaRoundAttuale(row: row)
        trovaMatchRound(round: dimensione)
        DispatchQueue.main.async {
            self.numRound.reloadAllComponents()
            self.contenitore.reloadData()
            self.numRound.selectRow(dimensione, inComponent: 0, animated: true)
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
    
    func sportLeague(id : String) -> String{
        let dizionario = Dati.esenzialiRicerca(condizioni: ["strSport"], lista: Dati.richiestraWeb(query: "https://www.thesportsdb.com/api/v1/json/1/lookupleague.php?id=" + id))
        return dizionario[0].value(forKey: "strSport") as! String
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
        }else if pickerView.tag == 1 && round.count > 0{
            return round.count
        }
        if stagione.count > 0{
            return stagione.count
        }
        return 1
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
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 85, height: 20))
        let label = UILabel(frame: CGRect(x: 0, y: 2, width: 85, height: 15))
        if stagione.count > 0{
            if pickerView.tag == 1{
                label.text = round[row]
            }else{
                label.text = String(stagione[row].split(separator: ";")[1])
                label.font = UIFont(name: label.font.fontName, size: 15)
            }
        }else{
            label.text = "No data"
        }
        label.textAlignment = NSTextAlignment.center
        view.addSubview(label)
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if stagione.count > 0{
            aggiorna(row: row, tag: pickerView.tag)
        }else if pickerView.tag == 0{
            aggiorna(row: row, tag: pickerView.tag)
        }
    }
}

extension Preferiti: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if match.count > 0{
            return match.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if match.count == 0{
            return contenitore.dequeueReusableCell(withReuseIdentifier: "NoData", for: indexPath)
        }
        return caricaLeague(dizionario: match[indexPath.row], cella: contenitore.dequeueReusableCell(withReuseIdentifier: "League", for: indexPath) as! League)
    }
    
    func caricaLeague(dizionario : NSDictionary, cella : League) -> UICollectionViewCell{
        var idteamH = NSDictionary(), idTeamA = NSDictionary()
        for item in allTeam{
            let appoggio = String((item.value(forKey: "strTeam") as! String).split(separator: " ")[0])
            if (dizionario.value(forKey: "strAwayTeam") as! String).contains(appoggio){
                idTeamA = item
            }
            if (dizionario.value(forKey: "strHomeTeam") as! String).contains(appoggio){
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
