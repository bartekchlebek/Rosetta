import Foundation

let genericError = NSError(domain: "Rosetta", code: -1, userInfo: nil)

private struct FakeProxy<T> { }

//MARK: Array encoding
extension Rosetta {
	private func encode<T, U>(obj: [T], usingElementBridge elementBridge: Bridge<T, U>, validator: ([T] -> Bool)?) throws -> JSON {
		let proxy = FakeProxy<T>()
		var objects: [T] = obj
		let json = try encode(proxy, usingMap: Map<FakeProxy<T>>.ValueTypeMap {
			objects <- $1["array"] ~ BridgeArray(elementBridge) § validator
			}
		)
		var dictionary = try json.toDictionary()
		guard let array = dictionary["array"] as? [AnyObject] else {
			throw genericError
		}
		return JSON(array: array)
	}

	func encode<T: Bridgeable>(obj: [T], validator: ([T] -> Bool)? = nil) throws -> JSON {
		return try encode(obj, usingElementBridge: T.bridge(), validator: validator)
	}

	public func encode<T: Bridgeable>(obj: [T], validator: ([T] -> Bool)? = nil) throws -> String {
		return try encode(obj, validator: validator).toString()
	}

	public func encode<T: Bridgeable>(obj: [T], validator: ([T] -> Bool)? = nil) throws -> NSData {
		return try encode(obj, validator: validator).toData()
	}

	func encode<T: JSONConvertible>(obj: [T]) throws -> JSON {
		return try encode(obj, usingElementBridge: JSONConvertibleBridge(), validator: nil)
	}

	public func encode<T: JSONConvertible>(obj: [T]) throws -> NSData {
		return try encode(obj).toData()
	}

	public func encode<T: JSONConvertible>(obj: [T]) throws -> String {
		return try encode(obj).toString()
	}

	func encode<T: JSONConvertibleClass>(obj: [T]) throws -> JSON {
		return try encode(obj, usingElementBridge: JSONConvertibleClassBridge(), validator: nil)
	}

	public func encode<T: JSONConvertibleClass>(obj: [T]) throws -> NSData {
		return try encode(obj).toData()
	}

	public func encode<T: JSONConvertibleClass>(obj: [T]) throws -> String {
		return try encode(obj).toString()
	}
}

//MARK: Array decoding
extension Rosetta {
	private func decode<T, U>(json: JSON, usingElementBridge elementBridge: Bridge<T, U>, validator: ([T] -> Bool)?) throws -> [T] {
		let jsonString = try json.toString()
		let json = JSON(string: "{\"array\":" + jsonString + "}")
		var proxy = FakeProxy<T>()
		var objects: [T]? = nil
		try decode(json, to: &proxy, usingMap: Map<FakeProxy<T>>.ValueTypeMap {
				objects <- $1["array"] ~ BridgeArray(elementBridge) § validator
			}
		)
		guard let unwrappedObjects = objects else { throw genericError }
		return unwrappedObjects
	}

	func decode<T, U>(json: JSON, usingElementBridge elementBridge: Bridge<T, U>) throws -> [T] {
		return try decode(json, usingElementBridge: elementBridge, validator: nil)
	}

	public func decode<T, U>(json: NSData, usingElementBridge elementBridge: Bridge<T, U>) throws -> [T] {
		return try decode(JSON(data: json), usingElementBridge: elementBridge, validator: nil)
	}

	public func decode<T: Bridgeable>(json: NSData, validator: ([T] -> Bool)? = nil) throws -> [T] {
		return try decode(JSON(data: json), usingElementBridge: T.bridge(), validator: validator)
	}

	func decode<T: JSONConvertible>(json: JSON) throws -> [T] {
		return try decode(json, usingElementBridge: JSONConvertibleBridge(), validator: nil)
	}

	public func decode<T: JSONConvertible>(json: NSData) throws -> [T] {
		return try decode(JSON(data: json), usingElementBridge: JSONConvertibleBridge(), validator: nil)
	}

	public func decode<T: JSONConvertibleClass>(json: NSData) throws -> [T] {
		return try decode(JSON(data: json), usingElementBridge: JSONConvertibleClassBridge(), validator: nil)
	}
}

