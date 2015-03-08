import Foundation

//MARK: Value types decoding
extension Rosetta {
  public func decode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonData: NSData,
    inout to object: T,
    usingMap map: (inout T, json: Rosetta) -> ()
    ) -> Bool {
      
      return self.decode(file: file, line: line, function: function, JSON.Data(jsonData), to: &object, usingMap: map)
  }
  
  public func decode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonString: String,
    inout to object: T,
    usingMap map: (inout T, json: Rosetta) -> ()
    ) -> Bool {
      
      let input = JSON.String(jsonString)
      return self.decode(file: file, line: line, function: function, input, to: &object, usingMap: map)
  }
  
  public func decode<T: Creatable>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonData: NSData,
    usingMap map: (inout T, json: Rosetta) -> ()
    ) -> T? {
      
      var object = T()
      if self.decode(file: file, line: line, function: function, jsonData, to: &object, usingMap: map) == false {
        return nil
      }
      return object
  }
  
  public func decode<T: Creatable>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonString: String,
    usingMap map: (inout T, json: Rosetta) -> ()
    ) -> T? {
      
      var object = T()
      if self.decode(file: file, line: line, function: function, jsonString, to: &object, usingMap: map) == false {
        return nil
      }
      return object
  }
  
  public func decode<T: Mappable>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonData: NSData,
    inout to object: T
    ) -> Bool {
      
      return self.decode(file: file, line: line, function: function, jsonData, to: &object, usingMap: T.map)
  }
  
  public func decode<T: Mappable>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonString: String,
    inout to object: T
    ) -> Bool {
      
      return self.decode(file: file, line: line, function: function, jsonString, to: &object, usingMap: T.map)
  }
  
  public func decode<T: JSONConvertible>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonData: NSData
    ) -> T? {
      
      var object = T()
      if self.decode(file: file, line: line, function: function, jsonData, to: &object, usingMap: T.map) == false {
        return nil
      }
      return object
  }
  
  public func decode<T: JSONConvertible>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonString: String
    ) -> T? {
      
      var object = T()
      if self.decode(file: file, line: line, function: function, jsonString, to: &object, usingMap: T.map) == false {
        return nil
      }
      return object
  }
}

//MARK: Value types encoding
extension Rosetta {
  public func encode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ obj: T,
    usingMap map: (inout T, json: Rosetta) -> ()
    ) -> NSData? {
      
      var data: NSData?
      if let json: [String: AnyObject] = self.encode(file: file, line: line, function: function, obj, usingMap: map) {
        // TODO: Add json parsing error
        data = NSJSONSerialization.dataWithJSONObject(json, options: nil, error: nil)
      }
      return data
  }
  
  public func encode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ obj: T,
    usingMap map: (inout T, json: Rosetta) -> ()
    ) -> String? {
      
      var string: String?
      if let data: NSData = self.encode(file: file, line: line, function: function, obj, usingMap: map) {
        string = data.toString()
        if string == nil {
          // TODO: Add error
        }
      }
      return string
  }
  
  public func encode<T: Mappable>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ obj: T
    ) -> NSData? {
      
      return self.encode(file: file, line: line, function: function, obj, usingMap: T.map)
  }
  
  public func encode<T: Mappable>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ obj: T
    ) -> String? {
      
      return self.encode(file: file, line: line, function: function, obj, usingMap: T.map)
  }
}

//MARK: Class types decoding
extension Rosetta {
  public func decode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonData: NSData,
    inout to object: T,
    usingMap map: (T, json: Rosetta) -> ()
    ) -> Bool {
      
      return self.decode(file: file, line: line, function: function, JSON.Data(jsonData), to: &object, usingMap: map)
  }
  
  public func decode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonString: String,
    inout to object: T,
    usingMap map: (T, json: Rosetta) -> ()
    ) -> Bool {
      
      let input = JSON.String(jsonString)
      return self.decode(file: file, line: line, function: function, input, to: &object, usingMap: map)
  }
  
  public func decode<T: Creatable>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonData: NSData,
    usingMap map: (T, json: Rosetta) -> ()
    ) -> T? {
      
      var object = T()
      if self.decode(file: file, line: line, function: function, jsonData, to: &object, usingMap: map) == false {
        return nil
      }
      return object
  }
  
  public func decode<T: Creatable>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonString: String,
    usingMap map: (T, json: Rosetta) -> ()
    ) -> T? {
      
      var object = T()
      if self.decode(file: file, line: line, function: function, jsonString, to: &object, usingMap: map) == false {
        return nil
      }
      return object
  }
  
  public func decode<T: MappableClass>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonData: NSData,
    inout to object: T
    ) -> Bool {
      
      return self.decode(file: file, line: line, function: function, jsonData, to: &object, usingMap: T.map)
  }
  
  public func decode<T: MappableClass>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonString: String,
    inout to object: T
    ) -> Bool {
      
      return self.decode(file: file, line: line, function: function, jsonString, to: &object, usingMap: T.map)
  }
  
  public func decode<T: JSONConvertibleClass>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonData: NSData
    ) -> T? {
      
      var object = T()
      if self.decode(file: file, line: line, function: function, jsonData, to: &object, usingMap: T.map) == false {
        return nil
      }
      return object
  }
  
  public func decode<T: JSONConvertibleClass>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ jsonString: String
    ) -> T? {
      
      var object = T()
      if self.decode(file: file, line: line, function: function, jsonString, to: &object, usingMap: T.map) == false {
        return nil
      }
      return object
  }
}

//MARK: Class types encoding
extension Rosetta {
  public func encode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ obj: T,
    usingMap map: (T, json: Rosetta) -> ()
    ) -> NSData? {
      
      var data: NSData?
      if let json: [String: AnyObject] = self.encode(file: file, line: line, function: function, obj, usingMap: map) {
        // TODO: Add json parsing error
        data = NSJSONSerialization.dataWithJSONObject(json, options: nil, error: nil)
      }
      return data
  }
  
  public func encode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ obj: T,
    usingMap map: (T, json: Rosetta) -> ()
    ) -> String? {
      
      var string: String?
      if let data: NSData = self.encode(file: file, line: line, function: function, obj, usingMap: map) {
        string = data.toString()
        if string == nil {
          // TODO: Add error
        }
      }
      return string
  }
  
  public func encode<T: MappableClass>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ obj: T
    ) -> NSData? {
      
      return self.encode(file: file, line: line, function: function, obj, usingMap: T.map)
  }
  
  public func encode<T: MappableClass>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ obj: T
    ) -> String? {
      
      return self.encode(file: file, line: line, function: function, obj, usingMap: T.map)
  }
}
