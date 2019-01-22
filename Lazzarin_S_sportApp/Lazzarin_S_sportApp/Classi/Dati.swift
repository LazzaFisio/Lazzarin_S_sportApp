//
//  Info.swift
//  sport app
//
//  Created by Leonardo Lazzarin on 15/01/2019.
//  Copyright © 2019 Leonardo Lazzarin. All rights reserved.
//

import Foundation
import UIKit

class Dati{
    
    static var errore : String = ""
    static var ricerca : String = ""
    static var condizione : Bool = false
    static var json : Array<NSDictionary> = []
    static var preferiti : Array<NSMutableDictionary> = caricaPreferiti()
    static var selezionato = NSDictionary()
    static var informazioni = NSDictionary()
    
    //---------------------------------------------------------------
    //                     Gestione json
    //---------------------------------------------------------------
    
    public static func caricaJson(query : String, ricerca : String){
        self.ricerca = ricerca
        let url = URL(string: query)
        let session = URLSession.shared
        session.dataTask(with: url!) { (data, response, error) in
            if error == nil{
                do{
                    if let risposta = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String : Array<NSDictionary>]{
                        for item in risposta{
                            json = item.value
                        }
                    }else{
                        errore = "nessun dato trovato"
                        json = Array<NSDictionary>()
                    }
                }catch{ errore = "errore" }
            }else{ errore = "Errore di connessione" }
            condizione = true
        }.resume()
        while !condizione {}
        condizione = false
        errore = ""
    }
    
    public static func elementi(key : String) -> [String]{
        var oggetti : [String] = []
        for item in json{
            oggetti.append(item.value(forKey: key) as? String ?? "")
        }
        return oggetti
    }
    
    public static func immagine(stringa : String) -> UIImage{
        let url = URL(string: stringa)
        let session = URLSession.shared
        var immagine = UIImage()
        if stringa != ""{
            session.dataTask(with: url!) { (data, res, error) in
                guard let data = data, error == nil
                else
                {
                    errore = "erorre si connessione"
                    return
                }
                immagine = UIImage(data: data)!
                condizione = true
                }.resume()
            while !condizione {}
            condizione = false
            errore = ""
        }
        return immagine
    }
    
    public static func aggiungiSelezionato(tag : Int){
        selezionato = json[tag]
        informazioni = NSDictionary()
    }
    
    public static func aggiungiSelezionatoInformazioni(tag : Int){
        informazioni = json[tag]
    }
    
    public static func creaView(dimensioni : [CGRect], imm : UIImage, testo : String, stella : [Bool], tag : Int) -> UIView{
        let view = UIView(frame: dimensioni[0])
        let bottone = UIButton(frame: dimensioni[1])
        bottone.setImage(UIImage(named: "cerchio.png"), for: .normal)
        bottone.tag = tag
        let label = UILabel(frame: dimensioni[2])
        label.numberOfLines = 0
        label.text = testo
        label.textAlignment = NSTextAlignment.center
        let immagine = UIImageView(frame: dimensioni[3])
        immagine.image = imm
        if stella[0] {
            let immStella = UIImageView(frame: dimensioni[4])
            if stella[1]{
                immStella.image = UIImage(named: "stellaPiena.png")
            }else{
                immStella.image = UIImage(named: "stellaVuota.png")
            }
            view.addSubview(immStella)
        }
        view.addSubview(bottone)
        view.addSubview(label)
        view.addSubview(immagine)
        return view
    }
    
    //---------------------------------------------------------------
    //                     Gestione preferiti
    //---------------------------------------------------------------
    
    private static func caricaPreferiti() -> Array<NSMutableDictionary> {
        var appoggio = Array<NSMutableDictionary>()
        let cercare = ["numLeague", "numTeam"]
        let nomi = ["League", "Team"]
        for i in 0...cercare.count - 1{
            let daAggiungere = NSMutableDictionary()
            daAggiungere.setValue(nomi[i], forKey: "nome")
            let dimensione = UserDefaults.standard.value(forKey: cercare[i]) as? Int ?? 0
            daAggiungere.setValue(dimensione, forKey: "dimensione")
            if dimensione > 0{
                for y in 1...dimensione{
                    let inserire = String(y) + nomi[i]
                    daAggiungere.setValue(UserDefaults.standard.value(forKey: inserire), forKey: inserire)
                }
            }
            appoggio.append(daAggiungere)
        }
        return appoggio
    }
    
    public static func aggiungiPreferiti(valore : String, opzione: String) {
        for item in preferiti{
            if item.value(forKey: "nome") as! String == opzione{
                var dimensione = item.value(forKey: "dimensione") as! Int
                dimensione += 1
                item.setValue(valore, forKey: String(dimensione) + (item.value(forKey: "nome") as! String))
                item.setValue(dimensione, forKey: "dimensione")
            }
        }
        salvaPreferiti()
    }
    
    public static func cancellaPreferiti(valore : String, opzione : String){
        for item in preferiti{
            if item.value(forKey: "nome") as! String == opzione{
                var dimensione = item.value(forKey: "dimensione") as! Int
                var dizionario : [String] = []
                for i in 1...dimensione{
                    UserDefaults.standard.removeObject(forKey: String(i) + opzione)
                    let appoggio = item.value(forKey: String(i) + opzione) as! String
                    if appoggio != valore{
                        dizionario.append(appoggio)
                    }
                    item.removeObject(forKey: appoggio)
                }
                dimensione -= 1
                if dimensione > 0{
                    for i in 1...dimensione{
                        item.setValue(dizionario[i - 1], forKey: String(i) + opzione)
                    }
                }
                item.setValue(dimensione, forKey: "dimensione")
            }
        }
        salvaPreferiti()
    }
    
    public static func preferito(valore : String, opzione : String) -> Bool{
        for item in preferiti{
            if item.value(forKey: "nome") as! String == opzione{
                let dimensione = item.value(forKey: "dimensione") as! Int
                if dimensione > 0{
                    for i in 1...dimensione{
                        if item.value(forKey: String(i) + opzione) as! String == valore{
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    private static func salvaPreferiti(){
        for item in preferiti{
            let nome = item.value(forKey: "nome") as! String
            UserDefaults.standard.removeObject(forKey: "num" + nome)
            UserDefaults.standard.setValue(item.value(forKey: "dimensione"), forKey: "num" + nome)
            let dimensione = item.value(forKey: "dimensione") as! Int
            if dimensione > 0{
                for i in 1...dimensione{
                    let inserire = String(i) + nome
                    UserDefaults.standard.removeObject(forKey: inserire)
                    UserDefaults.standard.setValue(item.value(forKey: inserire), forKey: inserire)
                }
            }
        }
    }
}
