# Rosetta
The Rosetta Stone is a granodiorite stele inscribed with a decree issued at Memphis in 196 BC. It provided the key to the modern understanding of Egyptian hieroglyphs. [wiki](http://en.wikipedia.org/wiki/Rosetta_Stone)  
Just like the Rosetta Stone made translation of Egyptian hieroglyphs possible, this library is intended to make **parsing JSON to Swift** objects and back easy and safe.

## Installation

Rosetta is still in development itself and requires **Swift 1.2** shipped with Xcode 6.3 beta.

### CocoaPods

[CocoaPods 0.36](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/) or newer required.  
```
pod 'Rosetta'
```

### Manual

Clone this repo. Add the Rosetta project file to your workspace. Then in your target's **Build Phases** in **Target Dependencies** add `Rosetta-iOS` or `Rosetta-OSX` framework. Then just add `import Rosetta` in you code and you should be good to go.

## Features

* Parsing `JSON` to `Swift types` (Both **classes** and **structures** are supported)
* Parsing back to `JSON` (if you can parse `JSON` to a `Swift type`, you can always get a `JSON` back)
* Type validation
* Type conversion (e.g. `Strings` in `JSON` can be bridged to `NSURL`)
* Value validation
* **Required** and **optional** fields support
* Concise syntax with advanced features opt-in
* Debug logs

## Usage (in a nutshell)

This is just a brief overview of how `Rosetta` works, but it should give you the idea. Please refer to [guide](https://github.com/bartekchlebek/Rosetta/blob/documentation/GUIDE.md) for thorough documentation.

### JSON Decoding/Encoding

The easiest way to use `Rosetta` is to have your type implement `JSONConvertible` protocol
```swift
struct User: JSONConvertible {
  var ID: String?
  var name: String?
  var age: Int?
  var website: NSURL?
  var friends: [User]?
  var family: [String : User]?
  
  init() {
    
  }
  
  static func map(inout object: User, json: Rosetta) {
    object.ID       <- json["uniqueID"] // Map required properties with <-
    object.name     <~ json["name"] // Map optional properties with <~
    object.age      <~ json["age"] § {$0 > 0} // Add validation closure after § operator (age > 0)
    // Types not conforming to Bridgeable protocol (like NSURL here) need to have bridging code after ~ operator
    object.website  <~ json["website_url"] ~ BridgeString(
      decoder: {NSURL(string: $0 as String)}, // convert NSString from json to NSURL
      encoder: {$0.absoluteString} // convert NSURL from Person to NSString for JSON
    )
    object.friends  <~ json["friends"] // Automaticaly mapped arrays
    object.family   <~ json["family"] // Automaticaly mapped dictionaries
  }
}
```
and then you can convert `JSON` to `Person` with
```swift
let user = Rosetta().decode(jsonDataOrString) as User?
```
and `Person` to `JSON` with
```swift
let jsonData = Rosetta().encode(user) as NSData?
let jsonString = Rosetta().encode(user) as String?
```

For details on how `decoding` and `encoding` work, please refer to [guide](https://github.com/bartekchlebek/Rosetta/blob/documentation/GUIDE.md#json-decodin)

### Required fields

If you want a certain field to be treated as required, map it with a `<-` operator:
```swift
object.name <- json["name"]
```
`Decoding` / `encoding` will fail if such value is missing, or does not pass conversion or validation.

### Optional fields

If you want to treat a certain field as optional, map it with a `<~` operator:
```swift
object.name <~ json["name"]
```
If this field is missing, or does not pass conversion or validation, `decoding` / `encoding` will not fail entirely, but will skip this field and move on.

### Type conversion

You can convert e.g. a `String` from `JSON` to `NSURL` using the `~` operator and a `bridge`
```swift
object.url <~ json["URL"] ~ BridgeString(
  decoder: {NSURL(string: $0 as String)},
  encoder: {$0.absoluteString}
)
```
The `decoder` closure, takes an `NSString` from a `JSON` and converts it into an `NSURL`.  
The `encoder` closure, works the other way around, returning a `String` representation of an `NSURL`.

To make it more concise you can return the `bridge` from a function:
```swift
func NSURLBridge() -> Bridge<NSURL, NSString> {
  return BridgeString(
    decoder: {NSURL(string: $0 as String)},
    encoder: {$0.absoluteString}
  )
}
```
and then map:
```swift
object.url <~ json["URL"] ~ NSURLBridge()
```
`NSURLBridge()` is in fact already built-in to `Rosetta`, but you'll likely make other bridges of your own.

Bridging is a pretty big but essential part of `Rosetta`. It's explained in-depth in [guide](https://github.com/bartekchlebek/Rosetta/blob/documentation/GUIDE.md#bridging-)

### Value validation

You can validate the value using a `§` operator (`⌥6`) followed by a  
`(<SwiftPropertyType>) -> (BOOL)` closure:
```swift
object.age <~ json["age"] § {$0 > 0}
```
So in this example, `age` (that's passed to the validation closure under `$0`) has to be greater than `0`.

More about validation in [guide](https://github.com/bartekchlebek/Rosetta/blob/documentation/GUIDE.md#validation-)

### Debug logs
`Rosetta` can print debug logs:
```
Rosetta
ViewController.swift:904 handleResult()
JSON String: {"age":0,"website":"ftp://nonono.bad"}
Error: Value Missing for key-path: name
Error: Validation Failed for key-path: age
Warning: Validation Failed for key-path: website
```
Logs are disabled by default. You can enable them by setting `.logLevel` property:
```swift
let rosetta = Rosetta()
rosetta.logLevel = .Errors
```
or
```swift
rosetta.logLevel = .Verbose
```
You can also change the **log output** (if `println()` does not suit you) and **customize** the log format. All that is described in-depth in [guide](https://github.com/bartekchlebek/Rosetta/blob/documentation/GUIDE.md#logs)

## Examples

```swift
struct CustomConvertibleType: JSONConvertible {
  var someValue: Double?
  
  init() {
    
  }
  
  static func map(inout object: CustomConvertibleType, json: Rosetta) {
    object.someValue <- json["value"]
  }
}
enum CustomBridgeableType: Int, Bridgeable {
  case One = 1, Two, Three, Four
  
  static func bridge() -> Bridge<CustomBridgeableType, NSNumber> {
    return BridgeNumber(
      decoder: {CustomBridgeableType(rawValue: $0.integerValue)},
      encoder: {$0.rawValue}
    )
  }
}
struct YourCustomType: JSONConvertible {
  var value1: Int?
  var value2: CustomBridgeableType?
  var value3: CustomConvertibleType?
  var value4: NSURL?
  
  var requiredValue1: String = ""
  var requiredValue2: String!
  var requiredValue3: String?
  
  var validatedValue1: String?
  var validatedValue2: CustomBridgeableType?
  var validatedValue3: CustomConvertibleType?
  var validatedValue4: NSURL?
  
  var array1: [Int]?
  var array2: [CustomBridgeableType]?
  var array3: [CustomConvertibleType]?
  var array4: [NSURL]?
  
  var dictionary1: [String : Int]?
  var dictionary2: [String : CustomBridgeableType]?
  var dictionary3: [String : CustomConvertibleType]?
  var dictionary4: [String : NSURL]?
  
  init() {
    
  }
  
  static func map(inout object: YourCustomType, json: Rosetta) {
    object.value1 <~ json["value1"]
    object.value2 <~ json["value2"]
    object.value2 <~ json["value3"]
    object.value4 <~ json["value4"] ~ BridgeString(
      decoder: {NSURL(string: $0 as String)},
      encoder: {$0.absoluteString}
    )
    
    // Bridging placed in a constant just to reuse
    let urlBridge = BridgeString(
      decoder: {NSURL(string: $0 as String)},
      encoder: {$0.absoluteString}
    )
    
    object.requiredValue1 <- json["required1"]
    object.requiredValue2 <- json["required2"]
    object.requiredValue3 <- json["required3"]
    
    object.validatedValue1 <~ json["validated1"] § {$0.hasPrefix("requiredPrefix")}
    object.validatedValue2 <~ json["validated2"] § {$0 == .One || $0 == .Three}
    object.validatedValue3 <~ json["validated3"] § {$0.someValue > 10.0}
    object.validatedValue4 <~ json["validated4"] ~ urlBridge § {$0.scheme == "https"}
    
    object.array1 <~ json["array1"]
    object.array2 <~ json["array2"]
    object.array3 <~ json["array3"]
    object.array4 <~ json["array4"] ~ BridgeArray(urlBridge)
    
    object.dictionary1 <~ json["dictionary1"]
    object.dictionary2 <~ json["dictionary2"]
    object.dictionary3 <~ json["dictionary3"]
    object.dictionary4 <~ json["dictionary4"] ~ BridgeObject(urlBridge)
  }
}
```

## License
Rosetta is available under the MIT license. See the [LICENSE](https://github.com/bartekchlebek/Rosetta/blob/master/LICENSE) file for more info.
