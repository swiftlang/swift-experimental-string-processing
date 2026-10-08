#===-----------------------------------------------------------------------===#
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2026 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information
#
#===-----------------------------------------------------------------------===#

# NOTE: This build configuration is only to validate that the settings
# match between the swiftlang/swift project and this one, not for
# producing installable libraries.

cmake_minimum_required(VERSION 3.26)

project(SwiftStringProcessing
  VERSION 1.0.0
  LANGUAGES C Swift)

include(GNUInstallDirs)

set(CMAKE_Swift_LANGUAGE_VERSION 5)
set(CMAKE_C_STANDARD 99)

option(BUILD_SHARED_LIBS "Build shared libraries" YES)

set(SwiftStringProcessing_INSTALL_LIBDIR "${CMAKE_INSTALL_LIBDIR}/swift"
  CACHE STRING "Destination for the built libraries")

#===-----------------------------------------------------------------------===#
# Compiler flags
#===-----------------------------------------------------------------------===#

add_compile_options(
  "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xfrontend -disable-implicit-concurrency-module-import>"
  "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xfrontend -disable-implicit-string-processing-module-import>")

foreach(definition
    "SwiftStdlib 5.7:macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0"
    "SwiftStdlib 5.8:macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4"
    "SwiftStdlib 5.9:macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0"
    "SwiftStdlib 6.0:macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0"
    "SwiftStdlib 6.1:macOS 15.4, iOS 18.4, watchOS 11.4, tvOS 18.4, visionOS 2.4"
    "SwiftStdlib 6.2:macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0"
    "SwiftStdlib 6.3:macOS 26.4, iOS 26.4, watchOS 26.4, tvOS 26.4, visionOS 26.4"
    "SwiftStdlib 6.4:macOS 27.0, iOS 27.0, watchOS 27.0, tvOS 27.0, visionOS 27.0"
    "SwiftStdlib 6.5:macOS 9999, iOS 9999, watchOS 9999, tvOS 9999, visionOS 9999")
  add_compile_options(
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xfrontend -define-availability -Xfrontend \"${definition}\">")
endforeach()

add_compile_options(
  "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-enable-upcoming-feature MemberImportVisibility>")

#===-----------------------------------------------------------------------===#
# Shims for the runtime build
#===-----------------------------------------------------------------------===#
#
# The module files call into helpers that only exist in the Swift runtime's
# build. Define just enough here for them to resolve. Each shim below is a no-op,
# so this configuration builds and links the two modules but does *not* produce
# an installable stdlib component.

# In the runtime build `swiftCore` is a real target. Standalone, the stdlib
# comes from the toolchain and needs no explicit link.
if(NOT TARGET swiftCore)
  add_library(swiftCore INTERFACE)
endif()

# Library evolution and `.swiftinterface` emission.
function(emit_swift_interface target)
endfunction()

function(install_swift_interface target)
endfunction()

# Darwin packaging metadata, irrelevant to a standalone build.
function(generate_plist name version target)
endfunction()

function(embed_manifest target)
endfunction()

#===-----------------------------------------------------------------------===#
# Modules
#===-----------------------------------------------------------------------===#

# Order matters: _StringProcessing links _RegexParser.
add_subdirectory(_RegexParser)
add_subdirectory(_StringProcessing)
