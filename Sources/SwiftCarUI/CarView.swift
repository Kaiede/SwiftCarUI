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

public protocol CarView {
    associatedtype Body: CarView
    var body: Self.Body { get }
}

internal extension CarView {
    func makeCollection() -> [any CarView] {
        if let collection = self as? CarViewCollection {
            return collection.children
        } else if self is EmptyCarView {
            return []
        } else {
            return [self]
        }
    }
}

extension Never: CarView {
    public var body: Never { fatalError() }
}

internal protocol CarViewCollection {
    var children: [any CarView] { get }
}

internal protocol CPTemplateRepresentable {
    func makeTemplate<T>(_ type: T.Type) throws -> T
}

func distillTemplate<T, V>(_ type: T.Type, for view: V) throws -> T
where V: CarView, T: AnyObject {
    if let representable = view as? CPTemplateRepresentable {
        let template = try representable.makeTemplate(type)
        return template
    } else if V.Body.self == Never.self {
        fatalError("\(V.self) has no body, but cannot be made into a CarPlay Template.")
    }

    let body = view.body
    let template = try distillTemplate(type, for: body)
    if let modifier = view as? any TemplateModifier {
        try modifier.mutatePossible(template: template)
    }
    return template
}

internal protocol LabelRepresentable {
    var labelTitle: String { get }

    var labelImage: UIImage? { get }
    var labelImageSymbol: String? { get }
    var labelImageBuiltin: Image.NowPlayingImage? { get }
}

func distillLabelRepresentable<V>(for view: V) -> LabelRepresentable
where V: CarView {
    if let representable = view as? LabelRepresentable {
        return representable
    } else if V.Body.self == Never.self {
        fatalError("\(V.self) has no body, but cannot be made into a label.")
    }

    let body = view.body
    return distillLabelRepresentable(for: body)
}

#endif
