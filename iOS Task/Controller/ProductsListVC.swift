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
        updateTableContent()
        
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
    
    private func updateTableContent() {
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
    
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map{self.createProductEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
        
    }
    
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

