//
//  ViewController.swift
//  iOS Task
//
//  Created by Medhat Mebed on 2/16/19.
//  Copyright © 2019 Medhat Mebed. All rights reserved.
//

import UIKit

class ProductsListVC: UIViewController {
    
    @IBOutlet weak var productsListTblView: UITableView!
    
    lazy var productsDataReceived = [ProductData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        requestAPIs()
        setNavigationController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !Reachability.Connection(){
            ToastView.shared.long(self.view, txt_msg: "Network error")
        }
        self.productsListTblView.rowHeight = UITableView.automaticDimension
        self.productsListTblView.estimatedRowHeight = 400
    }
    
    //MARK : -  Private Methods
    
    private func setNavigationController() {
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .bold) ]
        navigationItem.largeTitleDisplayMode = .automatic
        title = "Products"
    }
    
    private func requestAPIs(){
        let jsonUrlString = "https://limitless-forest-98976.herokuapp.com"
        guard let url = URL(string: jsonUrlString) else { return }
        let task = URLSession.shared.welcomeTask(with: url) { welcome, response, error in
            if error != nil {
                print(error ?? "")
            }
            if let welcome = welcome?.data {
                print(welcome[0])
                self.productsDataReceived = welcome
                DispatchQueue.main.async {
                    self.productsListTblView.reloadData()
                }
            }
        }
        
        task.resume()
        
    }
    
    //MARK: - PrepareForSegue Method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ProductDetailVC
            , let indexPath = self.productsListTblView.indexPathForSelectedRow {
            destination.selectedProductDescription = productsDataReceived[indexPath.row].productDescription
        }
    }
    
    
    
    
}

extension ProductsListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return productsDataReceived.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductCell
        cell.nameLbl.text = productsDataReceived[indexPath.row].name
        cell.priceLbl.text = String(format: "$%.2f", productsDataReceived[indexPath.row].price!)
        
        guard let url = URL(string: (productsDataReceived[indexPath.row].image?.link)!) else {  return cell }
        
        ImageService.getImage(withURL: url) { image, url in
            guard let _post = self.productsDataReceived[indexPath.row].image else { return }
            if _post.link == url.absoluteString {
                cell.activitySpinner.stopAnimating()
                cell.activitySpinner.hidesWhenStopped = true
                cell.productImageView.image = image
            } else {
                print("Not the right image")
            }
        }
        cell.selectionStyle = .none
        
        return cell
        
        
    }
}

