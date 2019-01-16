//
//  Sport.swift
//  Lazzarin_S_sportApp
//
//  Created by Leonardo Lazzarin on 16/01/2019.
//  Copyright © 2019 Leonardo Lazzarin. All rights reserved.
//

import UIKit

class Sport: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        creaSport()
        // Do any additional setup after loading the view.
    }
    
    func creaSport(){
        var dimensioni = arrayDimensioni(view: CGRect(x: 30, y: Int(view.frame.height / 2) - 84, width: 148, height: 168))
        var immagini : [UIImage] = [UIImage(named: "cerchio.png")!, UIImage(named: "rugby.png")!]
        Info.creaView(viewPrincipale: view, dimensioni: dimensioni, immagini: immagini, testo: "Rugby", stella: [false], tag: 0)
        dimensioni[0] = CGRect(x: Int(view.frame.width) - (30 + 148), y: Int(view.frame.height / 2) - 84, width: 148, height: 168)
        immagini[1] = UIImage(named: "motorsport.png")!
        Info.creaView(viewPrincipale: view, dimensioni: dimensioni, immagini: immagini, testo: "Motorsport", stella: [false], tag: 1)
        aggiungiAzione(azione: #selector(azioneSport(sender:)))
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
        for subviews in view.subviews{
            if subviews.subviews.count > 0, let item = subviews.subviews[0] as? UIButton{
                item.addTarget(self, action: #selector(azioneSport(sender:)), for: .touchUpInside)
            }
        }
    }
    
    @objc func azioneSport(sender : UIButton!){
        print("peneeeeeee")
    }
}
