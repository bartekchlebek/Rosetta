import Foundation
import XCTest
import Rosetta

func ==(lhs: SubObjectClass, rhs: SubObjectClass) -> Bool {
  return lhs.a1 == rhs.a1
}

class SubObjectClass: JSONConvertibleClass, Equatable {
  var a1: String = "x"
  required init () {
    
  }
  class func map(object: SubObjectClass, json: Rosetta) {
    object.a1 <- json["a1-key"]
  }
}

class ObjectClass: JSONConvertibleClass {
  var a1: String  = "x"
  var a2: String! = "x"
  var a3: String? = "x"
  
  var b1: Int   = 0
  var b2: Int!  = 0
  var b3: Int?  = 0
  
  var c1: Bool   = false
  var c2: Bool!  = false
  var c3: Bool?  = false
  
  var d1: [String]  = ["x"]
  var d2: [String]! = ["x"]
  var d3: [String]? = ["x"]
  
  var e1: [String: String]  = ["x": "y"]
  var e2: [String: String]! = ["x": "y"]
  var e3: [String: String]? = ["x": "y"]
  
  var f1: NSURL  = NSURL(string: "http://www.google.pl")!
  var f2: NSURL! = NSURL(string: "http://www.google.pl")!
  var f3: NSURL? = NSURL(string: "http://www.google.pl")!
  
  var g1: SubObjectClass  = SubObjectClass()
  var g2: SubObjectClass! = SubObjectClass()
  var g3: SubObjectClass? = SubObjectClass()
  
  var h1: [NSURL]  = [NSURL(string: "http://www.google.pl")!]
  var h2: [NSURL]! = [NSURL(string: "http://www.google.pl")!]
  var h3: [NSURL]? = [NSURL(string: "http://www.google.pl")!]
  
  var i1: [String: NSURL]  = ["x": NSURL(string: "http://www.google.pl")!]
  var i2: [String: NSURL]! = ["x": NSURL(string: "http://www.google.pl")!]
  var i3: [String: NSURL]? = ["x": NSURL(string: "http://www.google.pl")!]
  
  required init() {
    
  }
  
  class func map(object: ObjectClass, json: Rosetta) {
    object.a1 <- json["a1-key"]
    object.a2 <- json["a2-key"]
    object.a3 <~ json["a3-key"]
    
    object.b1 <- json["b1-key"]
    object.b2 <- json["b2-key"]
    object.b3 <~ json["b3-key"]
    
    object.c1 <- json["c1-key"]
    object.c2 <- json["c2-key"]
    object.c3 <~ json["c3-key"]
    
    object.d1 <- json["d1-key"]
    object.d2 <- json["d2-key"]
    object.d3 <~ json["d3-key"]
    
    object.e1 <- json["e1-key"]
    object.e2 <- json["e2-key"]
    object.e3 <~ json["e3-key"]
    
    object.f1 <- json["f1-key"] ~ NSURLBridge()
    object.f2 <- json["f2-key"] ~ NSURLBridge()
    object.f3 <~ json["f3-key"] ~ NSURLBridge()
    
    object.g1 <- json["g1-key"]
    object.g2 <- json["g2-key"]
    object.g3 <~ json["g3-key"]
    
    object.h1 <- json["h1-key"] ~ BridgeArray(NSURLBridge())
    object.h2 <- json["h2-key"] ~ BridgeArray(NSURLBridge())
    object.h3 <~ json["h3-key"] ~ BridgeArray(NSURLBridge())
    
    object.i1 <- json["i1-key"] ~ BridgeObject(NSURLBridge())
    object.i2 <- json["i2-key"] ~ BridgeObject(NSURLBridge())
    object.i3 <~ json["i3-key"] ~ BridgeObject(NSURLBridge())
  }
}

class RosettaClassTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testSimpleDecoder() {
    class ObjectClass: JSONConvertibleClass {
      var name: String
      
      required init() {
        name = "John"
      }
      
      private class func map(object: ObjectClass, json: Rosetta) {
        object.name <- json["name"]
      }
    }
    
