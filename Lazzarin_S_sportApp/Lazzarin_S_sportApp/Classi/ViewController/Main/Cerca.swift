//
//  Cerca.swift
//  Lazzarin_S_sportApp
//
//  Created by Leonardo Lazzarin on 22/01/2019.
//  Copyright © 2019 Leonardo Lazzarin. All rights reserved.
//

import UIKit

class Cerca: UIViewController {
    
    @IBOutlet weak var cerca: UITextField!
    
    @IBOutlet weak var contenitore: UICollectionView!
    
    @IBOutlet weak var dettagliCerca: UISegmentedControl!
    
    @IBOutlet weak var nomiSport: UIPickerView!
    
    @IBOutlet weak var togliTastiera: UIButton!
    
    var thread = DispatchQueue.global(qos: .default)
    var elementi = [NSDictionary]()
    var ricercaAttuale = [NSDictionary]()
    static var ricerca = "League"
    var sportScelto = "Rugby"
    var query = ""
    var dati = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cerca.delegate = self
        nomiSport.delegate = self
        nomiSport.dataSource = self
        contenitore.dataSource = self
        contenitore.delegate = self
        Cerca.ricerca = "League"
        threadAttesa()
        Dati.viewAttesa.aggiungiAllaView(view: view)
        Dati.viewAttesa.aggiungiBottone()
        Dati.viewAttesa.bottone.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: Any) {
        Dati.viewAttesa.rimuoviBottone()
        Dati.viewAttesa.fermaRotazione()
        Cerca.ricerca = ""
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cambiaRicerca(_ sender: Any) {
        Cerca.ricerca = dettagliCerca.titleForSegment(at: dettagliCerca.selectedSegmentIndex)!
        cerca.text = ""
        dati = -1
        threadAttesa()
    }
    
    @IBAction func aggiornaRicerca(_ sender: Any) {
        cerca.isSelected = false
        var i = 0
        ricercaAttuale.removeAll()
        if cerca.text != ""{
            while i < elementi.count{
                let daConfontare = (cerca!.text ?? "").lowercased()
                let main = (elementi[i].value(forKey: "str" + Cerca.ricerca) as! String).lowercased()
                if main.contains(daConfontare){
                    ricercaAttuale.append(elementi[i])
                }
                i += 1
            }
            dati = 1
            if ricercaAttuale.count == 0{
                ricercaAttuale.append(NSDictionary())
                dati = 0
            }
        }else { dati = -1 }
        contenitore.reloadData()
        cerca.isSelected = true
    }
    
    @IBAction func inizioRicerca(_ sender: Any) {
        togliTastiera.isHidden = false
    }
    
    @IBAction func fineRicerca(_ sender: Any) {
        view.endEditing(true)
        togliTastiera.isHidden = true
    }
    
    @IBAction func preferiti(_ sender: Any) {
        let dizionario = elementi[(sender as! UIButton).tag]
        if Dati.preferito(valore: dizionario.value(forKey: "id" + Cerca.ricerca) as! String, opzione: Cerca.ricerca){
            Dati.cancellaPreferiti(valore: dizionario.value(forKey: "id" + Cerca.ricerca) as! String, opzione: Cerca.ricerca)
            (sender as! UIButton).setBackgroundImage(UIImage(named: "stellaVuota"), for: .normal)
        }else{
            Dati.aggiungiPreferiti(valore: dizionario.value(forKey: "id" + Cerca.ricerca) as! String, opzione: Cerca.ricerca)
            (sender as! UIButton).setBackgroundImage(UIImage(named: "stellaPiena"), for: .normal)
        }
    }
    
    func threadAttesa(){
        thread.async {
            DispatchQueue.main.async {
                Dati.viewAttesa.avviaRotazione()
                self.cerca.isSelected = false
                self.view.endEditing(true)
            }
            switch Cerca.ricerca{
                case "Player": self.elementi = Dati.tuttiPlayer(sport: self.sportScelto, restrizioni: true); break
                case "Team": self.elementi = Dati.tuttiTeam(sport: self.sportScelto, restrizioni: true); break
                default: self.elementi = Dati.tutteLeghe(sport: self.sportScelto, restrizioni: true); break
            }
            DispatchQueue.main.async {
                if Cerca.ricerca != ""{
                    self.ricercaAttuale.removeAll()
                    self.contenitore.reloadData()
                    Dati.viewAttesa.fermaRotazione()
                }
            }
        }
    }
}

extension Cerca: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Rugby"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        threadAttesa()
    }
}

extension Cerca : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dati > -1 {
            return ricercaAttuale.count
        }
        return elementi.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cella = contenitore.dequeueReusableCell(withReuseIdentifier: "Visualizza", for: indexPath) as! elementoRicerca
        var appoggio = elementi[indexPath.row]
        if dati == 0{
            cella.nome.text = "Nessun dato trovato"
            cella.immagine.isHidden = true
            cella.stella.isHidden = true
        }else{
            cella.immagine.isHidden = false
            if ricercaAttuale.count > 0{
                appoggio = ricercaAttuale[indexPath.row]
            }
            let id = appoggio.value(forKey: "id" + Cerca.ricerca) as! String
            cella.immagine.image = Dati.immagine(chiave: id, url: appoggio.value(forKey: Dati.codImm(ricerca: Cerca.ricerca)) as? String ?? "")
            cella.nome.text = appoggio.value(forKey: "str" + Cerca.ricerca) as? String ?? ""
            if Cerca.ricerca != "Player"{
                var nomeImm = "stellaVuota.png"
                if Dati.preferito(valore: id, opzione: Cerca.ricerca){
                    nomeImm = "stellaPiena.png"
                }
                cella.stella.setBackgroundImage(UIImage(named: nomeImm), for: .normal)
                cella.stella.tag = indexPath.row
                cella.stella.isHidden = false
            }else{
                cella.stella.isHidden = true
            }
        }
        return cella
    }
}
