#  Lists

## Examples

A list can use `ImageButtons` and `Button` to create rows in the list. By using destination actions with these types,
navigation occurs when the user selects an item. Single actions can be used to modify application state without
navigating.

```swift
struct MyLibraryCarView: CarView {
    var body: some CarView {
        List(title: "Library") {
            ImageButtons(title: "Recently Added", destination: recentsDestination) {
                Image(/* ... */)
                Image(/* ... */)
                Image(/* ... */)
                Image(/* ... */)
                Image(/* ... */)
            }
            Button(destination: { ArtistsCarView(/* ... */) }, label: { Label("Artists", systemName: "mic.fill") })
            Button(destination: { AlbumsCarView(/* ... */) }, label: { Label("Albums", systemName: "") })
        }
    }
    
    func recentsDestination(_ item: ImageButtons.PressedButton) -> some CarView {
        switch item {
        case .row: RecentlyAddedCarView(/* ... */)
        case .item(let index): AlbumCarView(/* ... */)
        }
    }
}

```

## Notes

### List Item Performance

When displaying list items, you can provide handlers to update the list item asynchronously. However, be aware that
even when using something like CoreData fetches, this will fire off a task for every list item that is in the list
when the view is pushed onto CarPlay's navigation stack. Unlike with UIKit/SwiftUI, list items are not virtualized in
CarPlay. Heavy work being done in the initial set of items can produce a fair bit of latency at the moment as the items
are currently iterated rather than spawned using a task group.
