import Foundation

public enum DecodeResult<T> {
	case success(T)
	case unexpectedValue
	case null
}

public enum EncodeResult<T> {
	case success(T)
	case error
}

public class Bridge<T, U: NSObject> {
	public typealias Decoder = (U) -> DecodeResult<T>
	public typealias Encoder = (T) -> EncodeResult<U>

	private let decoder: Decoder
	private let encoder: Encoder

	private init(decoder: Decoder, encoder: Encoder) {
		self.decoder = decoder
		self.encoder = encoder
	}

	public func decode(jsonValue: Any) -> DecodeResult<T> {
		if jsonValue is NSNull { return .null }
		guard let castedJSONValue = jsonValue as? U else { return .unexpectedValue	}
		return self.decode(jsonValue: castedJSONValue)
	}

	public func decode(jsonValue: U) -> DecodeResult<T> {
		return self.decoder(jsonValue)
	}

	public func encode(value: T) -> EncodeResult<U> {
		return self.encoder(value)
	}
}

public final class BridgeString<T>: Bridge<T, NSString> {
	public override init(decoder: (NSString) -> DecodeResult<T>, encoder: (T) -> EncodeResult<NSString>) {
		super.init(decoder: decoder, encoder: encoder)
	}
}

public final class BridgeBoolean<T>: Bridge<T, NSNumber> {
	public override init(decoder: (NSNumber) -> DecodeResult<T>, encoder: (T) -> EncodeResult<NSNumber>) {
		super.init(decoder: decoder, encoder: encoder)
	}
}

public final class BridgeNumber<T>: Bridge<T, NSNumber> {
	public override init(decoder: (NSNumber) -> DecodeResult<T>, encoder: (T) -> EncodeResult<NSNumber>) {
		super.init(decoder: decoder, encoder: encoder)
	}
}

public final class _UnsafeBridgeDictionary<T>: Bridge<T, NSDictionary> {
	public override init(decoder: (NSDictionary) -> DecodeResult<T>, encoder: (T) -> EncodeResult<NSDictionary>) {
		super.init(decoder: decoder, encoder: encoder)
	}
}
//public class _UnsafeBridgeDictionary<T, [String: AnyObject]>: Bridge<T, [String: AnyObject]> { }
public final class _UnsafeBridgeArray<T>: Bridge<T, NSArray> {
	public override init(decoder: (NSArray) -> DecodeResult<T>, encoder: (T) -> EncodeResult<NSArray>) {
		super.init(decoder: decoder, encoder: encoder)
	}
}
//public class _UnsafeBridgeArray<T, [AnyObject]>: Bridge<T, [AnyObject]> { }

public func BridgeObject<T, U>(_ valueBridge: Bridge<T, U>) -> Bridge<[String: T?], NSDictionary> {
	return _UnsafeBridgeDictionary<[String: T?]>(
		decoder: { (dictionary) -> DecodeResult<[String : T?]> in

			var buffer: [String: T?] = [:]

			for (key, value) in dictionary {

				guard let stringKey = key as? String else { return .unexpectedValue }
				let bridgeResult = valueBridge.decode(jsonValue: value)

				switch bridgeResult {
				case .null: buffer.updateValue(.none, forKey: stringKey)
				case .unexpectedValue: return .unexpectedValue
				case .success(let value): buffer[stringKey] = value
				}
			}

			return .success(buffer)
		},
		encoder: { (dictionary) -> EncodeResult<NSDictionary> in

			var buffer = [String: AnyObject]()

			for (key, value) in dictionary {
				guard let value = value else {
					buffer[key] = NSNull()
					continue
				}

				let bridgeResult = valueBridge.encoder(value)
				switch bridgeResult {
				case .error: return .error
				case .success(let value): buffer[key] = value
				}
			}
			return .success(buffer)
		}
	)
}

public func BridgeObject<T, U>(_ valueBridge: Bridge<T, U>) -> Bridge<[String: T], NSDictionary> {
	return _UnsafeBridgeDictionary<[String: T]>(
		decoder: { (dictionary) -> DecodeResult<[String : T]> in

			var buffer: [String: T] = [:]

			for (key, value) in dictionary {

				guard let stringKey = key as? String else { return .unexpectedValue }
				let bridgeResult = valueBridge.decode(jsonValue: value)

				switch bridgeResult {
				case .null: return .unexpectedValue
				case .unexpectedValue: return .unexpectedValue
				case .success(let value): buffer[stringKey] = value
				}
			}

			return .success(buffer)
		},
		encoder: { (dictionary) -> EncodeResult<NSDictionary> in

			var buffer = [String: AnyObject]()

			for (key, value) in dictionary {

				let bridgeResult = valueBridge.encoder(value)
				switch bridgeResult {
				case .error: return .error
				case .success(let value): buffer[key] = value
				}
			}
			return .success(buffer)
		}
	)
}

public func BridgeArray<T, U>(_ itemBridge: Bridge<T, U>) -> Bridge<[T?], NSArray> {
	return _UnsafeBridgeArray<[T?]>(
		decoder: { (array) -> DecodeResult<[T?]> in

			var buffer: [T?] = []

			for element in array {
				let bridgeResult = itemBridge.decode(jsonValue: element)
				switch bridgeResult {
				case .null: buffer.append(.none)
				case .unexpectedValue: return .unexpectedValue
				case .success(let value): buffer.append(value)
				}
			}

			return .success(buffer)
		},
		encoder: { (array) -> EncodeResult<NSArray> in

			var buffer: [AnyObject] = []

			for element in array {
				guard let element = element else {
					buffer.append(NSNull())
					continue
				}

				let bridgeResult = itemBridge.encode(value: element)
				switch bridgeResult {
				case .error: return .error
				case .success(let value): buffer.append(value)
				}
			}

			return .success(buffer)
		}
	)
}

public func BridgeArray<T, U>(_ itemBridge: Bridge<T, U>) -> Bridge<[T], NSArray> {
	return _UnsafeBridgeArray<[T]>(
		decoder: { (array) -> DecodeResult<[T]> in

			var buffer: [T] = []

			for element in array {
				let bridgeResult = itemBridge.decode(jsonValue: element)
				switch bridgeResult {
				case .null: return .unexpectedValue
				case .unexpectedValue: return .unexpectedValue
				case .success(let value): buffer.append(value)
				}
			}

			return .success(buffer)
		},
		encoder: { (array) -> EncodeResult<NSArray> in

			var buffer: [U] = []

			for element in array {
				let bridgeResult = itemBridge.encode(value: element)
				switch bridgeResult {
				case .error: return .error
				case .success(let value): buffer.append(value)
				}
			}

			return .success(buffer)
		}
	)
}
