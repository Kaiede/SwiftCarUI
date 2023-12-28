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
import Combine
import Foundation

struct ListItemUpdateModifier<P>: TemplateModifier where P: Publisher, P.Failure == Never {
    private let publisher: P
    private let handler: (P.Output, ListItemUpdater) -> ()

    init(publisher: P, handler: @escaping (P.Output, ListItemUpdater) -> ()) {
        self.publisher = publisher
        self.handler = handler
    }

    func mutate(template: CPListItem) throws {
        let wrapper = ListItemUpdateWrapper(template)
        template.publisherCollection.insert(
            publisher.sink(receiveValue: { element in
                handler(element, wrapper)
            })
        )
    }
}

public extension CarView {
    func updateListItem<P>(
        on publisher: P,
        perform handler: @escaping (P.Output, ListItemUpdater) -> Void
    ) -> some CarView
    where P: Publisher, P.Failure == Never {
        ModifiedCarView(
            content: self,
            modifier: ListItemUpdateModifier(publisher: publisher, handler: handler)
        )
    }

    func listItemTask(
        perform handler: @escaping (ListItemUpdater) async -> Void
    ) -> some CarView {
        ModifiedCarView(
            content: self,
            modifier: TaskModifier(converter: { ListItemUpdateWrapper($0) }, handler: handler)
        )
    }
}

public protocol ListItemUpdater {
    func setText(_ text: String)
    func setDetailText(_ detailText: String?)
    func setImage(_ image: UIImage?)
    func setAccessoryImage(_ image: UIImage?)
    func setAccessoryType(_ type: CPListItemAccessoryType)
}

fileprivate struct ListItemUpdateWrapper: ListItemUpdater {
    private let listItem: CPListItem

    init(_ listItem: CPListItem) {
        self.listItem = listItem
    }

    func setText(_ text: String) {
        listItem.setText(text)
    }

    func setDetailText(_ detailText: String?) {
        listItem.setDetailText(detailText)
    }

    func setImage(_ image: UIImage?) {
        listItem.setImage(image)
    }

    func setAccessoryImage(_ image: UIImage?) {
        listItem.setAccessoryImage(image)
    }

    func setAccessoryType(_ type: CPListItemAccessoryType) {
        listItem.accessoryType = type
    }
}

#endif
