//
//  GitHubSearchMainViewController.swift
//  GithubSearch
//
//  Created by hongjunkim on 2022/10/15.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol GitHubSearchMainDisplayLogic: AnyObject {
    func displayRecentKeyWord(viewModel: GitHubSearchMain.ShowRecentKeyWord.ViewModel)
}

class GitHubSearchMainViewController: UITableViewController, GitHubSearchMainDisplayLogic {
    var interactor: GitHubSearchMainBusinessLogic?
    var dataSource: GitHubSearchMainDataSource?
    var router: (NSObjectProtocol & GitHubSearchMainRoutingLogic & GitHubSearchMainDataPassing)?
    let searchController = UISearchController(searchResultsController: nil)
    
    
    // MARK: Object lifecycle
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = GitHubSearchMainInteractor()
        let presenter = GitHubSearchMainPresenter()
        let router = GitHubSearchMainRouter()
        
        viewController.interactor = interactor
        viewController.router = router
        
        dataSource = presenter
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        router.viewController = viewController
        
        router.dataStore = interactor
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
    }
    
    private func setupNavigation() {
        title = "GitHub"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Repositories"
        searchController.searchBar.delegate = self
        searchController.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        tableView.register(RecentHeaderView.self, forHeaderFooterViewReuseIdentifier: "RecentHeaderView")
        tableView.register(KeywordTableCell.self, forCellReuseIdentifier: "KeywordTableCell")
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    
    func displayRecentKeyWord(viewModel: GitHubSearchMain.ShowRecentKeyWord.ViewModel) {
        tableView.reloadData()
    }
}

extension GitHubSearchMainViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let recentHeaerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "RecentHeaderView") as? RecentHeaderView
        
        recentHeaerView?.didTapClearAll = { [weak self] in
            self?.interactor?.removeAllKeyWord(request: .init())
        }
        
        return recentHeaerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController.isActive {
            return 50
        }

        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchController.isActive ? dataSource?.keywords.count ?? 0 : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeywordTableCell", for: indexPath) as! KeywordTableCell
        
        if let keyword = dataSource?.keywords[safe: indexPath.row] {
            cell.confige(keyword: keyword)
            cell.didTapClear = { [weak self] in
                self?.interactor?.removeKeyWord(request: .init(keyword: keyword))
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        router?.routeToGitHubRepositories(keyword: "test")
    }
}

extension GitHubSearchMainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print(#function, #line, searchController.searchBar.text ?? "")
        
        interactor?.showRecentKeyWord(request: .init(show: searchController.isActive))
    }
}

extension GitHubSearchMainViewController: UISearchControllerDelegate {
    
}

extension GitHubSearchMainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(#function, #line, searchController.isActive, searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print(#function, #line, searchController.isActive, searchBar.text ?? "")
    }
}

extension GitHubSearchMainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(#function, #line, searchController.isActive)
        return true
    }
}
