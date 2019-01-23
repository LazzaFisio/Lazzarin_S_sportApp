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
    static var json : Array<NSMutableDictionary> = []
    static var preferiti : Array<NSMutableDictionary> = caricaPreferiti()
    static var elementiRicerca = [String : Array<NSMutableDictionary>]()
    static var selezionato = NSDictionary()
    static var informazioni = NSDictionary()
    static var thread = DispatchQueue.global(qos: .background)
    
    //---------------------------------------------------------------
    //                     Gestione json
    //---------------------------------------------------------------
    
    public static func caricaJson(query : String, ricerca : String){
        self.ricerca = ricerca
        json = richiestraWeb(query: query)
    }
    
    public static func caricaElementiRicerca(){
        let sport = ["Rugby", "Motorsport"]
        for item in sport{
            let leaugue = richiestraWeb(query: "https://www.thesportsdb.com/api/v1/json/1/search_all_leagues.php?s=" + item)
            elementiRicerca.updateValue(leaugue, forKey: "League/" + item)
            var team = [NSMutableDictionary]()
            var player = [NSMutableDictionary]()
            for item1 in leaugue{
                var index = item1.value(forKey: "idLeague") as! String
                let appoggio = richiestraWeb(query: "https://www.thesportsdb.com/api/v1/json/1/lookup_all_teams.php?id=" + index)
                for item2 in appoggio{
                    team.append(item2)
                    index = team[team.count - 1].value(forKey: "idTeam") as! String
                    let app = richiestraWeb(query: "https://www.thesportsdb.com/api/v1/json/1/lookup_all_players.php?id=" + index)
                    for item3 in app{
                        player.append(item3)
                    }
                }
            }
            elementiRicerca.updateValue(team, forKey: "Team/" + item)
            elementiRicerca.updateValue(player, forKey: "Player/" + item)
            controllaEsistenzaImmagini(elementi: leaugue, chiave: "League")
            controllaEsistenzaImmagini(elementi: team, chiave: "Team")
            controllaEsistenzaImmagini(elementi: player, chiave: "Player")
        }
    }
    
    public static func elementiRicerca(chiave : String) -> [NSMutableDictionary]{
        var dizionario = [[NSMutableDictionary]]()
        let chiavi = Array(elementiRicerca.keys)
        for i in 0...chiavi.count - 1{
            if chiavi[i] == chiave{
                let valori = Array(elementiRicerca.values)
                dizionario.append(valori[i])
            }
        }
        return dizionario[0]
    }
    
    private static func richiestraWeb(query : String) -> [NSMutableDictionary]{
        let url = URL(string: query)
        var elementi = [NSMutableDictionary]()
        let session = URLSession.shared
        session.dataTask(with: url!) { (data, response, error) in
            if error == nil{
                do{
                    if let risposta = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String : Array<NSMutableDictionary>]{
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
        condizione = false
        errore = ""
        return elementi
    }
    
    public static func elementi(key : String) -> [String]{
        var oggetti : [String] = []
        for item in json{
            oggetti.append(item.value(forKey: key) as? String ?? "")
        }
        return oggetti
    }
    
    //---------------------------------------------------------------
    //                     Gestione immagini
    //---------------------------------------------------------------
    
    public static func immagine(stringa : String, chiave : String){
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
                immagine = UIImage(data: data) ?? UIImage()
                condizione = true
                }.resume()
            while !condizione {}
            condizione = false
            errore = ""
        }
        let imm = immagine.pngData()! as NSData
        UserDefaults.standard.set(imm, forKey: chiave)
    }
    
    
    private static func controllaEsistenzaImmagini(elementi : [NSMutableDictionary], chiave : String){
        for item in elementi{
            let id = item.value(forKey: "id" + chiave) as! String
            var urlImm = ""
            switch chiave{
            case "Player": urlImm = "strCutout"; break
            case "Team": urlImm = "strTeamBadge"; break
            default: urlImm = "strBadge"; break
            }
            let data = UserDefaults.standard.value(forKey: id)
            if  data == nil{
                immagine(stringa: (item.value(forKey: urlImm) as? String ?? ""), chiave: id)
            }
        }
    }
    
    public static func immagine(chiave : String) -> UIImage{
        let data = UserDefaults.standard.value(forKey: chiave)
        if data != nil{
            return UIImage(data: (data as! NSData) as Data)!
        }
        return UIImage()
    }
    
    //---------------------------------------------------------------
    //                     Gestione elementi json
    //---------------------------------------------------------------
    
    public static func creaView(dimensioni : [CGRect], imm : UIImage, testo : String, stella : [Bool], tag : Int) -> UIView{
        let view = UIView(frame: dimensioni[0])
        if dimensioni[1].size.width > -1{
            let bottone = UIButton(frame: dimensioni[1])
            bottone.setImage(UIImage(named: "cerchio.png"), for: .normal)
            bottone.tag = tag
            view.addSubview(bottone)
        }
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
        view.addSubview(label)
        view.addSubview(immagine)
        return view
    }
    
    public static func aggiungiSelezionato(tag : Int){
        selezionato = json[tag]
        informazioni = NSDictionary()
    }
    
    public static func aggiungiSelezionatoInformazioni(tag : Int){
        informazioni = json[tag]
    }
    
    //---------------------------------------------------------------
    //                     Gestione preferiti
    //---------------------------------------------------------------
    
    @objc private static func caricaPreferiti() -> Array<NSMutableDictionary> {
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
