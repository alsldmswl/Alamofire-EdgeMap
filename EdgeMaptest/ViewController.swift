//
//  ViewController.swift
//  EdgeMaptest
//
//  Created by eun-ji on 2023/01/19.
//

import UIKit
import NMapsMap
import DLRadioButton

class ViewController: UIViewController {
    
    
    @IBOutlet weak var MyLoc: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let mapView = NMFMapView(frame: MyLoc.frame)
        view.addSubview(mapView)
        
        mapView.positionMode = .compass
        
        
    }
    
    
}

