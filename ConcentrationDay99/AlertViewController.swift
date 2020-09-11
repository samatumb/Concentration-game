//
//  AlertViewController.swift
//  ConcentrationDay99
//
//  Created by Samat on 04.09.2020.
//  Copyright © 2020 samat.umirbekov. All rights reserved.
//

import Lottie
import UIKit

protocol AlertViewControllerDelegate {
    func alertButtonTapped()
}

class AlertViewController: UIViewController {

    
    var animationView: AnimationView?
    var messageLabel: UILabel?
    var actionButton: UIButton?
    
    var delegate: AlertViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //animationView = .init(name: "coffee")
        configureAnimationView()
        configureButton()
        configureMessage()
        
        
    }
    
    func configureAnimationView() {
        animationView = .init(name: "badge")
        
        guard let animation = animationView else { return }
        view.addSubview(animation)
        
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .playOnce
        animation.animationSpeed = 1
        animation.play()
        
        animation.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animation.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            animation.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            animation.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animation.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    
    func configureMessage() {
        messageLabel = UILabel(frame: .zero)
        
        guard let message = messageLabel else { return }
        view.addSubview(message)
        
        message.text = "Congratulations!\nYou completed the game"
        message.font = UIFont.boldSystemFont(ofSize: 24)
        message.numberOfLines = 0
        
        message.textColor = UIColor(named: "barared")
        message.textAlignment = .center
        message.backgroundColor = UIColor(named: "sunflower")
        message.layer.cornerRadius = 16
        message.layer.masksToBounds = true
        

        message.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            message.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            message.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            message.widthAnchor.constraint(equalToConstant: 260),
            message.heightAnchor.constraint(equalToConstant: 100)
        ])
        
    }
    
    
    func configureButton() {
        actionButton = UIButton(frame: .zero)
        
        guard let button = actionButton else { return }
        view.addSubview(button)
        
        button.backgroundColor = UIColor(named: "barared")
        button.layer.cornerRadius = 8
        button.setTitle("Start New Game", for: .normal)
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            button.heightAnchor.constraint(equalToConstant: 44)
        
        ])
    }

    @objc func dismissVC() {
        delegate?.alertButtonTapped()
        dismiss(animated: true)
    }
    
    deinit {
        print("removed")
    }
    
}
