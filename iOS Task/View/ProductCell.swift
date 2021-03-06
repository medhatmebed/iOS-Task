//
//  productCell.swift
//  iOS Task
//
//  Created by Medhat Mebed on 2/16/19.
//  Copyright © 2019 Medhat Mebed. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {
    
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var productPriceLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    /**
     this function initialize cell with its default data
     */
    private func initializeCell(){
        self.productNameLbl.text = "Name"
        self.productPriceLbl.text = "Price"
        self.productImageView.image = #imageLiteral(resourceName: "iOSTask_Image_PlaceHolder")
        self.activitySpinner.style = .whiteLarge
        self.activitySpinner.startAnimating()
    }
    
    /**
     this function feeding cell with data : Product
     */
    func setProductCell(product : Product) {
        self.nameLbl.text = product.name
        self.priceLbl.text = String(format: "$%.2f", product.price)
        guard let url = URL(string: (product.imageUrl)!) else {  return  }
        
        ImageService.getImage(withURL: url) { image, url in
            guard let _post = product.imageUrl else { return }
            if _post == url.absoluteString {
                self.activitySpinner.stopAnimating()
                self.activitySpinner.hidesWhenStopped = true
                self.productImageView.image = image
            } else {
                print("Not the right image")
            }
        }
    }
    
}