//MARK: Dictionary decoding
extension Rosetta {
	private func decode<T, U>(json: JSON, usingElementBridge elementBridge: Bridge<T, U>, validator: ([String: T] -> Bool)?) throws -> [String: T] {
		let jsonString = try json.toString()
		let json = JSON(string: "{\"dictionary\":" + jsonString + "}")
		var proxy = FakeProxy<T>()
		var objects: [String: T]? = nil
		try decode(json, to: &proxy, usingMap: Map<FakeProxy<T>>.ValueTypeMap {
			objects <- $1["dictionary"] ~ BridgeObject(elementBridge) § validator
			}
		)
		guard let unwrappedObjects = objects else { throw genericError }
		return unwrappedObjects
	}

	func decode<T, U>(json: JSON, usingElementBridge elementBridge: Bridge<T, U>) throws -> [String: T] {
		return try decode(json, usingElementBridge: elementBridge, validator: nil)
	}

	public func decode<T, U>(json: String, usingElementBridge elementBridge: Bridge<T, U>) throws -> [String: T] {
		return try decode(JSON(string: json), usingElementBridge: elementBridge, validator: nil)
	}

	public func decode<T, U>(json: NSData, usingElementBridge elementBridge: Bridge<T, U>) throws -> [String: T] {
		return try decode(JSON(data: json), usingElementBridge: elementBridge, validator: nil)
	}

	func decode<T: Bridgeable>(json: JSON, validator: ([String: T] -> Bool)? = nil) throws -> [String: T] {
		return try decode(json, usingElementBridge: T.bridge(), validator: validator)
	}

	public func decode<T: Bridgeable>(json: String, validator: ([String: T] -> Bool)? = nil) throws -> [String: T] {
		return try decode(JSON(string: json), usingElementBridge: T.bridge(), validator: validator)
	}

	public func decode<T: Bridgeable>(json: NSData, validator: ([String: T] -> Bool)? = nil) throws -> [String: T] {
		return try decode(JSON(data: json), usingElementBridge: T.bridge(), validator: validator)
	}

	func decode<T: JSONConvertible>(json: JSON) throws -> [String: T] {
		return try decode(json, usingElementBridge: JSONConvertibleBridge(), validator: nil)
	}

	public func decode<T: JSONConvertible>(json: String) throws -> [String: T] {
		return try decode(JSON(string: json), usingElementBridge: JSONConvertibleBridge(), validator: nil)
	}

	public func decode<T: JSONConvertible>(json: NSData) throws -> [String: T] {
		return try decode(JSON(data: json), usingElementBridge: JSONConvertibleBridge(), validator: nil)
	}

	func decode<T: JSONConvertibleClass>(json: JSON) throws -> [String: T] {
		return try decode(json, usingElementBridge: JSONConvertibleClassBridge(), validator: nil)
	}

	public func decode<T: JSONConvertibleClass>(json: String) throws -> [String: T] {
		return try decode(JSON(string: json), usingElementBridge: JSONConvertibleClassBridge(), validator: nil)
	}

	public func decode<T: JSONConvertibleClass>(json: NSData) throws -> [String: T] {
		return try decode(JSON(data: json), usingElementBridge: JSONConvertibleClassBridge(), validator: nil)
	}
}

//MARK: Dictionary encoding
extension Rosetta {
	private func encode<T, U>(obj: [String: T], usingElementBridge elementBridge: Bridge<T, U>, validator: ([String: T] -> Bool)?) throws -> JSON {
		let proxy = FakeProxy<T>()
		var objects: [String: T] = obj
		let json = try encode(proxy, usingMap: Map<FakeProxy<T>>.ValueTypeMap {
			objects <- $1["dictionary"] ~ BridgeObject(elementBridge) § validator
			}
		)
		var dictionary = try json.toDictionary()
		guard let jsonDictionary = dictionary["dictionary"] as? [String: AnyObject] else {
			throw genericError
		}
		return JSON(dictionary: jsonDictionary)
	}

	func encode<T: Bridgeable>(obj: [String: T], validator: ([String: T] -> Bool)? = nil) throws -> JSON {
		return try encode(obj, usingElementBridge: T.bridge(), validator: validator)
	}

