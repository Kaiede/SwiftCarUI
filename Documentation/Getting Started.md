#  Getting Started

## Configuring the CarPlayHost

Configuring the host happens when you get called in your CarPlay delegate, and a basic delegate looks like this:

```swift
final class CarPlaySceneDelegate: NSObject, CPTemplateApplicationSceneDelegate {
    private var host: CarPlayHost?

    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        /* Do your initialization here */
        
        /* If you are using CoreData backed components, you need to pass in your view context here as well */
        host = CarPlayHost(scene: templateApplicationScene, controller: interfaceController) {
            MyRootCarView()
        }
    }
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene, 
        didDisconnectInterfaceController interfaceController: CPInterfaceController
    ) {
        /* Do your teardown here */
        host = nil
    }
}
```

The CarPlayHost takes in your CarPlay scene and controller to make it available to your view hierarchy, as well as
your NSManagedObjectContext if you are going to be using CoreData with things like `DataList`. In this example,
`MyRootCarView()` is the view that will be set as the root CarPlay template for your application. For common situations,
this is expected to be something like a `TabBar` or `List` of some kind.
