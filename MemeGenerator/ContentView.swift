//
//  ContentView.swift
//  MemeGenerator
//
//  Created by Arunn, Karthick (D.) on 03/05/20.
//  Copyright © 2020 Arunn, Karthick (D.). All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let url = URL(string: "https://ronreiter-meme-generator.p.rapidapi.com/meme")!
    
    var body: some View {
        AsyncImage(
            url: url,
            placeholder: Text("Loading ...")
        ).aspectRatio(contentMode: .fit)
    }
}

//struct ContentView: View {
//    var memeViewModel: MemeViewModel
//    @State private var image: Image?
////    var image: UIImage?
//    init(memeViewModel: MemeViewModel) {
//        self.memeViewModel = memeViewModel
//    }
//    var body: some View {
//        Button(action: {
//            print("Button Action")
//            self.memeViewModel.generateMeme { (data, error) in
//                if let image = data {
//                    print("Loading ...")
//                    VStack {
//                        self.image?
//                            .resizable()
//                            .scaledToFit()
//                    }
//                    .onAppear(perform: {
//                        self.loadImage(uiimage: image)
//                    })
////                    self.loadImage(uiimage: image)
//                }
//            }
//        }) {
//            Text.init("Button")
//        }
////        Text("Hello, Welcome to my World!")
//    }
//
//    func loadImage(uiimage: UIImage) {
//        image = Image(uiImage: uiimage)
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import SwiftUI
import Combine
import Foundation

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private var cancellable: AnyCancellable?
    
    deinit {
        cancellable?.cancel()
    }

    private let url: URL

    init(url: URL) {
        self.url = url
    }
    
    func load() {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("ronreiter-meme-generator.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.setValue("fdd1a62164mshaa7d08ea69d24bdp117f0ejsn84495048cb87", forHTTPHeaderField: "x-rapidapi-key")
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
        .map { UIImage(data: $0.data) }
        .replaceError(with: nil)
        .receive(on: DispatchQueue.main)
        .assign(to: \.image, on: self)
    }

    func cancel() {
        cancellable?.cancel()
    }
}

struct AsyncImage<Placeholder: View>: View {
    @ObservedObject private var loader: ImageLoader
    private let placeholder: Placeholder?
    
    init(url: URL, placeholder: Placeholder? = nil) {
        loader = ImageLoader(url: url)
        self.placeholder = placeholder
    }

    private var image: some View {
        Group {
            if loader.image != nil {
                Image(uiImage: loader.image!)
                    .resizable()
            } else {
                placeholder
            }
        }
    }
    
    var body: some View {
        image
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }
}

public class MemeViewModel {
    var components = URLComponents()
    func memeApiCall(_ completion: @escaping (_ respone: UIImage?, _ error: String?) -> ()) {
        
        components.scheme = "https"
        components.host = "ronreiter-meme-generator.p.rapidapi.com"
        components.path = "/meme"
//        components.queryItems = [
//            URLQueryItem.init(name: "top", value: top),
//            URLQueryItem.init(name: "bottom", value: bottom),
//            URLQueryItem.init(name: "meme", value: image)
//        ]
        guard let requestUrl = components.url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.setValue("ronreiter-meme-generator.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.setValue("fdd1a62164mshaa7d08ea69d24bdp117f0ejsn84495048cb87", forHTTPHeaderField: "x-rapidapi-key")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error found: \(error.localizedDescription)")
                completion(nil, error.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse{
                print("Response https statuscode : \(response.statusCode)")
            }
            if let data = data, let dataString = UIImage(data: data) {
                completion(dataString,nil)
                
            }
        }
        task.resume()
    }
    
    func generateMeme(_ completion: @escaping(_ response: UIImage?, _ error: String?) -> ()) {
        print("Method")
        let headers = [
            "x-rapidapi-host": "ronreiter-meme-generator.p.rapidapi.com",
            "x-rapidapi-key": "fdd1a62164mshaa7d08ea69d24bdp117f0ejsn84495048cb87"
        ]
        let urlString = "https://ronreiter-meme-generator.p.rapidapi.com/meme"
//        if let url = URL(string: urlString) {
//            URLSession.shared.dataTask(with: url) { data, response, error in
//                if let data = data {
//                    print("Hi Data")
//                    print(data)
////                    let decoder = JSONDecoder()
////                    if let json = decoder.decode(Response.self, from: data) {
////                        print(json)
////                    }
//                }
//            }.resume()
//        }

        let request = NSMutableURLRequest(url: NSURL(string: "https://ronreiter-meme-generator.p.rapidapi.com/meme")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                if let data = data, let image = UIImage(data: data) {
                    completion(image, nil)
                }
            }
        })

        dataTask.resume()
    }
}

