//
//  MainViewController.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2021/12/06.
//

import UIKit

class MainViewController: UIViewController {

    var seoulUsecase: SeoulUsecase?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task {
            do {
                if let data = try await seoulUsecase?.getCultureInfo() {
                    print("getCultureInfo() result[\(data)]")
                } else {
                    throw SeoulError.requestFailure(message: "repository is NULL")
                }
            } catch {
                print("Unexpected error: \(error).")
            }
        }
    }

}

