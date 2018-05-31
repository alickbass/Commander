#if os(Linux)
  import Glibc
#else
  import Darwin
#endif


public protocol ANSIConvertible : Error, CustomStringConvertible {
  var ansiDescription: String { get }
}


extension ANSIConvertible {
  public func print() {
    // Check if we are in any term env and the output is a tty.
    if ANSI.isTerminalSupported {
      fputs("\(ansiDescription)\n", stderr)
    } else {
      fputs("\(description)\n", stderr)
    }
  }
}


public enum ANSI: UInt8, CustomStringConvertible {
  case reset = 0

  case black = 30
  case red
  case green
  case yellow
  case blue
  case magenta
  case cyan
  case white
  case `default`

  public var description: String {
    return "\u{001B}[\(self.rawValue)m"
  }

  public static var isTerminalSupported: Bool {
    if let termType = getenv("TERM"), String(cString: termType).lowercased() != "dumb" &&
      isatty(fileno(stdout)) != 0 {
      return true
    } else {
      return false
    }
  }

  public func print(_ string: String, to output: UnsafeMutablePointer<FILE> = stdout) {
    if ANSI.isTerminalSupported {
      fputs("\(self)\(string)\(ANSI.reset)\n", output)
    } else {
      fputs("\(string)\n", output)
    }
  }
}
