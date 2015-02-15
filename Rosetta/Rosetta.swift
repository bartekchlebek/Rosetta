import Foundation

public enum JSON {
  case Data(NSData)
  case String(Swift.String)
  
  var stringValue: Swift.String? {
    switch self {
    case let .Data(data):
      return NSString(data: data, encoding: NSUTF8StringEncoding) as? Swift.String
    case let .String(string):
      return string
    }
  }
  
  var dataValue: NSData? {
    switch self {
    case let .Data(data):
      return data
    case let .String(string):
      return string.toData()
    }
  }
}

enum Mode {
  case Decode
  case Encode
}

public class Rosetta {
  var keyPath: [String] = []
  var currentValue: AnyObject! {
    return valueForKeyPath(keyPath, inDictionary: dictionary)
  }
  var currentMode: Mode!
  var dictionary: [String: AnyObject]!
  var logs: [Log] = []
  
  public var logLevel: LogLevel = .Errors
  public typealias LogFormatter
    = (json: JSON?, logs: [Log], file: StaticString, line: UWord, function: StaticString) -> String
  public typealias LogHandler = (logString: String) -> ()
  public var logFormatter: LogFormatter = {
    json, logs, file, line, function in
    
    var string = "Rosetta"
    
    // "\(file)" is used instead of file.stringValue, because it causes compiler warning:
    // integer overflows when converted from 'Builtin.Int32' to 'Builtin.Int8'
    let fileString = "\(file)".componentsSeparatedByString("/").last ?? "\(file)"
    string += "\n"
    string += "\(fileString):\(line) \(function)"
    
    if let jsonString = json?.stringValue {
      string += "\n"
      string += "JSON String: \(jsonString)"
    }
    else if let jsonData = json?.dataValue {
      string += "\n"
      string += "JSON Data: \(jsonData)"
    }
    
    string += "\n"
    string += "\n".join(logs.map({$0.description}))
    return string
  }
  public var logHandler: LogHandler = {println("\($0)\n--------")}
  public func setLogFormatter(formatter: LogFormatter) {
    logFormatter = formatter
  }
  public func setLogHandler(handler: LogHandler) {
    logHandler = handler
  }
  
  public init() {
    
  }
  
  public subscript(key: String) -> Rosetta {
    get {
      keyPath.append(key)
      return self
    }
  }
  
  //MARK: Structure types decoding
  
