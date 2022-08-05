# python3 createBenchmark.py MyRegexBenchmark
# reference: https://github.com/apple/swift/blob/main/benchmark/scripts/create_benchmark.py

import argparse
import os

template = """import _StringProcessing

extension BenchmarkRunner {{
  mutating func add{name}() {{
  }}
}}
"""

def main():
    p = argparse.ArgumentParser()
    p.add_argument("name", help="The name of the new benchmark to be created")
    args = p.parse_args()
    
    # create a file in Sources/RegexBenchmark/Suite with the benchmark template
    create_benchmark_file(args.name)
    
    # add to the registration function in BenchmarkRunner
    register_benchmark(args.name)

def create_benchmark_file(name):
    contents = template.format(name= name)
    relative_path = create_relative_path("../Sources/RegexBenchmark/Suite/")
    source_file_path = os.path.join(relative_path, name + ".swift")
    
    print(f"Creating new benchmark file: {source_file_path}")
    with open(source_file_path, "w") as f:
        f.write(contents)

def register_benchmark(name):
    relative_path = create_relative_path("../Sources/RegexBenchmark/BenchmarkRegistration.swift")

    # read current contents into an array
    file_contents = []
    with open(relative_path, "r") as f:
        file_contents = f.readlines()
    
    new_file_contents = []
    for line in file_contents:
        if "end of registrations" not in line:
            new_file_contents.append(line)
        else:
            # add the newest benchmark
            new_file_contents.append(f"    self.add{name}()\n")
            new_file_contents.append(line)
    
    # write the new contents
    with open(relative_path, "w") as f:
        for line in new_file_contents:
            f.write(line)
            
def create_relative_path(file_path):
    return os.path.join(os.path.dirname(__file__), file_path)

if __name__ == "__main__":
    main()
