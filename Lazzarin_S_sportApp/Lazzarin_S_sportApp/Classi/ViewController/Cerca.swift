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
    
    var elementi = [NSMutableDictionary]()
    var ricerca = ""
    var sportScelto = "Rugby"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nomiSport.delegate = self
        nomiSport.dataSource = self
        threadAttesa()
        // Do any additional setup after loading the view.
    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cambiaRicerca(_ sender: Any) {
        ricerca = dettagliCerca.titleForSegment(at: dettagliCerca.selectedSegmentIndex)!
        elementi = Dati.elementiRicerca(chiave: ricerca + "/" + sportScelto)
        aggiorna()
    }
    
    func aggiorna(){
        cancella()
        var dimensioni =
        [CGRect(x: 0, y: 0, width: contenitore.frame.width, height: 81),
         CGRect(x: -1, y: -1, width: -1, height: -1),
         CGRect(x: 96, y: 12, width: 214, height: 54),
         CGRect(x: 8, y: 8, width: 64, height: 64),
         CGRect(x: 318, y: 15, width: 50, height: 50)]
        contenitore.contentSize = CGSize(width: Int(view.frame.width), height: 81 * elementi.count)
        for i in 0...elementi.count - 1{
            dimensioni[0].origin.y = CGFloat(81 * i)
            let index = "id" + ricerca
            let condizione = Dati.preferito(valore: elementi[i].value(forKey: index) as! String, opzione: ricerca)
            let view = Dati.creaView(dimensioni: dimensioni, imm: Dati.trovaImmagine(chiave: elementi[i].value(forKey: index) as! String), testo: elementi[i].value(forKey: "str" + ricerca) as! String, stella: [true, condizione], tag: -1)
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
        let thread = DispatchQueue.global(qos: .background)
        thread.async {
            DispatchQueue.main.async {
                self.caricamento.isHidden = false
                self.funcRotazione()
            }
            
            print(Dati.immagini)
            DispatchQueue.main.async {
                self.elementi = Dati.elementiRicerca(chiave: "League/Rugby")
                self.ricerca = "League"
                self.aggiorna()
                self.caricamento.isHidden = true
            }
        }
    }
}

extension Cerca: UIPickerViewDelegate, UIPickerViewDataSource{
    
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
        elementi = Dati.elementiRicerca(chiave: ricerca + "/" + sportScelto)
        aggiorna()
    }
    
    func sport(tag : Int) -> String{
        switch tag{
        case 1: return "Motorsport"
        default: return "Rugby"
        }
    }
}
