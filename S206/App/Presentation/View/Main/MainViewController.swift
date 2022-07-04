//
//  MainViewController.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2021/12/06.
//

import UIKit
import Moya

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let provider = MoyaProvider<SeoulDataApi>()
        provider.request(.cultureEventInfo) { (response) in
            switch response {
                case .success(let _response):
                    print("Moya() data [\(String(describing: _response.data))]")
                case .failure(let error):
                    print("Moya() Error [\(error.localizedDescription)]")
            }
        }
    }

}

