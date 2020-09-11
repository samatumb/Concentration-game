//
//  ViewController.swift
//  ConcentrationDay99
//
//  Created by Samat on 01.09.2020.
//  Copyright © 2020 samat.umirbekov. All rights reserved.
//

import UIKit

final class CardPair {
    var card1: Card?, card2: Card?
    var id1: Int?, id2: Int?
    
    var isMatched: Bool? {
        guard let card1 = card1, let card2 = card2 else { return nil }
        return card1.movie == card2.movie
    }
    
    func reset() { card1 = nil; card2 = nil; id1 = nil; id2 = nil }
}

enum FaceUpCards {
    case zero, one, two
}


class ViewController: UIViewController {
    
    // Header
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var flipsLabel: UILabel!
    
    var level = 1 { didSet { levelLabel.text = "Level\n\(level)"; levelLabel.textColor = UIColor(named: "barared") } }
    var score = 0 { didSet { scoreLabel.text = "Score\n\(score)"; scoreLabel.textColor = UIColor(named: "barared") } }
    var flips = 0 { didSet { flipsLabel.text = "Flips\n\(flips)"; flipsLabel.textColor = UIColor(named: "barared") } }
    
    // Cards
    @IBOutlet var collectionView: UICollectionView!
    var isTouchesEnabled = true { didSet { collectionView.isScrollEnabled = isTouchesEnabled } }
    
    var movies = Set<String>()
    
    var cards = [Card]()
    var cardImages = [UIImage]()
    
    var cardBackColors = ["sunflower", "energos", "bluemartina", "lavenderrose", "barared"]
    var currentLevelBackColor: UIColor!
    var cardBackImages = [UIImage]()
    
    var numberOfPairs = 2
    var pair = CardPair()
    var faceUpCards: FaceUpCards = .zero
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        setCardBackImages()
        startNewGame()
    }
    
    func startNewGame() {
        level = 1; score = 0; flips = 0
        numberOfPairs = 2
        loadMovies()
        setCards()
        setCardImages()
        cardBackImages.shuffle()
        setBackColor()
    }
    
    
    func loadMovies() {
        let fm = FileManager.default
        guard let path = Bundle.main.path(forResource: "Posters", ofType: nil) else { return }
        guard let posters = try? fm.contentsOfDirectory(atPath: path) else { return }
        
        for poster in posters {
            guard (poster.range(of: ".jpg") != nil) else { continue }
            
            let letter = poster[poster.index(poster.endIndex, offsetBy: -5)] //letter = 1 from leon1.jpg
            guard Int(String(letter)) != nil else { print("ERROR"); continue }
            
            let name = String(poster.dropLast(5))
            movies.insert(name)
        }
    }
    
    
    func setCardBackImages() {
        let fm = FileManager.default
        guard let path = Bundle.main.path(forResource: "CardBacks", ofType: nil) else { return }
        guard let backs = try? fm.contentsOfDirectory(atPath: path) else { return }
        
        let backImageSize = CGSize(width: 40, height: 40)
        for back in backs {
            guard let image = getImage(from: "CardBacks", with: back, size: backImageSize) else { fatalError() }
            cardBackImages.append(image)
        }
        
        assert(cardBackImages.count >= movies.count)
    }
    
    
    func setBackColor() {
        if let color = cardBackColors.randomElement() {
            currentLevelBackColor = UIColor(named: color)
        } else {
            currentLevelBackColor = .blue
        }
    }
    
    
    func levelUp() {
        guard movies.count >= numberOfPairs else {
            showEndGameAlert()
            return
        }
        
        level += 1
        numberOfPairs += 1
        setCards()
        setCardImages()
        setBackColor()
        cardBackImages.shuffle()
        collectionView.reloadData()
    }
    
    
    func setCards() {
        assert(movies.isEmpty == false)
        assert(movies.count >= numberOfPairs)
        
        let fm = FileManager.default
        guard let path = Bundle.main.path(forResource: "Posters", ofType: nil) else { fatalError() }
        guard let images = try? fm.contentsOfDirectory(atPath: path) else { fatalError() }
        
        for _ in 0 ..< numberOfPairs {
            guard let movie = movies.randomElement() else { fatalError() }
            movies.remove(movie)
            
            var filteredImages = Set(images.filter({ $0.hasPrefix(movie) }))
            guard filteredImages.count > 1 else { fatalError() }
            let card1: Card, card2: Card
            
            guard let randomImage1 = filteredImages.randomElement() else { fatalError() }
            filteredImages.remove(randomImage1)
            guard let randomImage2 = filteredImages.randomElement() else { fatalError() }
            
            card1 = Card(movie: movie, image: randomImage1)
            card2 = Card(movie: movie, image: randomImage2)
            cards.append(contentsOf: [card1, card2])
        }
        
        cards.shuffle()
    }

    
    func setCardImages() {
        assert(cards.count == numberOfPairs * 2)
        let cardImageSize = CGSize(width: 100, height: 135)
        for card in cards {
            guard let image = getImage(from: "Posters", with: card.image, size: cardImageSize) else { fatalError() }
            cardImages.append(image)
        }
    }
    
    
    func getImage(from folder: String, with name: String, size: CGSize) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil, subdirectory: folder) else { return nil }
        guard let original = UIImage(contentsOfFile: url.path) else { return nil }
        
        let rect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        
        let edited = renderer.image { ctx in
            ctx.cgContext.addRect(rect)
            ctx.cgContext.clip()
            original.draw(in: rect)
        }
        return edited
    }
}


