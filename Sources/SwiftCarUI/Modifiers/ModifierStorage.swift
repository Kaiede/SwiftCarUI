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

enum ModifierStorageKey: Int {
    case publisherCollection
    case task

    // Core Data
    case fetchController
    case fetchDelegate
    case contentFactory

    // Now Playing
    case nowPlayingObserver
}

protocol DefaultInitializable {
    init()
}

extension Set: DefaultInitializable {}

protocol StorageContainer: AnyObject {
    var userInfo: Any? { get set }
}

extension CPTemplate: StorageContainer {}
extension CPListItem: StorageContainer {}

extension StorageContainer {
    var storage: [ModifierStorageKey:Any] {
        get {
            if let storage = self.userInfo as? [ModifierStorageKey:Any] {
                return storage
            }

            let storage: [ModifierStorageKey:Any] = [:]
            self.userInfo = storage
            return storage
        }
        set {
            self.userInfo = newValue
        }
    }

    fileprivate func ensureStorage<T>(for key: ModifierStorageKey) -> T
    where T: DefaultInitializable {
        if let storedValue = self.storage[key] as? T {
            return storedValue
        }

        let newValue = T()
        self.storage[key] = newValue
        return newValue
    }
}

extension StorageContainer {
    var publisherCollection: Set<AnyCancellable> {
        get {
            return ensureStorage(for: .publisherCollection)
        }
        set {
            self.storage[.publisherCollection] = newValue
        }
    }

    var displayTask: (() async -> Void)? {
        get {
            return storage[.task] as? (() async -> Void)
        }
        set {
            storage[.task] = newValue
        }
    }
}

extension StorageContainer {
    func willDisplayTemplate() {
        Task {
            await displayTask?()
        }
    }
}

extension CPListTemplate {
    func willDisplayTemplate() {
        Task {
            await displayTask?()
            for section in sections {
                for item in section.items.compactMap({ $0 as? StorageContainer }) {
                    await item.displayTask?()
                }
            }
        }
    }
}

extension CPNowPlayingTemplate {
    var templateObserver: NowPlayingObserver {
        get {
            return ensureStorage(for: .nowPlayingObserver)
        }
        set {
            self.storage[.nowPlayingObserver] = newValue
        }
    }
}

#endif
