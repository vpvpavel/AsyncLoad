//
//  Service.swift
//  AsyncLoad
//
//  Created by Pavlo Vorobiov on 9/9/21.
//

import Foundation

enum PNetworkFailureReason {
    case decode
}

enum PNetworkError: Error {
    case undefined
    case failure(PNetworkFailureReason)
}

private actor PServiceStore {
    private var loadedPhotoList = PhotoList(list: [Photo(id: "0",
                                                         author: "Author",
                                                         download_url: "https://picsum.photos/id/0/5616/3744")])
    
    private var url: URL {
        urlComponents.url!
    }
    
    
    private var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "picsum.photos"
        components.path = "/v2/list"
        components.query = "limit=10"
        
        return components
    }
    
    func load() async throws -> PhotoList {
        do {
            let (data, responce) = try await URLSession.shared.data(from: url)
            guard let httpResponse = responce as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                throw PNetworkError.undefined
            }
            guard
                let decodedData = try? JSONDecoder().decode([Photo].self, from: data)
            else {
                throw PNetworkError.failure(.decode)
            }
            
            loadedPhotoList = PhotoList(list: decodedData)
            
            return loadedPhotoList
            
        } catch {
            print(error.localizedDescription)
        }
        
        return loadedPhotoList
    }
}

class PService: ObservableObject {
    @Published private(set) var photoList = PhotoList(list: [Photo(id: "0",
                                                                   author: "Author",
                                                                   download_url: "https://picsum.photos/id/0/5616/3744")])
    @Published private(set) var isFetching = false
    
    private let store = PServiceStore()
    
    @MainActor func fetchPhotoList() async throws {
        isFetching = true
        
        defer { isFetching = false }
        
        photoList = try await store.load()
    }
}

struct PhotoList: Codable {
    var list: [Photo]
}

struct Photo: Codable, Identifiable {
    let id: String
    let author: String
    let download_url: String
}
