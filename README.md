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
let firstname = Observable("Salvador")
let age = Observable(54)

func setupBindings() {
	age.bind(self) { [unowned self] newAge in
            print("Happy \(newAge) birthday, \(self.firstname.value)")
	}
	age.value = 55
}
```

Don't forget always use `[unowned owner]` in closure to prevent retain cycle.

### Signal and Array Sample

```swift
let messages = ObservableArray<Message>()
let newMessage = Signal<Message>()
    
func setupBindings() {
    newMessage.bind(self) { [unowned self] message in
            self.messages.append(message)
	}
	
    messages.updates.bind(self) { [unowned tableView] updates in
    	    self.tableView.pefrom(updates: updates)     
       }
       
func handleDidRecieveMessage(_ message: Message) {
	 newMessage.send(message)      
    }
}
```

You don't need remove binding manually if you don't want it, when object that you pass as owner in ```bind(_ owner: AnyObject...``` metod deallocates, corresponding bindings will clean. However, if you want to unbind manually, just call ```unbind(_ owner: AnyObject)```.
Bindy have an extension for tableView for performing updates ```tableView.perform(updates:...```

Also, observables has method ```observe(_ owner: AnyObject...```, it works like `bind`, but triggers callback immediately, this may be more comfortable in some situations.

### Transformations

If you want to recieve events with transformed type, you can use ```transform``` function on Observables like: 

```swift
let speed = Observable(20)
lazy var speedString = {
        speed.transform { "\($0)km/h" }
}()
    
func setupBindings() {
	speedString.observe(self) { [unowned self] speedString in
	    // speedString = "20km/h"
            self.speedLabel.text = speedString
        }
}
```

### Combinations

You can combine two Observable types with ```combined(with: ..., transform: ...)``` function like: 

```swift
let firstname = Observable("Maxim")
let lastname = Observable("Kotliar")
let age = Observable(24)

lazy var fullname = {
        return firstname
            .combined(with: lastname) { "name: \($0) \($1)" }
            .combined(with: age) { "\($0), age: \($1)" }
}()

func setupBindings() {
	userInfo.observe(self) { [unowned self] info in
            // info = "name: Maxim Kotliar, age:24"
            self.userInfoLabel.text = info
        }
}
```

For Observable<Bool> combinations Bindy have more convenient operators ```&&``` and ```||```, so you can combine Observable<Bool> like regular Bool, also you can invert it with ```!```:
	
```swift
let isPremiumPurchased = Observable(true)
let isInTrialPeriodEnded = Observable(false)
let isAdsShowForced = Observable(false)

lazy var shouldShowAds = {
        return isAdsShowForced || !isPremiumPurchased && isInTrialPeriodEnded
}()
```
