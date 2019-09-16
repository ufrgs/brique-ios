//
//  ViewItemController.swift
//  ufrgs-mural
//
//  Created by Augusto on 27/12/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import UIKit
import Hero

class ViewItemController: UIViewController {

    // MARK: - Properties
    
    var item = Item()
    var heroId: String = ""
    weak var delegate: EditItemProtocol?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hero.isEnabled = true
        self.navigationController?.hero.isEnabled = true
        self.navigationController?.hero.navigationAnimationType = .selectBy(presenting: .slide(direction: .left), dismissing: .slide(direction: .right))
        
        self.configureNavBar()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.hero.id = heroId
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.hero.id = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewToEditItem" {
            let vc = segue.destination as! EditItemController
            
            vc.item = self.item
            vc.delegate = self
            
        } else if segue.identifier == "viewToRequestItem" {
            let vc = segue.destination as! RequestItemController
            
            vc.nrSeqItem = self.item.nrSeq
            vc.delegate = self
        }
    }
    
    // MARK: - Configuration methods
    
    private func configureNavBar() {
    
        let tintColor = UIColor.black
        let backButton = UIBarButtonItem()
        
        backButton.title = "Cancelar"
        
        if let font = UIFont(name: "AvenirNext-Regular", size: 17) {
            
            backButton.setTitleTextAttributes([
                NSAttributedStringKey.font : font,
                NSAttributedStringKey.foregroundColor : tintColor,
                ], for: .normal)
        }
        
        navigationController?.navigationBar.tintColor = tintColor
        if let view = navigationItem.titleView { view.hero.id = HeroId.muralItemTitle }
        
        navigationItem.title = item.name
        navigationItem.backBarButtonItem = backButton
        
    }
    
    // MARK: - Action
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Table View Data Source

extension ViewItemController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "viewItemImageCell") as! ViewItemImageCell
            
            cell.myImageView.hero.id = HeroId.viewItemImage
            cell.configure(image: item.image)
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "viewItemButtonCell") as! ViewItemButtonCell
            
//            cell.hero.modifiers = [.cascade]
            cell.configure(userCanEdit: item.userCanEdit, userCanRequest: item.userCanRequest)
            cell.delegate = self
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "viewItemTextCell") as! ViewItemTextCell
            cell.configure(number: item.number, name: item.name, orgao: item.sourceOrgao?.name, description: item.description, person: item.personWhoRegistered)
            
            return cell
            
        default:
            return UITableViewCell()
        }
        
    }
    
}

// MARK: - Table View Delegate

extension ViewItemController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return tableView.frame.width
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
}

// MARK: - Item button actions

protocol ViewItemButtonClickProtocol: class {
    func buttonClicked()
}

extension ViewItemController: ViewItemButtonClickProtocol {
    
    func buttonClicked() {
        
        if self.item.userCanEdit {
            self.performSegue(withIdentifier: "viewToEditItem", sender: self)
        } else {
            if item.userCanRequest {
                self.performSegue(withIdentifier: "viewToRequestItem", sender: self)
            }
        }
        
    }
    
}

// MARK: - Edit Item delegate

extension ViewItemController: EditItemProtocol {
    
    func didEdit(item: Item) {
        self.delegate?.didEdit(item: item)
        
        tableView.reloadData()
        configureNavBar()
    }
    
    func didDelete(item: Item) {
        self.delegate?.didDelete(item: item)
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Item Request Protocol

protocol ItemRequestProtocol: class {
    func itemWasRequested(nrSeq: Int)
}

extension ViewItemController: ItemRequestProtocol {
    
    func itemWasRequested(nrSeq: Int) {
        if item.nrSeq == nrSeq {
            item.userCanRequest = false
            
            tableView.reloadData()
        }
    }
    
}
