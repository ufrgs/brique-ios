//
//  MuralController.swift
//  ufrgs-mural
//
//  Created by Augusto on 26/12/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import UIKit
import Hero

class MuralController: UIViewController {
    
    // MARK: - Properties
    
    var items = [Item]()
    var repository = ItemRepository()
    
    var selectedIndex = 0
    
    var nextPageToFetch = 1
    var lastPageToFetch = 1
    var totalItemsCount = 0
    var isFetching = false
    var hasWarnedAboutNoInternet = false

    lazy var refreshControl = UIRefreshControl()
    var noItemLabel: UILabel?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hero config
        self.hero.isEnabled = true
        self.navigationController?.hero.isEnabled = true
        self.tabBarController?.hero.isEnabled = true
        
        self.navigationController?.navigationBar.hero.id = HeroId.loginView
        self.showWaitOverlay()
        
        fetchItemsFromScratch()
        
        configureRefreshControl()
        configureTableView()
        configureNavBar()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleReceivedNotification),
            name: CustomNotification.muralMustRefresh,
            object: nil
        )

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationItem.titleView?.isHidden = true
//        self.navigationItem.titleView?.hero.modifiers = [.fade, .scale(y: 0.3), .delay(2.0)]
        configureNavBar()
        
        UIView.animate(withDuration: 0.5) {
            self.navigationItem.title = "Mural de bens"
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.tintColor = .white
        }
    }
    
    // MARK: - Segue methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "muralToViewItem" {
            let nav = segue.destination as! UINavigationController
            let vc = nav.viewControllers.first as! ViewItemController
            
            vc.item = items[selectedIndex]
            vc.delegate = self
            vc.heroId = HeroId.muralCard + String(selectedIndex)

        }
        else if segue.identifier == "muralToSearchItem" {
            
        }
    }
    
    // MARK: - Actions
    
    @IBAction func searchAction(_ sender: Any) {
        self.performSegue(withIdentifier: "muralToSearchItem", sender: self)
    }
    
    // MARK: - Configuration
    
    private func configureNavBar() {
        let back = UIBarButtonItem(title: "Mural", style: .done, target: nil, action: nil)
        
        self.navigationItem.backBarButtonItem = back
        self.navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
    }
    
    // MARK: - UI Methods
    
    private func showNoItemLabel(text: String) {
        noItemLabel?.removeFromSuperview()
        
        let frame = CGRect(origin: .zero, size: tableView.frame.size)
        
        noItemLabel = UILabel(frame: frame)
        noItemLabel?.text = text
        noItemLabel?.numberOfLines = 0
        
        if let font = UIFont(name: "AvenirNext-Medium", size: 17) {
            noItemLabel?.font = font
        }
        
        noItemLabel?.textColor = UIColor.darkGray
        noItemLabel?.lineBreakMode = .byWordWrapping
        noItemLabel?.textAlignment = .center
        
        tableView.addSubview(noItemLabel!)
    }
    
    private func stopAllLoadings() {
        self.removeAllOverlays()
        self.refreshControl.endRefreshing()
        self.hideFooterSpinner()
    }
    
}

// MARK: - Table View Data Source

extension MuralController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "resultsInfoCell") as! ResultsInfoCell
            
            if !isFetching {
                cell.label.text = "\(totalItemsCount) ofertas disponíveis".uppercased()
            } else {
                cell.label.text = ""
            }
            
            return cell
        }
        
        else if indexPath.row <= items.count {
            let item = items[indexPath.row - 1]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: MuralItemCell.identifier) as! MuralItemCell
            
            cell.configure(name: item.name, image: item.image, hasFetchedImage: item.didFetchImage)
            cell.tag = indexPath.row - 1
            cell.cardView.hero.id = HeroId.muralCard + String(cell.tag)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    private func configureTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 16, right: 0)
        
        self.tableView.addSubview(self.refreshControl)
        
        self.tableView.tableHeaderView = Helper.create1pxHeader(width: tableView.bounds.width)
        self.tableView.tableHeaderView?.isHidden = false
        
        registerNibs()
    }
    
    private func registerNibs() {
        let nib = UINib.init(nibName: MuralItemCell.identifier, bundle: nil)

        tableView.register(nib, forCellReuseIdentifier: MuralItemCell.identifier)
    }
    
}

