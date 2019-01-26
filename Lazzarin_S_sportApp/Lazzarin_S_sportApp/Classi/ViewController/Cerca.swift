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
    
    @IBOutlet weak var dettagliCerca: UISegmentedControl!
    
    @IBOutlet weak var caricamento: UIView!
    
    @IBOutlet weak var caricamentoImg: UIImageView!
    
    @IBOutlet weak var nomiSport: UIPickerView!
    
    @IBOutlet weak var contenitore: UIScrollView!
    
    let thread = DispatchQueue.global(qos: .default)
    var elementi = [NSDictionary]()
    var ricerca = "League"
    var sportScelto = "Rugby"
    var query = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nomiSport.delegate = self
        nomiSport.dataSource = self
        threadAttesa()
        Dati.viewAttesa.aggiungiAllaView(view: view)
        Dati.viewAttesa.aggiungiBottone()
        Dati.viewAttesa.bottone.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: Any) {
        Dati.viewAttesa.rimuoviBottone()
        Dati.viewAttesa.fermaRotazione()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cambiaRicerca(_ sender: Any) {
        ricerca = dettagliCerca.titleForSegment(at: dettagliCerca.selectedSegmentIndex)!
        threadAttesa()
    }
    
    @IBAction func aggiornaRicerca(_ sender: Any) {
        cerca.isSelected = false
        var i = 0
        var ricercaAttuale = [NSDictionary]()
        if cerca.text != ""{
            while i < elementi.count{
                let daConfontare = (cerca!.text ?? "").lowercased()
                let main = (elementi[i].value(forKey: "str" + ricerca) as! String).lowercased()
                if main.contains(daConfontare){
                    ricercaAttuale.append(elementi[i])
                }
                i += 1
            }
            if ricercaAttuale.count > 0{
                aggiorna(appoggio: ricercaAttuale)
            }else{
                cancella()
            }
        }else{
            aggiorna(appoggio: elementi)
        }
        cerca.isSelected = true
    }
    
    @IBAction func fineRicerca(_ sender: Any) {
        
    }
    
    func aggiorna(appoggio : [NSDictionary]){
        cancella()
        var dimensioni =
        [CGRect(x: 0, y: 0, width: contenitore.frame.width, height: 81),
         CGRect(x: -1, y: -1, width: -1, height: -1),
         CGRect(x: 96, y: 12, width: 214, height: 54),
         CGRect(x: 8, y: 8, width: 64, height: 64),
         CGRect(x: 318, y: 15, width: 50, height: 50)]
        contenitore.contentSize = CGSize(width: Int(view.frame.width), height: 81 * appoggio.count)
        for i in 0...appoggio.count - 1{
            dimensioni[0].origin.y = CGFloat(81 * i)
            let index = "id" + ricerca
            let condizione = Dati.preferito(valore: appoggio[i].value(forKey: index) as! String, opzione: ricerca)
            let view = Dati.creaView(dimensioni: dimensioni, imm: Dati.immagine(chiave: appoggio[i].value(forKey: index) as! String, url: ""), testo: appoggio[i].value(forKey: "str" + ricerca) as! String, stella: [true, condizione], tag: -1)
            contenitore.addSubview(view)
        }
        contenitore.setContentOffset(CGPoint(x: 0, y: self.contenitore.contentInset.top), animated: true)
    }
    
    func cancella(){
        for subviews in contenitore.subviews{
            if subviews.subviews.count > 0{
                subviews.removeFromSuperview()
            }
        }
    }
    
    func funcRotazione(){
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear, animations: {
            self.caricamentoImg.transform = self.caricamentoImg.transform.rotated(by: CGFloat(Double.pi))
        }) { (success) in
            if !self.caricamento.isHidden{
                self.funcRotazione()
            }
        }
    }
    
    func threadAttesa(){
        thread.async {
            DispatchQueue.main.async {
                Dati.viewAttesa.avviaRotazione()
                self.cerca.isSelected = false
                self.view.endEditing(true)
            }
            switch self.ricerca{
                case "Player": self.elementi = Dati.tuttiPlayer(sport: self.sportScelto, restrizioni: true); break
                case "Team": self.elementi = Dati.tuttiTeam(sport: self.sportScelto, restrizioni: true); break
                default: self.elementi = Dati.tutteLeghe(sport: self.sportScelto, restrizioni: true); break
            }
            for item in self.elementi{
                Dati.controllaEsistenzaImmagini(chiave: item.value(forKey: "id" + self.ricerca) as! String, richiesta: item.value(forKey: Dati.codImm(ricerca: self.ricerca)) as? String ?? "")
            }
            DispatchQueue.main.async {
                self.aggiorna(appoggio: self.elementi)
                Dati.viewAttesa.fermaRotazione()
            }
        }
    }
}

extension Cerca: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sport(tag: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sportScelto = sport(tag: row)
        threadAttesa()
    }
    
    func sport(tag : Int) -> String{
        switch tag{
        case 1: return "Motorsport"
        default: return "Rugby"
        }
    }
}
