//
//  ContentView.swift
//  AsyncLoad
//
//  Created by Pavlo Vorobiov on 9/8/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var photoService = PService()
    
    let columns = [
        GridItem(.adaptive(minimum: 200))
    ]
    
    
    var body: some View {
        VStack{
            Text("Loading in background...")
                .font(.subheadline)
            
            List{
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(photoService.photoList.list) { photo in
                        Text("\(photo.author)")
                        AsyncImage(url: URL(string: photo.download_url)) { image in
                            image.resizable()
                                .aspectRatio(contentMode:
                                                    .fill)
                        }placeholder: {
                            Color.blue
                        }
                            .frame(width: 200, height: 200)
                            .clipped()
                            .cornerRadius(20)
                    }
                }.padding()
            }
            Button {
                Task {
                    try? await photoService.fetchPhotoList()
                }
            } label: {
                Text("More data")
                    .overlay {
                        if photoService.isFetching {
                            ProgressView()
                        }
                    }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
