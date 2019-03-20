//
//  Eventi.swift
//  Lazzarin_S_sportApp
//
//  Created by Leonardo Lazzarin on 20/02/2019.
//  Copyright © 2019 Leonardo Lazzarin. All rights reserved.
//

import UIKit

class Eventi: UIViewController {

    @IBOutlet weak var dataScelta: UIDatePicker!
    
    @IBOutlet weak var contenitore: UICollectionView!
    
    var elementi = [NSDictionary]()
    var teams = [NSDictionary]()
    var trovati = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contenitore.delegate = self
        contenitore.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Dati.viewAttesa.aggiungiAllaView(view: view)
    }

    @IBAction func cambioData(_ sender: Any) {
        elementi.removeAll()
        teams.removeAll()
        let composizioneData = DateFormatter()
        composizioneData.dateFormat = "yyyy-MM-dd"
        let data = composizioneData.string(from: dataScelta.date)
        Dati.viewAttesa.avviaRotazione()
        DispatchQueue.global().sync {
            let condizioni = ["idLeague", "strHomeTeam", "strAwayTeam", "intHomeScore", "intAwayScore"]
            var appoggio = Dati.esenzialiRicerca(condizioni:condizioni, lista: Dati.richiestraWeb(query: "https://www.thesportsdb.com/api/v1/json/1/eventsday.php?d=" + data + "&s=Rugby"))
            if appoggio.count > 0{
                trovati = true
                for item in appoggio{
                    elementi.append(item)
                }
                appoggio = Dati.esenzialiRicerca(condizioni:condizioni, lista: Dati.richiestraWeb(query: "https://www.thesportsdb.com/api/v1/json/1/eventsday.php?d=" + data + "&s=Motorsport"))
                if appoggio.count > 0{
                    for item in appoggio{
                        elementi.append(item)
                    }
                }
                for item in elementi{
                    appoggio = Dati.esenzialiRicerca(condizioni: ["idTeam", "strTeam"], lista: Dati.richiestraWeb(query: "https://www.thesportsdb.com/api/v1/json/1/lookup_all_teams.php?id=" + (item.value(forKey: "idLeague") as! String)))
                    for squadra in appoggio{
                        let squadra1 = item.value(forKey: "strHomeTeam") as! String
                        let squadra2 = item.value(forKey: "strAwayTeam") as! String
                        let squadraP = squadra.value(forKey: "strTeam") as! String
                        if squadra1 == squadraP || squadra2 == squadraP {
                            teams.append(squadra)
                        }
                    }
                }
            }else { trovati = false }
            DispatchQueue.main.async {
                self.contenitore.reloadData()
            }
        }
        Dati.viewAttesa.fermaRotazione()
    }
}

extension Eventi : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if trovati{
            return elementi.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if trovati{
            let cella = collectionView.dequeueReusableCell(withReuseIdentifier: "Partita", for: indexPath) as! League
            let idSquadra1 = trovaSquadra(nome: elementi[indexPath.row].value(forKey: "strHomeTeam") as! String)
            let idSquadra2 = trovaSquadra(nome: elementi[indexPath.row].value(forKey: "strAwayTeam") as! String)
            cella.immSqr1.image = Dati.immagine(chiave: idSquadra1, url: elementi[indexPath.row].value(forKey: Dati.codImm(ricerca: "Team")) as? String ?? "")
            cella.immSqr2.image = Dati.immagine(chiave: idSquadra2, url: elementi[indexPath.row].value(forKey: Dati.codImm(ricerca: "Team")) as? String ?? "")
            cella.nomeSqr1.text = elementi[indexPath.row].value(forKey: "strHomeTeam") as? String
            cella.nomeSqr2.text = elementi[indexPath.row].value(forKey: "strAwayTeam") as? String
            cella.puntSqr1.text = elementi[indexPath.row].value(forKey: "intHomeScore") as? String
            cella.puntSqr2.text = elementi[indexPath.row].value(forKey: "intAwayScore") as? String
            return cella
        }
        let cella = collectionView.dequeueReusableCell(withReuseIdentifier: "NoEventi", for: indexPath) as! NoEventi
        return cella
    }
    
    func trovaSquadra(nome : String) -> String{
        for item in teams{
            if item.value(forKey: "strTeam") as! String == nome{
                return item.value(forKey: "idTeam") as! String
            }
        }
        return ""
    }
    
}
