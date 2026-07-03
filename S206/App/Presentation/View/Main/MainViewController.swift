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
        assert(self.viewModel == nil, "configure 는 한 번만 호출되어야 합니다.")
        self.viewModel = viewModel
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        setupRefreshControl()
        bindViewModel()
    }

    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        myTableView.refreshControl = refreshControl
    }

    @objc private func handlePullToRefresh() {
        viewModel?.refresh()
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
            // Pull-to-refresh 가 아닌 최초 로딩인 경우에만 레이블 표시
            if myTableView.refreshControl?.isRefreshing != true {
                myLabel.text = NSLocalizedString("loading", comment: "Loading state text")
            }
        case .loadingMore:
            break
        case .success:
            myTableView.refreshControl?.endRefreshing()
            let count = viewModel?.events.count ?? 0
            let format = NSLocalizedString("event_count_format", comment: "Format for event count")
            myLabel.text = String(format: format, count)
        case .error(let message):
            myTableView.refreshControl?.endRefreshing()
            let format = NSLocalizedString("error_format", comment: "Format for error message")
            myLabel.text = String(format: format, message)
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

