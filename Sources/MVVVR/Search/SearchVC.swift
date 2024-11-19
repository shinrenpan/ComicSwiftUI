//
//  SearchVC.swift
//
//  Created by Joe Pan on 2024/11/5.
//

import SwiftUI
import UIKit

extension Search {
    final class VC: UIViewController {
        private let vo = VO()
        private let vm = VM()
        private let router = Router()
        private lazy var dataSource = makeDataSource()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupSelf()
            setupBinding()
            setupVO()
        }
        
        // MARK: - Setup Something

        private func setupSelf() {
            view.backgroundColor = vo.mainView.backgroundColor
            navigationItem.title = "線上搜尋"
            
            let searchVC = UISearchController()
            searchVC.searchResultsUpdater = self
            searchVC.searchBar.placeholder = "線上搜尋漫畫名稱"
            searchVC.searchBar.searchTextField.delegate = self
            navigationItem.searchController = searchVC
            navigationItem.preferredSearchBarPlacement = .stacked
            navigationItem.hidesSearchBarWhenScrolling = false

            router.vc = self
        }

        private func setupBinding() {
            _ = withObservationTracking {
                vm.state
            } onChange: { [weak self] in
                guard let self else { return }
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if viewIfLoaded?.window == nil { return }
                    
                    switch vm.state {
                    case .none:
                        stateNone()
                    case let .dataLoaded(response):
                        stateDataLoaded(response: response)
                    case let .nextPageLoaded(response):
                        stateNextPageLoaded(response: response)
                    case let .favoriteChanged(response):
                        stateFavoriteChanged(response: response)
                    }
                    
                    setupBinding()
                }
            }
        }

        private func setupVO() {
            view.addSubview(vo.mainView)

            NSLayoutConstraint.activate([
                vo.mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                vo.mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                vo.mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                vo.mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])

            vo.list.setCollectionViewLayout(makeListLayout(), animated: false)
            vo.list.delegate = self
        }
        
        // MARK: - Handle State

        private func stateNone() {}

        private func stateDataLoaded(response: DataLoadedResponse) {
            hideLoading()
            
            let comics = response.comics
            var snapshot = Snapshot()
            snapshot.appendSections([0])
            snapshot.appendItems(comics, toSection: 0)
            
            dataSource.apply(snapshot) { [weak self] in
                guard let self else { return }
                if dataSource.snapshot().itemIdentifiers.isEmpty {
                    showEmptyContent(isEmpty: true)
                }
                else {
                    contentUnavailableConfiguration = nil
                }
            }
        }

        private func stateNextPageLoaded(response: NextPageLoadedResponse) {
            hideLoading()
            
            let comics = response.comics
            var snapshot = dataSource.snapshot()
            snapshot.appendItems(comics, toSection: 0)
            dataSource.apply(snapshot)
        }
        
        private func stateFavoriteChanged(response: FavoriteChangedResponse) {
            var snapshot = dataSource.snapshot()
            
            guard let old = snapshot.itemIdentifiers.first(where: { response.comic.id == $0.id }) else {
                return
            }
            
            snapshot.insertItems([response.comic], beforeItem: old)
            snapshot.deleteItems([old])
            dataSource.apply(snapshot)
        }
        
        // MARK: - Make Something

        private func makeListLayout() -> UICollectionViewCompositionalLayout {
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.separatorConfiguration.bottomSeparatorInsets = .init(top: 0, leading: 86, bottom: 0, trailing: 0)
            config.leadingSwipeActionsConfigurationProvider = makeSwipeProvider()
            config.trailingSwipeActionsConfigurationProvider = makeSwipeProvider()

            return UICollectionViewCompositionalLayout.list(using: config)
        }

        private func makeSwipeProvider() -> UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider {
            { [weak self] indexPath in
                guard let self else { return nil }

                return makeSwipeAction(indexPath: indexPath)
            }
        }
        
        private func makeSwipeAction(indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            guard let comic = dataSource.itemIdentifier(for: indexPath) else {
                return nil
            }

            switch comic.favorited {
            case true:
                return .init(actions: [makeRemoveFavoriteAction(comic: comic)])
            case false:
                return .init(actions: [makeAddFavoriteAction(comic: comic)])
            }
        }
        
        private func makeAddFavoriteAction(comic: DisplayComic) -> UIContextualAction {
            .init(style: .normal, title: "加入收藏") { [weak self] _, _, _ in
                guard let self else { return }
                vm.doAction(.changeFavorite(request: .init(comic: comic)))
            }.setup(\.backgroundColor, value: .blue)
        }
        
        private func makeRemoveFavoriteAction(comic: DisplayComic) -> UIContextualAction {
            .init(style: .normal, title: "取消收藏") { [weak self] _, _, _ in
                guard let self else { return }
                vm.doAction(.changeFavorite(request: .init(comic: comic)))
            }.setup(\.backgroundColor, value: .orange)
        }
        
        private func makeCell() -> CellRegistration {
            .init { cell, _, comic in
                cell.contentConfiguration = UIHostingConfiguration {
                    Cell(comic: comic)
                }
            }
        }

        private func makeDataSource() -> DataSource {
            let cell = makeCell()

            return .init(collectionView: vo.list) { collectionView, indexPath, comic in
                collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: comic)
            }
        }

        // MARK: - Do Something

        private func doSearch(nextPage: Bool) {
            guard let keywords = getSearchKeywords() else {
                return
            }
            
            showLoading()
            
            if nextPage {
                vm.doAction(.loadNextPage(request: .init(keywords: keywords.gb)))
            }
            else {
                vm.doAction(.loadData(request: .init(keywords: keywords.gb)))
            }
        }

        // MARK: - Get Something
        
        private func getSearchKeywords() -> String? {
            guard let result = navigationItem.searchController?.searchBar.text?.gb else {
                return nil
            }
            
            return result.isEmpty ? nil : result
        }
    }
}

// MARK: - UICollectionViewDelegate

extension Search.VC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        router.toDetail(comicId: comic.id)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let count = dataSource.snapshot().numberOfItems
        
        if indexPath.item == count - 1, vm.hasNextPage {
            doSearch(nextPage: true)
        }
    }
}

// MARK: - UISearchResultsUpdating

extension Search.VC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if !(searchController.isActive) {
            let snapshot = Search.Snapshot()
            dataSource.apply(snapshot)
            contentUnavailableConfiguration = nil
        }
    }
}

// MARK: - UITextFieldDelegate

extension Search.VC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doSearch(nextPage: false)
        return true
    }
}
