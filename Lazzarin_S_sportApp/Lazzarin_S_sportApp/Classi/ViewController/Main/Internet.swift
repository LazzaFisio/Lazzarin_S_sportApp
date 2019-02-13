//
//  Internet.swift
//  Lazzarin_S_sportApp
//
//  Created by Leonardo Lazzarin on 13/02/2019.
//  Copyright © 2019 Leonardo Lazzarin. All rights reserved.
//

import UIKit
import WebKit

class Internet: UIViewController {

    @IBOutlet weak var visualizza: WKWebView!
    
    static var richiesta = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualizza.load(URLRequest(url: URL(string: Internet.richiesta)!))
    }
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
