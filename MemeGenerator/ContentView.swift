//
//  ContentView.swift
//  MemeGenerator
//
//  Created by Arunn, Karthick (D.) on 03/05/20.
//  Copyright © 2020 Arunn, Karthick (D.). All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    let url = URL(string: "https://ronreiter-meme-generator.p.rapidapi.com/meme")!
    
    var body: some View {
        AsyncImage(
            url: url,
            placeholder: Text("Loading ...")
        ).aspectRatio(contentMode: .fit)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

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
