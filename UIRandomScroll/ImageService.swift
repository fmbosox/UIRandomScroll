//
//  ImageService.swift
//  UIRandomScroll
//
//  Created by Felipe Montoya on 2/6/22.
//

import Foundation


enum ImageService {
    
    static func download(size:Int, completion: @escaping (Result<Data,Error>) -> Void) {
        let urlRequest = URLRequest(url: URL(string: "https://picsum.photos/\(size)")!)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else { completion(.failure(error!)); return }
            guard let data = data else { completion(.failure(NSError(domain: "Bad response", code: -1))); return }
            completion(.success(data))
        }
        .resume()
    }
}

