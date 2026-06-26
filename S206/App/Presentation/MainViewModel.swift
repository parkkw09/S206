//
//  MainViewModel.swift
//  S206
//
//  mos 의 MainViewModel 과 동일한 구조:
//  - PAGE_SIZE=50, 무한스크롤 페이지네이션
//  - LoadState 로 UI 상태 일원화
//  - Combine @Published 로 StateFlow 와 동일한 단방향 데이터 흐름
//

import Foundation
import Combine

final class MainViewModel: ObservableObject {
    private static let pageSize = 50

    @Published private(set) var events: [CulturalEvent] = []
    @Published private(set) var loadState: LoadState = .idle

    private let usecase: SeoulUsecase
    private var totalCount = 0
    private var nextStart = 1
    private var isLoading = false

    init(usecase: SeoulUsecase) {
        self.usecase = usecase
    }

    func initialize() {
        guard events.isEmpty && !isLoading else { return }
        loadNextPage()
    }

    func loadNextPage() {
        guard !isLoading && (totalCount == 0 || nextStart <= totalCount) else { return }

        isLoading = true
        loadState = nextStart == 1 ? .loading : .loadingMore

        Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await usecase(startIndex: nextStart, endIndex: nextStart + Self.pageSize - 1)
                await MainActor.run {
                    self.totalCount = page.totalCount
                    self.events.append(contentsOf: page.events)
                    self.nextStart += Self.pageSize
                    self.loadState = .success
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.loadState = .error(error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }

    func refresh() {
        events = []
        totalCount = 0
        nextStart = 1
        isLoading = false
        loadNextPage()
    }
}
