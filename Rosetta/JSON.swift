import Foundation

private enum Source {
	case data(Foundation.Data)
	case string(Swift.String)
	case array([AnyObject])
	case dictionary([Swift.String: AnyObject])
}

final class JSON: CustomStringConvertible {
	private let source: Source

	lazy var data: Data? = {
		switch self.source {
		case .data(let data): return data
		case .string(let string): return string.toData()
		case .array(let array): return try? JSONSerialization.data(withJSONObject: array, options: [])
		case .dictionary(let dictionary): return try? JSONSerialization.data(withJSONObject: dictionary, options: [])
		}
	}()

	lazy var string: String? = {
		switch self.source {
		case .data(let data): return data.toString()
		case .string(let string): return string
		case .array(let array): return self.data?.toString()
		case .dictionary(let dictionary): return self.data?.toString()
		}
	}()

	lazy var dictionary: [String: AnyObject]? = {
		switch self.source {
		case .data(let data):
			guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
			return object as? [String: AnyObject]
		case .string(let string):
			guard let data = self.data else { return nil }
			guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
			return object as? [String: AnyObject]
		case .array(let array): return nil
		case .dictionary(let dictionary): return dictionary
		}
	}()

	lazy var array: [AnyObject]? = {
		switch self.source {
		case .data(let data):
			guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
			return object as? [AnyObject]
		case .string(let string):
			guard let data = self.data else { return nil }
			guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
			return object as? [AnyObject]
		case .array(let array): return array
		case .dictionary(let dictionary): return nil
		}
	}()

	var description: String {
		return ""
	}

	init(data: Data) {
		self.source = .data(data)
	}

	init(string: String) {
		self.source = .string(string)
	}

	init(dictionary: [String: AnyObject]) {
		self.source = .dictionary(dictionary)
	}

	init(array: [AnyObject]) {
		self.source = .array(array)
	}
}

extension JSON {
	func toData() throws -> Data {
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