	public func encode<T: Bridgeable>(obj: [String: T], validator: ([String: T] -> Bool)? = nil) throws -> String {
		return try encode(obj, validator: validator).toString()
	}

	public func encode<T: Bridgeable>(obj: [String: T], validator: ([String: T] -> Bool)? = nil) throws -> NSData {
		return try encode(obj, validator: validator).toData()
	}

	func encode<T: JSONConvertible>(obj: [String: T]) throws -> JSON {
		return try encode(obj, usingElementBridge: JSONConvertibleBridge(), validator: nil)
	}

	public func encode<T: JSONConvertible>(obj: [String: T]) throws -> NSData {
		return try encode(obj).toData()
	}

	public func encode<T: JSONConvertible>(obj: [String: T]) throws -> String {
		return try encode(obj).toString()
	}

	func encode<T: JSONConvertibleClass>(obj: [String: T]) throws -> JSON {
		return try encode(obj, usingElementBridge: JSONConvertibleClassBridge(), validator: nil)
	}

	public func encode<T: JSONConvertibleClass>(obj: [String: T]) throws -> NSData {
		return try encode(obj).toData()
	}

	public func encode<T: JSONConvertibleClass>(obj: [String: T]) throws -> String {
		return try encode(obj).toString()
	}
}

//MARK: Value types decoding
extension Rosetta {
	func decode<T>(json: JSON, inout to object: T, usingMap map: (inout T, Rosetta) -> ()) throws {
		return try decode(json, to: &object, usingMap: .ValueTypeMap(map))
	}

	public func decode<T>(json: NSData, inout to object: T, usingMap map: (inout T, Rosetta) -> ()) throws {
		return try decode(JSON(data: json), to: &object, usingMap: map)
	}

	public func decode<T>(json: String, inout to object: T, usingMap map: (inout T, Rosetta) -> ()) throws {
		return try decode(JSON(string: json), to: &object, usingMap: map)
	}

	func decode<T: Creatable>(json: JSON, usingMap map: (inout T, Rosetta) -> ()) throws -> T {
		var object = T()
		try decode(json, to: &object, usingMap: .ValueTypeMap(map))
		return object
	}

	public func decode<T: Creatable>(json: NSData, usingMap map: (inout T, Rosetta) -> ()) throws -> T {
		return try decode(JSON(data: json), usingMap: map)
	}

	public func decode<T: Creatable>(json: String, usingMap map: (inout T, Rosetta) -> ()) throws -> T {
		return try decode(JSON(string: json), usingMap: map)
	}

	func decode<T: Mappable>(json: JSON, inout to object: T) throws {
		return try decode(json, to: &object, usingMap: .ValueTypeMap(T.map))
	}

	public func decode<T: Mappable>(json: NSData, inout to object: T) throws {
		return try decode(JSON(data: json), to: &object, usingMap: T.map)
	}

	public func decode<T: Mappable>(json: String, inout to object: T) throws {
		return try decode(JSON(string: json), to: &object, usingMap: T.map)
	}

	func decode<T: JSONConvertible>(json: JSON) throws -> T {
		var object = T()
		try decode(json, to: &object, usingMap: .ValueTypeMap(T.map))
		return object
	}

	public func decode<T: JSONConvertible>(json: NSData) throws -> T {
		return try decode(JSON(data: json), usingMap: T.map)
	}

	public func decode<T: JSONConvertible>(json: String) throws -> T {
		return try decode(JSON(string: json), usingMap: T.map)
	}
}

//MARK: Value types encoding
extension Rosetta {
	func encode<T>(obj: T, usingMap map: (inout T, Rosetta) -> ()) throws -> JSON {
		return try encode(obj, usingMap: .ValueTypeMap(map))
	}

	public func encode<T>(obj: T, usingMap map: (inout T, Rosetta) -> ()) throws -> NSData {
		let json: JSON = try encode(obj, usingMap: map)
		guard let data = json.data else {
			throw genericError // TODO: Add json parsing error
		}
		return data
	}

