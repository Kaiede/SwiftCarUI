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

import CarPlay
import Foundation

struct TabDetailModifier: TemplateModifier {
    private let title: String?
    private let systemName: String?
    private let image: UIImage?

    init(title: String, image: UIImage) {
        self.title = title
        self.image = image
        self.systemName = nil
    }

    init(title: String, systemName: String) {
        self.title = title
        self.systemName = systemName
        self.image = nil
    }

    func mutate(template: CPTemplate) {
        template.tabTitle = title
        if let image = image {
            template.tabImage = image
        } else if let systemName = systemName {
            template.tabImage = UIImage(systemName: systemName)
        }
    }
}

struct TabSystemItemModifier: TemplateModifier {
    private let systemItem: UITabBarItem.SystemItem

    init(systemItem: UITabBarItem.SystemItem) {
        self.systemItem = systemItem
    }

    func mutate(template: CPTemplate) throws {
        template.tabSystemItem = systemItem
    }
}

public extension CarView {
    func tabDetails(title: String, systemName: String) -> some CarView {
        ModifiedCarView(
            content: self,
            modifier: TabDetailModifier(title: title, systemName: systemName)
        )
    }

    func tabDetails(title: String, image: UIImage) -> some CarView {
        ModifiedCarView(
            content: self,
            modifier: TabDetailModifier(title: title, image: image)
        )
    }

    func tabDetails(systemItem: UITabBarItem.SystemItem) -> some CarView {
        ModifiedCarView(
            content: self,
            modifier: TabSystemItemModifier(systemItem: systemItem)
        )
    }
}

#endif
