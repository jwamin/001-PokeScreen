//
//  PokemonScene.swift
//  001Tests
//
//  Created by Joss Manger on 3/21/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import SceneKit
import os

@objc
public class PokemonScene : NSObject {
  
  let cameraNode:SCNNode = SCNNode()
  var layers:[CAAnimationGroup:SCNNode] = [:]
  
  var scene:SCNScene!
  weak var scnView:SCNView!
  
  var pokedex:Pokedex!
  
  var opacity1:CABasicAnimation!
  var scale:CABasicAnimation!
  var scale2:CABasicAnimation!
  var opacity2:CABasicAnimation!
  
  var nodes:[SCNNode] = []
  
  var timer: Timer!
  
  public convenience init(pokedex:Pokedex, sceneView: SCNView){
    self.init(view: sceneView, load: false)
    initialiseScene(pokedex:pokedex)
  }
  
  @objc
  public init(view: SCNView,load: Bool){
    scnView = view
    super.init()
    
    if load {
      PokemonLoader.loadAll { [weak self] (dex) in
        os_log(.default, "loaded", [])
        self?.initialiseScene(pokedex: dex)
      }
    }
    
  }
  
  func initialiseScene(pokedex:Pokedex){
    
    self.pokedex = pokedex
    
    scene = SCNScene()
    
    scnView.allowsCameraControl = true
    scnView.scene = scene
    scnView.delegate = self
    scnView.backgroundColor = Color.gray
    
    setupBasicAnim()
    beginScene()
  }
  
  func addAndAnimatePlane(_ image:Image?, name: String = "Pokemon"){
     
     let isNode:SCNNode? = {
       for (index,node) in nodes.enumerated(){
         if(node.parent == nil){
           print("using node \(index) for \(name)")
           return node
         }
       }
       return nil
     }()
     
     guard let node = isNode else {
       print("returning")
       return
     }
     
     
    let multiples:[CGFloat] = [1,2,0.5]
    let size:CGFloat = CGFloat(1 *  multiples.randomElement()!)
     let box = SCNPlane(width: size, height: size)
    box.materials.first?.diffuse.contents = image ?? colors.randomElement()!
     box.materials.first?.isDoubleSided = true
     node.geometry = box
     
    let randomPostionsX: CGFloat = .random(in: -3...3)
     let randomPositionY: CGFloat = .random(in: -3...3)
    
    let minZ: CGFloat = -10.0
    let maxZ: CGFloat = CGFloat(cameraNode.position.z)
    
    let randomPositionZ: CGFloat = CGFloat.random(in: minZ...maxZ)
     
    node.position = SCNVector3(randomPostionsX, randomPositionY, randomPositionZ)
     
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
  
  func beginScene(){
    
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
    
    for _ in 0...nodeNumber {
      self.nodes.append(SCNNode())
    }
    
    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
      if let pokemon = self.pokedex.randomElement() {
        if let img = pokemon.sprite.image{
          
          DispatchQueue.main.async {
            
            //img
            self.addAndAnimatePlane(img,name: pokemon.name)
          }
          
        }
        
      }
      
    }
    
  }
  
  @objc
  public func stopScene(){
    timer.invalidate()
    timer = nil
    for node in nodes{
      node.removeAllAnimations()
      node.removeAllActions()
      node.removeFromParentNode()
    }
    nodes.removeAll()
  }
  
}

extension PokemonScene : SCNSceneRendererDelegate {
  
  
  
}

extension PokemonScene : CAAnimationDelegate {
  
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
  
  public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
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
  
}
