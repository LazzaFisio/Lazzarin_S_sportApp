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
    static var preferiti : Array<NSMutableDictionary> = []
    static var selezionato = NSDictionary()
    static var informazioni = NSDictionary()
    static var viewAttesa : ViewAttesa!
    
    //---------------------------------------------------------------
    //                     Gestione json
    //---------------------------------------------------------------
    
    public static func richiestraWeb(query : String) -> [NSDictionary]{
        let url = URL(string: query)
        var condizione = false
        var elementi = [NSDictionary]()
        let session = URLSession.shared
        if(query != ""){
            session.dataTask(with: url!) { (data, response, error) in
                if error == nil{
                    do{
                        if let risposta = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String : Array<NSDictionary>]{
                            for item in risposta{
                                elementi = item.value
                            }
                        }else{
                            errore = "nessun dato trovato"
                            elementi.removeAll()
                        }
                    }catch{ errore = "errore" }
                }else{ errore = "Errore di connessione" }
                condizione = true
                }.resume()
            while !condizione {}
            errore = ""
        }
        return elementi
    }
    
    public static func esenzialiRicerca(condizioni : [String], lista : [NSDictionary]) -> [NSMutableDictionary]{
        var dizionario = [NSMutableDictionary]()
        for item in lista{
            let appoggio = NSMutableDictionary()
            for item2 in condizioni{
                appoggio.setValue(item.value(forKey: item2) as? String ?? "", forKey: item2)
            }
            dizionario.append(appoggio)
        }
        return dizionario
    }
    
    public static func tutteLeghe(sport : String, restrizioni : Bool) -> [NSDictionary]{
        let richiesta = "https://www.thesportsdb.com/api/v1/json/1/search_all_leagues.php?s=" + sport
        if restrizioni{
            return esenzialiRicerca(condizioni: ["strLeague", "idLeague", "strBadge"], lista: richiestraWeb(query: richiesta))
        }else{
            return richiestraWeb(query: richiesta)
        }
    }
    
    public static func tuttiTeam(sport : String, restrizioni : Bool) -> [NSDictionary]{
        let leghe = tutteLeghe(sport: sport, restrizioni: restrizioni)
        var dizionario = [NSDictionary]()
        let query = "https://www.thesportsdb.com/api/v1/json/1/lookup_all_teams.php?id="
        for item in leghe{
            if Cerca.ricerca != ""{
                let appoggio = richiestraWeb(query: query + (item.value(forKey: "idLeague") as! String))
                for item2 in appoggio{
                    dizionario.append(item2)
                }
            }
        }
        if restrizioni && Cerca.ricerca != ""{
            return esenzialiRicerca(condizioni: ["strTeam", "idTeam", "strTeamBadge"], lista: dizionario)
        }
        return dizionario
    }
    
    public static func tuttiPlayer(sport : String, restrizioni : Bool) -> [NSDictionary]{
        let team = tuttiTeam(sport: sport, restrizioni: restrizioni)
        var dizionario = [NSDictionary]()
        let query = "https://www.thesportsdb.com/api/v1/json/1/lookup_all_players.php?id="
        for item in team{
            if Cerca.ricerca != ""{
                let appoggio = richiestraWeb(query: query + (item.value(forKey: "idTeam") as! String))
                for item2 in appoggio{
                    dizionario.append(item2)
                }
            }
        }
        if restrizioni && Cerca.ricerca != ""{
            return esenzialiRicerca(condizioni: ["strPlayer", "idPlayer", "strCutout"], lista: dizionario)
        }
        return dizionario
    }
    
    //---------------------------------------------------------------
    //                     Gestione immagini
    //---------------------------------------------------------------
    
    public static func scaricaImmagine(stringa : String, chiave : String){
        let url = URL(string: stringa)
        var condizione = false
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
                immagine = UIImage(data: data) ?? UIImage()
                condizione = true
                }.resume()
            while !condizione {}
            errore = ""
        }
        let imm = immagine.pngData() as NSData? ?? NSData()
        UserDefaults.standard.set(imm, forKey: chiave)
    }
    
    public static func immagine(chiave : String, url : String) -> UIImage{
        var data = UserDefaults.standard.value(forKey: chiave)
        var immagine = UIImage()
        if data != nil{
            let appoggio = data as! NSData
            immagine = UIImage(data: appoggio as Data) ?? UIImage()
        }else if url != ""{
            scaricaImmagine(stringa: url, chiave: chiave)
            data = UserDefaults.standard.value(forKey: chiave)
            immagine = UIImage(data: (data as! NSData) as Data)!
        }
        return immagine
    }
    
    public static func codImm(ricerca : String) -> String{
        switch ricerca {
        case "Player": return "strBadge"
        case "Team": return "strTeamBadge"
        default: return "strBadge"
        }
    }
    
    public static func immBandiera(stato : String) -> UIImage{
        let dizionario = esenzialiRicerca(condizioni: ["Response"], lista: richiestraWeb(query: "http://countryapi.gear.host/v1/Country/getCountries?pName=" + nomeCorrettoStato(stato: stato)))[0]
        return immagine(chiave: stato, url: (dizionario[0] as! NSDictionary).value(forKey: "FlagPng") as? String ?? "")
    }
    
    private static func nomeCorrettoStato(stato : String) -> String{
        if stato == "USA"{
            return "United States of America"
        }
        return stato
    }
    
    //---------------------------------------------------------------
    //                     Gestione preferiti
    //---------------------------------------------------------------
    
    public static func caricaPreferiti(){
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
            preferiti.append(daAggiungere)
        }
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
