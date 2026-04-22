//
//  MainViewController.swift
//  S206
//

import UIKit

final class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Storyboard 로 생성되므로 주입 시점은 `init` 이후(= SceneDelegate) 입니다.
    // 그래서 한 번만 설정되는 것을 의도하여 private(set) let 처럼 다루되, 프로퍼티 주입을 위해 옵셔널로 둡니다.
    private var usecase: SeoulUsecase?
    private var items: [NewCultureEvent] = []

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myLabel: UILabel!

    // MARK: - DI

    /// `AppContainer` 가 viewDidLoad 이전에 한 번 호출합니다.
    func configure(usecase: SeoulUsecase) {
        assert(self.usecase == nil, "configure(usecase:) 는 한 번만 호출되어야 합니다.")
        self.usecase = usecase
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        myLabel.text = "Loading..."
        myTableView.delegate = self
        myTableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchCultureInfo()
    }

    // MARK: - Data loading

    private func fetchCultureInfo() {
        guard let usecase = usecase else {
            assertionFailure("SeoulUsecase 가 주입되지 않았습니다. AppContainer 등록을 확인하세요.")
            return
        }

        Task { [weak self] in
            do {
                let response = try await usecase.getCultureInfo()
                await MainActor.run { [weak self] in
                    self?.items = response.list
                    self?.myLabel.text = "문화 행사 \(response.count)건"
                    self?.myTableView.reloadData()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.myLabel.text = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        return cell
    }
}
