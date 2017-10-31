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
* ObservableArray - Observable array, it conforms to MutableCollection protocol, so you can work with it like with regular array: subscript index, replace objects, map, enumerate, etc...

### Observables Sample

```
var firstname = Observable("Salvador")
var age = Observable(54)

func setupBindings() {
	age.bind(self) { [weak self] newAge in
            guard let name = self?.firstname.value else { return }
            print("Happy \(newAge) birthday, \(name)")
	}
}
```

Don't forget always use `[weak self]` in closure to prevent retain cycle

### Signal and Array Sample

```
var messages = ObservableArray<Message>()
var newMessage = Signal<Message>()
    
func setupBindings() {
    newMessage.bind(self) { [weak self] message in
            self?.messages.append(message)
	}
}
```

You don't need remove binding manually if you don't want it, when object that you pass as owner in ```bind(_ owner: AnyObject...``` metod deallocates, corresponding bindings will clean. However, if you want to unbind manually, just call ```unbind(_ owner: AnyObject)```.

Also, observables has method ```observe(_ owner: AnyObject...```, it works like `bind`, but triggers callback immediately, this may be more comfortable in some situations.