  func decode<T>(
    input: JSON,
    inout to object: T,
    usingMap map: (Rosetta, inout object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> Bool {
      
      // prepare rosetta
      currentMode = .Decode
      var jsonData: NSData?
      
      let parseData = {(data: NSData) -> ([String: AnyObject]?) in
        jsonData = data
        var error = NSErrorPointer()
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: error) as? [String: AnyObject] {
          return json
        }
        else {
          self.logs.append(Log.DataToJSON(data: data, error: error.memory))
          return nil
        }
      }
      
      let parseString = {(string: String) -> ([String: AnyObject]?) in
        if let data = string.toData() {
          return parseData(data)
        }
        else {
          self.logs.append(Log.StringToData(string: string))
          return nil
        }
      }
      
      var jsonDictionary: [String: AnyObject]?
      switch input {
      case let .String(string):
        jsonDictionary = parseString(string)
      case let .Data(data):
        jsonDictionary = parseData(data)
      }
      
      var localObject = object
      if let jsonDictionary = jsonDictionary {
        dictionary = jsonDictionary
        // map
        map(self, object: &localObject)
      }
      
      var success = !LogsContainError(logs)
      if success == true {
        object = localObject
      }
      
      switch logLevel {
      case .None:
        break
      case .Errors:
        if success == false {
          logHandler(logString: logFormatter(json: input, logs: logs, file: file, line: line, function: function))
        }
      case .Verbose:
        if logs.count > 0 {
          logHandler(logString: logFormatter(json: input, logs: logs, file: file, line: line, function: function))
        }
      }
      
      cleanup()
      return success
  }
  
  public func decode<T>(
    jsonData: NSData,
    inout to object: T,
    usingMap map: (Rosetta, inout object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> Bool {
      
      return self.decode(JSON.Data(jsonData), to: &object, usingMap: map, file: file, line: line, function: function)
  }
  
  public func decode<T>(
    jsonString: String,
    inout to object: T,
    usingMap map: (Rosetta, inout object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> Bool {
      
      let input = JSON.String(jsonString)
      return self.decode(input, to: &object, usingMap: map, file: file, line: line, function: function)
  }
  
  public func decode<T: Creatable>(
    jsonData: NSData,
    usingMap map: (Rosetta, inout object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> T? {
      
      var object = T()
      if self.decode(jsonData, to: &object, usingMap: map, file: file, line: line, function: function) == false {
        return nil
      }
      return object
  }
  
  public func decode<T: Creatable>(
    jsonString: String,
    usingMap map: (Rosetta, inout object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> T? {
      
      var object = T()
      if self.decode(jsonString, to: &object, usingMap: map, file: file, line: line, function: function) == false {
        return nil
      }
      return object
  }
  
  public func decode<T: Mappable>(
    jsonData: NSData,
    inout to object: T,
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> Bool {
      
      let map = {(x: Rosetta, inout y: T) -> () in T.map(x, object: &y)}
      return self.decode(jsonData, to: &object, usingMap: map, file: file, line: line, function: function)
  }
  
  public func decode<T: Mappable>(
    jsonString: String,
    inout to object: T,
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> Bool {
      
      let map = {(x: Rosetta, inout y: T) -> () in T.map(x, object: &y)}
      return self.decode(jsonString, to: &object, usingMap: map, file: file, line: line, function: function)
  }
  
  public func decode<T: JSONConvertible>(
    jsonData: NSData,
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> T? {
      
      var object = T()
      let map = {(x: Rosetta, inout y: T) -> () in T.map(x, object: &y)}
      if self.decode(jsonData, to: &object, usingMap: map, file: file, line: line, function: function) == false {
        return nil
      }
      return object
  }
  
  public func decode<T: JSONConvertible>(
    jsonString: String,
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> T? {
      
      var object = T()
      let map = {(x: Rosetta, inout y: T) -> () in T.map(x, object: &y)}
      if self.decode(jsonString, to: &object, usingMap: map, file: file, line: line, function: function) == false {
        return nil
      }
      return object
  }
  
  //MARK: Structure types encoding
  
  func encode<T>(
    object: T,
    usingMap map: (Rosetta, inout object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> [String: AnyObject]? {
      
      // prepare rosetta
      currentMode = .Encode
      dictionary = [:]
      
      // parse
      var mutableObject = object
      map(self, object: &mutableObject)
      
      let result = dictionary
      let logs = self.logs
      
      let success = !LogsContainError(logs)
      switch logLevel {
      case .None:
        break
      case .Errors:
        if success == false {
          logHandler(logString: logFormatter(json: nil, logs: logs, file: file, line: line, function: function))
        }
      case .Verbose:
        if logs.count > 0 {
          logHandler(logString: logFormatter(json: nil, logs: logs, file: file, line: line, function: function))
        }
      }
      
      cleanup()
      return success ? result : nil
  }
  
  public func encode<T>(
    obj: T,
    usingMap map: (Rosetta, inout object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> NSData? {
      
      var data: NSData?
      if let json: [String: AnyObject] = self.encode(obj, usingMap: map, file: file, line: line, function: function) {
        // TODO: Add json parsing error
        data = NSJSONSerialization.dataWithJSONObject(json, options: nil, error: nil)
      }
      return data
  }
  
  public func encode<T>(
    obj: T,
    usingMap map: (Rosetta, inout object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> String? {
      
      var string: String?
      if let data: NSData = self.encode(obj, usingMap: map, file: file, line: line, function: function) {
        string = data.toString()
        if string == nil {
          // TODO: Add error
        }
      }
      return string
  }
  
  public func encode<T: Mappable>(
    obj: T,
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> NSData? {
      
      let map = {(x: Rosetta, inout y: T) -> () in T.map(x, object: &y)}
      return self.encode(obj, usingMap: map, file: file, line: line, function: function)
  }
  
  public func encode<T: Mappable>(
    obj: T,
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> String? {
      
      let map = {(x: Rosetta, inout y: T) -> () in T.map(x, object: &y)}
      return self.encode(obj, usingMap: map, file: file, line: line, function: function)
  }
  
  //MARK: Class types decoding
  
  func decode<T>(
    input: JSON,
    inout to object: T,
    usingMap map: (Rosetta, object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> Bool {
      
      // prepare rosetta
      currentMode = .Decode
      var jsonData: NSData?
      
      let parseData = {(data: NSData) -> ([String: AnyObject]?) in
        jsonData = data
        var error = NSErrorPointer()
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: error) as? [String: AnyObject] {
          return json
        }
        else {
          self.logs.append(Log.DataToJSON(data: data, error: error.memory))
          return nil
        }
      }
      
      let parseString = {(string: String) -> ([String: AnyObject]?) in
        if let data = string.toData() {
          return parseData(data)
        }
        else {
          self.logs.append(Log.StringToData(string: string))
          return nil
        }
      }
      
      var jsonDictionary: [String: AnyObject]?
      switch input {
      case let .String(string):
        jsonDictionary = parseString(string)
      case let .Data(data):
        jsonDictionary = parseData(data)
      }
      
      var localObject = object
      if let jsonDictionary = jsonDictionary {
        dictionary = jsonDictionary
        // map
        map(self, object: localObject)
      }
      
      var success = !LogsContainError(logs)
      if success == true {
        object = localObject
      }
      
      switch logLevel {
      case .None:
        break
      case .Errors:
        if success == false {
          logHandler(logString: logFormatter(json: input, logs: logs, file: file, line: line, function: function))
        }
      case .Verbose:
        if logs.count > 0 {
          logHandler(logString: logFormatter(json: input, logs: logs, file: file, line: line, function: function))
        }
      }
      
      cleanup()
      return success
  }
  
  public func decode<T>(
    jsonData: NSData,
    inout to object: T,
    usingMap map: (Rosetta, object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> Bool {
      
      return self.decode(JSON.Data(jsonData), to: &object, usingMap: map, file: file, line: line, function: function)
  }
  
  public func decode<T>(
    jsonString: String,
    inout to object: T,
    usingMap map: (Rosetta, object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> Bool {
      
      let input = JSON.String(jsonString)
      return self.decode(input, to: &object, usingMap: map, file: file, line: line, function: function)
  }
  
  public func decode<T: Creatable>(
    jsonData: NSData,
    usingMap map: (Rosetta, object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> T? {
      
      var object = T()
      if self.decode(jsonData, to: &object, usingMap: map, file: file, line: line, function: function) == false {
        return nil
      }
      return object
  }
  
  public func decode<T: Creatable>(
    jsonString: String,
    usingMap map: (Rosetta, object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> T? {
      
      var object = T()
      if self.decode(jsonString, to: &object, usingMap: map, file: file, line: line, function: function) == false {
        return nil
      }
      return object
  }
  
  public func decode<T: MappableClass>(
    jsonData: NSData,
    inout to object: T,
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> Bool {
      
      let map = {(x: Rosetta, y: T) -> () in T.map(x, object: y)}
      return self.decode(jsonData, to: &object, usingMap: map, file: file, line: line, function: function)
  }
  
  public func decode<T: MappableClass>(
    jsonString: String,
    inout to object: T,
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> Bool {
      
      let map = {(x: Rosetta, y: T) -> () in T.map(x, object: y)}
      return self.decode(jsonString, to: &object, usingMap: map, file: file, line: line, function: function)
  }
  
  public func decode<T: JSONConvertibleClass>(
    jsonData: NSData,
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> T? {
      
      var object = T()
      let map = {(x: Rosetta, y: T) -> () in T.map(x, object: y)}
      if self.decode(jsonData, to: &object, usingMap: map, file: file, line: line, function: function) == false {
        return nil
      }
      return object
  }
  
  public func decode<T: JSONConvertibleClass>(
    jsonString: String,
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> T? {
      
      var object = T()
      let map = {(x: Rosetta, y: T) -> () in T.map(x, object: y)}
      if self.decode(jsonString, to: &object, usingMap: map, file: file, line: line, function: function) == false {
        return nil
      }
      return object
  }
  
  //MARK: Class types encoding
  
  func encode<T>(
    object: T,
    usingMap map: (Rosetta, object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> [String: AnyObject]? {
      
      // prepare rosetta
      currentMode = .Encode
      dictionary = [:]
      
      // parse
      var mutableObject = object
      map(self, object: mutableObject)
      
      let result = dictionary
      let logs = self.logs
      
      let success = !LogsContainError(logs)
      switch logLevel {
      case .None:
        break
      case .Errors:
        if success == false {
          logHandler(logString: logFormatter(json: nil, logs: logs, file: file, line: line, function: function))
        }
      case .Verbose:
        if logs.count > 0 {
          logHandler(logString: logFormatter(json: nil, logs: logs, file: file, line: line, function: function))
        }
      }
      
      cleanup()
      return success ? result : nil
  }
  
  public func encode<T>(
    obj: T,
    usingMap map: (Rosetta, object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> NSData? {
      
      var data: NSData?
      if let json: [String: AnyObject] = self.encode(obj, usingMap: map, file: file, line: line, function: function) {
        // TODO: Add json parsing error
        data = NSJSONSerialization.dataWithJSONObject(json, options: nil, error: nil)
      }
      return data
  }
  
  public func encode<T>(
    obj: T,
    usingMap map: (Rosetta, object: T) -> (),
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> String? {
      
      var string: String?
      if let data: NSData = self.encode(obj, usingMap: map, file: file, line: line, function: function) {
        string = data.toString()
        if string == nil {
          // TODO: Add error
        }
      }
      return string
  }
  
  public func encode<T: MappableClass>(
    obj: T,
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> NSData? {
      
      let map = {(x: Rosetta, y: T) -> () in T.map(x, object: y)}
      return self.encode(obj, usingMap: map, file: file, line: line, function: function)
  }
  
  public func encode<T: MappableClass>(
    obj: T,
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__
    ) -> String? {
      
      let map = {(x: Rosetta, y: T) -> () in T.map(x, object: y)}
      return self.encode(obj, usingMap: map, file: file, line: line, function: function)
  }
  
  //MARK: Helpers
  
  func cleanup() {
    currentMode = nil
    dictionary = nil
    logs.removeAll(keepCapacity: false)
  }
}

//MARK: Decoding

func decode<T, U, V>(
  #value: U?,
  #rosetta: Rosetta,
  #bridge: Bridge<T, V>,
  #validator: (T -> Bool)?,
  #optional: Bool) -> T? {
    
    let severity: Log.Severity = optional ? .Warning : .Error
    var decodedValue: T?
    if let value = value {
      if let value = value as? V {
        if let value = bridge.decoder(value) {
          if validator?(value) ?? true {
            decodedValue = value
          }
          else {
            rosetta.logs.append(Log.Mapping(severity: severity, type: .ValidationFailed, keyPath: rosetta.keyPath))
          }
        }
        else if optional == false {
          rosetta.logs.append(Log.Mapping(severity: severity, type: .BridgingFailed, keyPath: rosetta.keyPath))
        }
      }
      else if optional == false {
        rosetta.logs.append(Log.Mapping(severity: severity, type: .WrongType, keyPath: rosetta.keyPath))
      }
    }
    else if optional == false {
      rosetta.logs.append(Log.Mapping(severity: severity, type: .ValueMissing, keyPath: rosetta.keyPath))
    }
    rosetta.keyPath.removeAll(keepCapacity: false)
    return decodedValue
}

func decodeTo<T, U, V>(
  inout property: T,
  #value: U?,
  #rosetta: Rosetta,
  #bridge: Bridge<T, V>,
  #validator: (T -> Bool)?,
  #optional: Bool) {
    
    let decoded = decode(value: value, rosetta: rosetta, bridge: bridge, validator: validator, optional: optional)
    if let decoded = decoded {
      property = decoded
    }
}

func decodeTo<T, U, V>(
  inout property: T!,
  #value: U?,
  #rosetta: Rosetta,
  #bridge: Bridge<T, V>,
  #validator: (T -> Bool)?,
  #optional: Bool) {
    
    let decoded = decode(value: value, rosetta: rosetta, bridge: bridge, validator: validator, optional: optional)
    if let decoded = decoded {
      property = decoded
    }
}

func decodeTo<T, U, V>(
  inout property: T?,
  #value: U?,
  #rosetta: Rosetta,
  #bridge: Bridge<T, V>,
  #validator: (T -> Bool)?,
  #optional: Bool) {
    
    let decoded = decode(value: value, rosetta: rosetta, bridge: bridge, validator: validator, optional: optional)
    if let decoded = decoded {
      property = decoded
    }
}

//MARK: Encoding

func encodeFrom<T, U>(
  property: T?,
  #rosetta: Rosetta,
  #bridge: Bridge<T, U>,
  #validator: (T -> Bool)?,
  #optional: Bool) {
    
    let severity: Log.Severity = optional ? .Warning : .Error
    if let property = property {
      if validator?(property) ?? true {
        if let encodedValue = bridge.encoder(property) {
          setValue(encodedValue, atKeyPath: rosetta.keyPath, inDictionary: &rosetta.dictionary!)
        }
        else {
          rosetta.logs.append(Log.Mapping(severity: severity, type: .BridgingFailed, keyPath: rosetta.keyPath))
        }
      }
      else {
        rosetta.logs.append(Log.Mapping(severity: severity, type: .ValidationFailed, keyPath: rosetta.keyPath))
      }
    }
    else {
      rosetta.logs.append(Log.Mapping(severity: severity, type: .ValueMissing, keyPath: rosetta.keyPath))
    }
    rosetta.keyPath.removeAll(keepCapacity: false)
}

// ------------------------------------------------

func valueForKeyPath(keyPath: [String], inDictionary dictionary: [String: AnyObject]) -> AnyObject? {
  if keyPath.count == 0 {
    return dictionary
  }
  else {
    var branch = dictionary
    for index in 0..<keyPath.count - 1 {
      if let subdict = branch[keyPath[index]] as? [String: AnyObject] {
        branch = subdict
      }
      else {
        return nil
      }
    }
    return branch[keyPath.last!]
  }
}

func dictionaryBySettingValue(
  value: AnyObject,
  forKeyPath keyPath: [String],
  inDictionary dictionary: [String: AnyObject]
  ) -> [String: AnyObject] {
    
    if keyPath.count == 0 {
      NSException(name: NSInternalInconsistencyException, reason: "ketPath must not be empty", userInfo: nil).raise()
      abort()
    }
    else if keyPath.count == 1 {
      var dictionary = dictionary
      dictionary[keyPath.first!] = value
      return dictionary
    }
    else {
      var dictionary = dictionary
      let firstKey = keyPath[0]
      var keyPath = keyPath
      keyPath.removeAtIndex(0)
      if let subdict = dictionary[firstKey] as? [String: AnyObject] {
        dictionary[firstKey] = dictionaryBySettingValue(value, forKeyPath: keyPath, inDictionary: subdict)
      }
      else {
        dictionary[firstKey] = dictionaryBySettingValue(value, forKeyPath: keyPath, inDictionary: [:])
      }
      return dictionary
    }
}

func setValue(value: AnyObject, atKeyPath keyPath: [String], inout inDictionary dictionary: [String: AnyObject]) {
  dictionary = dictionaryBySettingValue(value, forKeyPath: keyPath, inDictionary: dictionary)
}

extension String {
  func toData() -> NSData? {
    return self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
  }
}

extension NSData {
  func toDictionary() -> [String: AnyObject]? {
    return NSJSONSerialization.JSONObjectWithData(self, options: nil, error: nil) as? [String: AnyObject]
  }
  
  func toString() -> String? {
    return NSString(data: self, encoding: NSUTF8StringEncoding) as? String
  }
}
