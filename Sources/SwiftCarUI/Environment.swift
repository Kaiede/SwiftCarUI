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

@propertyWrapper
public struct Environment<Value> {
    private let keyPath: KeyPath<EnvironmentValues, Value>

    public var wrappedValue: Value {
        get { EnvironmentValues.active[keyPath: keyPath] }
    }

    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }
}


public protocol EnvironmentKey {
    /// The associated type representing the type of the environment key's
    /// value.
    associatedtype Value

    /// The default value for the environment key.
    static var defaultValue: Self.Value { get }
}

public protocol CarTemplateApplicationScene {
    @available(iOS 15.4, *)
    var contentStyle: UIUserInterfaceStyle { get }
}

extension CPTemplateApplicationScene: CarTemplateApplicationScene {}

public struct EnvironmentValues {
    static var activeList: [EnvironmentValues] = [EnvironmentValues()]
    static var active: EnvironmentValues {
        get { activeList.last! }
        set { activeList[activeList.count - 1] = newValue }
    }

    private let scene: CarTemplateApplicationScene?
    private let objectContext: NSManagedObjectContext?

    private var values: [ObjectIdentifier:Any] = [:]

    internal init() {
        self.scene = nil
        self.objectContext = nil
    }

    internal init(scene: CarTemplateApplicationScene, objectContext: NSManagedObjectContext? = nil) {
        self.scene = scene
        self.objectContext = objectContext
    }

    public subscript<K>(key: K.Type) -> K.Value where K : EnvironmentKey {
        get {
            let identifier = ObjectIdentifier(key)
            guard let result = values[identifier] else {
                return K.defaultValue
            }

            return result as! K.Value
        }
        set {
            let identifier = ObjectIdentifier(key)
            values[identifier] = newValue
        }
    }

    func makeActive() {
        EnvironmentValues.activeList.append(self)
    }

    func resignActive() {
        assert(EnvironmentValues.activeList.count > 1)
        EnvironmentValues.activeList.removeLast()
    }

    public var managedObjectContext: NSManagedObjectContext {
        get {
            guard let objectContext = objectContext else {
                fatalError("managedObjectContext not configured for CarPlay")
            }

            return objectContext
        }
    }

    public var maximumListSectionCount: Int {
        get { CPListTemplate.maximumSectionCount }
    }

    public var maximumListItemCount: Int {
        get { CPListTemplate.maximumItemCount }
    }

    public var maximumListItemImageSize: CGSize {
        get { CPListItem.maximumImageSize }
    }

    public var maximumListImageRowItemImageSize: CGSize {
        get { CPListImageRowItem.maximumImageSize }
    }

    @available(iOS 15.4, *)
    public var contentStyle: UIUserInterfaceStyle {
        get { scene?.contentStyle ?? .unspecified }
    }
}

#endif
