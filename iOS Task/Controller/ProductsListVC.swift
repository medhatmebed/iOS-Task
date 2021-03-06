//
//  ViewController.swift
//  iOS Task
//
//  Created by Medhat Mebed on 2/16/19.
//  Copyright © 2019 Medhat Mebed. All rights reserved.
//

import UIKit
import CoreData

class ProductsListVC: UIViewController {
    
    @IBOutlet weak var productsListTblView: UITableView!
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Product.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = (self as NSFetchedResultsControllerDelegate)
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setNavigationController()
        fetchingData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.productsListTblView.rowHeight = UITableView.automaticDimension
        self.productsListTblView.estimatedRowHeight = 400
    }
    
    
    
    //MARK : -  Private Methods
    private func setNavigationController() {
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .bold) ]
        navigationItem.largeTitleDisplayMode = .automatic
        title = "Products"
    }
    
    /**
     This func is really important because it fetching data from coreData and call APIService to fetch data from api if ther is an error it displays toast view with error message and for handling the response data it calls func saveInCoreDataWith but before that it clears the old data by using func clearData()
     */
    private func fetchingData() {
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(String(describing: self.fetchedhResultController.sections?[0].numberOfObjects))")
        } catch let error  {
            print("ERROR: \(error)")
        }
        
        let service = APIService()
        service.getDataWith { (result) in
            switch result {
            case .Success(let data):
                self.clearData()
                self.saveInCoreDataWith(array: data)
            case .Error(let message):
                DispatchQueue.main.async {
                    ToastView.shared.long(self.view, txt_msg: message)
                }
            }
        }
    }
    
    //MARK : - CoreData Methods
    
    /**
     This func creates entity and parsing the response data from api to core data entity called Product
     */
    private func createProductEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let productEntity = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as? Product {
            productEntity.id = dictionary["id"] as? Int16 ?? 0
            productEntity.name = dictionary["name"] as? String
            productEntity.price = dictionary["price"] as? Double ?? 0.0
            productEntity.productDescription = dictionary["productDescription"] as? String
            let mediaDictionary = dictionary["image"] as? [String: AnyObject]
            productEntity.imageUrl = mediaDictionary?["link"] as? String
            return productEntity
        }
        return nil
    }
    
    /**
     This func manipulate the returned data from createProductEntity and save this data into core data
     */
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map{self.createProductEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    /**
     This func clear all data found in core data to make it fresh when use
     */
    private func clearData() {
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Product.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    //MARK : - PrepareForSegue Method
    /**
     This func passes the product description to display it in ProductDetailVC
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ProductDetailVC
            , let indexPath = self.productsListTblView.indexPathForSelectedRow {
            if let product = fetchedhResultController.object(at: indexPath) as? Product {
                destination.selectedProductDescription = product.productDescription
            }
        }
    }
    
}

//MARK : - TableView DataSource and Delegate

extension ProductsListVC: UITableViewDelegate, UITableViewDataSource {
    
    /**
     This func returns number of row in productsListTblView by calculating elements in fetchedhResultController
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
        
    }
    
    /**
     This func returns the ProductCell and call cell.setProductCell to display data from Product
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductCell
        if let product = fetchedhResultController.object(at: indexPath) as? Product {
            cell.setProductCell(product: product)
        }
        
        cell.selectionStyle = .none
        return cell
 
    }
}

//MARK: - Fetching Core Data Result

extension ProductsListVC: NSFetchedResultsControllerDelegate {
    
    /**
     This func is the delegate method of NSFetchedResultsControllerDelegate and it update table view
     */
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.productsListTblView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.productsListTblView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.productsListTblView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        productsListTblView.beginUpdates()
    }
}

