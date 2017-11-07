[![Build status](https://img.shields.io/travis/MaximKotliar/Bindy/master.svg?style=flat-square)](https://travis-ci.org/MaximKotliar/Bindy)
[![Version](https://img.shields.io/cocoapods/v/Bindy.svg?style=flat-square)](http://cocoapods.org/pods/Bindy)
[![License](https://img.shields.io/cocoapods/l/Bindy.svg?style=flat-square)](http://cocoapods.org/pods/Bindy)
[![Platform](https://img.shields.io/cocoapods/p/Bindy.svg?style=flat-square)](http://cocoapods.org/pods/Bindy)

# Bindy
Just a simple bindings.

## Installation
Add

`pod 'Bindy'`

to your podfile, and run
`pod install`

## Usage
For now, bindy has a couple basic types

* Signal - allows to trigger callback when some signal recieved.
* Observable - allows to observe changing of value.
* OptionalObservable - same as Observable, but with optional value.
* ObservableArray - conforms to MutableCollection protocol, so you can work with it like with regular array: subscript index, replace objects, map, enumerate, etc... Also, ObservableArray has ```updates``` signal, which will notify you about any changes in array, such as insert, replace, delete.

### Observables Sample

```swift
var firstname = Observable("Salvador")
var age = Observable(54)

func setupBindings() {
	age.bind(self) { [unowned self] newAge in
            print("Happy \(newAge) birthday, \(self.firstname.value)")
	}
}
```

Don't forget always use `[unowned owner]` in closure to prevent retain cycle.

### Signal and Array Sample

```swift
var messages = ObservableArray<Message>()
var newMessage = Signal<Message>()
    
func setupBindings() {
    newMessage.bind(self) { [unowned self] message in
            self.messages.append(message)
	}
	
    messages.updates.bind(self) { [unowned tableView] updates in
            tableView.beginUpdates()
            updates.forEach { update in
                let indexPaths = update.indexes.map { IndexPath(row: $0, section: 0) }
                switch update.event {
                case .insert:
                    tableView.insertRows(at: indexPaths, with: .bottom)
                case .replace:
                    tableView.reloadRows(at: indexPaths, with: .fade)
                case .delete:
                    tableView.deleteRows(at: indexPaths, with: .left)
                }
            }
            tableView.endUpdates()
       }
}
```

You don't need remove binding manually if you don't want it, when object that you pass as owner in ```bind(_ owner: AnyObject...``` metod deallocates, corresponding bindings will clean. However, if you want to unbind manually, just call ```unbind(_ owner: AnyObject)```.

Also, observables has method ```observe(_ owner: AnyObject...```, it works like `bind`, but triggers callback immediately, this may be more comfortable in some situations.