// MARK: -CollectionView

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        //collectionView.register(CardCell.self, forCellWithReuseIdentifier: "Card")
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardImages.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Card", for: indexPath) as? CardCell else { fatalError("cant create Cell") }
        guard cardImages.isEmpty == false else { return cell }
        
        let image = cardImages[indexPath.item]
        let card = cards[indexPath.item]
        
        cell.cardBackImageView.image = cardBackImages[indexPath.item]
        cell.cardBackImageView.backgroundColor = currentLevelBackColor
        
        cell.cardImageView.image = image
        cell.cardBackImageView.layer.cornerRadius = 10
        cell.cardImageView.layer.cornerRadius = 10
        
        if cell.cardImageView.isHidden != card.isFaceDown {
            cell.cardBackImageView.isHidden = !card.isFaceDown
            cell.cardImageView.isHidden = card.isFaceDown
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard isTouchesEnabled else { return }
        
        let selectedCard = cards[indexPath.item]
        
        switch faceUpCards {
        case .zero:
            flips += 1
            faceUpFirstCard(card: selectedCard, at: indexPath)
            
        case .one:
            if let firstCard = pair.card1, selectedCard.image == firstCard.image { //Close card if user tapped first card two times
                faceDownFirstCard(card: selectedCard, at: indexPath)
                return
            }
            flips += 1
            faceUpSecondCard(card: selectedCard, at: indexPath)
            fallthrough
            
        case .two:
            isTouchesEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.checkMatching()
            }
        }
    }
}


// MARK: -Card open, match actions

extension ViewController {
    
    func flipCard(at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else { return }
        if isTouchesEnabled { isTouchesEnabled = false }
        cell.flipCard()
        isTouchesEnabled = true
    }
    
    
    func faceUpFirstCard(card: Card, at indexPath: IndexPath) {
        pair.card1 = card
        pair.id1 = indexPath.item
        cards[indexPath.item].isFaceDown = false
        
        flipCard(at: indexPath)
        faceUpCards = .one
    }
    
    
    func faceDownFirstCard(card: Card, at indexPath: IndexPath) {
        pair.reset()
        cards[indexPath.item].isFaceDown = true
        
        flipCard(at: indexPath)
        faceUpCards = .zero
    }
    
    
    func faceUpSecondCard(card: Card, at indexPath: IndexPath) {
        pair.card2 = card
        pair.id2 = indexPath.item
        
        cards[indexPath.item].isFaceDown = false
        
        flipCard(at: indexPath)
        faceUpCards = .two
    }
    
    
    func checkMatching() {
        guard let firstCardIndex = pair.id1 else { fatalError() }
        guard let secondCardIndex = pair.id2 else { fatalError() }
        
        let firstCardIndexPath = IndexPath(item: firstCardIndex, section: 0)
        let secondCardIndexPath = IndexPath(item: secondCardIndex, section: 0)
        
        guard let isMatched = pair.isMatched else { fatalError() }
        self.pair.reset()
        
        if isMatched {//MATCH
            score += 1
            
            let leftItem = firstCardIndex < secondCardIndexPath.item ? firstCardIndex : secondCardIndexPath.item
            let rightItem = firstCardIndex < secondCardIndexPath.item ? secondCardIndexPath.item - 1 : firstCardIndex - 1
            
            cards.remove(at: leftItem)
            cards.remove(at: rightItem)
            cardImages.remove(at: leftItem)
            cardImages.remove(at: rightItem)

            collectionView.deleteItems(at: [firstCardIndexPath, secondCardIndexPath])
            
            if cards.isEmpty { levelUp() }
            isTouchesEnabled = true
            
        } else { //NON-MATCH
            
            cards[firstCardIndex].isFaceDown = true
            if let firstCardCell = collectionView.cellForItem(at: firstCardIndexPath) as? CardCell {
                firstCardCell.flipCard()
            } else {
                collectionView.reloadData()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  [weak self] in
                self?.cards[secondCardIndexPath.item].isFaceDown = true
                self?.flipCard(at: secondCardIndexPath)
            }
        }
        
        faceUpCards = .zero
    }
}


extension ViewController: AlertViewControllerDelegate {
    func showEndGameAlert() {
        let vc = AlertViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    
    func alertButtonTapped() {
        startNewGame()
        collectionView.reloadData()
    }
}
