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

extension JSON {
	func toDictionary() -> ([Swift.String: AnyObject]?, [Log]?) {
		var logs: [Log] = []

		let parseData = {(data: NSData) -> ([Swift.String: AnyObject]?) in
			do {
				let JSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
				if let dictionary = JSONObject as? [Swift.String: AnyObject] {
					return dictionary
				}
				else {
					logs.append(Log.DataToJSON(data: data, error: NSError(domain: "Rosetta", code: -1, userInfo: nil)))
					return nil
				}
			}
			catch let error as NSError {
				logs.append(Log.DataToJSON(data: data, error: error))
				return nil
			}
		}

		let parseString = {(string: Swift.String) -> ([Swift.String: AnyObject]?) in
			if let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
				return parseData(data)
			}
			else {
				logs.append(Log.StringToData(string: string))
				return nil
			}
		}

		var jsonDictionary: [Swift.String: AnyObject]?
		switch self {
		case let .String(string):
			jsonDictionary = parseString(string)
		case let .Data(data):
			jsonDictionary = parseData(data)
		}

		if (jsonDictionary != nil) {
			return (jsonDictionary, nil)
		}
		else {
			return (nil, logs)
		}
	}
}
