//
//  SearchResultVC.swift
//  EdgeMaptest
//
//  Created by eun-ji on 2023/01/26.
//

import Foundation
import UIKit
import NMapsMap
import CoreLocation
import Alamofire

// MARK: - ResoponseDTO
struct DrivingDTO: Codable {
    let code: Int
    let message: String
    let currentDateTime: Date?
    let route: RouteDTO?
}

// MARK: - Route
struct RouteDTO: Codable {
    let trafast: [Trafast]
}

// MARK: - Trafast
struct Trafast: Codable {
    let summary: Summary
    let path: [[Double]]
    let section: [Section]
    let guide: [Guide]
}

// MARK: - Guide
struct Guide: Codable {
    let pointIndex, type: Int
    let instructions: String
    let distance, duration: Int
}

// MARK: - Section
struct Section: Codable {
    let pointIndex, pointCount, distance: Int
    let name: String
    let congestion, speed: Int
}

// MARK: - Summary
struct Summary: Codable {
    let start: Start
    let goal: Goal
    let distance, duration: Int
    let departureTime: String
    let bbox: [[Double]]
    let tollFare, taxiFare, fuelPrice: Int
}

// MARK: - Goal
struct Goal: Codable {
    let location: [Double]
    let dir: Int
}

// MARK: - Start
struct Start: Codable {
    let location: [Double]
}

// MARK: - Welcome
struct ResponseGeoCode: Codable {
    let status: String
    let meta: Meta
    let addresses: [Address]
    let errorMessage: String
}

// MARK: - Address
struct Address: Codable {
    let roadAddress, jibunAddress, englishAddress: String
    let addressElements: [AddressElement]
    let x, y: String
    let distance: Int
}

// MARK: - AddressElement
struct AddressElement: Codable {
    let types: [String]
    let longName, shortName, code: String
}

// MARK: - Meta
struct Meta: Codable {
    let totalCount, page, count: Int
}

// MARK: - Welcome
struct ReverseGeoCode: Codable {
    let status: Status
    let results: [Result]
}

// MARK: - Result
struct Result: Codable {
    let name: String
    let code: Code
    let region: Region
}

// MARK: - Code
struct Code: Codable {
    let id, type, mappingID: String
    
    enum CodingKeys: String, CodingKey {
        case id, type
        case mappingID = "mappingId"
    }
}

// MARK: - Region
struct Region: Codable {
    let area0: Area
    let area1: Area1
    let area2, area3, area4: Area
}

// MARK: - Area
struct Area: Codable {
    let name: String
    let coords: Coords
}

// MARK: - Coords
struct Coords: Codable {
    let center: Center
}

// MARK: - Center
struct Center: Codable {
    let crs: CRS
    let x, y: Double
}

enum CRS: String, Codable {
    case empty = ""
    case epsg4326 = "EPSG:4326"
}

// MARK: - Area1
struct Area1: Codable {
    let name: String
    let coords: Coords
    let alias: String
}

// MARK: - Status
struct Status: Codable {
    let code: Int
    let name, message: String
}


// MARK: - Welcome
struct SearchInfoDto: Codable {
    let lastBuildDate: String
    let total, start, display: Int
    let searchLists: [SearchList]
    
    enum CodingKeys : String, CodingKey {
        case lastBuildDate = "lastBuildDate"
        case total = "total", start = "start", display
        case searchLists = "items"
    }
}

// MARK: - Item
struct SearchList: Codable {
    let title: String
    let link: String
    let category, description, telephone, address: String
    let roadAddress, mapx, mapy: String
}



class SearchResultVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var SearchResultView: UIView!
    
    //LocationManager 선언
    var locationManager:CLLocationManager!
    
    //위도와 경도
    var latitude: Double? = 0.0
    var longitude: Double? = 0.0
    
    var getSearchData: String = ""
    var getSelectedData : String = ""
    var startX: String = ""
    var startY: String = ""
    var goalX: String = ""
    var goalY: String = ""
    
    var addressList: [String] = []
    
    var searchApiResultList: [SearchList] = []
    
    var markerList: [NMFMarker] = []
    var infoWindowList: [NMFInfoWindow] = []
    
    var infoWindow = NMFInfoWindow()
    
    let header: HTTPHeaders = [
        "X-NCP-APIGW-API-KEY-ID" : "qt7i1jc6oa",
        "X-NCP-APIGW-API-KEY" : "HhmGBmyCUekbtLOg2ZxrtZB7AkJJMZ2fgcKQDXw0"
    ]
    
    let GEO_CODE_BASE_URL = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode"
    let DIRECTION_5_BASE_URL = "https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving"
    let REVERSE_GEO_CODE_BASE_URL = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"
    let SEARCH_INFO_BASE_URL = "https://openapi.naver.com/v1/search/local.json"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchView = NMFMapView(frame: SearchResultView.frame)
        view.addSubview(searchView)
        
        searchView.positionMode = .compass
        getCurrentLocation(searchView: searchView)
        
        searchView.touchDelegate = self
    }
    
    private func getCurrentLocation(searchView: NMFMapView) {
        //locationManager 인스턴스 생성 및 델리게이트 생성
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //포그라운드 상태에서 위치 추적 권한 요청
        locationManager.requestWhenInUseAuthorization()
        
        //배터리에 맞게 권장되는 최적의 정확도
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //위치업데이트
        locationManager.startUpdatingLocation()
        
        //위도 경도 가져오기
        let coor = locationManager.location?.coordinate
        latitude = coor?.latitude
        longitude = coor?.longitude
        
        startX = String(format: "%f", latitude!)
        startY = String(format: "%f", longitude!)
        
        getGeoCode(searchView: searchView)
    }
    
    private func getGeoCode(searchView: NMFMapView) {
        let getGoalData = getSearchData
        
        let geoQuery : [String : String] = [
            "query" : getGoalData,
        ]
        
        Alamofire.request(GEO_CODE_BASE_URL,
                          method: .get,
                          parameters: geoQuery,
                          encoding: URLEncoding.default,
                          headers: header)
        .validate(statusCode: 200..<300)
        .responseJSON { response in
            switch response.result {
            case .success(let res):
                do {
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(ResponseGeoCode.self, from: jsonData)
                    
                    let startxy = self.startY + "," + self.startX
                    let goalxy = json.addresses[0].x + "," + json.addresses[0].y
                    
                    self.getDirection5(startXY: startxy, goalXY: goalxy, searchView: searchView)
                    
                } catch(let error) {
                    print("error: ", error)
                }
            case .failure(let res):
                print(res)
            }
        }
    }
    
    private func getDirection5(startXY: String, goalXY: String, searchView: NMFMapView) {
        let directionQuery : [String : String] = [
            "start" : startXY,
            "goal" : goalXY,
            "option" : "trafast"
        ]
        
        Alamofire.request(DIRECTION_5_BASE_URL,
                          method: .get,
                          parameters: directionQuery,
                          encoding: URLEncoding.default,
                          headers: header)
        .validate(statusCode: 200..<300)
        .responseJSON { response in
            switch response.result {
            case .success(let res):
                do {
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    //                    let response = try JSONDecoder().decode(DrivingDTO.self, from: jsonData)
                    
                    
                    let json = JSONDecoder()
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    
                    json.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    let response = try json.decode(DrivingDTO.self, from: jsonData)
                    
                    let path = response.route?.trafast[0].path ?? [[0.0]]
                    
                    self.drawPath(path: path, searchView: searchView)
                    
                } catch(let error) {
                    print("error: ", error)
                }
            case .failure(let res):
                print(res)
            }
        }
    }
    
    private func drawPath(path: [[Double]], searchView: NMFMapView) {
        let pathOveray = NMFPath()
        var coords: [NMGLatLng] = []
        
        for i in path {
            coords.append(NMGLatLng(lat: i[1], lng: i[0]))
        }
        
        pathOveray.path = NMGLineString(points: coords)
        pathOveray.mapView = searchView
        
        transAddress(coords: coords, searchView: searchView) {
            (ids) in self.getSearchInfo(infoSet: Set(ids), searchView: searchView) {
                (getResultListData) in self.drawMarker(apiResultList: getResultListData, searchView: searchView)
            }
        }
    }
    
    private func transAddress(coords: [NMGLatLng], searchView: NMFMapView, completion: @escaping ([String]) -> Void) {
        var cnt = 0
        
        for i in coords {
            Alamofire.request(self.REVERSE_GEO_CODE_BASE_URL,
                              method: .get,
                              parameters: [
                                "coords" : String(format: "%f,%f", i.lng, i.lat),
                                "output" : "json"
                              ],
                              encoding: URLEncoding.default,
                              headers: self.header)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                
                switch response.result {
                case .success(let res):
                    do {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                        let response = try JSONDecoder().decode(ReverseGeoCode.self, from: jsonData)
                        
                        let address = response.results[0].region.area1.name
                        + " " + response.results[0].region.area2.name
                        + " " + response.results[0].region.area3.name
                        
                        self.addressList.append(address)
                        
                        cnt += 1
                        if cnt == coords.count {
                            completion(self.addressList)
                        }
                    } catch(let error) {
                        print("error: ", error)
                    }
                case .failure(let res):
                    print(res)
                }
                
            }
        }
    }
    
    private func getSearchInfo(infoSet: Set<String>, searchView: NMFMapView, completion: @escaping ([SearchList]) -> Void) {
        print(infoSet)
        var cnt = 0
        
        let queue = DispatchQueue.init(label: "serialQueue")
        
        let searchInfoHeader : HTTPHeaders = [
            "X-Naver-Client-Id" : "QHTg5tFiAFlprwsl7llw",
            "X-Naver-Client-Secret" : "9dWkx1xl6u"
        ]
        
        for i in infoSet {
            queue.async {
                Alamofire.request(self.SEARCH_INFO_BASE_URL,
                                  method: .get,
                                  parameters: [
                                    "query" : i + " " + self.getSelectedData,
                                    "sort" : "comment",
                                    "display" : 5
                                  ],
                                  encoding: URLEncoding.default,
                                  headers: searchInfoHeader)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    switch response.result {
                    case .success(let res):
                        do {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                            let response = try JSONDecoder().decode(SearchInfoDto.self, from: jsonData)
                            
                            self.searchApiResultList.append(contentsOf: response.searchLists)
                            
                            cnt += 1
                            if(cnt == infoSet.count) {
                                completion(self.searchApiResultList)
                            }
                            
                        } catch {
                            print("error: ")
                        }
                    case .failure(let res):
                        print(res)
                    }
                }
            }
            Thread.sleep(forTimeInterval: 0.5)
        }
    }
    
    private func drawMarker(apiResultList: [SearchList], searchView: NMFMapView) {
        for i in apiResultList {
            var tm128 = NMGTm128(x: Double(i.mapx) ?? 0.0, y: Double(i.mapy) ?? 0.0)
            var latLng = tm128.toLatLng()
            
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: latLng.lat, lng: latLng.lng)
            marker.captionText = i.title
            markerList.append(marker)
        }
        onClickMarker(apiResultList: apiResultList, searchView: searchView)
        
    }
    
    private func onClickMarker(apiResultList: [SearchList], searchView: NMFMapView) {
        let dataSource = NMFInfoWindowDefaultTextSource.data()
        
        // 마커를 탭하면:
        let handler = { [weak self] (overlay: NMFOverlay) -> Bool in
            
            if let marker = overlay as? NMFMarker {
                dataSource.title = marker.captionText
                self?.infoWindow.dataSource = dataSource
                
                if marker.infoWindow == nil {
                    // 현재 마커에 정보 창이 열려있지 않을 경우 엶
                    self?.infoWindow.open(with: marker)
                    let pushMarkerInfoVC = self?.storyboard?.instantiateViewController(withIdentifier: "MarkerInfoVC") as? MarkerInfoVC
//                    pushMarkerInfoVC?.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
//                    self?.performSegue(withIdentifier: "markerInfoSegue", sender: self)
                    pushMarkerInfoVC?.getMarkerData = marker.captionText
                    self?.navigationController?.pushViewController(pushMarkerInfoVC!, animated: true)
                } else {
                    // 이미 현재 마커에 정보 창이 열려있을 경우 닫음
                    self?.infoWindow.close()
                }
            }
            return true
        }
        
        for i in markerList {
            i.mapView = searchView
            i.touchHandler = handler
        }
    }
    
}

extension SearchResultVC: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        self.infoWindow.close()
    }
}
