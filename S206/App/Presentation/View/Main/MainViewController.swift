//
//  MainViewController.swift
//  S206
//

import UIKit
import Combine
import AuthenticationServices

final class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var viewModel: MainViewModel?
    private var cancellables: Set<AnyCancellable> = []

    /// 표시 컨텍스트(UIWindow)가 필요한 시점에 `GoogleSignInManager` 를 생성하는 팩토리.
    private var signInManagerFactory: ((@escaping () -> ASPresentationAnchor) -> GoogleSignInManaging)?
    private var signInManager: GoogleSignInManaging?
    private var didStartGoogleSignIn = false

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myLabel: UILabel!

    // MARK: - DI

    func configure(
        viewModel: MainViewModel,
        signInManagerFactory: @escaping (@escaping () -> ASPresentationAnchor) -> GoogleSignInManaging
    ) {
        assert(self.viewModel == nil, "configure 는 한 번만 호출되어야 합니다.")
        self.viewModel = viewModel
        self.signInManagerFactory = signInManagerFactory
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
        startGoogleSignInIfNeeded()
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

        viewModel.$googleAuthState
            .receive(on: DispatchQueue.main)
            .sink { state in
                // mos MainActivity.observeGoogleAuthState 대응 (Toast → 로그).
                switch state {
                case .authenticated:
                    print("[Google] 로그인 성공")
                case .error(let message):
                    print("[Google] 로그인 실패: \(message)")
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Google sign-in (mos MainActivity.startGoogleSignIn 대응)

    private func startGoogleSignInIfNeeded() {
        guard !didStartGoogleSignIn,
              let viewModel,
              let factory = signInManagerFactory else { return }
        didStartGoogleSignIn = true

        let manager = factory { [weak self] in
            self?.view.window ?? ASPresentationAnchor()
        }
        signInManager = manager

        viewModel.onGoogleSignInStarted()
        Task { @MainActor in
            do {
                let token = try await manager.signIn()
                viewModel.onGoogleSignInSuccess(token: token)
            } catch {
                viewModel.onGoogleSignInError(message: error.localizedDescription)
            }
        }
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
