import Foundation

//MARK: Bridging between basic JSON types and Swift types

public func BoolBridge() -> Bridge<Bool, NSNumber> {
	return BridgeNumber(
		decoder: {$0 as Bool},
		encoder: {$0}
	)
}

public func IntBridge() -> Bridge<Int, NSNumber> {
	return BridgeNumber(
		decoder: { numberInRange($0, min: Int64(Int.min), max: Int64(Int.max)).map{Int($0)} },
		encoder: {$0}
	)
}

public func UIntBridge() -> Bridge<UInt, NSNumber> {
	return BridgeNumber(
		decoder: { numberInRange($0, min: UInt64(UInt.min), max: UInt64(UInt.max)).map{UInt($0)} },
		encoder: {$0}
	)
}

public func FloatBridge() -> Bridge<Float, NSNumber> {
	return BridgeNumber(
		decoder: {$0 as Float},
		encoder: {$0}
	)
}

public func DoubleBridge() -> Bridge<Double, NSNumber> {
	return BridgeNumber(
		decoder: {$0 as Double},
		encoder: {$0}
	)
}

public func StringBridge() -> Bridge<String, NSString> {
	return BridgeString(
		decoder: {$0 as String},
		encoder: {$0}
	)
}

public func Int8Bridge() -> Bridge<Int8, NSNumber> {
	return BridgeNumber(
		decoder: { numberInRange($0, min: Int64(Int8.min), max: Int64(Int8.max)).map{Int8($0)} },
		encoder: { NSNumber(char: $0) }
	)
}

public func Int16Bridge() -> Bridge<Int16, NSNumber> {
	return BridgeNumber(
		decoder: { numberInRange($0, min: Int64(Int16.min), max: Int64(Int16.max)).map{Int16($0)} },
		encoder: { NSNumber(short: $0) }
	)
}

public func Int32Bridge() -> Bridge<Int32, NSNumber> {
	return BridgeNumber(
		decoder: { numberInRange($0, min: Int64(Int32.min), max: Int64(Int32.max)).map{Int32($0)} },
		encoder: { NSNumber(int: $0) }
	)
}

public func Int64Bridge() -> Bridge<Int64, NSNumber> {
	return BridgeNumber(
		decoder: { numberInRange($0, min: Int64.min, max: Int64.max) },
		encoder: { NSNumber(longLong: $0) }
	)
}

public func UInt8Bridge() -> Bridge<UInt8, NSNumber> {
	return BridgeNumber(
		decoder: { numberInRange($0, min: UInt64(UInt8.min), max: UInt64(UInt8.max)).map{UInt8($0)} },
		encoder: { NSNumber(unsignedChar: $0) }
	)
}

public func UInt16Bridge() -> Bridge<UInt16, NSNumber> {
	return BridgeNumber(
		decoder: { numberInRange($0, min: UInt64(UInt16.min), max: UInt64(UInt16.max)).map{UInt16($0)} },
		encoder: { NSNumber(unsignedShort: $0) }
	)
}

public func UInt32Bridge() -> Bridge<UInt32, NSNumber> {
	return BridgeNumber(
		decoder: { numberInRange($0, min: UInt64(UInt32.min), max: UInt64(UInt32.max)).map{UInt32($0)} },
		encoder: { NSNumber(unsignedInt: $0) }
	)
}

public func UInt64Bridge() -> Bridge<UInt64, NSNumber> {
	return BridgeNumber(
		decoder: { numberInRange($0, min: UInt64.min, max: UInt64.max) },
		encoder: { NSNumber(unsignedLongLong: $0) }
	)
}

public func NSStringBridge() -> Bridge<NSString, NSString> {
	return BridgeString(decoder: {$0}, encoder: {$0})
}

public func NSMutableStringBridge() -> Bridge<NSMutableString, NSString> {
	return BridgeString(decoder: {NSMutableString(string: $0 as String)}, encoder: {$0})
}

public func NSNumberBridge() -> Bridge<NSNumber, NSNumber> {
	return BridgeNumber(decoder: {$0}, encoder: {$0})
}

//MARK: Bridge between a JSONConvertible and an object JSON type

public func JSONConvertibleBridge<T: JSONConvertible>() -> Bridge<T, NSDictionary> {
	return UnsafeBridgeObject(
		decoder: {
			if let json = try? NSJSONSerialization.dataWithJSONObject($0, options: []) {
				return Rosetta().decode(json)
			}
			else {
				return nil
			}
		},
		encoder: {
			if let data: NSData = Rosetta().encode($0) {
				if let dictionary = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? NSDictionary {
					return dictionary
				}
			}
			return nil
		}
	)
}

//MARK: Bridge between a JSONConvertibleClass and an object JSON type

public func JSONConvertibleClassBridge<T: JSONConvertibleClass>() -> Bridge<T, NSDictionary> {
	return UnsafeBridgeObject(
		decoder: {
			if let json = try? NSJSONSerialization.dataWithJSONObject($0, options: []) {
				return Rosetta().decode(json)
			}
			else {
				return nil
			}
		},
		encoder: {
			if let data: NSData = Rosetta().encode($0) {
				if let dictionary = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? NSDictionary {
					return dictionary
				}
			}
			return nil
		}
	)
}

//MARK: Bridges for common conversions

public func NSURLBridge() -> Bridge<NSURL, NSString> {
	return BridgeString(
		decoder: {NSURL(string: $0 as String)},
		encoder: {$0.absoluteString}
	)
}

//MARK: Helpers

func numberInRange(number: NSNumber, min: Int64, max: Int64) -> Int64? {
	let value = number.longLongValue
	return (value >= min) && (value <= max) ? value : nil
}

func numberInRange(number: NSNumber, min: UInt64, max: UInt64) -> UInt64? {
	let value = number.unsignedLongLongValue
	return (value >= min) && (value <= max) ? value : nil
}
