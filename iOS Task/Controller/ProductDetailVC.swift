//
//  ProductDetailVC.swift
//  iOS Task
//
//  Created by Medhat Mebed on 2/16/19.
//  Copyright © 2019 Medhat Mebed. All rights reserved.
//

import UIKit

class ProductDetailVC: UIViewController {

    @IBOutlet weak var productDescriptionTxtView: UITextView!
    
    
    var selectedProductDescription : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let productDescrption = selectedProductDescription {
            productDescriptionTxtView.text = productDescrption
        }
        title = "Product Details"
        
    }
    
}
