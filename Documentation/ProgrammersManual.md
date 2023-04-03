# Programmer's Manual

## Programming patterns

### Engine quick checks and fast paths

In the engine nomenclature, a quick-check results in a yes/no/maybe while a thorough check always results in a definite answer.

The nature of quick checks and fast paths is that they bifurcate testing coverage. One easy way to prevent this in simple cases is to assert that a definite quick result matches the thorough result.

One example of this pattern is matching against a builtin character class. The engine has a `_doMatchBuiltinCC`

```swift
  func _doMatchBuiltinCC(...) -> Input.Index? {
    // Calls _quickMatchBuiltinCC, if that gives a definite result 
    // asserts that it is the same as the result of 
    // _thoroughMatchBuiltinCC and returns it. Otherwise returns the
    // result of _thoroughMatchBuiltinCC
  }

  @inline(__always)
  func _quickMatchBuiltinCC(...) -> QuickResult<Input.Index?>

  @inline(never)
  func _thoroughMatchBuiltinCC(...) -> Input.Index?
```

The thorough check is never inlined, as it is a lot of cold code. Note that quick and thorough functions should be pure, that is they shouldn't update processor state.


