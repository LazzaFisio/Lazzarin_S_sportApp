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
    
    var elementi = [NSDictionary()]
    
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
        let composizioneData = DateFormatter()
        composizioneData.dateFormat = "yyyy-MM-dd"
        let data = composizioneData.string(from: dataScelta.date)
        Dati.viewAttesa.avviaRotazione()
        DispatchQueue.global().sync {
            let condizioni = ["idLeague", "strHomeTeam", "strAwayTeam", "intHomeScore", "intAwayScore"]
            var appoggio = Dati.esenzialiRicerca(condizioni:condizioni, lista: Dati.richiestraWeb(query: "https://www.thesportsdb.com/api/v1/json/1/eventsday.php?d=" + data + "&s=Rugby"))
            for item in appoggio{
                elementi.append(item)
            }
            appoggio = Dati.esenzialiRicerca(condizioni:condizioni, lista: Dati.richiestraWeb(query: "https://www.thesportsdb.com/api/v1/json/1/eventsday.php?d=" + data + "&s=Motorsport"))
            for item in appoggio{
                elementi.append(item)
            }
            DispatchQueue.main.async {
                self.contenitore.reloadData()
            }
        }
        Dati.viewAttesa.fermaRotazione()
    }
}

extension Eventi : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elementi.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cella = collectionView.dequeueReusableCell(withReuseIdentifier: "Partita", for: indexPath) as! League
        return cella
    }
    
}
