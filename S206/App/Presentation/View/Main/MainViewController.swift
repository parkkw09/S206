//
//  MainViewController.swift
//  S206
//

import UIKit
import Combine

final class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var viewModel: MainViewModel?
    private var cancellables: Set<AnyCancellable> = []

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myLabel: UILabel!

    // MARK: - DI

    func configure(viewModel: MainViewModel) {
        assert(self.viewModel == nil, "configure(viewModel:) 는 한 번만 호출되어야 합니다.")
        self.viewModel = viewModel
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        bindViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.initialize()
    }

    // MARK: - Binding

    private func bindViewModel() {
        guard let viewModel else { return }

        viewModel.$events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.myTableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$loadState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.applyLoadState(state)
            }
            .store(in: &cancellables)
    }

    private func applyLoadState(_ state: LoadState) {
        switch state {
        case .idle:
            break
        case .loading:
            myLabel.text = "Loading..."
        case .loadingMore:
            break
        case .success:
            myLabel.text = "문화 행사 \(viewModel?.events.count ?? 0)건"
        case .error(let message):
            myLabel.text = "Error: \(message)"
        }
    }

    // MARK: - UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.events.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        cell.textLabel?.text = viewModel?.events[indexPath.row].title
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel, viewModel.events.count > 10 else { return }
        if indexPath.row >= viewModel.events.count - 10 {
            viewModel.loadNextPage()
        }
    }
}
