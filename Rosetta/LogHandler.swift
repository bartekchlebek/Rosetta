import Foundation

public typealias LogHandler = (logString: String) -> ()
let defaultLogHandler: LogHandler = { print("\($0)\n--------") }
