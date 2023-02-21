//
//  MyLocationVC.swift
//  EdgeMaptest
//
//  Created by eun-ji on 2023/01/19.
//

import NMapsMap

class MyLocationVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)
    }
}
