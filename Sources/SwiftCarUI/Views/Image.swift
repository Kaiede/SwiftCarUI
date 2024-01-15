/*
SwiftCarUI

Copyright (c) 2023 Adam Thayer
Licensed under the MIT license, as follows:

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.)
*/

#if canImport(UIKit) && canImport(CarPlay)

import Foundation
import UIKit

public struct Image: CarView {
    private let kind: Kind

    @Environment(\.traitCollection) private var traits

    public init(systemName: String) {
        self.kind = .systemName(systemName)
    }

    public init(image: UIImage) {
        self.kind = .image(image)
    }

    public init(size: CGSize, renderer: @escaping (UIGraphicsImageRendererContext) -> Void) {
        self.kind = .renderer(size, renderer)
    }

    public init(nowPlaying: NowPlayingImage) {
        self.kind = .nowPlayingBuiltin(nowPlaying)
    }

    public var body: Never { fatalError() }
}

extension Image {
    public enum NowPlayingImage {
        case addToLibrary
        case more
        case playbackRate
        case `repeat`
        case shuffle
    }

    fileprivate enum Kind {
        case image(UIImage)
        case systemName(String)
        case nowPlayingBuiltin(NowPlayingImage)
        case renderer(CGSize, (UIGraphicsImageRendererContext) -> Void)
    }
}

extension Image {
    func renderSingle(size: CGSize, actions: (UIGraphicsImageRendererContext) -> Void) -> UIImage {
        return renderDual(size: size, lightActions: actions, darkActions: actions)
    }

    func renderDual(
        size: CGSize,
        lightActions: (UIGraphicsImageRendererContext) -> Void,
        darkActions: (UIGraphicsImageRendererContext) -> Void
    ) -> UIImage {
        let (lightTraits, darkTraits) = mutateTraits()
        let lightFormat = UIGraphicsImageRendererFormat(for: lightTraits)
        let darkFormat = UIGraphicsImageRendererFormat(for: darkTraits)
        let lightRenderer = UIGraphicsImageRenderer(size: size, format: lightFormat)
        let darkRenderer = UIGraphicsImageRenderer(size: size, format: darkFormat)

        let lightImage = lightRenderer.image(actions: lightActions)
        let darkImage = darkRenderer.image(actions: darkActions)
        lightImage.imageAsset?.register(darkImage, with: UITraitCollection(userInterfaceStyle: .dark))
        return lightImage
    }

    func mutateTraits() -> (light: UITraitCollection, dark: UITraitCollection) {
        if #available(iOS 17.0, *) {
            let lightTraits = traits.modifyingTraits { traits in
                traits.userInterfaceStyle = .light
            }
            let darkTraits = traits.modifyingTraits { traits in
                traits.userInterfaceStyle = .dark
            }
            return (lightTraits, darkTraits)
        } else {
            let lightTraits = UITraitCollection(traitsFrom: [
                traits, 
                UITraitCollection(userInterfaceStyle: .light)
            ])
            let darkTraits = UITraitCollection(traitsFrom: [
                traits,
                UITraitCollection(userInterfaceStyle: .dark)
            ])
            return (lightTraits, darkTraits)
        }
    }
}

extension Image: LabelRepresentable {
    var labelTitle: String { "Image" }

    var labelImage: UIImage? {
        switch kind {
        case .image(let image): return image
        case .systemName(let systemName): return UIImage(systemName: systemName)
        case .nowPlayingBuiltin(_): return nil
        case .renderer(let size, let actions): return renderSingle(size: size, actions: actions)
        }
    }

    var labelImageSymbol: String? {
        switch kind {
        case .image(_): return nil
        case .systemName(let systemName): return systemName
        case .nowPlayingBuiltin(_): return nil
        case .renderer(_, _): return nil
        }
    }

    var labelImageBuiltin: NowPlayingImage? {
        switch kind {
        case .image(_): return nil
        case .systemName(_): return nil
        case .nowPlayingBuiltin(let image): return image
        case .renderer(_, _): return nil
        }
    }
}

#endif
