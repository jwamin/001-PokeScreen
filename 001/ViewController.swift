//
//  ViewController.swift
//  001
//
//  Created by Joss Manger on 1/27/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import SceneKit


class MyViewController: ViewController, SCNSceneRendererDelegate, CAAnimationDelegate {
  
  var pokemonScene: PokemonScene!
  var scnView:SCNView!

  private var pokedex: Pokedex!
  
  var blurView:BlurViewWithDeinit?
  var blurviewConstrsints: [NSLayoutConstraint] = Array<NSLayoutConstraint>()
  var naniumator: UIActivityIndicatorView?
  
  var constrants: [NSLayoutConstraint] = Array<NSLayoutConstraint>()
  
  override func viewDidAppear(_ animated: Bool) {
    print("view appeared")
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
        
    scnView = SCNView(frame: view.frame)
    scnView.backgroundColor = .gray

    scnView.translatesAutoresizingMaskIntoConstraints = false
    //scnView.showsStatistics = true
    view.addSubview(scnView)
    
    
    blurView = BlurViewWithDeinit(effect: UIBlurEffect(style: .regular))
    
    guard let blurView = self.blurView else {
      fatalError()
    }
    
    blurView.clipsToBounds = true
    blurView.layer.cornerRadius = 8
    blurView.translatesAutoresizingMaskIntoConstraints = false
    
    let naniumator = UIActivityIndicatorView(style: .medium)
    naniumator.translatesAutoresizingMaskIntoConstraints = false
    naniumator.startAnimating()
    
    blurView.contentView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    blurView.contentView.addSubview(naniumator) 
    self.naniumator = naniumator
    
    view.addSubview(blurView)
    
    createConstraints()
    
    if unitTesting {
      return
    }
    
    //add background URLSessions, with index, to dispatch group

    PokemonLoader.loadAll { [weak self] (dex) in

      guard let self = self else {
        fatalError()
      }

      self.pokemonScene = PokemonScene(pokedex: dex, sceneView: self.scnView)

      //remove blurview
      NSLayoutConstraint.deactivate(self.blurviewConstrsints)
      for subview in (self.blurView?.subviews)!{
        subview.removeFromSuperview()
      }
      self.blurviewConstrsints.removeAll()
      print(self.blurviewConstrsints)
      self.blurView?.effect = nil
      self.blurView?.removeFromSuperview()

    }
    
  }
  
  
  func createConstraints(){
    
    if blurviewConstrsints.isEmpty && constrants.isEmpty {
    
      guard let blurView = blurView, let naniumator = naniumator else {
        fatalError()
      }
      
      let views: [String:Any] = ["scnView":scnView!,"blurView":blurView,"activity":naniumator]
       var constraints:[NSLayoutConstraint] = [NSLayoutConstraint]()
       
       constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[scnView]-0-|", options: [], metrics: nil, views: views)
       constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[scnView]-0-|", options: [], metrics: nil, views: views)
       
       blurviewConstrsints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activity]-|", options: [], metrics: nil, views: views)
       blurviewConstrsints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activity]-|", options: [], metrics: nil, views: views)
       
       blurviewConstrsints += NSLayoutConstraint.constraints(withVisualFormat: "H:[blurView]-8-|", options: [], metrics: nil, views: views)
       
       let safeArea = view.safeAreaLayoutGuide
       
       blurviewConstrsints += [safeArea.bottomAnchor.constraint(equalToSystemSpacingBelow: blurView.bottomAnchor, multiplier: 1.0)]
       
       NSLayoutConstraint.activate(blurviewConstrsints)
       
       NSLayoutConstraint.activate(constraints)
         }
      view.setNeedsLayout()
       view.layoutIfNeeded()
  
  }
  

  
  

  

 
  

  
}
