//
//  View.swift
//  SC Demo
//
//  Created by Ryan Forsyth on 2023-08-13.
//

import SwiftUI

// MARK: - Frame helpers
extension View {
    func fullWidth(_ alignment: Alignment = .center) -> some View {
        self.frame(minWidth: 0, maxWidth: .infinity, alignment: alignment)
    }
    
    func fullWidthAndHeight() -> some View {
        self.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
    
    func size(_ size: CGSize) -> some View {
        self.frame(width: size.width, height: size.height)
    }
    
    func square(_ size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }

    @ViewBuilder
    func symbolReplaceEffect(_ speed: Double = 1.0) -> some View {
        if #available(watchOS 10.0, iOS 17.0, *) {
            self.contentTransition(.symbolEffect(.replace, options: .speed(speed)))
        } else {
            self
        }
    }
    
    func onVisibilityChange(_ perform: @escaping (Bool) -> Void) -> some View {
        self.onAppear {
            perform(true)
        }.onDisappear {
            perform(false)
        }
    }
}

extension List {
    
    @ViewBuilder
    func sectionSpacing(_ spacing: CGFloat) -> some View {
        if #available(watchOS 10, iOS 17, *) {
            self.listSectionSpacing(spacing)
        } else {
            self
        }
    }
}

// MARK: - LazyVStack header + footer
func sectionHeaderView(_ title: String) -> some View {
    Text(verbatim: title.uppercased())
        .font(.system(size: 12))
        .foregroundColor(.secondary)
        .padding(.leading)
        .padding(.top, 6)
        .fullWidth(.leading)
}

func sectionFooterView(_ text: String) -> some View {
    Text(verbatim: text)
        .font(.footnote)
        .fontWeight(.medium)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.top, 6)
        .padding(.bottom, 12)
}
