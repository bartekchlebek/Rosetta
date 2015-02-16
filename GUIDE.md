## Contents

- [JSON Decoding](#json-decoding)
    - [The Verbose Option](#the-verbose-option)
    - [Mappable protocol](#mappable-protocol)
    - [Creatable protocol](#creatable-protocol)
    - [JSONConvertible protocol](#jsonconvertible-protocol)
- [JSON Encoding](#json-encoding)
    - [The Verbose Option](#the-verbose-option)
    - [Mappable protocol](#mappable-protocol-1)
- [Map](#map)
    - [Required `<-`](#required-)
    - [Optional `<~`](#optional-)
    - [Bridging `~`](#bridging-)
        - [Overview](#overview)
        - [Bridges](#bridges)
        - [Implicit Bridging (structs and final classes only)](#implicit-bridging-structs-and-final-classes-only)
        - [Built-in bridgeable types](#builtin-bridgeable-types)
        - [Type conversion](#type-conversion)
        - [Bridging and JSONConvertible](#bridging-and-jsonconvertible)
        - [UnsafeBridgeArray / UnsafeBridgeObject](#unsafebridgearray-unsafebridgeobject)
            - [BridgeArray / BridgeObject](#bridgearray-bridgeobject)
            - [JSONConvertible and Bridgeable](#jsonconvertible-and-bridgeable)
        - [Bridging and classes](#bridging-and-classes)
    - [Validation `§`](#validation-)
    - [Key-paths](#keypaths)
- [Classes](#classes)
- [Logs](#logs)
    - [Log redirecting](#log-redirecting)
    - [Custom formatting](#custom-formatting)
        - [json](#json)
        - [logs](#logs)
        - [file](#file)
        - [line](#line)
        - [function](#function)
- [Thread safety](#thread-safety)
- [Caveats and best practices](#caveats-and-best-practices)

<!-- end toc 4 -->

# JSON Decoding
Rosetta's basic functionality is `JSON` decoding, that is converting an `NSData` or `String` representation of a `JSON` into a Swift `struct` or `class` object. All methods described below accept `JSON` as either `NSData` or `String` transparently, so method calls look the same no matter the `JSON` type.
## The Verbose Option
Let's look at a simple example. Say we have a `JSON` representation of a user:
```json
{  
  "name": "Bill",
  "age": 22
}
```
and want to be able to parse that into a Swift `struct`:
```swift
struct User {
  var name: String?
  var age: Int?
}
```
The most verbose way to do that is:
```swift
// assuming jsonDataOrString is either NSData or String of the example JSON
var user = User(name: nil, age: nil)
let success = Rosetta().decode(jsonDataOrString, to: &user, usingMap: {(inout object: User, json) -> () in
  object.name <~ json["name"]
  object.age  <~ json["age"]
})
```
Now that's a mouthful, but bear with me, more concise ways are just up ahead. Let's walk through this example step by step:

* a `user` instance is created
* `Rosetta().decode(to:usingMap:)` is called
	* `jsonDataOrString` is `NSData` or `String` of the `JSON`
    * `user` is passed by reference with `&user`
    * a `map` closure describing `JSON` to `Swift type` properties mapping is passed
* if parsing succeeds, `success` is set to `true` and `user` is updated with values from `JSON`
* if parsing fails, `success` is set to `false` and `user` is left **untouched**

This is the most verbose way but it does not require `User` to implement any protocols and/or allows using a custom `Map` if you need to.

## Mappable protocol
You can make decoding more concise by implementing `Mappable` protocol in `User`:
```swift
protocol Mappable {
  static func map(inout object: Self, json: Rosetta)
}
```
`User`'s implementation may look like this:
```swift
extension User: Mappable {
  static func map(inout object: User, json: Rosetta) {
    object.name <~ json["name"]
    object.age  <~ json["age"]
  }
}
```
This allows `Rosetta` to infer the mapping while decoding, and so reducing the call to:
```swift
let success = Rosetta().decode(jsonDataOrString, to: &user)
```
The behaviour is the same as with the verbose option, only that `User.map` is used implicitly. You can of course still use the verbose option with a `Mappable` type if you need to. The `map` passed explicitly will be prefered.

## Creatable protocol
Another useful protocol is `Creatable`
```swift
protocol Creatable {
  init()
}
```
It's pretty self explanatory, and the implementation for `User` with only two optional ivars may be as simple as empty:
```swift
extension User: Creatable {
  init() {
    
  }
}
```
However, this allows us to use `decode` without the need of creating a `user` instance beforehand and passing it by reference. Now you may call:
```swift
let user = Rosetta().decode(jsonDataOrString, usingMap: {(inout object: User, json) -> () in
  object.name <~ json["name"]
  object.age  <~ json["age"]
})
```
**Notice** that this time, `Rosetta().decode(usingMap:)` returns an `Optional<User>` rather than `Bool`. With this method, `.None` is returned if decoding fails and `.Some(User)` if it succeeds.

## JSONConvertible protocol
This protocol simply inherits from both `Creatable` and `Mappable` enabling the benefints of both.
```swift
protocol JSONConvertible : Creatable, Mappable {
  
}
```
So if `User` implements `JSONConvertible`, e.g.
```swift
extension User: JSONConvertible {
  init() {
    
  }
  
  static func map(inout object: User, json: Rosetta) {
    object.name <~ json["name"]
    object.age  <~ json["age"]
  }
}
```
Your `decode` call may have its simplest form:
```swift
let user: User? = Rosetta().decode(jsonDataOrString)
```
Where `map` is infered from `Mappable` protocol  
and `User` instance is created via `Creatable` protocol

# JSON Encoding
Rosetta allows you to create a `JSON` representation of Swift `structs` and `classes`. All methods described below can return `JSON` value as either `NSData` or `String`.

## The Verbose Option
Similarly to `decoding`, `encoding` also has its most basic method, which allows encoding `structs` and `classes` without the need for them to implement any protocols.  
Let's use the same example as in `decoding`, so we have a `struct`
```swift
struct User {
  var name: String?
  var age: Int?
}
```
which we want to encode into a `JSON`
```json
{  
  "name":"Bill",
  "age":22
}
```
We can achieve this with a call:
```swift
let user = User(name: "Bill", age: 22)
let jsonData: NSData? = Rosetta().encode(user, usingMap: { (inout object: User, json) -> () in
  object.name <~ json["name"]
  object.age  <~ json["age"]
})
```
or, if you want to have `JSON` as a `String` just change  
`let jsonData: NSData?` to  
`let jsonData: String?`

If `JSON` representation cannot be created, `.None` is returned.
(`Encoding` may fail for a number of reasons (missing required fields, value validation etc.) described in the `Map` section)

## Mappable protocol
You can make encoding more concise by implementing `Mappable` protocol. It's the same one as described in the `Decoding` section:
```swift
protocol Mappable {
  static func map(inout object: Self, json: Rosetta)
}
```
Implementation may look like this:
```swift
extension User: Mappable {
  static func map(inout object: User, json: Rosetta) {
    object.name <~ json["name"]
    object.age  <~ json["age"]
  }
}
```
This allows `Rosetta` to infer the mapping while encoding, and so reducing the call to:
```swift
let jsonData: NSData? = Rosetta().encode(user)
```
The behaviour is the same as with the verbose option, only that `User.map` is used implicitly. You can of course still use the verbose option with a `Mappable` type if you need to. The `map` passed explicitly will be prefered.

# Map

A map describes which `JSON` field goes where in your `Swift type`, what data types are expected where,  how a `JSON` data type should be converted to a `Swift type`, whether a field is optional or required, as well as any validation you'd like to have performed.
You describe all that using a set of operators (`<-` `<~` `~` `§`) in a map block. The syntax can be described like so (in pseudo-code):
```swift
object.ivar <-/<~ json["key"] ~ bridging § validation
```
`Maps` are implemented either via `Mappable` protocol, or as a closure passed to the `decode`/`encode` methods. In both cases, there are two input parameters:

* `object` which is the instance you are mapping the `JSON` to
* `json` which is an instance of `Rosetta` but think of it as if it were the `JSON` you are mapping

A real-life example (as an implementation of the `Mappable` protocol) may look something like this
```swift
static func map(inout object: User, json: Rosetta) {
  object.name    <- json["name"]
  object.age     <~ json["age"] § {age in age > 0}
  object.website <~ json["website"] ~ BridgeString(
    decoder: {NSURL(string: $0 as String)},
    encoder: {$0.absoluteString}
  )
}
```
In the first line, we have `object.name` linked to `"name"` key in `JSON` with a `<-` operator. This operator says that this field is **required**. `Bridging` is done implicitly and there is no `validation`.

The second line links `object.age` to `"age"` key in `JSON` with a `<~` operator. This operator says that this field is **optional**. `Bridging` is done implicitly and `validation` requires age to be greater than zero.

The last lines link `object.website` to `"website"` key in `JSON` with a `<~` operator. This is again the **optional** operator. `Bridging` is done explicitly, converting a `String` from `JSON` to an `NSURL` when `decoding` and back to `String` when `encoding`. No `validation` is performed.

This is just a brief overview of how `maps` are implemented and should give you the idea. Things like differences between **required** and **optional** links, how they work, when and how you can **implicitly bridge** types and all implementation details are described in sections below.

## Required `<-`

This operator is used to indicate that a property is **required**. 
As a result, `decoding` or `encoding` will **fail** if the value is **missing**, cannot be **bridged** or does not pass **validation**.

For example, if we have a `User` type defined like so:
```swift
struct User: JSONConvertible {
  var name: String?
  
  init() {
    
  }
  
  static func map(inout object: User, json: Rosetta) {
    object.name <- json["name"]
  }
}
```

And try to `decode` a `JSON`
```json
{
  "age": 22,
  "website": "https://www.mynameisbill.com"
}
```
e.g.
```swift
let user: User? = Rosetta().decode(jsonDataOrString)
```
`Rosetta` will return `.None` because the `JSON` is missing the required `"name"` field.
It would also fail if `JSON` had a `Number` instead of a `String` under `"name"` field.
Or,  if there was `validation`, e.g.
```swift
static func map(inout object: User, json: Rosetta) {
  object.name <- json["name"] § {countElements($0) > 3}
}
```
then
```json
{
  "name": "Bob",
  "age": 22,
  "website": "https://www.mynameisbill.com"
}
```
would also fail, because `validation` requires the `"name"` to be longer than 3 characters.

Exactly the same rules apply to `encoding`.
So if you do
```swift
let user = User()
let jsonData: NSData? = Rosetta().encode(user)
```
then `Rosetta` will return `.None` because `user.name` is missing.

**Required** links can be mapped to:

* normal types (e.g. `var name: String`)
* implicitly unwrapped optionals (e.g. `var name: String!`)
* optionals (e.g. `var name: String?`)

## Optional `<~`

Optional link, as the name suggests, indicates that a property is **optional**.
For these links `Rosetta` will ignore any failures during `decoding` or `encoding` and just skip it. This applies to all scenarios:

* missing value
* bridging failure
* validation failure

For example, if we have a `User` type defined like so:
```swift
struct User: JSONConvertible {
  var name: String?
  var age: Int?
  
  init() {
    
  }
  
  static func map(inout object: User, json: Rosetta) {
    object.name <~ json["name"]
    object.age  <~ json["age"]
  }
}
```

And try to `decode` a `JSON`
```json
{
  "age": 22,
  "website": "https://www.mynameisbill.com"
}
```
e.g.
```swift
let user: User? = Rosetta().decode(jsonDataOrString)
```
`Rosetta` will return `.Some(User)`.   
However, `user!.name` will be `.None` and `user!.age` will be `.Some(22)`.
Exactly the same result will be if **bridging** fails or **validation** is not passed for `"name"` field.

Same rules apply to `encoding`. So
```swift
var user = User()
user.age = 22
let jsonData: NSData? = Rosetta().encode(user)
```
will produce a `.Some(NSData)` with an `NSData` representation of `JSON`
```json
{
  "age": 22
}
```

However, **optional** link can **only** be used with **Swift Optionals**.
The example below will not compile because neither `name` nor `age` are **Swift Optionals**
```swift
struct User: JSONConvertible {
  var name: String = "some init value"
  var age: Int!
  
  init() {
    
  }
  
  static func map(inout object: User, json: Rosetta) {
    object.name <~ json["name"]
    object.age  <~ json["age"]
  }
}
```
Non-optional types can **only** by linked using the required `<-` operator.



## Bridging `~`
### Overview
The purpose of **Bridging** is to provide a translation mechanism between `JSON` types and `Swift types`.  

`JSON` types are [[wiki]](http://en.wikipedia.org/wiki/JSON#Data_types.2C_syntax_and_example):  
`Number` `Boolean` `String` `Array` `Object` `null`  

which are then converted by `NSJSONSerialization`, which is at the heart of `Rosetta`, into:  
`NSNumber` `NSString` `NSArray` `NSDictionary` `NSNull`  

next, these need to be convertible into your `Swift types` e.g. `String`, `Int` `Float` etc. (and back).  
This is achieved with **Bridging** used in conjunction with `~` operator.

### Bridges

There are 5 bridges available. One for each `JSON` type (except `null`, which is treated as *no value* at the moment)

* `BridgeNumber`
* `BridgeBoolean`
* `BridgeString`
* `UnsafeBridgeArray`
* `UnsafeBridgeObject` 

Each of them has a similar constructor:

BridgeNumber
```swift
func BridgeNumber<T>(
  decoder: (NSNumber) -> (T?),
  encoder: (T) -> (NSNumber?)
) -> Bridge<T, NSNumber>
```
BridgeBoolean
```swift
func BridgeBoolean<T>(
  decoder: (NSNumber) -> (T?),
  encoder: (T) -> (NSNumber?)
) -> Bridge<T, NSNumber>
```
BridgeString
```swift
func BridgeString<T>(
  decoder: (NSString) -> (T?),
  encoder: (T) -> (NSString?)
) -> Bridge<T, NSString>
```
UnsafeBridgeArray
```swift
func UnsafeBridgeArray<T>(
  decoder: (NSArray) -> (T?),
  encoder: (T) -> (NSArray?)
) -> Bridge<T, NSArray>
```
UnsafeBridgeObject
```swift
func UnsafeBridgeObject<T>(
  decoder: (NSDictionary) -> (T?),
  encoder: (T) -> (NSDictionary?)
) -> Bridge<T, NSDictionary>
```

Each bridge constructor takes a `decoder` closure and an `encoder` closure.  
`Decoder` closure's job is to convert a passed `JSON` value into a `Swift` value, or return `nil` if it is unable to do it.  
The `encoder` closure works the opposite way, trying to convert a `Swift` value into a `JSON` value, or returning `nil` if it is unable to do so.

An **example** of a simple bridge may look like this:
```swift
static func map(inout object: User, json: Rosetta) {
  object.age <~ json["age"] ~ BridgeNumber(
      decoder: {jsonValue in Int(jsonValue.integerValue)},
      encoder: {swiftValue in swiftValue as NSNumber}
    )
}
```
Here, `object.age` which is of type `Int` is bridged using `BridgeNumber`. The `decoder` will transform an `NSNumber` from the `JSON` into an `Int`, and the `encoder` will convert `Int` back into `NSNumber`.

Of course this can be simplified to:
```swift
static func map(json: Rosetta, inout object: User) {
  object.age <~ json["age"] ~ BridgeNumber(decoder: {$0.integerValue}, encoder: {$0})
}
```

Bridge also indicates what type you expect under a given key in `JSON`. In the example above **BridgeNumber** indicates that you expect a `Number` in `JSON` under `"age"` key. If there is a different type, this link will fail and produce an appropriate log.

### Implicit Bridging (structs and final classes only)
`Bridging` is **required**, but writing `bridging` code each time would of course be **mundane and repetitive**, especially for some very basic types like `String` and `Int`. This is why it can be done implicitly with `Bridgeable` protocol.  
```swift
protocol Bridgeable {
  typealias JSONType: NSObject
  static func bridge() -> Bridge<Self, JSONType>
}
```
If a type implements this protocol, bridging can be omitted, becuase the one returned by `bridge()` function is implicitly used. An example implementation for `Int` may look like this:
```swift
extension Int: Bridgeable {
  static func bridge() -> Bridge<Int, NSNumber> {
    return BridgeNumber(decoder: {$0.integerValue}, encoder: {$0})
  }
}
```
And now, bridging can be omitted completely:
```swift
static func map(inout object: User, json: Rosetta) {
  object.age <~ json["age"] // ~ Int.bridge() is implicitly used
}
```
Of course, if you provide Bridging explicitly, the **explicit version will be used** even for the `Bridgeable` types.

### Built-in bridgeable types
`Rosetta` has a range of `Bridgeable` types built-in. The full list is:

* `Int`
* `Int8`
* `Int16`
* `Int32`
* `Int64`
* `UInt`
* `UInt8`
* `UInt16`
* `UInt32`
* `UInt64`
* `Float`
* `Double`
* `Bool`
* `String`

So you don't need to worry about those. You may of course write your own if you like. However, it's worth mentioning that the default bridging implementation checks for **overflow** and **underflow** when it comes to types like `Int8`, `Int16` or `Int` on 32-bit platforms, etc. So if you use `Int8` and a `JSON` has a value `300` for that ivar, bridging will fail and return `nil`, to prevent overflow.  

These are the functions that return bridging for the types above, so you can check them out in the source:

* `IntBridge()`
* `Int8Bridge()`
* `Int16Bridge()`
* `Int32Bridge()`
* `Int64Bridge()`
* `UIntBridge()`
* `UInt8Bridge()`
* `UInt16Bridge()`
* `UInt32Bridge()`
* `UInt64Bridge()`
* `FloatBridge()`
* `DoubleBridge()`
* `BoolBridge()`
* `StringBridge()`

### Type conversion

This is all nice, but the case where `bridging` is really useful is **type conversion**. So far we looked at bridging between `Swift` types mimicking `JSON` types, like `String` and `Int`. A good example of type conversion is `NSURL`. It is not uncommon to have URLs in `JSON`, and the best way to store them in our code is with `NSURL` rather than `String`.  Conversion between the two can be done with simple bridging.

Let's expand our example to handle the **website** field:
```json
{  
  "name": "Bill",
  "age": 22,
  "website": "https://www.mynameisbill.com"
}
```
Let's add an ivar to our `User` struct:
```swift
struct User {
  var name: String?
  var age: Int?
  var website: NSURL?
}
```
And update the `map` function
```swift
static func map(inout object: User, json: Rosetta) {
  object.name    <~ json["name"]
  object.age     <~ json["age"]
  object.website <~ json["website"]
}
```
This will not work, because there is no implicit bridge available for `NSURL` (and unfortunately there cannot be one, because it is a `non-final class`). So we need to make one. We can add one **inline**:
```swift
static func map(inout object: User, json: Rosetta) {
  object.name    <~ json["name"]
  object.age     <~ json["age"]
  object.website <~ json["website"] ~ BridgeString(
    decoder: {NSURL(string: $0 as String)},
    encoder: {$0.absoluteString}
  )
}
```
But my preference is to add a function which returns one for us. This makes the `map` cleaner and `bridge` reusable.
```swift
func NSURLBridge() -> Bridge<NSURL, NSString> {
  return BridgeString(
    decoder: {NSURL(string: $0 as String)},
    encoder: {$0.absoluteString}
  )
}

static func map(inout object: User, json: Rosetta) {
  object.name    <~ json["name"]
  object.age     <~ json["age"]
  object.website <~ json["website"] ~ NSURLBridge()
}
```
Now, the `"https://www.mynameisbill.com"` from `JSON` will be converted to `NSURL` while `decoding`, and the `NSURL` will be reverted back to `"https://www.mynameisbill.com"` when `encoding`.

### Bridging and JSONConvertible

Types conforming to `JSONConvertible` protocol can be implicitly `bridged`.

For example,  we can have a `JSON` representation of a `Dog` which can have an owner, that can be represented by a `User`
```json
{
  "name": "Fluffy",
  "breed": "Border Collie",
  "owner": {
    "name": "Bob",
    "age": 22,
    "website": "http://www.mynameisbob.com"
  }
}
```

```swift
struct User: JSONConvertible {
  var name: String?
  var age: Int?
  var website: NSURL?
  
  init() {
    
  }
  
  static func map(inout object: User, json: Rosetta) {
    object.name    <~ json["name"]
    object.age     <~ json["age"]
    object.website <~ json["website"] ~ NSURLBridge()
  }
}

struct Dog: JSONConvertible {
  var name: String?
  var breed: String?
  var owner: User?
  
  init() {
    
  }
  
  static func map(inout object: Dog, json: Rosetta) {
    object.name  <~ json["name"]
    object.breed <~ json["breed"]
    object.owner <~ json["owner"] // Owner conforms to JSONConvertible protocol and is bridged implicitly
  }
}
```
As in the example, `object.owner <~ json["owner"]` does not need any explicit `bridging` because `owner` is of `User` type, which conforms to `JSONConvertible` protocol.

### UnsafeBridgeArray / UnsafeBridgeObject

Why are they named **unsafe**? Well, because they are. Unlike `BridgeNumber`, `BridgeBoolean` and `BridgeString` which guarantee type-safety, `Arrays` and `Objects` are a bit different.
`UnsafeBridgeArray` and `UnsafeBridgeObject` map to `NSArray` and `NSDictionary` respectively. This introduces a potential problem because both `NSArray` and `NSDictionary` can contain objects of any type, while `NSJSONSerialization` allows only specific types.  
From `NSJSONSerialization` docs:
```
An object that may be converted to JSON must have the following properties:

The top level object is an NSArray or NSDictionary.

All objects are instances of NSString, NSNumber, NSArray, NSDictionary, or NSNull.

All dictionary keys are instances of NSString.

Numbers are not NaN or infinity.
```

So `UnsafeBridgeArray` and `UnsafeBridgeObject` cannot check that at compile-time, which is not Swift-like. That is why these `bridges` have **unsafe** prefix to remind you of that type restriction.  
If you use `UnsafeBridgeArray` or `UnsafeBridgeObject` and return an `NSArray` or `NSDictionary` with unsupported types, `Rosetta` will throw an **exception**. This is considered a programmer error.

**However**, `UnsafeBridgeArray` and `UnsafeBridgeObject` are not a necessity. In fact, you should find yourself having to use them quite rarely, if at all. There are **type-safe** ways to link **arrays** and **objects**.

#### BridgeArray / BridgeObject
These two bridges enforce type-safety
```swift
func BridgeArray<T, U>(itemBridge: Bridge<T, U>) -> Bridge<[T], NSArray>
```
```swift
func BridgeObject<T, U>(valueBridge: Bridge<T, U>) -> Bridge<[String: T], NSDictionary>
```
Each of them, takes one argument, which is another `bridge` that will be used to transform array's items in case of `BridgeArray` or dictionary's values in case of `BridgeObject`.  
An example will demonstrate it best.  
Let's consider a `JSON`:
```json
{
  "bookmarks": [
    "http://www.github.com",
    "http://cocoapods.org",
    "http://apple.com"
  ]
}
```
Now let's assume we have a `User` `struct` with a property `bookmarks` that is an array of `NSURL`s.
```swift
struct User {
  var bookmarks: [NSURL]?
}
```
And we want to convert the array of `URL Strings` from the `JSON` into an array of `NSURL`s. We would do it like so:
```swift
struct User: JSONConvertible {
  var bookmarks: [NSURL]?
  
  init() {
    
  }
  
  static func map(inout object: User, json: Rosetta) {
    object.bookmarks <~ json["bookmarks"] ~ BridgeArray(NSURLBridge())
  }
}
```
Let's look at what's going on here:
```swift
object.bookmarks <~ json["bookmarks"] ~ BridgeArray(NSURLBridge())
```
`BridgeArray` converts an `Array of Strings` into an `Array of NSURLs` using the `NSURLBridge()`. So, in short, `BridgeArray` tells `Rosetta` that there should be an `Array` in `JSON` under `"bookmarks"` key, while `NSURLBridge()` indicates that the array should contain `Strings` that should be converted to `NSURL`s.  

Same goes for `BridgeObject` but insted of an `Array` we deal with a `Dictionary`.  
For example:
```json
{
  "bookmarks": {
    "Github": "http://www.github.com",
    "CocoaPods": "http://cocoapods.org",
    "Apple": "http://apple.com"
  }
}
```
```swift
struct User: JSONConvertible {
  var bookmarks: [String: NSURL]?
  
  init() {
    
  }
  
  static func map(inout object: User, json: Rosetta) {
    object.bookmarks <~ json["bookmarks"] ~ BridgeObject(NSURLBridge())
  }
}
```
`BridgeObject` enforces keys to be `Strings` and converts values using `NSURLBridge()`.

#### JSONConvertible and Bridgeable

Types that conform to either `JSONConvertible` or `Bridgeable` protocol, can be implicitly bridged to `Arrays` or `Dictionaries` and omit `BridgeArray`/`BridgeObject`.

For example, let's consider a `JSON` with an `Array` of `numbers` under `"primeNumbers"` key, and a `dictionary` with `number` values under `"population"` key.
```json
{
  "primeNumbers": [2, 3, 5, 7, 11, 13, 17, 19, 23, 29],
  "population": {
    "Africa": 1022234000,
    "Antarctica": 4490,
    "Asia": 4164252000,
    "Australia": 29127000,
    "Europe": 738199000,
    "North America": 542056000,
    "South America": 392555000
  }
}
```
We could map that `JSON` into a `FunFacts` structure like so:
```swift
struct FunFacts: JSONConvertible {
  var primeNumbers: [Int]?
  var population: [String: Int64]?
  
  init() {
    
  }
  
  static func map(inout object: FunFacts, json: Rosetta) {
    object.primeNumbers <~ json["primeNumbers"] ~ BridgeArray(IntBridge())
    object.population <~ json["population"] ~ BridgeObject(Int64Bridge())
  }
}
```
But, since both `Int` and `Int64` conform to the `Bridgeable` protocol, we can omit the `bridges`, because they will be used implicitly. So the `map` can look like this:
```swift
static func map(inout object: User, json: Rosetta) {
  object.primeNumbers <~ json["primeNumbers"]
  object.population <~ json["population"]
}
```
And `Rosetta` will do the right thing.  

As mentioned earlier, the same goes for `JSONConvertible` protocol.  
For example:
```json
{
  "arrayOfUsers": [
    {
      "name": "Bob",
      "age": 22
    },
    {
      "name": "Tim",
      "age": 34
    }
  ],
  "dictionaryOfUsers": {
    "user one": {
      "name": "Andy",
      "age": 24
    },
    "user two": {
      "name": "Steve",
      "age": 17
    }
  }
}
```
Let's have a `User` struct that conforms to `JSONConvertible` protocol.
```swift
struct User: JSONConvertible {
  var name: String?
  var age: Int?
  
  init() {
  
  }
  
  static func map(inout object: User, json: Rosetta) {
    object.name <~ json["name"]
    object.age  <~ json["age"]
  }
}
```
And map that `JSON` info a `FunPeople` struct
```swift
struct FunPeople: JSONConvertible {
  var arrayOfUsers: [User]?
  var dictionaryOfUsers: [String: User]?
  
  init() {
    
  }
  
  static func map(inout object: FunPeople, json: Rosetta) {
    object.arrayOfUsers <~ json["arrayOfUsers"] ~ BridgeArray(JSONConvertibleBridge())
    object.dictionaryOfUsers <~ json["dictionaryOfUsers"] ~ BridgeObject(JSONConvertibleBridge())
  }
}
```
Again, because `User` conforms to `JSONConvertible` protocol, we can omit `bridgin` and this reduce `map` to:
```swift
  static func map(inout object: FunPeople, json: Rosetta) {
    object.arrayOfUsers <~ json["arrayOfUsers"]
    object.dictionaryOfUsers <~ json["dictionaryOfUsers"]
  }
```

### Bridging and classes

## Validation `§`

Validation is a simple closure placed after `§` operator (`⌥6`), where you can validate the `decoded` or `encoded` value. It takes in one parameter, which is the `Swift type` value and returns returns `true` if validation is passed, and `false` if not.
It is fully optional, so may be omitted.
Validation is performed always on the `Swift type` value, which means after `bridging` while `decoding`, and before `bridging` while `encoding`. Let's consider this example:
```swift
struct SecureBookmark: JSONConvertible {
  var url: NSURL?
  
  init() {
    
  }
  
  static func map(inout object: User, json: Rosetta) {
    object.url <~ json["url"] ~ NSURLBridge() § {$0.scheme == "https"}
  }
}
```
`$0` in the validaiton closure will always be of `NSURL` type in this case. So if you're `decoding` a `JSON`
```json
{
  "url": "https://www.mynameisbill.com"
}
```
First, `"https://www.mynameisbill.com"` has to be succesfully `bridged` from `String` to `NSURL` using `NSURLBridge()`, and then the `validation` is performed.
If you're `encoding` a `SecureBookmark` object into `JSON`, then `url` property is first `validated` and if it passes `validation` it is then `bridged` to `String`.

## Key-paths
You can also map to values in `JSON` using `key-paths`. Just chain keys like so:
```swift
object.ivar <- json["key1"]["key2"]
```
to map the `"value"` from the `JSON` below.
```json
{
  "key1": {
    "key2": "value"
  }
}
```
Maps with `key-paths` behave exactly the same as with simple `keys` and follow the same rules.
# Classes
# Logs

`Rosetta` has a built-in elastic logging mechanism. It's disabled by default (set to `.None`) and can be turned on by setting `.logLevel` property on an instance of `Rosetta` like so:
```swfit
let rosetta = Rosetta()
rosetta.logLevel = .Errors
// do your decoding or encoding now
let user: User? = rosetta.decode(jsonData)
```
All possible `logLevel` values are:

* .None (no logs are triggered ever)
* .Errors (logs are triggered *only* if `decoding` or `encoding` fails)
* .Verbose (logs are triggered always if there are any)

By default logs print:

* **File** and **line number** where `decode` or `encode` was called
* **JSON String** or **JSON Data** that was `decoded`
* **Warnings** and **Errors** that were encountered during `decoding` or `encoding` such as:
	* JSON String to NSData conversion failure
	* NSJSONSerialization failure
	* Mapping errors:
		* Wrong Type
		* Missing Value
		* Failed Validation
		* Failed Bridging

And may look like so
```
Rosetta
ViewController.swift:904 handleResult()
JSON String: {"age":0,"website":"ftp://nonono.bad"}
Error: Value Missing for key-path: name
Error: Validation Failed for key-path: age
Warning: Validation Failed for key-path: website
```

## Log redirecting

By default `Rosetta` prints all logs using the standard `println()`. However, you can change that to whatever custom logging mechanism you use, or write to a file etc. by setting the `Rosetta`'s `.logHandler` property.
It's a simple `(String) -> ()` closure, that takes a `String` which is the log string generated by `Rosetta`.
```swift
let rosetta = Rosetta()
rosetta.logHandler = { (logString) -> () in
  // now you can pass the logString wherever you want, e.g. NSLog if you prefer that over println()
  NSLog(logString)
}
// do your decoding or encoding now
let user: User? = rosetta.decode(jsonData)
```
Alternatively for better code completion you can use `rosetta.setLogHandler` (just hit enter at the end)

![enter image description here](https://www.dropbox.com/s/b2un1w26yzn5bnp/Untitled%20-1.gif?dl=1)

## Custom formatting

If you need to for any reason, you can construct the log string the way you want. To do so, you set a custom `.logFormatter` on an instance of `Rosetta`

```swift
let rosetta = Rosetta()
rosetta.logFormatter = { (json, logs, file, line, function) -> String in
  // Construct whatever logString you desire with the log data passed to the closure
  return logString
}
// do your decoding or encoding now
let user: User? = rosetta.decode(jsonData)
```
Alternatively for better code completion you can use `rosetta.setLogFormatter` (just hit enter at the end)

![enter image description here](https://www.dropbox.com/s/sxo9v5abchhri69/zz.gif?dl=1)

`.logFormatter` is a closure
 `(json: JSON?, logs: [Log], file: StaticString, line: UWord, function: StaticString) -> String`
The parameters are:

### json
If available, it's the JSON that was being `decoded` or produced during `encoding`. It's represented by a `JSON` enum which encapsulates two possible formats in which `JSON` was originally produced or provided, that is `NSData` or `String`
```swift
enum JSON {
  case Data(NSData)
  case String(Swift.String)
}
```
e.g. if you called `rosetta.decode(jsonData)`, then `JSON` in logs would be `.Data(jsonData)`.
If you called `rosetta.decode(jsonString)`, then `JSON` in logs would be `.String(jsonString)`.
So you can always retrieve in logs the originally passed JSON.
In case of `rosetta.encode(object)`, `JSON` will be either `nil` or `.Data`, because `NSJSONSerialization` produces `NSData` or fails.

### logs
This parameter is an array of `Log` objects. There should always be at least one log in the array.
```swift
enum Log {
  case StringToData(string: String)
  case DataToJSON(data: NSData, error: NSError?)
  case Mapping(severity: Severity, type: MapType, keyPath: [String])
  
  enum Severity {
    case Warning
    case Error
  }
  
  enum MapType {
    case WrongType
    case ValueMissing
    case ValidationFailed
    case BridgingFailed
  }
}
```
Each log, represents one unexpected event encountered during `decoding` or `encoding`. Logs can represent either **errors** or **warnings**. If logs contain at least one **error**, this means that `decoding` or `encoding` has failed. **Warnings** on the other hand can happen if e.g. an optional value is missing or does not pass validation. They do not indicate that `decoding` or `encoding` failed completely, but provide information that might be useful during debugging.

Currently there are 3 types logs

- .StringToData - which always represents an **error** that happened while trying to convert a passed `JSON String` into `NSData` during `decoding`. It also contains the `JSON String` under `string` key so you can log that as well. Note that this error can occur only during `decoding`, not `encoding`.
- .DataToJSON - this log indicates that `NSJSONSerialization` (which powers `Rosetta`) failed to parse `JSON Data`. You can find the `JSON Data` under `data` key, and if `NSJSONSerialization` produced an `NSError` it will be under `error` key. This is always an **error** and can be produced only during `decoding`, not `encoding`.
- .Mapping - you can have many of those. Each log talks about exclusively one `link` from the `map`. It can represent either an **error** or **warning** depending on the value under `severity`. Under `type` you'll find what kind of problem occurred. And under `keyPath` you'll find the JSON key-path that this log reports.

### file
It is simply a full path of the file where the `decode` or `encode` call was made. The default log formatter implementation drops the path and prints only the filename.

### line
This parameter is the line number where the `decode` or `encode` call was made.

### function
This parameter is the name of the function in which the `decode` or `encode` call was made.

# Thread safety
There is one simple rule. An instance of `Rosetta` should only be used on the thread it was created on. You are most likely to create a new instance each time you `decode` or `encode` but if you'd like to reuse one, make sure not to pass it between threads.
# Caveats and best practices
