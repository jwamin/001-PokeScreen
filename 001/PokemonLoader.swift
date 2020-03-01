//
//  PokemonLoader.swift
//  001
//
//  Created by Joss Manger on 3/1/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import Foundation

class PokemonLoader {
  
  static let queueID = "org.jossy.pokemonrequestQueue"
  static var queue: DispatchQueue = DispatchQueue(label: PokemonLoader.queueID, qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
  
  
  static func loadAll(callback: @escaping (Pokedex)->Void){
    
    var pokedex = Pokedex()
    pokedex.reserveCapacity(MAX)
    
    let queue = DispatchGroup()
    
    for index in 1...MAX{
      let task = createTask(taskManager:queue, index: index){ poke in
        pokedex.insert(poke)
      }
      task.resume()
    }
    
    queue.notify(queue: .main) {
      callback(pokedex)
    }
    
  }
  
  static func createTask(taskManager: DispatchGroup, index: Int, callback: @escaping (Pokemon)->Void) -> URLSessionDataTask {
    
    taskManager.enter()
    
    guard let url = URL(string:"http://pokeapi.co/api/v2/pokemon/\(index)/") else {
      fatalError()
    }
    
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
          
          let imageTask = URLSession.shared.dataTask(with: poke.sprite.url) { (data, response, error) in
            
            guard let gotdata = data else {
              fatalError()
            }
            
            let image = Image(data: gotdata)
            
            poke.sprite.image = image
            
            //notify DispatchGroup that we are done with this particular last
            taskManager.leave()
            
            callback(poke)
            
          }
          imageTask.resume()
          
        } catch {
          fatalError()
        }
      }
      
    })
  }
  
  
}
