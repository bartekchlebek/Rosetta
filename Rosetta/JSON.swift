import Foundation

private enum Source {
	case Data(NSData)
	case String(Swift.String)
	case Array([AnyObject])
	case Dictionary([Swift.String: AnyObject])
}

final class JSON: CustomStringConvertible {
	private let source: Source

	lazy var data: NSData? = {
		switch self.source {
		case .Data(let data): return data
		case .String(let string): return string.toData()
		case .Array(let array): return try? NSJSONSerialization.dataWithJSONObject(array, options: [])
		case .Dictionary(let dictionary): return try? NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
		}
	}()

	lazy var string: String? = {
		switch self.source {
		case .Data(let data): return data.toString()
		case .String(let string): return string
		case .Array(let array): return self.data?.toString()
		case .Dictionary(let dictionary): return self.data?.toString()
		}
	}()

	lazy var dictionary: [String: AnyObject]? = {
		switch self.source {
		case .Data(let data):
			guard let object = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else { return nil }
			return object as? [String: AnyObject]
		case .String(let string):
			guard let data = self.data else { return nil }
			guard let object = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else { return nil }
			return object as? [String: AnyObject]
		case .Array(let array): return nil
		case .Dictionary(let dictionary): return dictionary
		}
	}()

	lazy var array: [AnyObject]? = {
		switch self.source {
		case .Data(let data):
			guard let object = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else { return nil }
			return object as? [AnyObject]
		case .String(let string):
			guard let data = self.data else { return nil }
			guard let object = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else { return nil }
			return object as? [AnyObject]
		case .Array(let array): return array
		case .Dictionary(let dictionary): return nil
		}
	}()

	var description: String {
		return ""
	}

	init(data: NSData) {
		self.source = .Data(data)
	}

	init(string: String) {
		self.source = .String(string)
	}

	init(dictionary: [String: AnyObject]) {
		self.source = .Dictionary(dictionary)
	}

	init(array: [AnyObject]) {
		self.source = .Array(array)
	}
}

extension JSON {
	func toData() throws -> NSData {
		if let data = self.data {
			return data
		}
		else {
			throw genericError
		}
	}

	func toString() throws -> Swift.String {
		if let string = self.string {
			return string
		}
		else {
			throw genericError
		}
	}

	func toArray() throws -> [AnyObject] {
		if let array = self.array {
			return array
		}
		else {
			throw genericError
		}
	}

	func toDictionary() throws -> [String: AnyObject] {
		if let dictionary = self.dictionary {
			return dictionary
		}
		else {
			throw genericError
		}
	}
}
