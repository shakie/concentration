//
//  PhotoCollectionViewCell.swift
//  Concentration
//
//  Created by Shaun Rowe on 18/08/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class PhotoCollectionViewCell: UICollectionViewCell {    
    
    @IBOutlet weak var imageViewKitten: UIImageView!
    @IBOutlet weak var imageViewBack: UIImageView!
    
    var revealed: Bool = false
        
    func turn(_ reveal: Bool) {
        self.revealed = reveal
        
        UIView.transition(from: reveal ? imageViewBack : imageViewKitten,
                          to: reveal ? imageViewKitten : imageViewBack,
                          duration: 0.5,
                          options: [.transitionFlipFromLeft, .showHideTransitionViews],
                          completion: nil)
    }
    
}
