// RUN: %empty-directory(%t)
// RUN: %target-build-swift %s -parse-as-library -Onone -g -o %t/EarlyMessage
// RUN: (env SWIFT_BACKTRACE=enable=yes,cache=no %target-run %t/EarlyMessage 2>&1 || true) | %FileCheck %s

// UNSUPPORTED: use_os_stdlib
// UNSUPPORTED: back_deployment_runtime
// UNSUPPORTED: asan
// REQUIRES: executable_test
// REQUIRES: backtracing
// REQUIRES: OS=macosx || OS=linux-gnu

func level1() {
  level2()
}

func level2() {
  level3()
}

func level3() {
  level4()
}

func level4() {
  level5()
}

func level5() {
  print("About to crash")
  let ptr = UnsafeMutablePointer<Int>(bitPattern: 4)!
  ptr.pointee = 42
}

@main
struct EarlyMessage {
  static func main() {
    level1()
  }
}

// Make sure we get the early crash message from the backtracer (the first
// part is generated by the runtime itself; the "done ***" on the end is from
// swift-backtrace).

// CHECK: *** Signal {{[0-9]+}}: Backtracing from 0x{{[0-9a-f]+}}... done ***
