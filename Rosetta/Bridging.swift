import Foundation

public enum _DecodeResult<T> {
	case success(T)
	case unexpectedValue
	case null
}

public enum _EncodeResult<T> {
	case success(T)
	case error
}

public class _Bridge<T, U: NSObject> {
	public typealias Decoder = (U) -> _DecodeResult<T>
	public typealias Encoder = (T) -> _EncodeResult<U>

	private let decoder: Decoder
	private let encoder: Encoder

	private init(decoder: Decoder, encoder: Encoder) {
		self.decoder = decoder
		self.encoder = encoder
	}

	public func decode(jsonValue: Any) -> _DecodeResult<T> {
		if jsonValue is NSNull { return .null }
		guard let castedJSONValue = jsonValue as? U else { return .unexpectedValue	}
		return self.decode(jsonValue: castedJSONValue)
	}

	public func decode(jsonValue: U) -> _DecodeResult<T> {
		return self.decoder(jsonValue)
	}

	public func encode(value: T) -> _EncodeResult<U> {
		return self.encoder(value)
	}
}

public final class _BridgeString<T>: _Bridge<T, NSString> {
	public override init(decoder: (NSString) -> _DecodeResult<T>, encoder: (T) -> _EncodeResult<NSString>) {
		super.init(decoder: decoder, encoder: encoder)
	}
}

public final class _BridgeBoolean<T>: _Bridge<T, NSNumber> {
	public override init(decoder: (NSNumber) -> _DecodeResult<T>, encoder: (T) -> _EncodeResult<NSNumber>) {
		super.init(decoder: decoder, encoder: encoder)
	}
}

public final class _BridgeNumber<T>: _Bridge<T, NSNumber> {
	public override init(decoder: (NSNumber) -> _DecodeResult<T>, encoder: (T) -> _EncodeResult<NSNumber>) {
		super.init(decoder: decoder, encoder: encoder)
	}
}

public final class _UnsafeBridgeDictionary<T>: _Bridge<T, NSDictionary> {
	public override init(decoder: (NSDictionary) -> _DecodeResult<T>, encoder: (T) -> _EncodeResult<NSDictionary>) {
		super.init(decoder: decoder, encoder: encoder)
	}
}
//public class _UnsafeBridgeDictionary<T, [String: AnyObject]>: _Bridge<T, [String: AnyObject]> { }
public final class _UnsafeBridgeArray<T>: _Bridge<T, NSArray> {
	public override init(decoder: (NSArray) -> _DecodeResult<T>, encoder: (T) -> _EncodeResult<NSArray>) {
		super.init(decoder: decoder, encoder: encoder)
	}
}
//public class _UnsafeBridgeArray<T, [AnyObject]>: _Bridge<T, [AnyObject]> { }

public func BridgeObject<T, U>(_ valueBridge: _Bridge<T, U>) -> _Bridge<[String: T?], NSDictionary> {
	return _UnsafeBridgeDictionary<[String: T?]>(
		decoder: { (dictionary) -> _DecodeResult<[String : T?]> in

			var buffer: [String: T?] = [:]

			for (key, value) in dictionary {

				guard let stringKey = key as? String else { return .unexpectedValue }
				let bridgeResult = valueBridge.decode(jsonValue: value)

				switch bridgeResult {
				case .null: buffer[stringKey] = .none
				case .unexpectedValue: return .unexpectedValue
				case .success(let value): buffer[stringKey] = value
				}
			}

			return .success(buffer)
		},
		encoder: { (dictionary) -> _EncodeResult<NSDictionary> in

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

public func BridgeObject<T, U>(_ valueBridge: _Bridge<T, U>) -> _Bridge<[String: T], NSDictionary> {
	return _UnsafeBridgeDictionary<[String: T]>(
		decoder: { (dictionary) -> _DecodeResult<[String : T]> in

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
		encoder: { (dictionary) -> _EncodeResult<NSDictionary> in

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

public func BridgeArray<T, U>(_ itemBridge: _Bridge<T, U>) -> _Bridge<[T?], NSArray> {
	return _UnsafeBridgeArray<[T?]>(
		decoder: { (array) -> _DecodeResult<[T?]> in

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
		encoder: { (array) -> _EncodeResult<NSArray> in

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

public func BridgeArray<T, U>(_ itemBridge: _Bridge<T, U>) -> _Bridge<[T], NSArray> {
	return _UnsafeBridgeArray<[T]>(
		decoder: { (array) -> _DecodeResult<[T]> in

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
		encoder: { (array) -> _EncodeResult<NSArray> in

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
