//
//  MainViewController.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2021/12/06.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var seoulUsecase: SeoulUsecase?
    var myData: [NewCultureEvent]?
    let myData2 = ["a", "b", "c"]

    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var myLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        myLabel.text = "gdsg"
        myTableView.delegate = self
        myTableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        myTableView.reloadData()

//        Task {
//            do {
//                if let data = try await seoulUsecase?.getCultureInfo() {
//                    print("getCultureInfo() result[\(data)]")
//                    myData = data.list
//                    DispatchQueue.main.async {
//                        self.myTableView?.reloadData()
//                    }
//                } else {
//                    throw SeoulError.requestFailure(message: "repository is NULL")
//                }
//            } catch {
//                print("Unexpected error: \(error).")
//            }
//        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return myData?.count ?? 0
        return myData2.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.myTableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
//        if let title = myData?[indexPath.row].title {
//            cell.textLabel?.text = title
//        }
//        print("title = \(String(describing: cell.textLabel?.text))")
        cell.textLabel?.text = myData2[indexPath.row]
        return cell
    }

}

