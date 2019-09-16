//
//  SearchItemController.swift
//  ufrgs-mural
//
//  Created by Augusto on 10/01/2019.
//  Copyright © 2019 Augusto. All rights reserved.
//

import Foundation
import SwiftOverlays
import UIKit

class SearchItemController: UIViewController {
    
    // MARK: - Properties
    
    var items = [Item]()
    var didSearch = false
    var repository = ItemRepository()
    
    var searchTerm = ""
    var selectedIndex = 0
    
    var isFetching = false
    var nextPageToFetch = 1
    var lastPageToFetch = 1
    var totalResults = 0
    
    weak var delegate: EditItemProtocol?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        self.searchView.hero.modifiers = [.translate(y:-100.0), .scale(0.5), .fade]
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        textField.becomeFirstResponder()
        
        configureTableView()
        configureNavBar()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        hideKeyboard()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchToViewItem" {
            let nav = segue.destination as! UINavigationController
            let vc = nav.viewControllers.first as! ViewItemController
            
            vc.item = items[selectedIndex]
            vc.delegate = self
        }
    }
    
    // MARK: - Actions
    
    @IBAction func searchAction(_ sender: Any) {
        
        if Helper.isValid(string: textField.text) {
            
            didSearch = true
            
            items.removeAll()
            nextPageToFetch = 1
            lastPageToFetch = 1
            totalResults = 0
            
            searchTerm = textField.text!

            // animates waiting
            showWaitOverlayWithText("Buscando...")
            self.hideKeyboard()
            
            self.fetchMoreItems()
            
        } else {
            
            let alert = Helper.createSimpleAlert(title: "Parâmetros faltando", message: "Digite no campo de texto o termo que deseja pesquisar")
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    private func fetchMoreItems() {
        
        isFetching = true
        
        repository.readPageWithTerm(
            page: nextPageToFetch,
            term: searchTerm,
            pageCompletion: { (newItems, lastPage, itemsCount) in
                
                self.removeAllOverlays()
                self.hideFooterSpinner()
                
                self.nextPageToFetch += 1
                self.lastPageToFetch = lastPage
                self.totalResults = itemsCount
                
                self.isFetching = false
            
                for item in newItems {
                    self.items.append(item)
                }
                
                self.tableView.reloadData()
                
                // se acabou de buscar a primeira página
                if self.nextPageToFetch == 2 {
                    
                    // sobe até o topo
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
                
        }) {
            self.tableView.reloadData()
        }
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
}

// MARK: - Table View Data Source

extension SearchItemController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if didSearch {
            return items.count + 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if didSearch {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "resultsInfoCell") as! ResultsInfoCell
                
                cell.label.text = createResultsInfo()
                
                return cell
                
            } else {
                let index = indexPath.row - 1
                
                if index < items.count {
                    
                    let item = items[index]
                    let cell = tableView.dequeueReusableCell(withIdentifier: MuralItemCell.identifier) as! MuralItemCell
                    
                    cell.configure(name: item.name, image: item.image, hasFetchedImage: item.didFetchImage)
                    cell.tag = indexPath.row
                    
                    return cell
                }
            }
            
        }
        
        return UITableViewCell()
    }
    
    private func createResultsInfo() -> String {
        if items.count > 0 {
            return "Fo\((totalResults > 1) ? "ram" : "i") encontrado\((totalResults > 1) ? "s" : "") \(totalResults) resultado\((totalResults > 1) ? "s" : "") para a busca \"\(searchTerm)\""
        } else {
            return "Não há resultados para a busca \"\(searchTerm)\""
        }
    }
    
    private func configureTableView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        tableView.backgroundView = UIView()
        tableView.backgroundView?.addGestureRecognizer(tap)
        
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 16, right: 0)
        
        registerNibs()
    }
    
    private func registerNibs() {
        let nib = UINib.init(nibName: MuralItemCell.identifier, bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: MuralItemCell.identifier)
    }
    
}

// MARK: - Table View Delegate

extension SearchItemController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideKeyboard()
        
        if indexPath.row <= 0 { return }
        
        selectedIndex = indexPath.row - 1
        
        if selectedIndex < items.count {
            self.performSegue(withIdentifier: "searchToViewItem", sender: self)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let lastVisibleCell = tableView.visibleCells.last {
            if let lastVisibleRow = tableView.indexPath(for: lastVisibleCell)?.row {
                
                let lastRow = tableView.numberOfRows(inSection: 0) - 1
                
                if lastVisibleRow == lastRow {
                    if !isFetching && didSearch {
                        
                        if nextPageToFetch <= lastPageToFetch {
                            self.showFooterSpinner()
                            self.fetchMoreItems()
                        }
                    }
                }
            }
        }
    }
    
}

// MARK: Text Field Delegate

extension SearchItemController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchAction(self)
        return true
    }
    
}

// MARK: - Edit Item delegate

extension SearchItemController: EditItemProtocol {
    
    func didEdit(item: Item) {
        tableView.reloadData()
        
        NotificationCenter.default.post(name: CustomNotification.muralMustRefresh, object: nil)
        NotificationCenter.default.post(name: CustomNotification.myItemsMustRefresh, object: nil)
    }
    
    func didDelete(item: Item) {
        
        if item.number == items[selectedIndex].number {
            items.remove(at: selectedIndex)
            
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            NotificationCenter.default.post(name: CustomNotification.muralMustRefresh, object: nil)
            NotificationCenter.default.post(name: CustomNotification.myItemsMustRefresh, object: nil)
        }
        
    }
    
}

// MARK: - Results Info Cell

class ResultsInfoCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }
    
}

// MARK: - Table View Footer Spinner

extension SearchItemController {
    
    func showFooterSpinner() {
        self.tableView.tableFooterView = Helper.createSpinner(width: tableView.bounds.width)
        self.tableView.tableFooterView?.isHidden = false
    }
    
    func hideFooterSpinner() {
        self.tableView.tableFooterView = UIView()
        self.tableView.tableFooterView?.isHidden = true
    }
    
}
