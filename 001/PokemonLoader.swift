//
//  PokemonLoader.swift
//  001
//
//  Created by Joss Manger on 3/1/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import Foundation

@objc
public class PokemonLoader : NSObject {
  
  static var rootURL = URL(string: "http://pokeapi.co/api/v2/pokemon/")!
  
  static let queueID = "org.jossy.pokemonrequestQueue"
  static var queue: DispatchQueue = DispatchQueue(label: PokemonLoader.queueID, qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
  
  @objc public func loadAll(callback: @escaping ([Image]) -> Void) {
    print("load all called")
    PokemonLoader.loadAll { (dex) in
      print(dex.count)
      var arr = Array<Image>()
      for item in dex {
       if let img = item.sprite.image {
          arr.append(img)
        }
      }
      callback(arr)
    }
  }
  
  public static func loadAll(callback: @escaping (Pokedex)->Void){
    
    var pokedex = Pokedex()
    //pokedex.reserveCapacity(MAX)
    
    let dispatchGroup = DispatchGroup()
    
    for index in 1...MAX{
      let task = createTask(taskManager:dispatchGroup, index: index){ poke in
        
        if Thread.isMainThread {
          pokedex.insert(poke)
          dispatchGroup.leave()
        } else {
          PokemonLoader.queue.async(flags: .barrier, execute: {
            print("pokedex count: \(pokedex.count), inserting \(poke.name)")
            pokedex.insert(poke)
            dispatchGroup.leave()
          })
        }

      }
      task.resume()
    }
    
    dispatchGroup.notify(queue: .main) {
      print("final count \(pokedex.count)")
      callback(pokedex)
    }
    
  }
  
  static var directory: URL = {
    
    let folder = "images"
    let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let destination = URL(fileURLWithPath: documentFolder).appendingPathComponent(folder, isDirectory: true)
    var objcbool = ObjCBool(booleanLiteral: true)
    if !FileManager.default.fileExists(atPath: destination.absoluteString, isDirectory: &objcbool){
      do{
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
        return destination
      } catch {
        fatalError(error.localizedDescription)
      }
    }
    
    return destination
    
  }()
  
  static func emptyCache(){
    
    let url = PokemonLoader.directory
    do {
    let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
      try contents.forEach { (url) in
        try FileManager.default.removeItem(at: url)
        print("successfully deleted \(url)")
      }
    } catch {
      print("failed to delete cache, \(error.localizedDescription)")
    }
    
    
  }
  
  static func createTask(taskManager: DispatchGroup, index: Int, callback: @escaping (Pokemon)->Void) -> URLSessionDataTask {
    
    taskManager.enter()
    
    let url = rootURL.appendingPathComponent("\(index)")
    
    return URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
      
      if(error != nil){
        fatalError(error.debugDescription)
      }
      
      guard let data = data else {
        return
      }
      
      PokemonLoader.queue.async {
        
        do{
          var poke = try JSONDecoder().decode(Pokemon.self, from: data)
          
          //Is there currently an image in the relevant folder?
          
          let url = PokemonLoader.directory
          
          let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
          
          let imageName = "\(poke.number)-\(poke.name).png"
          let imgurl = url.appendingPathComponent(imageName)
          
          var image: Image?
          
          switch contents.contains(imgurl) {
          case true:
            print("loading \(poke.name) from cache")
            guard let data = try? Data(contentsOf: imgurl) else {
              fatalError()
            }
            image = Image(data:data)
            poke.sprite.image = image
            
            callback(poke)
            break;
          case false:
            print("loading \(poke.name) from url")
            PokemonLoader.loadImage(url: poke.sprite.url, filePath:imgurl) { (image) in
              poke.sprite.image = image
              DispatchQueue.main.async {
                //notify DispatchGroup that we are done with this particular task
                
                callback(poke)
              }
              return
            }
          }
          

          
        } catch {
          fatalError()
        }
        
      }
      
    }
      
      
    )
  }
  
  private static func loadImage(url:URL,filePath:URL,count:Int = 0,callback:@escaping (Image?)->Void){
    
    let imageTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
      
      guard let gotdata = data else {
        if count <= 3{
          let newCount = count + 1
          print("retrying \(newCount)")
          loadImage(url: url, filePath: filePath,count: newCount, callback: callback)
        
        } else {
          fatalError()
        }
        return
      }
      
      let image = Image(data: gotdata)
      
      do {
        try gotdata.write(to: filePath)
      } catch {
        print(error)
      }
      
      callback(image)
      
    }
    imageTask.resume()
    
  }
  
}
