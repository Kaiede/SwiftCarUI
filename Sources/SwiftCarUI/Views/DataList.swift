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
import CoreData
import Foundation

struct DataList<Content, Element>: CarView
where Content: CarView, Element: NSFetchRequestResult {
    typealias Factory = (Element) -> Content
    let title: String?
    let request: NSFetchRequest<Element>
    let content: Factory

    @Environment(\.managedObjectContext) private var managedObjectContext

    init(title: String?, request: NSFetchRequest<Element>, content: @escaping Factory) {
        self.title = title
        self.request = request
        self.content = content
    }

    var body: Never { fatalError() }
}

extension DataList: CPTemplateRepresentable {
    func makeTemplate<T>(_ type: T.Type) throws -> T {
        if T.self == CPListTemplate.self || T.self == CPTemplate.self {
            return try makeListTemplate() as! T
        } else {
            throw SwiftCarUIError()
        }
    }

    private func makeListTemplate() throws -> CPListTemplate {
        // Needs a managed object context...
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)


        let children = try makeChildren(controller: controller)
        let template = CPListTemplate(title: title, sections: children)

        let delegate = DataListCoreDataFetchDelegate<Content, Element>(list: template, managedObjectContext: managedObjectContext)
        controller.delegate = delegate

        template.storage[.contentFactory] = content
        template.storage[.fetchController] = controller
        template.storage[.fetchDelegate] = delegate
        return template
    }

    private func makeChildren(controller: NSFetchedResultsController<Element>) throws -> [CPListSection] {
        do {
            try controller.performFetch()
            guard let results = controller.fetchedObjects else {
                // TODO: Should report a runtime error here
                return []
            }

            let items = try results.map({ element in
                let view = content(element)
                return try distillTemplate(CPListTemplateItem.self, for: view)
            })

            return [CPListSection(items: items)]
        } catch {
            // TODO: Should report a runtime error here
            return []
        }
    }
}

fileprivate final class DataListCoreDataFetchDelegate<Content, Element>: NSObject, NSFetchedResultsControllerDelegate
where Content: CarView, Element: NSFetchRequestResult{
    weak var list: CPListTemplate?
    let managedObjectContext: NSManagedObjectContext

    init(list: CPListTemplate, managedObjectContext: NSManagedObjectContext) {
        self.list = list
        self.managedObjectContext = managedObjectContext
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        for change in diff {
            switch change {
            case .insert(offset: let offset, element: let managedItem, associatedWith: _):
                add(at: offset, element: managedItem)
                continue
            case .remove(offset: let offset, element: _, associatedWith: _):
                remove(at: offset)
                continue
            }
        }
    }

    private func add(at offset: Int, element: NSManagedObjectID) {
        guard var sections = list?.sections else {
            return
        }

        guard let section = list?.sections.first else {
            return
        }

        var items = section.items
        let item = makeItem(element: element)
        items.insert(item, at: offset)

        // Clone and re-insert modified section
        if let header = section.header {
            let newSection = CPListSection(
                items: items,
                header: header,
                headerSubtitle: section.headerSubtitle,
                headerImage: section.headerImage,
                headerButton: section.headerButton,
                sectionIndexTitle: section.sectionIndexTitle
            )
            sections[0] = newSection
        } else {
            let newSection = CPListSection(
                items: items,
                header: section.header,
                sectionIndexTitle: section.sectionIndexTitle)
            sections[0] = newSection
        }

        list?.updateSections(sections)
    }

    private func makeItem(element: NSManagedObjectID) -> CPListTemplateItem {
        guard let handler = list?.storage[.contentFactory] as? (Element) -> Content else {
            fatalError("Internal state for list item factory is invalid")
        }

        do {
            let element = managedObjectContext.object(with: element) as! Element
            let view = handler(element)
            return try distillTemplate(CPListTemplateItem.self, for: view)
        } catch {
            fatalError("Internal typing for list item factory is invalid.")
        }
    }

    private func remove(at offset: Int) {
        guard var sections = list?.sections else {
            return
        }

        guard let section = list?.sections.first else {
            return
        }

        // Remove item from section
        var items = section.items
        items.remove(at: offset)

        // Clone and re-insert section
        if let header = section.header {
            let newSection = CPListSection(
                items: items,
                header: header,
                headerSubtitle: section.headerSubtitle,
                headerImage: section.headerImage,
                headerButton: section.headerButton,
                sectionIndexTitle: section.sectionIndexTitle
            )
            sections[0] = newSection
        } else {
            let newSection = CPListSection(
                items: items,
                header: section.header,
                sectionIndexTitle: section.sectionIndexTitle)
            sections[0] = newSection
        }

        list?.updateSections(sections)
    }
}

#endif

