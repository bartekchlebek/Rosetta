import Foundation

public enum Log {
  case StringToData(string: String)
  case DataToJSON(data: NSData, error: NSError?)
  case Mapping(severity: Severity, type: MapType, keyPath: [String])
  
  public enum Severity {
    case Warning
    case Error
  }
  
  public enum MapType {
    case WrongType
    case ValueMissing
    case ValidationFailed
    case BridgingFailed
  }
}

extension Log: Printable {
  public var description: String {
    var string = ""
    switch self {
    case let .StringToData(info):
      string += "String to NSData conversion failed"
      string += "\n"
      string += "String:\(info.string)"
    case let .DataToJSON(info):
      string += "NSJSONSerialization failed"
      string += "\n"
      string += "Data:\(info.data)"
      if let dataString = NSString(data: info.data, encoding: NSUTF8StringEncoding) {
        string += "\n"
        string += "String:\(dataString)"
      }
      if let error = info.error {
        string += "\n"
        string += "Error:\(error)"
      }
    case let .Mapping(info):
      switch info.severity {
      case .Error:
        string += "Error:"
      case .Warning:
        string += "Warning:"
      }
      switch info.type {
      case .BridgingFailed:
        string += " Bridging Failed"
      case .ValidationFailed:
        string += " Validation Failed"
      case .ValueMissing:
        string += " Value Missing"
      case .WrongType:
        string += " Wrong Type"
      }
      string += " for key-path: "
      string += ".".join(info.keyPath)
    }
    return string
  }
}

func LogsContainError(logs: [Log]) -> Bool {
  for log in logs {
    switch log {
    case .StringToData:
      return true
    case .DataToJSON:
      return true
    case let .Mapping(info):
      if info.severity == .Error {
        return true
      }
    }
  }
  return false
}

public enum LogLevel {
  case None
  case Errors
  case Verbose
}
