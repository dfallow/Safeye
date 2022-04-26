//
//  AnimationLottieView.swift
//  Safeye
//
//  Created by Pavlo Leinonen on 26.4.2022.
//

import Foundation
import SwiftUI
import Lottie

// Custon lottie view struct
struct AnimationLottieView: UIViewRepresentable {
    
    typealias UIViewType = UIView
    
    var lottieJson: String
    
    func makeUIView(context: UIViewRepresentableContext<AnimationLottieView>) -> UIView {
        let view = UIView(frame: .zero)
        
        //Adding animation
        let animationView = AnimationView()
        animationView.animation = Animation.named(lottieJson)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
        
        //Constrains as container for animation view
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AnimationLottieView>) {
    }
}