// MARK: - Table View Delegate

extension MuralController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row - 1
        
        if selectedIndex < items.count {
            self.performSegue(withIdentifier: "muralToViewItem", sender: self)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let lastVisibleCell = tableView.visibleCells.last {
            if let lastVisibleRow = tableView.indexPath(for: lastVisibleCell)?.row {
                
                let lastRow = tableView.numberOfRows(inSection: 0) - 1

                if lastVisibleRow == lastRow {
                    fetchMoreItemsIfNeeded()
                }
            }
        }
    }
}

// MARK: - Edit Item delegate

extension MuralController: EditItemProtocol {
    
    func didEdit(item: Item) {
        tableView.reloadData()
        
        NotificationCenter.default.post(name: CustomNotification.myItemsMustRefresh, object: nil)
    }
    
    func didDelete(item: Item) {
        
        if item.number == items[selectedIndex].number {
            items.remove(at: selectedIndex)

            let indexPath = IndexPath(row: selectedIndex, section: 0)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            NotificationCenter.default.post(name: CustomNotification.myItemsMustRefresh, object: nil)
        }
        
    }
    
}

// MARK: - Fetch methods

extension MuralController {
    
    func fetchItemsFromScratch() {
        
        if !Helper.internetIsConnected() {
            self.stopAllLoadings()
            
            let alert = Helper.createNoInternetAlert()
            self.present(alert, animated: true, completion: {
                self.showNoItemLabel(text: "Falha na conexão à internet")
            })
            
            return
        }
        
        self.nextPageToFetch = 1
        self.lastPageToFetch = 1
        self.totalItemsCount = 0
        
        self.items.removeAll()
        
        self.fetchMoreItems()
    }
    
    func fetchMoreItems() {
        
        if !Helper.internetIsConnected() {
            if !hasWarnedAboutNoInternet {
                let alert = Helper.createSimpleAlert(title: "Erro de conexão", message: "Não possível carregar mais itens pois o dispositivo parece estar desconectado da internet.")
                
                self.present(alert, animated: true, completion: nil)
                self.hasWarnedAboutNoInternet = true
                self.stopAllLoadings()
                
                return
            }
        }
        
        self.isFetching = true
        
        repository.readPageWithImages(page: nextPageToFetch, pageCompletion: { (newItems, lastPage, totalCount) in
            
            self.stopAllLoadings()
            
            self.nextPageToFetch += 1
            self.lastPageToFetch = lastPage
            self.totalItemsCount = totalCount
            
            for item in newItems {
                self.items.append(item)
            }
            
            self.isFetching = false
            self.tableView.reloadData()
            
            // se nenhum item encontrado, mostra label avisando
            if self.items.count == 0 {
                self.showNoItemLabel(text: "Nenhuma oferta disponível")
            } else {
                self.noItemLabel?.removeFromSuperview()
            }
            
        }) {
            // will be executed when the image is loaded
            self.tableView.reloadData()
        }
        
    }
    
    func fetchMoreItemsIfNeeded() {
        
        if !isFetching {
            
            if nextPageToFetch <= lastPageToFetch {
                self.showFooterSpinner()
                self.fetchMoreItems()
                
            }
        }
    }
    
    @objc func handleReceivedNotification() {
        if !isFetching {
            self.showWaitOverlay()
            fetchItemsFromScratch()
        }
    }
    
}

// MARK: - Refresh methods

extension MuralController {
    
    func configureRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        if !isFetching {
            if Helper.internetIsConnected() {
                fetchItemsFromScratch()
            } else {
                refreshControl.endRefreshing()
                self.showNoItemLabel(text: "Falha na conexão à internet")
                self.items.removeAll()
                self.tableView.reloadData()
            }
        } else {
            refreshControl.endRefreshing()
        }
    }
    
}

// MARK: - Table View Footer and Header

extension MuralController {
    
    func showFooterSpinner() {
        self.tableView.tableFooterView = Helper.createSpinner(width: tableView.bounds.width)
        self.tableView.tableFooterView?.isHidden = false
    }
    
    func hideFooterSpinner() {
        self.tableView.tableFooterView = UIView()
        self.tableView.tableFooterView?.isHidden = true
    }
    
}
