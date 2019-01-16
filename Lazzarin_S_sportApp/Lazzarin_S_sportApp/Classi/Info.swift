//
//  Info.swift
//  sport app
//
//  Created by Leonardo Lazzarin on 15/01/2019.
//  Copyright © 2019 Leonardo Lazzarin. All rights reserved.
//

import Foundation
import UIKit

class Info{
    
    static var errore : String = ""
    static var ricerca : String = ""
    static var condizione : Bool = false
    static var selezionato : [String : Any] = [:]
    static var json : Array<NSDictionary> = []
    
    public static func caricaJson(query : String, ricerca : String){
        self.ricerca = ricerca
        let url = URL(string: query)
        let session = URLSession.shared
        session.dataTask(with: url!) { (data, response, error) in
            do{
                let risposta = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : Array<NSDictionary>]
                for item in risposta{
                    json = item.value
                }
                condizione = true
            }catch{
                errore = error as! String
                condizione = true
            }
        }.resume()
    }
    
    public static func elementi(key : String) -> [String]{
        var oggetti : [String] = []
        for item in json{
            oggetti.append(item.value(forKey: key) as? String ?? "")
        }
        return oggetti
    }
    
    public static func immagine(url : String) -> UIImage{
        let url = URL(string: url)
        let session = URLSession.shared
        var immagine = UIImage()
        session.dataTask(with: url!) { (data, res, error) in
            guard let data = data, error == nil
            else
            {
                errore = error as! String
                condizione = true
                return
            }
            immagine = UIImage(data: data)!
            condizione = true
        }.resume()
        while !condizione {}
        return immagine
    }
    
    public static func creaView(viewPrincipale : UIView, dimensioni : [CGRect], immagini : [UIImage], testo : String, stella : [Bool], tag : Int){
        let view = UIView(frame: dimensioni[0])
        let bottone = UIButton(frame: dimensioni[1])
        bottone.setImage(immagini[0], for: .normal)
        bottone.tag = tag
        let label = UILabel(frame: dimensioni[2])
        label.text = testo
        label.textAlignment = NSTextAlignment.center
        let immagine = UIImageView(frame: dimensioni[3])
        immagine.image = immagini[1]
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
        viewPrincipale.addSubview(view)
    }
}
