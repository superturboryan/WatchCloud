//
//  ImagePipeline.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-11-23.
//

import Nuke
import UIKit

extension ImagePipeline {
    func loadImage(with url: URL) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            loadImage(with: url) { result in
                switch result {
                case .success(let imageResponse):
                    continuation.resume(returning: imageResponse.image)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