    let object: ObjectClass? = Rosetta().decode(dataFrom(["name": "Bob"]))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testSimpleDecoderWithUnwrappedOptional() {
    class ObjectClass: JSONConvertibleClass {
      var name: String!
      
      required init() {
        
      }
      
      private class func map(object: ObjectClass, json: Rosetta) {
        object.name <- json["name"]
      }
    }
    
    let object: ObjectClass? = Rosetta().decode(dataFrom(["name": "Bob"]))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testSimpleDecoderWithOptional() {
    class ObjectClass: JSONConvertibleClass {
      var name: String?
      
      required init() {
        
      }
      
      private class func map(object: ObjectClass, json: Rosetta) {
        object.name <~ json["name"]
      }
    }
    
    let object: ObjectClass? = Rosetta().decode(dataFrom(Dictionary<String, AnyObject>()))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertTrue(object!.name == nil, "object.name should remain unmodified")
  }
  
  func testComplexDecoder() {
    let dictionary = complexJSON()
    let object: ObjectClass? = Rosetta().decode(dictionary)
    
    XCTAssertTrue(object != nil, "object should exist")
    
    XCTAssertEqual(object!.a1, "a1-value")
    XCTAssertEqual(object!.a2, "a2-value")
    XCTAssertEqual(object!.a3!, "a3-value")
    
    XCTAssertEqual(object!.b1, 1)
    XCTAssertEqual(object!.b2, 2)
    XCTAssertEqual(object!.b3!, 3)
    
    XCTAssertEqual(object!.c1, true)
    XCTAssertEqual(object!.c2, true)
    XCTAssertEqual(object!.c3!, true)
    
    XCTAssertEqual(object!.d1, ["d1-1", "d1-2", "d1-3"])
    XCTAssertEqual(object!.d2, ["d2-1", "d2-2", "d2-3"])
    XCTAssertEqual(object!.d3!, ["d3-1", "d3-2", "d3-3"])
    
    XCTAssertEqual(object!.e1, ["e1": "e1-value"])
    XCTAssertEqual(object!.e2, ["e2": "e2-value"])
    XCTAssertEqual(object!.e3!, ["e3": "e3-value"])
    
    XCTAssertEqual(object!.f1, NSURL(string: "http://www.wp.pl")!)
    XCTAssertEqual(object!.f2, NSURL(string: "http://www.wp.pl")!)
    XCTAssertEqual(object!.f3!, NSURL(string: "http://www.wp.pl")!)
    
    var subObjectClass = SubObjectClass(); subObjectClass.a1 = "a1-value"
    XCTAssertEqual(object!.g1, subObjectClass)
    XCTAssertEqual(object!.g2, subObjectClass)
    XCTAssertEqual(object!.g3!, subObjectClass)
  }
  
  func testComplexEncoder() {
    let data = complexJSON()
    let decoded: ObjectClass? = Rosetta().decode(data)
    XCTAssertTrue(decoded != nil, "decoded object should exist")
    let encoded: NSData? = Rosetta().encode(decoded!)
    XCTAssertTrue(encoded != nil, "encoded object should exist")
    XCTAssertTrue(
      jsonFrom(data).isEqualToDictionary(jsonFrom(encoded!) as! [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }
  
  func testFailingDecoder() {
    class ObjectClass: JSONConvertibleClass {
      var name: String
      
      required init() {
        name = "John"
      }
      
      private class func map(object: ObjectClass, json: Rosetta) {
        object.name <- json["name"]
      }
    }
    
    let object: ObjectClass? = Rosetta().decode(dataFrom(["name": 11]))
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testFailingDecoderWithError() {
    class ObjectClass: JSONConvertibleClass {
      var name: String
      
      required init() {
        name = "John"
      }
      
      private class func map(object: ObjectClass, json: Rosetta) {
        object.name <- json["name"]
      }
    }
    
    let object: ObjectClass? = Rosetta().decode(dataFrom(["name": 11]))
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testValidatedEncoder() {
    class Structure: JSONConvertibleClass {
      var a1: String = "x"
      
      required init() {
        
      }
      
      private class func map(object: Structure, json: Rosetta) {
        object.a1 <- json["a1"] § {$0 == "a1"}
      }
    }
    
    let structure = Structure()
    let json: NSData? = Rosetta().encode(structure)
    XCTAssertTrue(json == nil, "json should not exist")
  }
  
  func testValidatedEncoder1() {
    class Structure: JSONConvertibleClass {
      var a1: String? = "x"
      
      required init() {
        
      }
      
      private class func map(object: Structure, json: Rosetta) {
        object.a1 <~ json["a1"] § {$0 == "a1"}
      }
    }
    
    let structure = Structure()
    let json: NSData? = Rosetta().encode(structure)
    XCTAssertTrue(json != nil, "json should exist")
    XCTAssertTrue(jsonFrom(json!)["a1"] == nil, "json[\"a1\"] should not exist")
  }
  
  func testKeyPathsDecoder() {
    class ObjectClass: JSONConvertibleClass {
      var name: String
      
      required init() {
        name = "John"
      }
      
      private class func map(object: ObjectClass, json: Rosetta) {
        object.name <- json["result"]["name"]
      }
    }
    
    let object: ObjectClass? = Rosetta().decode(dataFrom(["result": ["name": "Bob"]]))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testKeyPathsEncoder() {
    class ObjectClass: JSONConvertibleClass {
      var name: String
      
      required init() {
        name = "John"
      }
      
      private class func map(object: ObjectClass, json: Rosetta) {
        object.name <- json["result"]["name"]
      }
    }
    
    let object: ObjectClass? = Rosetta().decode(dataFrom(["result": ["name": "Bob"]]))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testRequiredOptionalType() {
    class ObjectClass: JSONConvertibleClass {
      var a1: String?
      
      required init() {
        
      }
      
      private class func map(object: ObjectClass, json: Rosetta) {
        object.a1 <- json["a1"]
      }
    }
    
    let object: ObjectClass? = Rosetta().decode(dataFrom(["a2": "a2"]))
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testCustomMap() {
    class ObjectClass {
      var a1: String?
      
      init() {
        
      }
    }
    let jsonData = dataFrom(["a1": "a1-value"])
    var object = ObjectClass()
    let result = Rosetta().decode(jsonData, to: &object, usingMap: { (object, json) -> () in
      object.a1 <- json["a1"]
    })
    XCTAssertTrue(result == true, "result should be 'true'")
    XCTAssertTrue(object.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object.a1!, "a1-value")
  }
  
  func testCustomMapFailing() {
    class ObjectClass {
      var a1: String?
      
      init() {
        
      }
    }
    let jsonData = dataFrom(["a2": "garbage"])
    var object = ObjectClass()
    object.a1 = "a1-value"
    let result = Rosetta().decode(jsonData, to: &object, usingMap: { (object, json) -> () in
      object.a1 <- json["a1"]
    })
    XCTAssertTrue(result == false, "result should be 'false'")
    XCTAssertTrue(object.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object.a1!, "a1-value")
  }
  
  func testCreatableWithCustomMap() {
    class ObjectClass: Creatable {
      var a1: String?
      
      required init() {
        
      }
    }
    let jsonData = dataFrom(["a1": "a1-value"])
    let object = Rosetta().decode(jsonData, usingMap: { (object: ObjectClass, json) -> () in
      object.a1 <- json["a1"]
    })
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertTrue(object!.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object!.a1!, "a1-value")
  }
  
  func testCreatableWithCustomMapFailing() {
    class ObjectClass: Creatable {
      var a1: String?
      
      required init() {
        
      }
    }
    let jsonData = dataFrom(["a2": "garbage"])
    let object = Rosetta().decode(jsonData, usingMap: { (object: ObjectClass, json) -> () in
      object.a1 <- json["a1"]
    })
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testCreatableWithCustomMapOptionalIgnored() {
    class ObjectClass: Creatable {
      var a1: String?
      
      required init() {
        
      }
    }
    let jsonData = dataFrom(["a2": "garbage"])
    let object = Rosetta().decode(jsonData, usingMap: { (object: ObjectClass, json) -> () in
      object.a1 <~ json["a1"]
    })
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertTrue(object!.a1 == nil, "object.a1 should not exist")
  }
  
  //MARK: Key Path tests
  
  class KeyPathObject: JSONConvertibleClass {
    var a1: String  = "x"
    var a2: String! = "x"
    var a3: String? = "x"
    
    var b1: Int   = 0
    var b2: Int!  = 0
    var b3: Int?  = 0
    
    var c1: Bool   = false
    var c2: Bool!  = false
    var c3: Bool?  = false
    
    var d1: [String]  = ["x"]
    var d2: [String]! = ["x"]
    var d3: [String]? = ["x"]
    
    var e1: [String: String]  = ["x": "y"]
    var e2: [String: String]! = ["x": "y"]
    var e3: [String: String]? = ["x": "y"]
    
    var f1: NSURL  = NSURL(string: "http://www.google.pl")!
    var f2: NSURL! = NSURL(string: "http://www.google.pl")!
    var f3: NSURL? = NSURL(string: "http://www.google.pl")!
    
    var g1: SubObjectClass  = SubObjectClass()
    var g2: SubObjectClass! = SubObjectClass()
    var g3: SubObjectClass? = SubObjectClass()
    
    var h1: [NSURL]  = [NSURL(string: "http://www.google.pl")!]
    var h2: [NSURL]! = [NSURL(string: "http://www.google.pl")!]
    var h3: [NSURL]? = [NSURL(string: "http://www.google.pl")!]
    
    var i1: [String: NSURL]  = ["x": NSURL(string: "http://www.google.pl")!]
    var i2: [String: NSURL]! = ["x": NSURL(string: "http://www.google.pl")!]
    var i3: [String: NSURL]? = ["x": NSURL(string: "http://www.google.pl")!]
    
    required init() {
      
    }
    
    class func map(object: KeyPathObject, json: Rosetta) {
      object.a1 <- json["result"]["object"]["a1-key"]
      object.a2 <- json["result"]["object"]["a2-key"]
      object.a3 <- json["result"]["object"]["a3-key"]
      
      object.b1 <- json["result"]["object"]["b1-key"]
      object.b2 <- json["result"]["object"]["b2-key"]
      object.b3 <- json["result"]["object"]["b3-key"]
      
      object.c1 <- json["result"]["object"]["c1-key"]
      object.c2 <- json["result"]["object"]["c2-key"]
      object.c3 <- json["result"]["object"]["c3-key"]
      
      object.d1 <- json["result"]["object"]["d1-key"]
      object.d2 <- json["result"]["object"]["d2-key"]
      object.d3 <- json["result"]["object"]["d3-key"]
      
      object.e1 <- json["result"]["object"]["e1-key"]
      object.e2 <- json["result"]["object"]["e2-key"]
      object.e3 <- json["result"]["object"]["e3-key"]
      
      object.f1 <- json["result"]["object"]["f1-key"] ~ NSURLBridge()
      object.f2 <- json["result"]["object"]["f2-key"] ~ NSURLBridge()
      object.f3 <- json["result"]["object"]["f3-key"] ~ NSURLBridge()
      
      object.g1 <- json["result"]["object"]["g1-key"]
      object.g2 <- json["result"]["object"]["g2-key"]
      object.g3 <- json["result"]["object"]["g3-key"]
      
      object.h1 <- json["result"]["object"]["h1-key"] ~ BridgeArray(NSURLBridge())
      object.h2 <- json["result"]["object"]["h2-key"] ~ BridgeArray(NSURLBridge())
      object.h3 <- json["result"]["object"]["h3-key"] ~ BridgeArray(NSURLBridge())
      
      object.i1 <- json["result"]["object"]["i1-key"] ~ BridgeObject(NSURLBridge())
      object.i2 <- json["result"]["object"]["i2-key"] ~ BridgeObject(NSURLBridge())
      object.i3 <- json["result"]["object"]["i3-key"] ~ BridgeObject(NSURLBridge())
    }
  }
  
  func complexKeyPathJSON() -> NSData {
    let bundle = NSBundle(forClass: RosettaClassTests.classForCoder())
    let url = bundle.URLForResource("complex keyPath JSON", withExtension: "json")
    return NSData(contentsOfURL: url!)!
  }
  
  func testComplexKeyPathDecoder() {
    let jsonData = complexKeyPathJSON()
    let object: KeyPathObject? = Rosetta().decode(jsonData)
    
    XCTAssertTrue(object != nil, "object should exist")
    
    XCTAssertEqual(object!.a1, "a1-value")
    XCTAssertEqual(object!.a2, "a2-value")
    XCTAssertEqual(object!.a3!, "a3-value")
    
    XCTAssertEqual(object!.b1, 1)
    XCTAssertEqual(object!.b2, 2)
    XCTAssertEqual(object!.b3!, 3)
    
    XCTAssertEqual(object!.c1, true)
    XCTAssertEqual(object!.c2, true)
    XCTAssertEqual(object!.c3!, true)
    
    XCTAssertEqual(object!.d1, ["d1-1", "d1-2", "d1-3"])
    XCTAssertEqual(object!.d2, ["d2-1", "d2-2", "d2-3"])
    XCTAssertEqual(object!.d3!, ["d3-1", "d3-2", "d3-3"])
    
    XCTAssertEqual(object!.e1, ["e1": "e1-value"])
    XCTAssertEqual(object!.e2, ["e2": "e2-value"])
    XCTAssertEqual(object!.e3!, ["e3": "e3-value"])
    
    XCTAssertEqual(object!.f1, NSURL(string: "http://www.wp.pl")!)
    XCTAssertEqual(object!.f2, NSURL(string: "http://www.wp.pl")!)
    XCTAssertEqual(object!.f3!, NSURL(string: "http://www.wp.pl")!)
    
    var subObjectClass = SubObjectClass(); subObjectClass.a1 = "a1-value"
    XCTAssertEqual(object!.g1, subObjectClass)
    XCTAssertEqual(object!.g2, subObjectClass)
    XCTAssertEqual(object!.g3!, subObjectClass)
  }
  
  func testComplexKeyPathEncoder() {
    let jsonData = complexKeyPathJSON()
    let decoded: KeyPathObject? = Rosetta().decode(jsonData)
    XCTAssertTrue(decoded != nil, "decoded should not be nil")
    let encoded: NSData? = Rosetta().encode(decoded!)
    XCTAssertTrue(encoded != nil, "encoded should not be nil")
    XCTAssertTrue(
      jsonFrom(jsonData).isEqualToDictionary(jsonFrom(encoded!) as! [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }
  
  func testFailingComplexKeyPathDecoder() {
    let dictionary = complexJSON()
    let object: KeyPathObject? = Rosetta().decode(dictionary)
    
    
    
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testFailingComplexKeyPathDecoder2() {
    let dictionary = complexKeyPathJSON()
    let object: ObjectClass? = Rosetta().decode(dictionary)
    
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testDecodingWithCustomMap() {
    class ObjectClass {
      var a1: String?
      init () {
        
      }
    }
    
    var object = ObjectClass()
    Rosetta().decode(dataFrom(["a1": "a1"]), to: &object, usingMap: { (object: ObjectClass, json) -> () in
      object.a1 <- json["a1"]
    })
    
    XCTAssertTrue(object.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object.a1!, "a1")
  }
  
  //MARK: auto-bridged types
  
  func testAutoBridgedTypes() {
    class ObjectClass: JSONConvertibleClass {
      var a0: Int?
      var a1: Int8?
      var a2: Int16?
      var a3: Int32?
      var a4: Int64?
      var a5: UInt?
      var a6: UInt8?
      var a7: UInt16?
      var a8: UInt32?
      var a9: UInt64?
      
      var b0: Float?
      var b1: Double?
      //      var b2: Swift.Float80? // NOT SUPPORTED
      //      var b3: Float96? // NOT SUPPORTED
      
      var c0: Bool?
      
      var d0: NSNumber?
      
      var e0: String?
      var e1: NSString?
      var e2: NSMutableString?
      
      var f0: AnyObject?
      var g0: [AnyObject]?
      var h0: [String: AnyObject]?
      
      var i0: AnyObject?
      
      required init() {
        
      }
      
      private class func map(object: ObjectClass, json: Rosetta) {
        object.a0 <- json["a0"]
        object.a1 <- json["a1"]
        object.a2 <- json["a2"]
        object.a3 <- json["a3"]
        object.a4 <- json["a4"]
        object.a5 <- json["a5"]
        object.a6 <- json["a6"]
        object.a7 <- json["a7"]
        object.a8 <- json["a8"]
        object.a9 <- json["a9"]
        
        object.b0 <- json["b0"]
        object.b1 <- json["b1"]
        //        object.b2 <- json["b2"]
        //        object.b3 <- json["b3"]
        
        object.c0 <- json["c0"]
        
        object.d0 <- json["d0"] ~ NSNumberBridge()
        
        object.e0 <- json["e0"]
        object.e1 <- json["e1"] ~ NSStringBridge()
        object.e2 <- json["e2"] ~ NSMutableStringBridge()
        
        //        object.f0 <- json["f0"] ~ AnyObjectBridge()
        //        object.g0 <- json["g0"] ~ BridgeArray(AnyObjectBridge())
        //        object.h0 <- json["h0"] ~ BridgeObject(AnyObjectBridge())
        //
        //        object.i0 <- json["i0"] ~ TollFreeBridge()
      }
    }
  }
  
  //MARK: validators
  
  func testValidation() {
    class Structure: JSONConvertibleClass {
      var a1: String  = "x"
      var a2: String!
      var a3: String?
      
      required init() {
        
      }
      
      private class func map(object: Structure, json: Rosetta) {
        object.a1 <- json["a1"] § {$0 == "a1"}
        object.a2 <- json["a2"] § {$0 == "a2"}
        object.a3 <~ json["a3"] § {$0 == "a3"}
      }
    }
    
    var s1: Structure? = Rosetta().decode(
      dataFrom(
        ["a1": "a1",
          "a2": "a2",
          "a3": "a3"]
      )
    )
    XCTAssertTrue(s1 != nil, "structure object should exist")
    
    XCTAssertTrue(s1!.a2 != nil, "s1.a2 should exist")
    XCTAssertTrue(s1!.a3 != nil, "s1.a3 should exist")
    
    XCTAssertEqual(s1!.a1, "a1")
    XCTAssertEqual(s1!.a2, "a2")
    XCTAssertEqual(s1!.a3!, "a3")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a2",
          "a3": "a3"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a1",
          "a2": "a",
          "a3": "a3"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a1",
          "a2": "a2",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 != nil, "structure object should exist")
    
    XCTAssertTrue(s1!.a2 != nil, "s1.a2 should exist")
    XCTAssertTrue(s1!.a3 == nil, "s1.a3 should not exist")
    
    XCTAssertEqual(s1!.a1, "a1")
    XCTAssertEqual(s1!.a2, "a2")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a",
          "a3": "a3"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a2",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a1",
          "a2": "a",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
  }
  
  func testValidationWithCustomBridge() {
    class Structure: JSONConvertibleClass {
      var a1: NSURL  = NSURL(string: "http://www.wp.pl")!
      var a2: NSURL!
      var a3: NSURL?
      
      required init() {
        
      }
      
      private class func map(object: Structure, json: Rosetta) {
        object.a1 <- json["a1"] ~ NSURLBridge() § {$0.absoluteString == "http://www.google.com"}
        object.a2 <- json["a2"] ~ NSURLBridge() § {$0.absoluteString == "http://www.google.com"}
        object.a3 <~ json["a3"] ~ NSURLBridge() § {$0.absoluteString == "http://www.google.com"}
      }
    }
    
    var s1: Structure? = Rosetta().decode(
      dataFrom(
        ["a1": "http://www.google.com",
          "a2": "http://www.google.com",
          "a3": "http://www.google.com"]
      )
    )
    XCTAssertTrue(s1 != nil, "structure object should exist")
    
    XCTAssertTrue(s1!.a2 != nil, "s1.a2 should exist")
    XCTAssertTrue(s1!.a3 != nil, "s1.a3 should exist")
    
    XCTAssertEqual(s1!.a1.absoluteString!, "http://www.google.com")
    XCTAssertEqual(s1!.a2.absoluteString!, "http://www.google.com")
    XCTAssertEqual(s1!.a3!.absoluteString!, "http://www.google.com")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "http://www.google.com",
          "a3": "http://www.google.com"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "http://www.google.com",
          "a2": "a",
          "a3": "http://www.google.com"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "http://www.google.com",
          "a2": "http://www.google.com",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 != nil, "structure object should exist")
    
    XCTAssertTrue(s1!.a2 != nil, "s1.a2 should exist")
    XCTAssertTrue(s1!.a3 == nil, "s1.a3 should not exist")
    
    XCTAssertEqual(s1!.a1.absoluteString!, "http://www.google.com")
    XCTAssertEqual(s1!.a2.absoluteString!, "http://www.google.com")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a",
          "a3": "http://www.google.com"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "http://www.google.com",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "http://www.google.com",
          "a2": "a",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
  }
  
  func testArrayOfJSONConvertibleClass() {
    class User: JSONConvertibleClass {
      var name: String?
      
      required init() {
        
      }
      
      init(name: String) {
        self.name = name
      }
      
      class func map(object: User, json: Rosetta) {
        object.name <- json["name"]
      }
    }
    
    class Group: JSONConvertibleClass {
      var users1: [User] = []
      var users2: [User]!
      var users3: [User]?
      
      required init() {
        
      }
      
      init(users1: [User], users2: [User], users3: [User]) {
        self.users1 = users1
        self.users2 = users2
        self.users3 = users3
      }
      
      class func map(object: Group, json: Rosetta) {
        object.users1 <- json["users1"]
        object.users2 <- json["users2"]
        object.users3 <- json["users3"]
      }
    }
    
    let data = dataFrom(
      ["users1": [
        ["name": "Bob"],
        ["name": "Jony"]
        ],
        "users2": [
          ["name": "Tim"]
        ],
        "users3": [
          ["name": "Steve"],
          ["name": "Eddy"],
          ["name": "Craig"]
      ]]
    )
    var group: Group? = Rosetta().decode(data)
    XCTAssertTrue(group != nil, "group should exist")
    XCTAssertTrue(group!.users2 != nil, "group.users2 should exist")
    XCTAssertTrue(group!.users3 != nil, "group.users3 should exist")
    XCTAssertTrue(group!.users1.count == 2, "group.users should have 2 items")
    XCTAssertTrue(group!.users2.count == 1, "group.users should have 2 items")
    XCTAssertTrue(group!.users3!.count == 3, "group.users should have 2 items")
    
    // encoding
    
    group = Group(
      users1: [User(name: "Bob"), User(name: "Jony")],
      users2: [User(name: "Tim")],
      users3: [User(name: "Steve"), User(name: "Eddy"), User(name: "Craig")]
    )
    let encoded: NSData? = Rosetta().encode(group!)
    XCTAssertTrue(encoded != nil, "encoded data should exist")
    XCTAssertTrue(
      jsonFrom(data).isEqualToDictionary(jsonFrom(encoded!) as! [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }
  
  func testDictionaryOfJSONConvertible() {
    class User: JSONConvertibleClass {
      var name: String?
      
      required init() {
        
      }
      
      init(name: String) {
        self.name = name
      }
      
      class func map(object: User, json: Rosetta) {
        object.name <- json["name"]
      }
    }
    
    class Group: JSONConvertibleClass {
      var users1: [String: User] = [:]
      var users2: [String: User]!
      var users3: [String: User]?
      
      required init() {
        
      }
      
      init(users1: [String: User], users2: [String: User], users3: [String: User]) {
        self.users1 = users1
        self.users2 = users2
        self.users3 = users3
      }
      
      class func map(object: Group, json: Rosetta) {
        object.users1 <- json["users1"]
        object.users2 <- json["users2"]
        object.users3 <- json["users3"]
      }
    }
    
    let data = dataFrom(
      ["users1": [
        "H/W Guy": ["name": "Bob"],
        "Design": ["name": "Jony"]
        ],
        "users2": [
          "CEO": ["name": "Tim"]
        ],
        "users3": [
          "Founder": ["name": "Steve"],
          "Ferrari guy": ["name": "Eddy"],
          "California guy": ["name": "Craig"]
      ]]
    )
    var group: Group? = Rosetta().decode(data)
    XCTAssertTrue(group != nil, "group should exist")
    XCTAssertTrue(group!.users2 != nil, "group.users2 should exist")
    XCTAssertTrue(group!.users3 != nil, "group.users3 should exist")
    XCTAssertTrue(group!.users1.count == 2, "group.users should have 2 items")
    XCTAssertTrue(group!.users2.count == 1, "group.users should have 2 items")
    XCTAssertTrue(group!.users3!.count == 3, "group.users should have 2 items")
    
    // encoding
    
    group = Group(
      users1: ["H/W Guy": User(name: "Bob"), "Design": User(name: "Jony")],
      users2: ["CEO": User(name: "Tim")],
      users3: ["Founder": User(name: "Steve"), "Ferrari guy": User(name: "Eddy"), "California guy": User(name: "Craig")]
    )
    let encoded: NSData? = Rosetta().encode(group!)
    XCTAssertTrue(encoded != nil, "encoded data should exist")
    XCTAssertTrue(
      jsonFrom(data).isEqualToDictionary(jsonFrom(encoded!) as! [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }
}
