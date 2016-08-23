import Foundation

public typealias LogHandler = (_ logString: String) -> ()
let defaultLogHandler: LogHandler = { print("\($0)\n--------") }
