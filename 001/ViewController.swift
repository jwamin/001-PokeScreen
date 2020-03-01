//
//  ViewController.swift
//  001
//
//  Created by Joss Manger on 1/27/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import SceneKit


class MyViewController:ViewController, SCNSceneRendererDelegate, CAAnimationDelegate {
  
  var scene:SCNScene!
  var scnView:SCNView!
  let cameraNode:SCNNode = SCNNode()
  var tasks:DispatchGroup!

  var layers:[CAAnimationGroup:SCNNode] = [:]
  
  var blurView:BlurViewWithDeinit?
  var blurviewConstrsints: [NSLayoutConstraint] = Array<NSLayoutConstraint>()
  var naniumator: UIActivityIndicatorView?
  
  var constrants: [NSLayoutConstraint] = Array<NSLayoutConstraint>()
  
  var opacity1:CABasicAnimation!
  var scale:CABasicAnimation!
  var scale2:CABasicAnimation!
  var opacity2:CABasicAnimation!
  
  var nodes:[SCNNode] = []
  
  private var pokedex: Pokedex!
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    scnView = SCNView(frame: view.frame)
    scnView.translatesAutoresizingMaskIntoConstraints = false
    //scnView.showsStatistics = true
    view.addSubview(scnView)
    scene = SCNScene()
    
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
   
    
    scnView.allowsCameraControl = true
    scnView.scene = scene
    scnView.delegate = self
    scnView.backgroundColor = Color.gray
    
    setupBasicAnim()
    
    //add background URLSessions, with index, to dispatch group
    PokemonLoader.loadAll { [weak self] (dex) in
      
      guard let self = self else {
        fatalError()
      }
      
      self.pokedex = dex
      for subviews in (self.blurView?.contentView.subviews)!{
        subviews.removeFromSuperview()
      }
      
      for subview in (self.blurView?.subviews)!{
        subview.removeFromSuperview()
      }
      
      NSLayoutConstraint.deactivate(self.blurviewConstrsints)
      self.blurviewConstrsints.removeAll()
      print(self.blurviewConstrsints)
      self.blurView?.effect = nil
      self.blurView?.removeFromSuperview()
      
      
      for _ in 0...nodeNumber {
        self.nodes.append(SCNNode())
      }
      
      self.setupScene()
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
  
  //MARK: SceneKit
  
  func setupBasicAnim(){
    
    opacity1 = CABasicAnimation(keyPath: "opacity")
    opacity1.fromValue = 0.0
    opacity1.toValue = 1.0
    opacity1.duration = 0.1
    opacity1.beginTime = 0
    opacity1.fillMode = .forwards
    
    scale = CABasicAnimation(keyPath: "scale")
    scale.fromValue = SCNVector3Make(0.6, 0.6, 0.6)
    scale.toValue = SCNVector3Make(1, 1, 1)
    scale.duration = 0.1
    scale.beginTime = 0
    scale.fillMode = .forwards
    
    
    opacity2 = CABasicAnimation(keyPath: "opacity")
    opacity2.fromValue = 1.0
    opacity2.toValue = 0.0
    opacity2.duration = 0.1
    opacity2.beginTime = 9.9
    opacity2.fillMode = .forwards
    
    scale2 = CABasicAnimation(keyPath: "scale")
    scale2.fromValue = SCNVector3Make(1, 1, 1)
    scale2.toValue = SCNVector3Make(0.6, 0.6, 0.6)
    scale2.duration = 1.1
    scale2.beginTime = 9.9
    scale2.fillMode = .forwards
    
  }
  
  

  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    print("call",flag)
    
    if(flag){
      let group = anim as! CAAnimationGroup
      if let node:SCNNode = layers[group]{
        node.geometry = nil
        node.removeFromParentNode()
        layers.removeValue(forKey: group)
        //node.geometry
      }
    }
  }
  
  func addAndAnimatePlane(_ image:Image?){
    
    let isNode:SCNNode? = {
      for (index,node) in nodes.enumerated(){
        if(node.parent == nil){
          print("using node \(index)")
          return node
        }
      }
      return nil
    }()
    
    guard let node = isNode else {
      print("returning")
      return
    }
    
    
    let multiples = [1,2,0.5]
    let size:CGFloat = CGFloat(1 *  multiples[multiples.randomIndex])
    let box = SCNPlane(width: size, height: size)
    box.materials.first?.diffuse.contents = image ?? colors[colors.randomIndex]
    box.materials.first?.isDoubleSided = true
    node.geometry = box
    
    let randomPostionsX = Float.random(min:-3,max:3)
    let randomPositionY = Float.random(min:-3,max:3)
    let randomPositionZ = Float.random(min:-10,max:Float(cameraNode.position.z))
    
    node.position = SCNVector3Make(Float(randomPostionsX), Float(randomPositionY), Float(randomPositionZ))
    
    node.opacity = 0
    node.scale = SCNVector3(0.6, 0.6, 0.6)
    
    scnView.scene?.rootNode.addChildNode(node)
    
    let group = CAAnimationGroup()
    group.duration = 10
    
    let position = CABasicAnimation(keyPath: "position")
    position.fromValue = node.position
    position.toValue = SCNVector3(node.position.x, node.position.y, cameraNode.position.z)
    position.duration = 9.9
    position.beginTime = 0.1
    position.fillMode = .forwards
    
    group.animations = [opacity1,scale,position,scale2,opacity2]
    group.fillMode = .forwards
    group.isRemovedOnCompletion = true
    layers[group] = node
    group.delegate = self
    node.addAnimation(group, forKey: "all")
    
  }
  
  func setupScene(){
    
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3Make(0, 0, 3)
    scene.rootNode.addChildNode(cameraNode)
    scnView.pointOfView = cameraNode
    
    //debug positioning
    if(DEBUG){
      let box = SCNPlane(width: 1, height: 1)
      box.materials.first?.diffuse.contents = Color.black.cgColor
      let node = SCNNode(geometry: box)
      scene.rootNode.addChildNode(node)
    }
    
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
      if let pokemon = self.pokedex.randomElement() {
        if let img = pokemon.sprite.image{
          
          DispatchQueue.main.async {
            
            //img
            self.addAndAnimatePlane(img)
          }
          
        }
        
      }
      
    }
    
  }
  
}
