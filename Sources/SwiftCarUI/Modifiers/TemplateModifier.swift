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

import Foundation

public protocol TemplateModifier {
    associatedtype Template: AnyObject
    func mutate(template: Template) throws
}

extension TemplateModifier {
    /// Used to "box" the protocol and enable type erasure
    func mutatePossible<T>(template: T) throws
    where T: AnyObject {
        if let template = template as? Template {
            try mutate(template: template)
        }
    }
}

public struct ModifiedCarView<Content, Modifier>: CarView, TemplateModifier
where Content: CarView, Modifier: TemplateModifier {
    private let content: Content
    private let modifier: Modifier

    internal init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }

    public var body: Content {
        content
    }

    public func mutate(template: Modifier.Template) throws {
        try modifier.mutate(template: template)
    }
}
