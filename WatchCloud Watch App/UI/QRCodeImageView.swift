//
//  QRCodeImageView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-21.
//

import QRCode
import SwiftUI

struct QRCodeImageView: View {
    
    let url: String
    
    var body: some View {
        Image(uiImage: qrCode)
            .resizable()
            .interpolation(.none)
            .scaledToFit()
    }
    
    var qrCode: UIImage {
        let qr = QRCode.Document(utf8String: url, errorCorrection: .high)
        qr.design.shape.eye = QRCode.EyeShape.RoundedOuter()
        qr.design.style.background = QRCode.FillStyle.Solid(UIColor.black.cgColor)
        qr.design.style.onPixels = QRCode.FillStyle.Solid(UIColor(Color.scOrange).cgColor)
        return qr.uiImage(CGSize(width: 1000, height: 1000))!
    }
}

@available(watchOS 10, *)
#Preview(traits: .sizeThatFitsLayout) {
    QRCodeImageView(url: "https://soundcloud.com")
        .frame(width: 200, height: 200)
}
