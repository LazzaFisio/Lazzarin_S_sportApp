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
    static var selezionato = NSDictionary()
    
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
}
