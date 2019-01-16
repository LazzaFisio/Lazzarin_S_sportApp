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
    static var selezionato : [String : Any] = [:]
    static let sports = ["Rugby"]
    static var json : Array<NSDictionary> = []
    
    public static func caricaJson(query : String, ricerca : String){
        self.ricerca = ricerca
        let url = URL(string: query)
        let session = URLSession.shared
        var cond = false
        session.dataTask(with: url!) { (data, response, error) in
            do{
                let risposta = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : Array<NSDictionary>]
                for item in risposta{
                    json = item.value
                }
                cond = true
            }catch{
                errore = error as! String
                cond = true
            }
        }.resume()
        while !cond {}
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
        var cond = false
        session.dataTask(with: url!) { (data, res, error) in
            guard let data = data, error == nil
            else
            {
                errore = error as! String
                cond = true
                return
            }
            immagine = UIImage(data: data)!
            cond = true
        }.resume()
        while !cond {}
        return immagine
    }
}