	public func encode<T>(obj: T, usingMap map: (inout T, Rosetta) -> ()) throws -> String {
		let json: JSON = try encode(obj, usingMap: map)
		guard let string = json.string else {
			throw genericError // TODO: Add json parsing error
		}
		return string
	}

	func encode<T: Mappable>(obj: T) throws -> JSON {
		return try encode(obj, usingMap: .ValueTypeMap(T.map))
	}

	public func encode<T: Mappable>(obj: T) throws -> NSData {
		let json: JSON = try encode(obj)
		guard let data = json.data else {
			throw genericError // TODO: Add json parsing error
		}
		return data
	}

	public func encode<T: Mappable>(obj: T) throws -> String {
		let json: JSON = try encode(obj)
		guard let string = json.string else {
			throw genericError // TODO: Add json parsing error
		}
		return string
	}
}

//MARK: Class types decoding
extension Rosetta {
	func decode<T>(json: JSON, inout to object: T, usingMap map: (T, Rosetta) -> ()) throws {
		return try decode(json, to: &object, usingMap: .ClassTypeMap(map))
	}

	public func decode<T>(json: NSData, var to object: T, usingMap map: (T, Rosetta) -> ()) throws {
		return try decode(JSON(data: json), to: &object, usingMap: map)
	}

	public func decode<T>(json: String, var to object: T, usingMap map: (T, Rosetta) -> ()) throws {
		return try decode(JSON(string: json), to: &object, usingMap: map)
	}

	func decode<T: Creatable>(json: JSON, usingMap map: (T, Rosetta) -> ()) throws -> T {
		var object = T()
		try decode(json, to: &object, usingMap: map)
		return object
	}

	public func decode<T: Creatable>(json: NSData, usingMap map: (T, Rosetta) -> ()) throws -> T {
		return try decode(JSON(data: json), usingMap: map)
	}

	public func decode<T: Creatable>(json: String, usingMap map: (T, Rosetta) -> ()) throws -> T {
		return try decode(JSON(string: json), usingMap: map)
	}

	func decode<T: MappableClass>(json: JSON, inout to object: T) throws {
		return try decode(json, to: &object, usingMap: T.map)
	}

	public func decode<T: MappableClass>(json: NSData, inout to object: T) throws {
		return try decode(JSON(data: json), to: &object)
	}

	public func decode<T: MappableClass>(json: String, inout to object: T) throws {
		return try decode(JSON(string: json), to: &object)
	}

	func decode<T: JSONConvertibleClass>(json: JSON) throws -> T {
		var object = T()
		try decode(json, to: &object, usingMap: T.map)
		return object
	}

	public func decode<T: JSONConvertibleClass>(json: NSData) throws -> T {
		return try decode(JSON(data: json))
	}

	public func decode<T: JSONConvertibleClass>(json: String) throws -> T {
		return try decode(JSON(string: json))
	}
}

//MARK: Class types encoding
extension Rosetta {
	func encode<T>(obj: T, usingMap map: (T, Rosetta) -> ()) throws -> JSON {
		return try self.encode(obj, usingMap: .ClassTypeMap(map))
	}

	public func encode<T>(obj: T, usingMap map: (T, Rosetta) -> ()) throws -> NSData {
		let json: JSON = try self.encode(obj, usingMap: map)
		guard let data = json.data else {
			throw genericError // TODO: Add json parsing error
		}
		return data
	}

	public func encode<T>(obj: T, usingMap map: (T, Rosetta) -> ()) throws -> String {
		let json: JSON = try self.encode(obj, usingMap: map)
		guard let string = json.string else {
			throw genericError // TODO: Add json parsing error
		}
		return string
	}

	func encode<T: MappableClass>(obj: T) throws -> JSON {
		return try self.encode(obj, usingMap: T.map)
	}

	public func encode<T: MappableClass>(obj: T) throws -> NSData {
		let json: JSON = try self.encode(obj, usingMap: T.map)
		guard let data = json.data else {
			throw genericError // TODO: Add json parsing error
		}
		return data
	}

	public func encode<T: MappableClass>(obj: T) throws -> String {
		let json: JSON = try self.encode(obj, usingMap: T.map)
		guard let string = json.string else {
			throw genericError // TODO: Add json parsing error
		}
		return string
	}
}
