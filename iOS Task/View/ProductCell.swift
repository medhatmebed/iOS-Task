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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.productNameLbl.text = "Name"
        self.productPriceLbl.text = "Price"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}