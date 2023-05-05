//
//  PhotosTableViewCell.swift
//  Photos1
//
//  Created by Mac on 04/05/23.
//

import UIKit
import Kingfisher
class PhotosTableViewCell: UITableViewCell {
    
    @IBOutlet weak var authorImageView : UIImageView!
    @IBOutlet weak var authornameLbl : UILabel!
    @IBOutlet weak var checkBtn : UIButton!
    @IBOutlet weak var downloadBtn : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(value: String) {
        authorImageView.kf.indicatorType = .activity
        authorImageView.kf.setImage(with: URL(string: value)!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
