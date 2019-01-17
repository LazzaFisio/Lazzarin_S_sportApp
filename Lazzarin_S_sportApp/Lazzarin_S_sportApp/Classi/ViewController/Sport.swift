//
//  Sport.swift
//  Lazzarin_S_sportApp
//
//  Created by Leonardo Lazzarin on 16/01/2019.
//  Copyright © 2019 Leonardo Lazzarin. All rights reserved.
//

import UIKit

class Sport: UIViewController {

    @IBOutlet weak var contenitore: UIScrollView!
    
    @IBOutlet weak var titolo: UILabel!
    
    @IBOutlet weak var back: UIButton!
    
    var dimensioni : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dimensioni = view.frame.height
        creaSport()
        // Do any additional setup after loading the view.
    }
    
    func creaSport(){
        contenitore.contentSize = CGSize(width: view.frame.width, height: view.frame.height - 104)
        var dimensioni = arrayDimensioni(view: CGRect(x: 30, y: Int(contenitore.frame.height / 2) - 84, width: 148, height: 168))
        var immagini : [UIImage] = [UIImage(named: "cerchio.png")!, UIImage(named: "rugby.png")!]
        Info.creaView(viewPrincipale: contenitore, dimensioni: dimensioni, immagini: immagini, testo: "Rugby", stella: [false], tag: 0)
        dimensioni[0] = CGRect(x: Int(view.frame.width) - (30 + 148), y: Int(contenitore.frame.height / 2) - 84, width: 148, height: 168)
        immagini[1] = UIImage(named: "motorsport.png")!
        Info.creaView(viewPrincipale: contenitore, dimensioni: dimensioni, immagini: immagini, testo: "Motorsport", stella: [false], tag: 1)
        aggiungiAzione(azione: #selector(azioneSport(sender:)))
        titolo.text = "TUTTI GLI SPORT"
        back.isHidden = true
    }
    
    func creaLeghe(){
        var i = 0
        var height = 0
        while i < Info.json.count{
            var dimensioni = arrayDimensioni(view: CGRect(x: 30, y: height, width: 148, height: 168))
            dimensioni.append(CGRect(x: 92, y: 0, width: 48, height: 48))
            var immagini : [UIImage] = [UIImage(named: "cerchio.png")!]
            immagini.append(Info.immagine(url: Info.elementi(key: "strBadge")[i]))
            Info.creaView(viewPrincipale: contenitore, dimensioni: dimensioni, immagini: immagini, testo: Info.elementi(key: "strLeague")[i], stella: [true, false], tag: i)
            i += 1
            if i < Info.json.count - 1{
                dimensioni[0] = CGRect(x: Int(view.frame.width) - (30 + 148), y: height, width: 148, height: 168)
                immagini[1] = Info.immagine(url: Info.elementi(key: "strBadge")[i])
                Info.creaView(viewPrincipale: contenitore, dimensioni: dimensioni, immagini: immagini, testo: Info.elementi(key: "strLeague")[i], stella: [true, false], tag: i)
            }
            i += 1
            height += 200
        }
        aggiungiAzione(azione: #selector(azioneLeghe(sender:)))
        titolo.text = "TUTTE LE LEGHE"
        back.isHidden = false
    }
    
    func cancellaUIView(){
        for subviews in contenitore.subviews{
            if subviews.subviews.count > 0{
                subviews.removeFromSuperview()
            }
        }
    }
    
    func arrayDimensioni(view : CGRect) -> [CGRect]{
        var dimensioni : [CGRect] = []
        dimensioni.append(view)
        dimensioni.append(CGRect(x: 20, y: 20, width: 100, height: 100))
        dimensioni.append(CGRect(x: 12, y: 127, width: 116, height: 20))
        dimensioni.append(CGRect(x: 40, y: 40, width: 60, height: 60))
        return dimensioni
    }
    
    func aggiungiAzione(azione : Selector){
        for subviews in contenitore.subviews{
            if subviews.subviews.count > 0, let item = subviews.subviews[0] as? UIButton{
                item.addTarget(self, action: azione, for: .touchUpInside)
            }
        }
    }
    
    @IBAction func indietro(_ sender: Any) {
        if Info.ricerca == "leghe"{
            cancellaUIView()
            contenitore.contentSize = CGSize(width: view.frame.width, height: view.frame.height - 104)
            creaSport()
        }
    }
    
    @objc func azioneSport(sender : UIButton!){
        var sport = ""
        switch sender.tag {
        case 1: sport = "Motorsport"; break
        default: sport = "Rugby"; break
        }
        Info.caricaJson(query: "https://www.thesportsdb.com/api/v1/json/1/search_all_leagues.php?s=" + sport, ricerca: "leghe")
        cancellaUIView()
        contenitore.contentSize = CGSize(width: Int(view.frame.width), height: (200 * Info.json.count / 2) + 84)
        creaLeghe()
    }
    
    @objc func azioneLeghe(sender : UIButton!){
        
    }
}
