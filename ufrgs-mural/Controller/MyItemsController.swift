//
//  MyItemsController.swift
//  ufrgs-alerta
//
//  Created by Augusto on 18/09/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import UIKit
import SwiftOverlays

class MyItemsController: UIViewController {
    
    // MARK: - Properties
    
    var items = [Item]()
    let repository = ItemRepository()
    
    var selectedIndex = 0
    
    var nextPageToFetch = 1
    var lastPageToFetch = 1
    var isFetching = false
    
    lazy var refreshControl = UIRefreshControl()
    var noItemLabel: UILabel?
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - init methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = "Bens oferecidos"
  
        self.hero.isEnabled = true
        
        self.showWaitOverlay()
        fetchItemsFromScratch()
        
        configureRefreshControl()
        configureTableView()
        configureNavBar()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleReceivedNotification),
            name: CustomNotification.myItemsMustRefresh,
            object: nil
        )
    }
    
    // MARK: - Overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "muralToEditItem" {
            let vc = segue.destination as! EditItemController
            
            vc.item = self.items[selectedIndex]
            vc.delegate = self
        } else if segue.identifier == "muralToCreateItem" {
            let nav = segue.destination as! UINavigationController
            let vc = nav.viewControllers.first as! CreateItemBaseController
            
            vc.delegate = self
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noItemLabel?.frame = CGRect(origin: .zero, size: tableView.frame.size)
    }
 
    // MARK: - Actions
    
    @IBAction func addBemAction(_ sender: Any) {
        self.performSegue(withIdentifier: "muralToCreateItem", sender: Any?.self)
    }
    
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Deseja fazer logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (_) in
            User.current.delete()
            self.tabBarController?.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNoItemLabel(text: String) {
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

// MARK: - Table View data source

extension MyItemsController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < items.count {
            
            let item = items[indexPath.row]
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "bemCell", for: indexPath) as! MyItemCell
            
            cell.configure(title: item.name, number: item.number, description: item.description, image: item.image)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
}

// MARK: - Table View delegate

extension MyItemsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? MyItemCell else {
            return
        }
        
        cell.animateSelection()
        
        selectedIndex = indexPath.row
        
        performSegue(withIdentifier: "muralToEditItem", sender: self)
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

// MARK: - UI Configuration and Spinner handler

extension MyItemsController {
    
    private func configureTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 12, right: 0)
        
        self.tableView.addSubview(self.refreshControl)
        
        self.tableView.tableHeaderView = Helper.create1pxHeader(width: tableView.bounds.width)
        self.tableView.tableHeaderView?.isHidden = false
    }
    
    private func configureNavBar() {
        let back = UIBarButtonItem(title: "Bens", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = back
        
        self.navigationController?.hero.isEnabled = true
    }
    
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
            }
        } else {
            refreshControl.endRefreshing()
        }
    }
    
}

// MARK: - Create Item delegate

protocol DidCreateItemProtocol: class {
    func didCreate(item: Item)
}

extension MyItemsController: DidCreateItemProtocol {
    
    func didCreate(item: Item) {
        self.items.append(item)
        self.tableView.reloadData()
    }
    
}

// MARK: - Edit Item delegate

protocol EditItemProtocol: class {
    func didEdit(item: Item)
    func didDelete(item: Item)
}

extension MyItemsController: EditItemProtocol {
    
    func didEdit(item: Item) {
        tableView.reloadData()
        
        NotificationCenter.default.post(name: CustomNotification.muralMustRefresh, object: nil)
    }
    
    func didDelete(item: Item) {
        if item.number == items[selectedIndex].number {
            items.remove(at: selectedIndex)
            
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            NotificationCenter.default.post(name: CustomNotification.muralMustRefresh, object: nil)
        }
    }
    
}

// MARK: - Fetch methods

extension MyItemsController {
    
    func fetchItemsFromScratch() {
        
        if !Helper.internetIsConnected() {
            self.stopAllLoadings()
            self.showNoItemLabel(text: "Falha na conexão à internet")
            
            return
        }
        
        self.nextPageToFetch = 1
        self.lastPageToFetch = 1
        
        self.items.removeAll()
        
        self.fetchMoreItems()
    }
    
    func fetchMoreItems() {
        
        self.isFetching = true
        
        repository.readPageFromUserWithImage(page: nextPageToFetch, pageCompletion: { (items, lastPage) in
            self.removeAllOverlays()
            self.refreshControl.endRefreshing()
            self.hideFooterSpinner()
            
            self.nextPageToFetch += 1
            self.lastPageToFetch = lastPage
            
            for item in items {
                self.items.append(item)
            }
            
            self.isFetching = false
            self.tableView.reloadData()
            
            // se nenhum item encontrado, mostra label avisando
            if self.items.count == 0 {
                self.showNoItemLabel(text: "Nenhum bem oferecido")
            } else {
                self.noItemLabel?.removeFromSuperview()
            }
        }) {
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
        self.showWaitOverlay()
        fetchItemsFromScratch()
    }
    
}

// MARK: - Table View Footer Spinner

extension MyItemsController {
    
    func showFooterSpinner() {
        self.tableView.tableFooterView = Helper.createSpinner(width: tableView.bounds.width)
        self.tableView.tableFooterView?.isHidden = false
    }
    
    func hideFooterSpinner() {
        self.tableView.tableFooterView = UIView()
        self.tableView.tableFooterView?.isHidden = true
    }
    
}
