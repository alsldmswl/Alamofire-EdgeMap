//
//  SearchVC.swift
//  Pods
//
//  Created by eun-ji on 2023/01/19.
//

import UIKit
import DLRadioButton
import Alamofire


import Foundation

// MARK: - Welcome
struct Response: Codable {
    let response: ResponseDto
}

// MARK: - Response
struct ResponseDto: Codable {
    let header: Header
    let body: Body
}

// MARK: - Body
struct Body: Codable {
    let items: Items
    let numOfRows, pageNo, totalCount: Int
}

// MARK: - Items
struct Items: Codable {
    let item: [Item]
}

// MARK: - Item
struct Item: Codable {
    let routeIdx, crsIdx, crsKorNm, crsDstnc: String
    let crsTotlRqrmHour, crsLevel, crsCycle, crsContents: String
    let crsSummary, crsTourInfo, travelerinfo, sigun: String
    let brdDiv: String
    let gpxpath: String
    let createdtime, modifiedtime: String
}

// MARK: - Header
struct Header: Codable {
    let resultCode, resultMsg: String
}


class SearchVC: UIViewController {
    
    var radioButton1 = DLRadioButton()
    var radioButton2 = DLRadioButton()
    var radioButton3 = DLRadioButton()
    private var getWord: String = "맛집"
   
    @IBOutlet weak var searchBar: UISearchBar!

    var cellImage: [String] = ["01.jpg", "02.jpg", "03.jpg", "04.jpg"]

    
    let BASE_URL = "https://apis.data.go.kr/B551011/Durunubi/courseList"
    
    let query : [String : String] = [
        "MobileOS" : "IOS",
        "MobileApp" : "EdgeMap",
        "serviceKey" : "qcjQXVRmqbxl/++PgL+DmjuHYAoLUDxFVyZcI70vaGOrYXYAWdBmNIEXwuNH7impD0bkwGKhWiX4IRTQB1aPXQ==",
        "numOfRows" : "270",
        "pageNo" : "1",
        "_type": "json"
    ]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initRadioButton()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.searchBar.delegate = self
        self.searchBar.placeholder = "목적지를 입력하세요"
        self.searchBar.searchBarStyle = .minimal

    }
    
    private func initRadioButton() {
        radioButton1.setTitle("맛집", for: .normal)
        radioButton2.setTitle("관광지", for: .normal)
        radioButton3.setTitle("숙박", for: .normal)
        
        radioButton1.frame = CGRect(x: 40, y: 100, width: 100, height: 50)
        radioButton2.frame = CGRect(x: 140, y: 100, width: 100, height: 50)
        radioButton3.frame = CGRect(x: 240, y: 100, width: 100, height: 50)
        
        radioButton1.setTitleColor( .systemBlue , for: .normal)
        radioButton2.setTitleColor( .systemBlue , for: .normal)
        radioButton3.setTitleColor( .systemBlue , for: .normal)
        
        radioButton1.otherButtons.append(radioButton2)
        radioButton1.otherButtons.append(radioButton3)
        
        radioButton1.isSelected = true
        
        radioButton1.addTarget(self, action: #selector(btnTouch(_:)), for: .touchUpInside)
        radioButton2.addTarget(self, action: #selector(btnTouch(_:)), for: .touchUpInside)
        radioButton3.addTarget(self, action: #selector(btnTouch(_:)), for: .touchUpInside)
        
        self.view.addSubview(radioButton1)
        self.view.addSubview(radioButton2)
        self.view.addSubview(radioButton3)
    }
    
    @objc func btnTouch(_ sender:DLRadioButton) {
        getWord = sender.currentTitle!
    }

}

extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionCellView
        
        cell.imgView.image = UIImage(named: cellImage[indexPath.row]) ?? UIImage()
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 0.3
        cell.layer.borderColor = UIColor.gray.cgColor
        
        Alamofire.request(BASE_URL,
                          method: .get,
                          parameters: query,
                          encoding: URLEncoding.default)
        .validate(statusCode: 200..<300)
        .responseJSON { response in
            switch response.result {
            case .success(let res):
                do {
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(Response.self, from: jsonData)
                    
                    // 랜덤 추천 산책로
                    cell.label.text = json.response.body.items.item[Int.random(in: 1...269)].crsKorNm
                    cell.tvContents.text = json.response.body.items.item[Int.random(in: 1...269)].crsContents
                } catch(let error) {
                    print("error: ", error)
                }
            case .failure(let res):
                print(res)
            }
        }
        
        return cell

    }
}

extension SearchVC: UISearchBarDelegate {
    
    private func dissmissKeyboard() {
           searchBar.resignFirstResponder()
       }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let userInputString = searchBar.text, userInputString.isEmpty == false else {return}
        
        
        let pushVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchResultVC") as? SearchResultVC // 캐스팅
        pushVC?.getSearchData = userInputString
        pushVC?.getSelectedData = getWord
        
        self.navigationController?.pushViewController(pushVC!, animated: true)
        dissmissKeyboard()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

class CustomCollectionCellView: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tvContents: UILabel!
   
}
