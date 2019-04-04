//
//  ViewAttesa.swift
//  Lazzarin_S_sportApp
//
//  Created by Leonardo Lazzarin on 25/01/2019.
//  Copyright © 2019 Leonardo Lazzarin. All rights reserved.
//

import Foundation
import UIKit

class ViewAttesa{
    
    let tabBar : UITabBar!
    let view : UIView!
    var immagine : UIImageView!
    var label : UILabel!
    var bottone : UIButton!
    var ruota = false
    
    init(view : UIView, valore : String, colore : UIColor, tabBar : UITabBar) {
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        self.view.backgroundColor = colore
        immagine = UIImageView(frame: CGRect(x: (view.frame.width / 2) - 30, y: (view.frame.height / 2) - 30, width: 60, height: 60))
        immagine.image = UIImage(named: "loader.png")
        label = UILabel(frame: CGRect(x: immagine.frame.origin.x, y: immagine.frame.origin.y + 80, width: view.frame.width, height: 21))
        label.text = valore
        label.textColor = UIColor.white
        bottone = UIButton(frame: CGRect(x: (view.frame.width / 2) - 50, y: view.frame.height - 100, width: 100, height: 30))
        bottone.setTitle("ANNULLA", for: .normal)
        bottone.setTitleColor(UIColor.blue, for: .normal)
        self.view.addSubview(immagine)
        self.view.addSubview(label)
        self.view.isHidden = true
        self.tabBar = tabBar
        view.addSubview(self.view)
    }
    
    public func aggiungiAllaView(view : UIView){
        DispatchQueue.main.async {
            view.addSubview(self.view)
        }
    }
    
    public func aggiungiBottone(){
        view.addSubview(bottone)
    }
    
    public func rimuoviBottone(){
        bottone.removeFromSuperview()
    }
    
    public func avviaRotazione(){
        ruota = true
        view.isHidden = false
        for item in tabBar.items!{
            item.isEnabled = false
        }
        eseguiRotazione()
    }
    
    public func fermaRotazione(){
        ruota = false
        view.isHidden = true
        for item in tabBar.items!{
            item.isEnabled = true
        }
    }
    
    private func eseguiRotazione(){
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear, animations: {
            self.immagine.transform = self.immagine.transform.rotated(by: CGFloat(Double.pi))
        }) { (success) in
            if !self.view.isHidden{
                self.eseguiRotazione()
            }
        }
    }
    
}
