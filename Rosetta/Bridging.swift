import Foundation

public class Bridge<DecodedType, JSONType: AnyObject> {
  typealias Decoder = (JSONType) -> (DecodedType?)
  typealias Encoder = (DecodedType) -> (JSONType?)
  
  let decoder: Decoder
  let encoder: Encoder
  
  private init(decoder: Decoder, encoder: Encoder) {
    self.decoder = decoder
    self.encoder = encoder
  }
}

public func BridgeString<T>(
  #decoder: Bridge<T, NSString>.Decoder,
  #encoder: Bridge<T, NSString>.Encoder
  ) -> Bridge<T, NSString> {
    
    return Bridge<T, NSString>(decoder: decoder, encoder: encoder)
}

public func BridgeBoolean<T>(
  #decoder: Bridge<T, NSNumber>.Decoder,
  #encoder: Bridge<T, NSNumber>.Encoder
  ) -> Bridge<T, NSNumber> {
    
    return Bridge<T, NSNumber>(decoder: decoder, encoder: encoder)
}

public func BridgeNumber<T>(
  #decoder: Bridge<T, NSNumber>.Decoder,
  #encoder: Bridge<T, NSNumber>.Encoder
  ) -> Bridge<T, NSNumber> {
    
    return Bridge<T, NSNumber>(decoder: decoder, encoder: encoder)
}

public func UnsafeBridgeObject<T>(
  #decoder: Bridge<T, NSDictionary>.Decoder,
  #encoder: Bridge<T, NSDictionary>.Encoder
  ) -> Bridge<T, NSDictionary> {
    
    return Bridge<T, NSDictionary>(decoder: decoder, encoder: encoder)
}

public func UnsafeBridgeArray<T>(
  #decoder: Bridge<T, NSArray>.Decoder,
  #encoder: Bridge<T, NSArray>.Encoder
  ) -> Bridge<T, NSArray> {
    
    return Bridge<T, NSArray>(decoder: decoder, encoder: encoder)
}

public func BridgeObject<T, U>(valueBridge: Bridge<T, U>) -> Bridge<[String: T], NSDictionary> {
  return UnsafeBridgeObject(
    decoder: {dictionary in
      var buffer = [String: T]()
      let dictionary = dictionary as [String: U]
      for (key, jsonValue) in dictionary {
        let decodedValue = valueBridge.decoder(jsonValue)
        if let decodedValue = decodedValue {
          buffer[key] = decodedValue
        }
        else {
          return nil
        }
      }
      return buffer
    },
    encoder: {dictionary in
      var buffer = [String: AnyObject]()
      for (key, value) in dictionary {
        if let x = valueBridge.encoder(value) {
          buffer[key] = x
        }
        else {
          return nil
        }
      }
      return buffer
    }
  )
}

public func BridgeArray<T, U>(itemBridge: Bridge<T, U>) -> Bridge<[T], NSArray> {
  return UnsafeBridgeArray(
    decoder: {array in
      var buffer = [T]()
      let array = array as [U]
      for jsonValue in array {
        let decodedValue = itemBridge.decoder(jsonValue)
        if let decodedValue = decodedValue {
          buffer.append(decodedValue)
        }
        else {
          return nil
        }
      }
      return buffer
    },
    encoder: {array in
      var buffer = [AnyObject]()
      for value in array {
        if let x = itemBridge.encoder(value) {
          buffer.append(x)
        }
        else {
          return nil
        }
      }
      return buffer
    }
  )
}
