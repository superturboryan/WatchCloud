//
//  CachedImageView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-29.
//

import Nuke
import NukeUI
import SwiftUI

struct CachedImageView: View {
    
    enum AspectRatio { case fit, fill }
    
    let url: String?
    var fallbackSystemImageName = "photo"
    var useCache = true // Default
    var ratio: AspectRatio = .fit
    
    var body: some View {
        LazyImage(url: URL(string: url ?? "")) { state in
            GeometryReader { geo in
                ZStack {
                    if let image = state.image {
                        image.resizable()
                            .aspectRatio(contentMode: ratio == .fit ? .fit : .fill)
                    } else if state.error != nil {
                        Image(systemName: fallbackSystemImageName).resizable()
                            .aspectRatio(contentMode: ratio == .fit ? .fit : .fill)
                            .padding(geo.size.height / 5)
                    } else {
                        ProgressView()
                    }
                }
                .fullWidthAndHeight()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .pipeline(useCache ? ImagePipeline(configuration: .withDataCache) : ImagePipeline.shared)
    }
}

@available(watchOS 10, *)
#Preview(traits: .sizeThatFitsLayout){
    CachedImageView(url: "https://i1.sndcdn.com/artworks-P5t8zt92gBJyn3Ng-9YMhCg-t500x500.jpg")
        .frame(width: 100, height: 100)
}
