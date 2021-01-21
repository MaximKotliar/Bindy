[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/vsouza/awesome-ios)
[![Build status][image-1]][1]
[![Version][image-2]][2]
[![License][image-3]][3]
[![Platform][image-4]][4]

# Bindy
Just a simple bindings.

## Installation

Add
`pod 'Bindy'`

to your podfile, and run
`pod install`

## Usage
For now, Bindy has a couple of basic types

* Signal - allows triggering a callback when some signal received.
* Observable - allows observing changing of value.
* ObservableArray - conforms to MutableCollection protocol, so you can work with it like with a regular array: subscript index, replace objects, map, enumerate, etc... Also, ObservableArray has `updates` signal, which will notify you about any changes in the array, such as insert, replace, delete.

### Observables Sample (updated with property wrappers)

```swift
@Observable var firstname = "Salvador"
@Observable var age = 54

func setupBindings() {
    $age.bind(self) { [unowned self] newAge in
            print("Happy \(newAge) birthday, \(firstname)")
    }
    age = 55
}
```

Don't forget always use `[unowned owner]` in closure to prevent the retain cycle.

### Signal and Array Sample

```swift
let messages: ObservableArray<Message> = []
let newMessage = Signal<Message>()
    
func setupBindings() {
    newMessage.bind(self) { [unowned self] message in
            self.messages.append(message)
    }
    
    messages.updates.bind(self) { [unowned tableView] updates in
            self.tableView.pefrom(updates: updates)     
       }
}
       
func handleDidRecieveMessage(_ message: Message) {
     newMessage.send(message)      
    }
}
```

You don't need to remove binding manually if you don't want. When the object that you pass as owner in `bind(_ owner: AnyObject...` method deallocates, corresponding bindings will clean. However, if you want to unbind manually, just call `unbind(_ owner: AnyObject)`.
Bindy has an extension for tableView for performing updates `tableView.perform(updates:...`

Also, observables have a method `observe(_ owner: AnyObject...`, it works like `bind`, but triggers callback immediately, this may be more comfortable in some situations.

### Transformations

If you want to receive events with transformed type, you can use `transform` function on Observables like: 

```swift
let speed = Observable(20)
lazy var speedString = speed.transform { "\($0)km/h" }
    
func setupBindings() {
    speedString.observe(self) { [unowned self] speedString in
        // speedString = "20km/h"
            self.speedLabel.text = speedString
        }
}
```

### Combinations

You can combine two Observable types with `combined(with: ..., transform: ...)` function like: 

```swift
let firstname = Observable("Maxim")
let lastname = Observable("Kotliar")
let age = Observable(24)

lazy var fullName = firstname
            .combined(with: lastname) { "name: \($0) \($1)" }
            .combined(with: age) { "\($0), age: \($1)" }

func setupBindings() {
    userInfo.observe(self) { [unowned self] info in
            // info = "name: Maxim Kotliar, age:24"
            self.userInfoLabel.text = info
        }
}
```

For `Observable<Bool>` combinations Bindy have more convenient operators `&&` and `||`, so you can combine `Observable<Bool>` like regular Bool, also you can invert it with `!`:

```swift
let isPremiumPurchased = Observable(true)
let isInTrialPeriodEnded = Observable(false)
let isAdsShowForced = Observable(false)

lazy var shouldShowAds = isAdsShowForced || !isPremiumPurchased && isInTrialPeriodEnded
```

### KVO support

Bindy supports KVO, so you can create `Observable` from any KVO capable property with easy subscript syntax like:

```swift
let textField = UITextField()
let text = textField[\.text] // type will be Observable<String?>

text.observe(self) { newText in
    print(newText)
}
```

### Old value

For any `Observable` type you can receive old value in closure, just pass two parameters to binding closure, first one will be an old value, the second one – new value: 

```swift
let observableString = Observable("test")

observableString.bind(self) { oldString, newString in
    print("String changed from \(oldString) to \(newString)")
}
```

### High order functions

Bindy contains some high order functions:
- `map` - applies on any type, behavior similar to a swift map.
- `flatMap` - applies on Observable with optional type, returns Signal with non-optional type.
- `compactMap` - applies on Observable with Collection inside, behavior similar to a swift version of the function.
- `reduce` - applies on Observable with Collection inside, behavior similar to a swift version of the function.
- `filter` - applies on Observable with Collection inside, behavior similar to a swift version of the function.

[1]:    https://travis-ci.org/MaximKotliar/Bindy
[2]:    http://cocoapods.org/pods/Bindy
[3]:    http://cocoapods.org/pods/Bindy
[4]:    http://cocoapods.org/pods/Bindy

[image-1]:    https://img.shields.io/travis/MaximKotliar/Bindy/master.svg?style=flat-square
[image-2]:    https://img.shields.io/cocoapods/v/Bindy.svg?style=flat-square
[image-3]:    https://img.shields.io/cocoapods/l/Bindy.svg?style=flat-square
[image-4]:    https://img.shields.io/cocoapods/p/Bindy.svg?style=flat-square
