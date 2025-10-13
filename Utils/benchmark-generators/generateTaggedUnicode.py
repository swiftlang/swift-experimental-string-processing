<<<<<<< HEAD
=======
##===----------------------------------------------------------------------===##
##
## This source file is part of the Swift.org open source project
##
## Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
## Licensed under Apache License v2.0 with Runtime Library Exception
##
## See https://swift.org/LICENSE.txt for license information
##
##===----------------------------------------------------------------------===##

>>>>>>> main
# Generates lines of junk unicode wrapped in html tags
import random

# devanagari
#low = 0x0900
#high = 0x097F

# emojis only
low = 0x1F600
high = 0x1F64F

numLines = 1000

start = "<data> "
end = " </data>"
minLine = 10
maxLine = 100

<<<<<<< HEAD
def get_random(i):
   return "".join([chr(random.randint(low, high)) for _ in range(i)])
   
lines = [start + get_random(random.randint(minLine, maxLine)) + end for _ in range(numLines)]
=======

def get_random(i):
    return "".join([chr(random.randint(low, high)) for _ in range(i)])


lines = [
    start + get_random(random.randint(minLine, maxLine)) + end
    for _ in range(numLines)
]
>>>>>>> main

print("\n".join(lines))
