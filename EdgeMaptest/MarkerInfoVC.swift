//
//  MarkerInfoVC.swift
//  EdgeMaptest
//
//  Created by eun-ji on 2023/01/30.
//

import Foundation
import UIKit
import NMapsMap
import CoreLocation

class MarkerInfoVC: UIViewController {
    var getMarkerData: String? = "hello"

    @IBOutlet weak var MarkerTitle: UILabel!
    @IBOutlet weak var FocusView: UIView!
    @IBOutlet weak var MarkerAddress: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(getMarkerData)
        
        let mapView = NMFMapView(frame: FocusView.frame)
        view.addSubview(mapView)
        
        self.MarkerTitle.text = getMarkerData
        
    }
    
}
