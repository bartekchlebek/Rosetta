import Foundation

public enum Log {
	case stringToData(string: String)
	case dataToJSON(data: Data, error: NSError?)
	case mapping(severity: Severity, type: MapType, keyPath: [String])

	public enum Severity {
		case warning
		case error
	}

	public enum MapType {
		case wrongType
		case valueMissing
		case validationFailed
		case bridgingFailed
	}
}

extension Log: CustomStringConvertible {
	public var description: String {
		var string = ""
		switch self {
		case let .stringToData(info):
			string += "String to NSData conversion failed"
			string += "\n"
			string += "String:\(info)"
		case let .dataToJSON(info):
			string += "NSJSONSerialization failed"
			string += "\n"
			string += "Data:\(info.data)"
			if let dataString = NSString(data: info.data, encoding: String.Encoding.utf8.rawValue) {
				string += "\n"
				string += "String:\(dataString)"
			}
			if let error = info.error {
				string += "\n"
				string += "Error:\(error)"
			}
		case let .mapping(info):
			switch info.severity {
			case .error:
				string += "Error:"
			case .warning:
				string += "Warning:"
			}
			switch info.type {
			case .bridgingFailed:
				string += " Bridging Failed"
			case .validationFailed:
				string += " Validation Failed"
			case .valueMissing:
				string += " Value Missing"
			case .wrongType:
				string += " Wrong Type"
			}
			string += " for key-path: "
			string += info.keyPath.joined(separator: ".")
		}
		return string
	}
}

func LogsContainError(_ logs: [Log]) -> Bool {
	for log in logs {
		switch log {
		case .stringToData:
			return true
		case .dataToJSON:
			return true
		case let .mapping(info):
			if info.severity == .error {
				return true
			}
		}
	}
	return false
}

public enum LogLevel {
	case none
	case errors
	case verbose
}
