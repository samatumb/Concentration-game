//
//  CardCell.swift
//  ConcentrationDay99
//
//  Created by Samat on 01.09.2020.
//  Copyright © 2020 samat.umirbekov. All rights reserved.
//

import UIKit

struct Card {
    let movie: String
    let image: String
    var isFaceDown = true
}


class CardCell: UICollectionViewCell {
    
    @IBOutlet var cardBackImageView: UIImageView!
    @IBOutlet var cardImageView: UIImageView!
    
    
    var cardViews: (front: UIImageView, back: UIImageView)?
    
    var isCardHidden = true
    
    func flipCard() {
        cardViews = (cardBackImageView.isHidden == false) ? (cardImageView, cardBackImageView) : (cardBackImageView, cardImageView)
        
        let transitionOptions = UIView.AnimationOptions.transitionFlipFromRight
        
        UIView.transition(with: self.contentView, duration: 0.3, options: transitionOptions, animations: { [weak self] in
            guard let cardViews = self?.cardViews else { return }
            cardViews.back.isHidden = true
            cardViews.front.isHidden = false
            
        })
    }
}
