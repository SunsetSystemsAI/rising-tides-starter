---
name: security-testing-handbook
description: "Use when performing security testing. Invoke for fuzzing, coverage analysis, AFL, libFuzzer, AddressSanitizer, Atheris, cargo-fuzz, OSS-Fuzz, Wycheproof, harness writing, constant-time testing."
---

# address-sanitizer

# AddressSanitizer (ASan)

AddressSanitizer (ASan) is a widely adopted memory error detection tool used extensively during software testing, particularly fuzzing. It helps detect memory corruption bugs that might otherwise go unnoticed, such as buffer overflows, use-after-free errors, and other memory safety violations.

## Overview

ASan is a standard practice in fuzzing due to its effectiveness in identifying memory vulnerabilities. It instruments code at compile time to track memory allocations and accesses, detecting illegal operations at runtime.

### Key Concepts

| Concept | Description |
|---------|-------------|
| Instrumentation | ASan adds runtime checks to memory operations during compilation |
| Shadow Memory | Maps 20TB of virtual memory to track allocation state |
| Performance Cost | Approximately 2-4x slowdown compared to non-instrumented code |
| Detection Scope | Finds buffer overflows, use-after-free, double-free, and memory leaks |

## When to Apply

**Apply this technique when:**
- Fuzzing C/C++ code for memory safety vulnerabilities
- Testing Rust code with unsafe blocks
- Debugging crashes related to memory corruption
- Running unit tests where memory errors are suspected

**Skip this technique when:**
- Running production code (ASan can reduce security)
- Platform is Windows or macOS (limited ASan support)
- Performance overhead is unacceptable for your use case
- Fuzzing pure safe languages without FFI (e.g., pure Go, pure Java)

## Quick Reference

| Task | Command/Pattern |
|------|-----------------|
| Enable ASan (Clang/GCC) | `-fsanitize=address` |
| Enable verbosity | `ASAN_OPTIONS=verbosity=1` |
| Disable leak detection | `ASAN_OPTIONS=detect_leaks=0` |
| Force abort on error | `ASAN_OPTIONS=abort_on_error=1` |
| Multiple options | `ASAN_OPTIONS=verbosity=1:abort_on_error=1` |

## Step-by-Step

### Step 1: Compile with ASan

Compile and link your code with the `-fsanitize=address` flag:

```bash
clang -fsanitize=address -g -o my_program my_program.c
```

The `-g` flag is recommended to get better stack traces when ASan detects errors.

### Step 2: Configure ASan Options

Set the `ASAN_OPTIONS` environment variable to configure ASan behavior:

```bash
export ASAN_OPTIONS=verbosity=1:abort_on_error=1:detect_leaks=0
```

### Step 3: Run Your Program

Execute the ASan-instrumented binary. When memory errors are detected, ASan will print detailed reports:

```bash
./my_program
```

### Step 4: Adjust Fuzzer Memory Limits

ASan requires approximately 20TB of virtual memory. Disable fuzzer memory restrictions:

- libFuzzer: `-rss_limit_mb=0`
- AFL++: `-m none`

## Common Patterns

### Pattern: Basic ASan Integration

**Use Case:** Standard fuzzing setup with ASan

**Before:**
```bash
clang -o fuzz_target fuzz_target.c
./fuzz_target
```

**After:**
```bash
clang -fsanitize=address -g -o fuzz_target fuzz_target.c
ASAN_OPTIONS=verbosity=1:abort_on_error=1 ./fuzz_target
```

### Pattern: ASan with Unit Tests

**Use Case:** Enable ASan for unit test suite

**Before:**
```bash
gcc -o test_suite test_suite.c -lcheck
./test_suite
```

**After:**
```bash
gcc -fsanitize=address -g -o test_suite test_suite.c -lcheck
ASAN_OPTIONS=detect_leaks=1 ./test_suite
```

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| Use `-g` flag | Provides detailed stack traces for debugging |
| Set `verbosity=1` | Confirms ASan is enabled before program starts |
| Disable leaks during fuzzing | Leak detection doesn't cause immediate crashes, clutters output |
| Enable `abort_on_error=1` | Some fuzzers require `abort()` instead of `_exit()` |

### Understanding ASan Reports

When ASan detects a memory error, it prints a detailed report including:

- **Error type**: Buffer overflow, use-after-free, etc.
- **Stack trace**: Where the error occurred
- **Allocation/deallocation traces**: Where memory was allocated/freed
- **Memory map**: Shadow memory state around the error

Example ASan report:
```
==12345==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x60300000eff4 at pc 0x00000048e6a3
READ of size 4 at 0x60300000eff4 thread T0
    #0 0x48e6a2 in main /path/to/file.c:42
```

### Combining Sanitizers

ASan can be combined with other sanitizers for comprehensive detection:

```bash
clang -fsanitize=address,undefined -g -o fuzz_target fuzz_target.c
```

### Platform-Specific Considerations

**Linux**: Full ASan support with best performance
**macOS**: Limited support, some features may not work
**Windows**: Experimental support, not recommended for production fuzzing

## Anti-Patterns

| Anti-Pattern | Problem | Correct Approach |
|--------------|---------|------------------|
| Using ASan in production | Can make applications less secure | Use ASan only for testing |
| Not disabling memory limits | Fuzzer may kill process due to 20TB virtual memory | Set `-rss_limit_mb=0` or `-m none` |
| Ignoring leak reports | Memory leaks indicate resource management issues | Review leak reports at end of fuzzing campaign |

## Tool-Specific Guidance

### libFuzzer

Compile with both fuzzer and address sanitizer:

```bash
clang++ -fsanitize=fuzzer,address -g harness.cc -o fuzz
```

Run with unlimited RSS:

```bash
./fuzz -rss_limit_mb=0
```

**Integration tips:**
- Always combine `-fsanitize=fuzzer` with `-fsanitize=address`
- Use `-g` for detailed stack traces in crash reports
- Consider `ASAN_OPTIONS=abort_on_error=1` for better crash handling

See: [libFuzzer: AddressSanitizer](https://github.com/google/fuzzing/blob/master/docs/good-fuzz-target.md#memory-error-detection)

### AFL++

Use the `AFL_USE_ASAN` environment variable:

```bash
AFL_USE_ASAN=1 afl-clang-fast++ -g harness.cc -o fuzz
```

Run with unlimited memory:

```bash
afl-fuzz -m none -i input_dir -o output_dir ./fuzz
```

**Integration tips:**
- `AFL_USE_ASAN=1` automatically adds proper compilation flags
- Use `-m none` to disable AFL++'s memory limit
- Consider `AFL_MAP_SIZE` for programs with large coverage maps

See: [AFL++: AddressSanitizer](https://github.com/AFLplusplus/AFLplusplus/blob/stable/docs/fuzzing_in_depth.md#a-using-sanitizers)

### cargo-fuzz (Rust)

Use the `--sanitizer=address` flag:

```bash
cargo fuzz run fuzz_target --sanitizer=address
```

Or configure in `fuzz/Cargo.toml`:

```toml
[profile.release]
opt-level = 3
debug = true
```

**Integration tips:**
- ASan is useful for fuzzing unsafe Rust code or FFI boundaries
- Safe Rust code may not benefit as much (compiler already prevents many errors)
- Focus on unsafe blocks, raw pointers, and C library bindings

See: [cargo-fuzz: AddressSanitizer](https://rust-fuzz.github.io/book/cargo-fuzz/tutorial.html#sanitizers)

### honggfuzz

Compile with ASan and link with honggfuzz:

```bash
honggfuzz -i input_dir -o output_dir -- ./fuzz_target_asan
```

Compile the target:

```bash
hfuzz-clang -fsanitize=address -g target.c -o fuzz_target_asan
```

**Integration tips:**
- honggfuzz works well with ASan out of the box
- Use feedback-driven mode for better coverage with sanitizers
- Monitor memory usage, as ASan increases memory footprint

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Fuzzer kills process immediately | Memory limit too low for ASan's 20TB virtual memory | Use `-rss_limit_mb=0` (libFuzzer) or `-m none` (AFL++) |
| "ASan runtime not initialized" | Wrong linking order or missing runtime | Ensure `-fsanitize=address` used in both compile and link |
| Leak reports clutter output | LeakSanitizer enabled by default | Set `ASAN_OPTIONS=detect_leaks=0` |
| Poor performance (>4x slowdown) | Debug mode or unoptimized build | Compile with `-O2` or `-O3` alongside `-fsanitize=address` |
| ASan not detecting obvious bugs | Binary not instrumented | Check with `ASAN_OPTIONS=verbosity=1` that ASan prints startup info |
| False positives | Interceptor conflicts | Check ASan FAQ for known issues with specific libraries |

## Related Skills

### Tools That Use This Technique

| Skill | How It Applies |
|-------|----------------|
| **libfuzzer** | Compile with `-fsanitize=fuzzer,address` for integrated fuzzing with memory error detection |
| **aflpp** | Use `AFL_USE_ASAN=1` environment variable during compilation |
| **cargo-fuzz** | Use `--sanitizer=address` flag to enable ASan for Rust fuzz targets |
| **honggfuzz** | Compile target with `-fsanitize=address` for ASan-instrumented fuzzing |

### Related Techniques

| Skill | Relationship |
|-------|--------------|
| **undefined-behavior-sanitizer** | Often used together with ASan for comprehensive bug detection (undefined behavior + memory errors) |
| **fuzz-harness-writing** | Harnesses must be designed to handle ASan-detected crashes and avoid false positives |
| **coverage-analysis** | Coverage-guided fuzzing helps trigger code paths where ASan can detect memory errors |

## Resources

### Key External Resources

**[AddressSanitizer on Google Sanitizers Wiki](https://github.com/google/sanitizers/wiki/AddressSanitizer)**

The official ASan documentation covers:
- Algorithm and implementation details
- Complete list of detected error types
- Performance characteristics and overhead
- Platform-specific behavior
- Known limitations and incompatibilities

**[SanitizerCommonFlags](https://github.com/google/sanitizers/wiki/SanitizerCommonFlags)**

Common configuration flags shared across all sanitizers:
- `verbosity`: Control diagnostic output level
- `log_path`: Redirect sanitizer output to files
- `symbolize`: Enable/disable symbol resolution in reports
- `external_symbolizer_path`: Use custom symbolizer

**[AddressSanitizerFlags](https://github.com/google/sanitizers/wiki/AddressSanizerFlags)**

ASan-specific configuration options:
- `detect_leaks`: Control memory leak detection
- `abort_on_error`: Call `abort()` vs `_exit()` on error
- `detect_stack_use_after_return`: Detect stack use-after-return bugs
- `check_initialization_order`: Find initialization order bugs

**[AddressSanitizer FAQ](https://github.com/google/sanitizers/wiki/AddressSanitizer#faq)**

Common pitfalls and solutions:
- Linking order issues
- Conflicts with other tools
- Platform-specific problems
- Performance tuning tips

**[Clang AddressSanitizer Documentation](https://clang.llvm.org/docs/AddressSanitizer.html)**

Clang-specific guidance:
- Compilation flags and options
- Interaction with other Clang features
- Supported platforms and architectures

**[GCC Instrumentation Options](https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html#index-fsanitize_003daddress)**

GCC-specific ASan documentation:
- GCC-specific flags and behavior
- Differences from Clang implementation
- Platform support in GCC

**[AddressSanitizer: A Fast Address Sanity Checker (USENIX Paper)](https://www.usenix.org/sites/default/files/conference/protected-files/serebryany_atc12_slides.pdf)**

Original research paper with technical details:
- Shadow memory algorithm
- Virtual memory requirements (historically 16TB, now ~20TB)
- Performance benchmarks
- Design decisions and tradeoffs

# aflpp

# AFL++

AFL++ is a fork of the original AFL fuzzer that offers better fuzzing performance and more advanced features while maintaining stability. A major benefit over libFuzzer is that AFL++ has stable support for running fuzzing campaigns on multiple cores, making it ideal for large-scale fuzzing efforts.

## When to Use

| Fuzzer | Best For | Complexity |
|--------|----------|------------|
| AFL++ | Multi-core fuzzing, diverse mutations, mature projects | Medium |
| libFuzzer | Quick setup, single-threaded, simple harnesses | Low |
| LibAFL | Custom fuzzers, research, advanced use cases | High |

**Choose AFL++ when:**
- You need multi-core fuzzing to maximize throughput
- Your project can be compiled with Clang or GCC
- You want diverse mutation strategies and mature tooling
- libFuzzer has plateaued and you need more coverage
- You're fuzzing production codebases that benefit from parallel execution

## Quick Start

```c++
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    // Call your code with fuzzer-provided data
    check_buf((char*)data, size);
    return 0;
}
```

Compile and run:
```bash
# Setup AFL++ wrapper script first (see Installation)
./afl++ docker afl-clang-fast++ -DNO_MAIN=1 -O2 -fsanitize=fuzzer harness.cc main.cc -o fuzz
mkdir seeds && echo "aaaa" > seeds/minimal_seed
./afl++ docker afl-fuzz -i seeds -o out -- ./fuzz
```

## Installation

AFL++ has many dependencies including LLVM, Python, and Rust. We recommend using a current Debian or Ubuntu distribution for fuzzing with AFL++.

| Method | When to Use | Supported Compilers |
|--------|-------------|---------------------|
| Ubuntu/Debian repos | Recent Ubuntu, basic features only | Ubuntu 23.10: Clang 14 & GCC 13<br>Debian 12: Clang 14 & GCC 12 |
| Docker (from Docker Hub) | Specific AFL++ version, Apple Silicon support | As of 4.35c: Clang 19 & GCC 11 |
| Docker (from source) | Test unreleased features, apply patches | Configurable in Dockerfile |
| From source | Avoid Docker, need specific patches | Adjustable via `LLVM_CONFIG` env var |

### Ubuntu/Debian

Prior to installing afl++, check the clang version dependency of the packge with `apt-cache show afl++`, and install the matching `lld` version (e.g., `lld-17`).


```bash
apt install afl++ lld-17
```


### Docker (from Docker Hub)

```bash
docker pull aflplusplus/aflplusplus:stable
```

### Docker (from source)

```bash
git clone --depth 1 --branch stable https://github.com/AFLplusplus/AFLplusplus
cd AFLplusplus
docker build -t aflplusplus .
```

### From source

Refer to the [Dockerfile](https://github.com/AFLplusplus/AFLplusplus/blob/stable/Dockerfile) for Ubuntu version requirements and dependencies. Set `LLVM_CONFIG` to specify Clang version (e.g., `llvm-config-18`).

### Wrapper Script Setup

Create a wrapper script to run AFL++ on host or Docker:

```bash
cat <<'EOF' > ./afl++
#!/bin/sh
AFL_VERSION="${AFL_VERSION:-"stable"}"
case "$1" in
   host)
        shift
        bash -c "$*"
        ;;
    docker)
        shift
        /usr/bin/env docker run -ti \
            --privileged \
            -v ./:/src \
            --rm \
            --name afl_fuzzing \
            "aflplusplus/aflplusplus:$AFL_VERSION" \
            bash -c "cd /src && bash -c \"$*\""
        ;;
    *)
        echo "Usage: $0 {host|docker}"
        exit 1
        ;;
esac
EOF
chmod +x ./afl++
```

**Security Warning:** The `afl-system-config` and `afl-persistent-config` scripts require root privileges and disable OS security features. Do not fuzz on production systems or your development environment. Use a dedicated VM instead.

### System Configuration

Run after each reboot for up to 15% more executions per second:

```bash
./afl++ <host/docker> afl-system-config
```

For maximum performance, disable kernel security mitigations (requires grub bootloader, not supported in Docker):

```bash
./afl++ host afl-persistent-config
update-grub
reboot
./afl++ <host/docker> afl-system-config
```

Verify with `cat /proc/cmdline` - output should include `mitigations=off`.

## Writing a Harness

### Harness Structure

AFL++ supports libFuzzer-style harnesses:

```c++
#include <stdint.h>
#include <stddef.h>

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    // 1. Validate input size if needed
    if (size < MIN_SIZE || size > MAX_SIZE) return 0;

    // 2. Call target function with fuzz data
    target_function(data, size);

    // 3. Return 0 (non-zero reserved for future use)
    return 0;
}
```

### Harness Rules

| Do | Don't |
|----|-------|
| Reset global state between runs | Rely on state from previous runs |
| Handle edge cases gracefully | Exit on invalid input |
| Keep harness deterministic | Use random number generators |
| Free allocated memory | Create memory leaks |
| Validate input sizes | Process unbounded input |

> **See Also:** For detailed harness writing techniques, patterns for handling complex inputs,
> and advanced strategies, see the **fuzz-harness-writing** technique skill.

## Compilation

AFL++ offers multiple compilation modes with different trade-offs.

### Compilation Mode Decision Tree

Choose your compilation mode:
- **LTO mode** (`afl-clang-lto`): Best performance and instrumentation. Try this first.
- **LLVM mode** (`afl-clang-fast`): Fall back if LTO fails to compile.
- **GCC plugin** (`afl-gcc-fast`): For projects requiring GCC.

### Basic Compilation (LLVM mode)

```bash
./afl++ <host/docker> afl-clang-fast++ -DNO_MAIN=1 -O2 -fsanitize=fuzzer harness.cc main.cc -o fuzz
```

### GCC Compilation

```bash
./afl++ <host/docker> afl-g++-fast -DNO_MAIN=1 -O2 -fsanitize=fuzzer harness.cc main.cc -o fuzz
```

**Important:** GCC version must match the version used to compile the AFL++ GCC plugin.

### With Sanitizers

```bash
./afl++ <host/docker> AFL_USE_ASAN=1 afl-clang-fast++ -DNO_MAIN=1 -O2 -fsanitize=fuzzer harness.cc main.cc -o fuzz
```

> **See Also:** For detailed sanitizer configuration, common issues, and advanced flags,
> see the **address-sanitizer** and **undefined-behavior-sanitizer** technique skills.

### Build Flags

Note that `-g` is not necessary, it is added by default by the AFL++ compilers.

| Flag | Purpose |
|------|---------|
| `-DNO_MAIN=1` | Skip main function when using libFuzzer harness |
| `-O2` | Production optimization level (recommended for fuzzing) |
| `-fsanitize=fuzzer` | Enable libFuzzer compatibility mode and adds the fuzzer runtime when linking executable |
| `-fsanitize=fuzzer-no-link` | Instrument without linking fuzzer runtime (for static libraries and object files) |

## Corpus Management

### Creating Initial Corpus

AFL++ requires at least one non-empty seed file:

```bash
mkdir seeds
echo "aaaa" > seeds/minimal_seed
```

For real projects, gather representative inputs:
- Download example files for the format you're fuzzing
- Extract test cases from the project's test suite
- Use minimal valid inputs for your file format

### Corpus Minimization

After a campaign, minimize the corpus to keep only unique coverage:

```bash
./afl++ <host/docker> afl-cmin -i out/default/queue -o minimized_corpus -- ./fuzz
```

> **See Also:** For corpus creation strategies, dictionaries, and seed selection,
> see the **fuzzing-corpus** technique skill.

## Running Campaigns

### Basic Run

```bash
./afl++ <host/docker> afl-fuzz -i seeds -o out -- ./fuzz
```

### Setting Environment Variables

```bash
./afl++ <host/docker> AFL_FAST_CAL=1 afl-fuzz -i seeds -o out -- ./fuzz
```

### Interpreting Output

The AFL++ UI shows real-time fuzzing statistics:

| Output | Meaning |
|--------|---------|
| **execs/sec** | Execution speed - higher is better |
| **cycles done** | Number of queue passes completed |
| **corpus count** | Number of unique test cases in queue |
| **saved crashes** | Number of unique crashes found |
| **stability** | % of stable edges (should be near 100%) |

### Output Directory Structure

```text
out/default/
├── cmdline          # How was the SUT invoked?
├── crashes/         # Inputs that crash the SUT
│   └── id:000000,sig:06,src:000002,time:286,execs:13105,op:havoc,rep:4
├── hangs/           # Inputs that hang the SUT
├── queue/           # Test cases reproducing final fuzzer state
│   ├── id:000000,time:0,execs:0,orig:minimal_seed
│   └── id:000001,src:000000,time:0,execs:8,op:havoc,rep:6,+cov
├── fuzzer_stats     # Campaign statistics
└── plot_data        # Data for plotting
```

### Analyzing Results

View live campaign statistics:

```bash
./afl++ <host/docker> afl-whatsup out
```

Create coverage plots:

```bash
apt install gnuplot
./afl++ <host/docker> afl-plot out/default out_graph/
```

### Re-executing Test Cases

```bash
./afl++ <host/docker> ./fuzz out/default/crashes/<test_case>
```

### Fuzzer Options

| Option | Purpose |
|--------|---------|
| `-G 4000` | Maximum test input length (default: 1048576 bytes) |
| `-t 1000` | Timeout in milliseconds for each test case (default: 1000ms) |
| `-m 1000` | Memory limit in megabytes (default: 0 = unlimited) |
| `-x ./dict.dict` | Use dictionary file to guide mutations |

## Multi-Core Fuzzing

AFL++ excels at multi-core fuzzing with two major advantages:
1. More executions per second (scales linearly with physical cores)
2. Asymmetrical fuzzing (e.g., one ASan job, rest without sanitizers)

### Starting a Campaign

Start the primary fuzzer (in background):

```bash
./afl++ <host/docker> afl-fuzz -M primary -i seeds -o state -- ./fuzz 1>primary.log 2>primary.error &
```

Start secondary fuzzers (as many as you have cores):

```bash
./afl++ <host/docker> afl-fuzz -S secondary01 -i seeds -o state -- ./fuzz 1>secondary01.log 2>secondary01.error &
./afl++ <host/docker> afl-fuzz -S secondary02 -i seeds -o state -- ./fuzz 1>secondary02.log 2>secondary02.error &
```

### Monitoring Multi-Core Campaigns

List all running jobs:

```bash
jobs
```

View live statistics (updates every second):

```bash
./afl++ <host/docker> watch -n1 --color afl-whatsup state/
```

### Stopping All Fuzzers

```bash
kill $(jobs -p)
```

## Coverage Analysis

AFL++ automatically tracks coverage through edge instrumentation. Coverage information is stored in `fuzzer_stats` and `plot_data`.

### Measuring Coverage

Use `afl-plot` to visualize coverage over time:

```bash
./afl++ <host/docker> afl-plot out/default out_graph/
```

### Improving Coverage

- Use dictionaries for format-aware fuzzing
- Run longer campaigns (cycles_wo_finds indicates plateau)
- Try different mutation strategies with multi-core fuzzing
- Analyze coverage gaps and add targeted seed inputs

> **See Also:** For detailed coverage analysis techniques, identifying coverage gaps,
> and systematic coverage improvement, see the **coverage-analysis** technique skill.

## CMPLOG

CMPLOG/RedQueen is the best path constraint solving mechanism available in any fuzzer.
To enable it, the fuzz target needs to be instrumented for it.
Before building the fuzzing target set the environment variable:

```bash
./afl++ <host/docker> AFL_LLVM_CMPLOG=1 make
```

No special action is needed for compiling and linking the harness.

To run a fuzzer instance with a CMPLOG instrumented fuzzing target, add `-c0` to the command like arguments:

```bash
./afl++ <host/docker> afl-fuzz -c0 -S cmplog -i seeds -o state -- ./fuzz 1>secondary02.log 2>secondary02.error &
```

## Sanitizer Integration

Sanitizers are essential for finding memory corruption bugs that don't cause immediate crashes.

### AddressSanitizer (ASan)

```bash
./afl++ <host/docker> AFL_USE_ASAN=1 afl-clang-fast++ -DNO_MAIN=1 -O2 -fsanitize=fuzzer harness.cc main.cc -o fuzz
```

**Note:** Memory limit (`-m`) is not supported with ASan due to 20TB virtual memory reservation.

### UndefinedBehaviorSanitizer (UBSan)

```bash
./afl++ <host/docker> AFL_USE_UBSAN=1 afl-clang-fast++ -DNO_MAIN=1 -O2 -fsanitize=fuzzer,undefined harness.cc main.cc -o fuzz
```

### Common Sanitizer Issues

| Issue | Solution |
|-------|----------|
| ASan slows fuzzing | Use only 1 ASan job in multi-core setup |
| Stack exhaustion | Increase stack with `ASAN_OPTIONS=stack_size=...` |
| GCC version mismatch | Ensure system GCC matches AFL++ plugin version |

> **See Also:** For comprehensive sanitizer configuration and troubleshooting,
> see the **address-sanitizer** technique skill.

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| Use LLVMFuzzerTestOneInput harnesses where possible | If a fuzzing campaign has at least 85% stability then this is the most efficient fuzzing style. If not then try standard input or file input fuzzing |
| Use dictionaries | Helps fuzzer discover format-specific keywords and magic bytes |
| Set realistic timeouts | Prevents false positives from system load |
| Limit input size | Larger inputs don't necessarily explore more space |
| Monitor stability | Low stability indicates non-deterministic behavior |

### Standard Input Fuzzing

AFL++ can fuzz programs reading from stdin without a libFuzzer harness:

```bash
./afl++ <host/docker> afl-clang-fast++ -O2 main_stdin.c -o fuzz_stdin
./afl++ <host/docker> afl-fuzz -i seeds -o out -- ./fuzz_stdin
```

This is slower than persistent mode but requires no harness code.

### File Input Fuzzing

For programs that read files, use `@@` placeholder:

```bash
./afl++ <host/docker> afl-clang-fast++ -O2 main_file.c -o fuzz_file
./afl++ <host/docker> afl-fuzz -i seeds -o out -- ./fuzz_file @@
```

For better performance, use `fmemopen` to create file descriptors from memory.

### Argument Fuzzing

Fuzz command-line arguments using `argv-fuzz-inl.h`:

```c++
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __AFL_COMPILER
#include "argv-fuzz-inl.h"
#endif

void check_buf(char *buf, size_t buf_len) {
    if(buf_len > 0 && buf[0] == 'a') {
        if(buf_len > 1 && buf[1] == 'b') {
            if(buf_len > 2 && buf[2] == 'c') {
                abort();
            }
        }
    }
}

int main(int argc, char *argv[]) {
#ifdef __AFL_COMPILER
    AFL_INIT_ARGV();
#endif

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_string>\n", argv[0]);
        return 1;
    }

    char *input_buf = argv[1];
    size_t len = strlen(input_buf);
    check_buf(input_buf, len);
    return 0;
}
```

Download the header:

```bash
curl -O https://raw.githubusercontent.com/AFLplusplus/AFLplusplus/stable/utils/argv_fuzzing/argv-fuzz-inl.h
```

Compile and run:

```bash
./afl++ <host/docker> afl-clang-fast++ -O2 main_arg.c -o fuzz_arg
./afl++ <host/docker> afl-fuzz -i seeds -o out -- ./fuzz_arg
```

### Performance Tuning

| Setting | Impact |
|---------|--------|
| CPU core count | Linear scaling with physical cores |
| Persistent mode | 10-20x faster than fork server |
| `-G` input size limit | Smaller = faster, but may miss bugs |
| ASan ratio | 1 ASan job per 4-8 non-ASan jobs |

## Real-World Examples

### Example: libpng

Fuzzing libpng demonstrates fuzzing a C project with static libraries:

```bash
# Get source
curl -L -O https://downloads.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.xz
tar xf libpng-1.6.37.tar.xz
cd libpng-1.6.37/

# Install dependencies
apt install zlib1g-dev

# Configure and build static library
export CC=afl-clang-fast CFLAGS=-fsanitize=fuzzer-no-link
export CXX=afl-clang-fast++ CXXFLAGS="$CFLAGS"
./configure --enable-shared=no
export AFL_LLVM_CMPLOG=1
export AFL_USE_ASAN=1
make

# Download harness
curl -O https://raw.githubusercontent.com/glennrp/libpng/f8e5fa92b0e37ab597616f554bee254157998227/contrib/oss-fuzz/libpng_read_fuzzer.cc

# Link fuzzer
export AFL_USE_ASAN=1
$CXX -fsanitize=fuzzer libpng_read_fuzzer.cc .libs/libpng16.a -lz -o fuzz

# Prepare seeds and dictionary
mkdir seeds/
curl -o seeds/input.png https://raw.githubusercontent.com/glennrp/libpng/acfd50ae0ba3198ad734e5d4dec2b05341e50924/contrib/pngsuite/iftp1n3p08.png
curl -O https://raw.githubusercontent.com/glennrp/libpng/2fff013a6935967960a5ae626fc21432807933dd/contrib/oss-fuzz/png.dict

# Start fuzzing
./afl++ <host/docker> afl-fuzz -i seeds -o out -- ./fuzz
```

### Example: CMake-based Project

```cmake
project(BuggyProgram)
cmake_minimum_required(VERSION 3.0)

add_executable(buggy_program main.cc)

add_executable(fuzz main.cc harness.cc)
target_compile_definitions(fuzz PRIVATE NO_MAIN=1)
target_compile_options(fuzz PRIVATE -O2 -fsanitize=fuzzer-no-link)
target_link_libraries(fuzz -fsanitize=fuzzer)
```

Build and fuzz:

```bash
# Build non-instrumented binary
./afl++ <host/docker> cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ .
./afl++ <host/docker> cmake --build . --target buggy_program

# Build fuzzer
./afl++ <host/docker> cmake -DCMAKE_C_COMPILER=afl-clang-fast -DCMAKE_CXX_COMPILER=afl-clang-fast++ .
./afl++ <host/docker> cmake --build . --target fuzz

# Fuzz
./afl++ <host/docker> afl-fuzz -i seeds -o out -- ./fuzz
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Low exec/sec (<1k) | Not using persistent mode | Create a LLVMFuzzerTestOneInput style harness |
| Low stability (<85%) | Non-deterministic code | Fuzz a program via stdin or file inputs, or create such a harness |
| GCC plugin error | GCC version mismatch | Ensure system GCC matches AFL++ build and install gcc-$GCC_VERSION-plugin-dev |
| No crashes found | Need sanitizers | Recompile with `AFL_USE_ASAN=1` |
| Memory limit exceeded | ASan uses 20TB virtual | Remove `-m` flag when using ASan |
| Docker performance loss | Virtualization overhead | Use bare metal or VM for production fuzzing |

## Related Skills

### Technique Skills

| Skill | Use Case |
|-------|----------|
| **fuzz-harness-writing** | Detailed guidance on writing effective harnesses |
| **address-sanitizer** | Memory error detection during fuzzing |
| **undefined-behavior-sanitizer** | Detect undefined behavior bugs |
| **fuzzing-corpus** | Building and managing seed corpora |
| **fuzzing-dictionaries** | Creating dictionaries for format-aware fuzzing |

### Related Fuzzers

| Skill | When to Consider |
|-------|------------------|
| **libfuzzer** | Quick prototyping, single-threaded fuzzing is sufficient |
| **libafl** | Need custom mutators or research-grade features |

## Resources

### Key External Resources

**[AFL++ GitHub Repository](https://github.com/AFLplusplus/AFLplusplus)**
Official repository with comprehensive documentation, examples, and issue tracker.

**[Fuzzing in Depth](https://aflplus.plus/docs/fuzzing_in_depth.md)**
Advanced documentation by the AFL++ team covering instrumentation modes, optimization techniques, and advanced use cases.

**[AFL++ Under The Hood](https://blog.ritsec.club/posts/afl-under-hood/)**
Technical deep-dive into AFL++ internals, mutation strategies, and coverage tracking mechanisms.

**[AFL++: Combining Incremental Steps of Fuzzing Research](https://www.usenix.org/system/files/woot20-paper-fioraldi.pdf)**
Research paper describing AFL++ architecture and performance improvements over original AFL.

### Video Resources

- [Fuzzing cURL](https://blog.trailofbits.com/2023/02/14/curl-audit-fuzzing-libcurl-command-line-interface/) - Trail of Bits blog post on using AFL++ argument fuzzing for cURL
- [Sudo Vulnerability Walkthrough](https://www.youtube.com/playlist?list=PLhixgUqwRTjy0gMuT4C3bmjeZjuNQyqdx) - LiveOverflow series on rediscovering CVE-2021-3156
- [Rediscovery of libpng bug](https://www.youtube.com/watch?v=PJLWlmp8CDM) - LiveOverflow video on finding CVE-2023-4863

# atheris

# Atheris

Atheris is a coverage-guided Python fuzzer built on libFuzzer. It enables fuzzing of both pure Python code and Python C extensions with integrated AddressSanitizer support for detecting memory corruption issues.

## When to Use

| Fuzzer | Best For | Complexity |
|--------|----------|------------|
| Atheris | Python code and C extensions | Low-Medium |
| Hypothesis | Property-based testing | Low |
| python-afl | AFL-style fuzzing | Medium |

**Choose Atheris when:**
- Fuzzing pure Python code with coverage guidance
- Testing Python C extensions for memory corruption
- Integration with libFuzzer ecosystem is desired
- AddressSanitizer support is needed

## Quick Start

```python
import sys
import atheris

@atheris.instrument_func
def test_one_input(data: bytes):
    if len(data) == 4:
        if data[0] == 0x46:  # "F"
            if data[1] == 0x55:  # "U"
                if data[2] == 0x5A:  # "Z"
                    if data[3] == 0x5A:  # "Z"
                        raise RuntimeError("You caught me")

def main():
    atheris.Setup(sys.argv, test_one_input)
    atheris.Fuzz()

if __name__ == "__main__":
    main()
```

Run:
```bash
python fuzz.py
```

## Installation

Atheris supports 32-bit and 64-bit Linux, and macOS. We recommend fuzzing on Linux because it's simpler to manage and often faster.

### Prerequisites

- Python 3.7 or later
- Recent version of clang (preferably [latest release](https://github.com/llvm/llvm-project/releases))
- For Docker users: [Docker Desktop](https://www.docker.com/products/docker-desktop/)

### Linux/macOS

```bash
uv pip install atheris
```

### Docker Environment (Recommended)

For a fully operational Linux environment with all dependencies configured:

```dockerfile
# https://hub.docker.com/_/python
ARG PYTHON_VERSION=3.11

FROM python:$PYTHON_VERSION-slim-bookworm

RUN python --version

RUN apt update && apt install -y \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# LLVM builds version 15-19 for Debian 12 (Bookworm)
# https://apt.llvm.org/bookworm/dists/
ARG LLVM_VERSION=19

RUN echo "deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-$LLVM_VERSION main" > /etc/apt/sources.list.d/llvm.list
RUN echo "deb-src http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-$LLVM_VERSION main" >> /etc/apt/sources.list.d/llvm.list
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key > /etc/apt/trusted.gpg.d/apt.llvm.org.asc

RUN apt update && apt install -y \
    build-essential \
    clang-$LLVM_VERSION \
    && rm -rf /var/lib/apt/lists/*

ENV APP_DIR "/app"
RUN mkdir $APP_DIR
WORKDIR $APP_DIR

ENV VIRTUAL_ENV "/opt/venv"
RUN python -m venv $VIRTUAL_ENV
ENV PATH "$VIRTUAL_ENV/bin:$PATH"

# https://github.com/google/atheris/blob/master/native_extension_fuzzing.md#step-1-compiling-your-extension
ENV CC="clang-$LLVM_VERSION"
ENV CFLAGS "-fsanitize=address,fuzzer-no-link"
ENV CXX="clang++-$LLVM_VERSION"
ENV CXXFLAGS "-fsanitize=address,fuzzer-no-link"
ENV LDSHARED="clang-$LLVM_VERSION -shared"
ENV LDSHAREDXX="clang++-$LLVM_VERSION -shared"
ENV ASAN_SYMBOLIZER_PATH="/usr/bin/llvm-symbolizer-$LLVM_VERSION"

# Allow Atheris to find fuzzer sanitizer shared libs
# https://github.com/google/atheris#building-from-source
RUN LIBFUZZER_LIB=$($CC -print-file-name=libclang_rt.fuzzer_no_main-$(uname -m).a) \
    python -m pip install --no-binary atheris atheris

# https://github.com/google/atheris/blob/master/native_extension_fuzzing.md#option-a-sanitizerlibfuzzer-preloads
ENV LD_PRELOAD "$VIRTUAL_ENV/lib/python3.11/site-packages/asan_with_fuzzer.so"

# 1. Skip memory allocation failures for now, they are common, and low impact (DoS)
# 2. https://github.com/google/atheris/blob/master/native_extension_fuzzing.md#leak-detection
ENV ASAN_OPTIONS "allocator_may_return_null=1,detect_leaks=0"

CMD ["/bin/bash"]
```

Build and run:
```bash
docker build -t atheris .
docker run -it atheris
```

### Verification

```bash
python -c "import atheris; print(atheris.__version__)"
```

## Writing a Harness

### Harness Structure for Pure Python

```python
import sys
import atheris

@atheris.instrument_func
def test_one_input(data: bytes):
    """
    Fuzzing entry point. Called with random byte sequences.

    Args:
        data: Random bytes generated by the fuzzer
    """
    # Add input validation if needed
    if len(data) < 1:
        return

    # Call your target function
    try:
        your_target_function(data)
    except ValueError:
        # Expected exceptions should be caught
        pass
    # Let unexpected exceptions crash (that's what we're looking for!)

def main():
    atheris.Setup(sys.argv, test_one_input)
    atheris.Fuzz()

if __name__ == "__main__":
    main()
```

### Harness Rules

| Do | Don't |
|----|-------|
| Use `@atheris.instrument_func` for coverage | Forget to instrument target code |
| Catch expected exceptions | Catch all exceptions indiscriminately |
| Use `atheris.instrument_imports()` for libraries | Import modules after `atheris.Setup()` |
| Keep harness deterministic | Use randomness or time-based behavior |

> **See Also:** For detailed harness writing techniques, patterns for handling complex inputs,
> and advanced strategies, see the **fuzz-harness-writing** technique skill.

## Fuzzing Pure Python Code

For fuzzing broader parts of an application or library, use instrumentation functions:

```python
import atheris
with atheris.instrument_imports():
    import your_module
    from another_module import target_function

def test_one_input(data: bytes):
    target_function(data)

atheris.Setup(sys.argv, test_one_input)
atheris.Fuzz()
```

**Instrumentation Options:**
- `atheris.instrument_func` - Decorator for single function instrumentation
- `atheris.instrument_imports()` - Context manager for instrumenting all imported modules
- `atheris.instrument_all()` - Instrument all Python code system-wide

## Fuzzing Python C Extensions

Python C extensions require compilation with specific flags for instrumentation and sanitizer support.

### Environment Configuration

If using the provided Dockerfile, these are already configured. For local setup:

```bash
export CC="clang"
export CFLAGS="-fsanitize=address,fuzzer-no-link"
export CXX="clang++"
export CXXFLAGS="-fsanitize=address,fuzzer-no-link"
export LDSHARED="clang -shared"
```

### Example: Fuzzing cbor2

Install the extension from source:
```bash
CBOR2_BUILD_C_EXTENSION=1 python -m pip install --no-binary cbor2 cbor2==5.6.4
```

The `--no-binary` flag ensures the C extension is compiled locally with instrumentation.

Create `cbor2-fuzz.py`:
```python
import sys
import atheris

# _cbor2 ensures the C library is imported
from _cbor2 import loads

def test_one_input(data: bytes):
    try:
        loads(data)
    except Exception:
        # We're searching for memory corruption, not Python exceptions
        pass

def main():
    atheris.Setup(sys.argv, test_one_input)
    atheris.Fuzz()

if __name__ == "__main__":
    main()
```

Run:
```bash
python cbor2-fuzz.py
```

> **Important:** When running locally (not in Docker), you must [set `LD_PRELOAD` manually](https://github.com/google/atheris/blob/master/native_extension_fuzzing.md#option-a-sanitizerlibfuzzer-preloads).

## Corpus Management

### Creating Initial Corpus

```bash
mkdir corpus
# Add seed inputs
echo "test data" > corpus/seed1
echo '{"key": "value"}' > corpus/seed2
```

Run with corpus:
```bash
python fuzz.py corpus/
```

### Corpus Minimization

Atheris inherits corpus minimization from libFuzzer:
```bash
python fuzz.py -merge=1 new_corpus/ old_corpus/
```

> **See Also:** For corpus creation strategies, dictionaries, and seed selection,
> see the **fuzzing-corpus** technique skill.

## Running Campaigns

### Basic Run

```bash
python fuzz.py
```

### With Corpus Directory

```bash
python fuzz.py corpus/
```

### Common Options

```bash
# Run for 10 minutes
python fuzz.py -max_total_time=600

# Limit input size
python fuzz.py -max_len=1024

# Run with multiple workers
python fuzz.py -workers=4 -jobs=4
```

### Interpreting Output

| Output | Meaning |
|--------|---------|
| `NEW    cov: X` | Found new coverage, corpus expanded |
| `pulse  cov: X` | Periodic status update |
| `exec/s: X` | Executions per second (throughput) |
| `corp: X/Yb` | Corpus size: X inputs, Y bytes total |
| `ERROR: libFuzzer` | Crash detected |

## Sanitizer Integration

### AddressSanitizer (ASan)

AddressSanitizer is automatically integrated when using the provided Docker environment or when compiling with appropriate flags.

For local setup:
```bash
export CFLAGS="-fsanitize=address,fuzzer-no-link"
export CXXFLAGS="-fsanitize=address,fuzzer-no-link"
```

Configure ASan behavior:
```bash
export ASAN_OPTIONS="allocator_may_return_null=1,detect_leaks=0"
```

### LD_PRELOAD Configuration

For native extension fuzzing:
```bash
export LD_PRELOAD="$(python -c 'import atheris; import os; print(os.path.join(os.path.dirname(atheris.__file__), "asan_with_fuzzer.so"))')"
```

> **See Also:** For detailed sanitizer configuration, common issues, and advanced flags,
> see the **address-sanitizer** and **undefined-behavior-sanitizer** technique skills.

### Common Sanitizer Issues

| Issue | Solution |
|-------|----------|
| `LD_PRELOAD` not set | Export `LD_PRELOAD` to point to `asan_with_fuzzer.so` |
| Memory allocation failures | Set `ASAN_OPTIONS=allocator_may_return_null=1` |
| Leak detection noise | Set `ASAN_OPTIONS=detect_leaks=0` |
| Missing symbolizer | Set `ASAN_SYMBOLIZER_PATH` to `llvm-symbolizer` |

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| Use `atheris.instrument_imports()` early | Ensures all imports are instrumented for coverage |
| Start with small `max_len` | Faster initial fuzzing, gradually increase |
| Use dictionaries for structured formats | Helps fuzzer understand format tokens |
| Run multiple parallel instances | Better coverage exploration |

### Custom Instrumentation

Fine-tune what gets instrumented:
```python
import atheris

# Instrument only specific modules
with atheris.instrument_imports():
    import target_module
# Don't instrument test harness code

def test_one_input(data: bytes):
    target_module.parse(data)
```

### Performance Tuning

| Setting | Impact |
|---------|--------|
| `-max_len=N` | Smaller values = faster execution |
| `-workers=N -jobs=N` | Parallel fuzzing for faster coverage |
| `ASAN_OPTIONS=fast_unwind_on_malloc=0` | Better stack traces, slower execution |

### UndefinedBehaviorSanitizer (UBSan)

Add UBSan to catch additional bugs:
```bash
export CFLAGS="-fsanitize=address,undefined,fuzzer-no-link"
export CXXFLAGS="-fsanitize=address,undefined,fuzzer-no-link"
```

Note: Modify flags in Dockerfile if using containerized setup.

## Real-World Examples

### Example: Pure Python Parser

```python
import sys
import atheris
import json

@atheris.instrument_func
def test_one_input(data: bytes):
    try:
        # Fuzz Python's JSON parser
        json.loads(data.decode('utf-8', errors='ignore'))
    except (ValueError, UnicodeDecodeError):
        pass

def main():
    atheris.Setup(sys.argv, test_one_input)
    atheris.Fuzz()

if __name__ == "__main__":
    main()
```

### Example: HTTP Request Parsing

```python
import sys
import atheris

with atheris.instrument_imports():
    from urllib3 import HTTPResponse
    from io import BytesIO

def test_one_input(data: bytes):
    try:
        # Fuzz HTTP response parsing
        fake_response = HTTPResponse(
            body=BytesIO(data),
            headers={},
            preload_content=False
        )
        fake_response.read()
    except Exception:
        pass

def main():
    atheris.Setup(sys.argv, test_one_input)
    atheris.Fuzz()

if __name__ == "__main__":
    main()
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| No coverage increase | Poor seed corpus or target not instrumented | Add better seeds, verify `instrument_imports()` |
| Slow execution | ASan overhead or large inputs | Reduce `max_len`, use `ASAN_OPTIONS=fast_unwind_on_malloc=1` |
| Import errors | Modules imported before instrumentation | Move imports inside `instrument_imports()` context |
| Segfault without ASan output | Missing `LD_PRELOAD` | Set `LD_PRELOAD` to `asan_with_fuzzer.so` path |
| Build failures | Wrong compiler or missing flags | Verify `CC`, `CFLAGS`, and clang version |

## Related Skills

### Technique Skills

| Skill | Use Case |
|-------|----------|
| **fuzz-harness-writing** | Detailed guidance on writing effective harnesses |
| **address-sanitizer** | Memory error detection during fuzzing |
| **undefined-behavior-sanitizer** | Catching undefined behavior in C extensions |
| **coverage-analysis** | Measuring and improving code coverage |
| **fuzzing-corpus** | Building and managing seed corpora |

### Related Fuzzers

| Skill | When to Consider |
|-------|------------------|
| **hypothesis** | Property-based testing with type-aware generation |
| **python-afl** | AFL-style fuzzing for Python when Atheris isn't available |

## Resources

### Key External Resources

**[Atheris GitHub Repository](https://github.com/google/atheris)**
Official repository with installation instructions, examples, and documentation for fuzzing both pure Python and native extensions.

**[Native Extension Fuzzing Guide](https://github.com/google/atheris/blob/master/native_extension_fuzzing.md)**
Comprehensive guide covering compilation flags, LD_PRELOAD setup, sanitizer configuration, and troubleshooting for Python C extensions.

**[Continuously Fuzzing Python C Extensions](https://blog.trailofbits.com/2024/02/23/continuously-fuzzing-python-c-extensions/)**
Trail of Bits blog post covering CI/CD integration, ClusterFuzzLite setup, and real-world examples of fuzzing Python C extensions in continuous integration pipelines.

**[ClusterFuzzLite Python Integration](https://google.github.io/clusterfuzzlite/build-integration/python-lang/)**
Guide for integrating Atheris fuzzing into CI/CD pipelines using ClusterFuzzLite for automated continuous fuzzing.

### Video Resources

Videos and tutorials are available in the main Atheris documentation and libFuzzer resources.

# cargo-fuzz

# cargo-fuzz

cargo-fuzz is the de facto choice for fuzzing Rust projects when using Cargo. It uses libFuzzer as the backend and provides a convenient Cargo subcommand that automatically enables relevant compilation flags for your Rust project, including support for sanitizers like AddressSanitizer.

## When to Use

cargo-fuzz is currently the primary and most mature fuzzing solution for Rust projects using Cargo.

| Fuzzer | Best For | Complexity |
|--------|----------|------------|
| cargo-fuzz | Cargo-based Rust projects, quick setup | Low |
| AFL++ | Multi-core fuzzing, non-Cargo projects | Medium |
| LibAFL | Custom fuzzers, research, advanced use cases | High |

**Choose cargo-fuzz when:**
- Your project uses Cargo (required)
- You want simple, quick setup with minimal configuration
- You need integrated sanitizer support
- You're fuzzing Rust code with or without unsafe blocks

## Quick Start

```rust
#![no_main]

use libfuzzer_sys::fuzz_target;

fn harness(data: &[u8]) {
    your_project::check_buf(data);
}

fuzz_target!(|data: &[u8]| {
    harness(data);
});
```

Initialize and run:
```bash
cargo fuzz init
# Edit fuzz/fuzz_targets/fuzz_target_1.rs with your harness
cargo +nightly fuzz run fuzz_target_1
```

## Installation

cargo-fuzz requires the nightly Rust toolchain because it uses features only available in nightly.

### Prerequisites

- Rust and Cargo installed via [rustup](https://rustup.rs/)
- Nightly toolchain

### Linux/macOS

```bash
# Install nightly toolchain
rustup install nightly

# Install cargo-fuzz
cargo install cargo-fuzz
```

### Verification

```bash
cargo +nightly --version
cargo fuzz --version
```

## Writing a Harness

### Project Structure

cargo-fuzz works best when your code is structured as a library crate. If you have a binary project, split your `main.rs` into:

```text
src/main.rs  # Entry point (main function)
src/lib.rs   # Code to fuzz (public functions)
Cargo.toml
```

Initialize fuzzing:
```bash
cargo fuzz init
```

This creates:
```text
fuzz/
├── Cargo.toml
└── fuzz_targets/
    └── fuzz_target_1.rs
```

### Harness Structure

```rust
#![no_main]

use libfuzzer_sys::fuzz_target;

fn harness(data: &[u8]) {
    // 1. Validate input size if needed
    if data.is_empty() {
        return;
    }

    // 2. Call target function with fuzz data
    your_project::target_function(data);
}

fuzz_target!(|data: &[u8]| {
    harness(data);
});
```

### Harness Rules

| Do | Don't |
|----|-------|
| Structure code as library crate | Keep everything in main.rs |
| Use `fuzz_target!` macro | Write custom main function |
| Handle `Result::Err` gracefully | Panic on expected errors |
| Keep harness deterministic | Use random number generators |

> **See Also:** For detailed harness writing techniques and structure-aware fuzzing with the
> `arbitrary` crate, see the **fuzz-harness-writing** technique skill.

## Structure-Aware Fuzzing

cargo-fuzz integrates with the [arbitrary](https://github.com/rust-fuzz/arbitrary) crate for structure-aware fuzzing:

```rust
// In your library crate
use arbitrary::Arbitrary;

#[derive(Debug, Arbitrary)]
pub struct Name {
    data: String
}
```

```rust
// In your fuzz target
#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: your_project::Name| {
    data.check_buf();
});
```

Add to your library's `Cargo.toml`:
```toml
[dependencies]
arbitrary = { version = "1", features = ["derive"] }
```

## Running Campaigns

### Basic Run

```bash
cargo +nightly fuzz run fuzz_target_1
```

### Without Sanitizers (Safe Rust)

If your project doesn't use unsafe Rust, disable sanitizers for 2x performance boost:

```bash
cargo +nightly fuzz run --sanitizer none fuzz_target_1
```

Check if your project uses unsafe code:
```bash
cargo install cargo-geiger
cargo geiger
```

### Re-executing Test Cases

```bash
# Run a specific test case (e.g., a crash)
cargo +nightly fuzz run fuzz_target_1 fuzz/artifacts/fuzz_target_1/crash-<hash>

# Run all corpus entries without fuzzing
cargo +nightly fuzz run fuzz_target_1 fuzz/corpus/fuzz_target_1 -- -runs=0
```

### Using Dictionaries

```bash
cargo +nightly fuzz run fuzz_target_1 -- -dict=./dict.dict
```

### Interpreting Output

| Output | Meaning |
|--------|---------|
| `NEW` | New coverage-increasing input discovered |
| `pulse` | Periodic status update |
| `INITED` | Fuzzer initialized successfully |
| Crash with stack trace | Bug found, saved to `fuzz/artifacts/` |

Corpus location: `fuzz/corpus/fuzz_target_1/`
Crashes location: `fuzz/artifacts/fuzz_target_1/`

## Sanitizer Integration

### AddressSanitizer (ASan)

ASan is enabled by default and detects memory errors:

```bash
cargo +nightly fuzz run fuzz_target_1
```

### Disabling Sanitizers

For pure safe Rust (no unsafe blocks in your code or dependencies):

```bash
cargo +nightly fuzz run --sanitizer none fuzz_target_1
```

**Performance impact:** ASan adds ~2x overhead. Disable for safe Rust to improve fuzzing speed.

### Checking for Unsafe Code

```bash
cargo install cargo-geiger
cargo geiger
```

> **See Also:** For detailed sanitizer configuration, flags, and troubleshooting,
> see the **address-sanitizer** technique skill.

## Coverage Analysis

cargo-fuzz integrates with Rust's coverage tools to analyze fuzzing effectiveness.

### Prerequisites

```bash
rustup toolchain install nightly --component llvm-tools-preview
cargo install cargo-binutils
cargo install rustfilt
```

### Generating Coverage Reports

```bash
# Generate coverage data from corpus
cargo +nightly fuzz coverage fuzz_target_1
```

Create coverage generation script:

```bash
cat <<'EOF' > ./generate_html
#!/bin/sh
if [ $# -lt 1 ]; then
    echo "Error: Name of fuzz target is required."
    echo "Usage: $0 fuzz_target [sources...]"
    exit 1
fi
FUZZ_TARGET="$1"
shift
SRC_FILTER="$@"
TARGET=$(rustc -vV | sed -n 's|host: ||p')
cargo +nightly cov -- show -Xdemangler=rustfilt \
  "target/$TARGET/coverage/$TARGET/release/$FUZZ_TARGET" \
  -instr-profile="fuzz/coverage/$FUZZ_TARGET/coverage.profdata"  \
  -show-line-counts-or-regions -show-instantiations  \
  -format=html -o fuzz_html/ $SRC_FILTER
EOF
chmod +x ./generate_html
```

Generate HTML report:
```bash
./generate_html fuzz_target_1 src/lib.rs
```

HTML report saved to: `fuzz_html/`

> **See Also:** For detailed coverage analysis techniques and systematic coverage improvement,
> see the **coverage-analysis** technique skill.

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| Start with a seed corpus | Dramatically speeds up initial coverage discovery |
| Use `--sanitizer none` for safe Rust | 2x performance improvement |
| Check coverage regularly | Identifies gaps in harness or seed corpus |
| Use dictionaries for parsers | Helps overcome magic value checks |
| Structure code as library | Required for cargo-fuzz integration |

### libFuzzer Options

Pass options to libFuzzer after `--`:

```bash
# See all options
cargo +nightly fuzz run fuzz_target_1 -- -help=1

# Set timeout per run
cargo +nightly fuzz run fuzz_target_1 -- -timeout=10

# Use dictionary
cargo +nightly fuzz run fuzz_target_1 -- -dict=dict.dict

# Limit maximum input size
cargo +nightly fuzz run fuzz_target_1 -- -max_len=1024
```

### Multi-Core Fuzzing

```bash
# Experimental forking support (not recommended)
cargo +nightly fuzz run --jobs 1 fuzz_target_1
```

Note: The multi-core fuzzing feature is experimental and not recommended. For parallel fuzzing, consider running multiple instances manually or using AFL++.

## Real-World Examples

### Example: ogg Crate

The [ogg crate](https://github.com/RustAudio/ogg) parses Ogg media container files. Parsers are excellent fuzzing targets because they handle untrusted data.

```bash
# Clone and initialize
git clone https://github.com/RustAudio/ogg.git
cd ogg/
cargo fuzz init
```

Harness at `fuzz/fuzz_targets/fuzz_target_1.rs`:

```rust
#![no_main]

use ogg::{PacketReader, PacketWriter};
use ogg::writing::PacketWriteEndInfo;
use std::io::Cursor;
use libfuzzer_sys::fuzz_target;

fn harness(data: &[u8]) {
    let mut pck_rdr = PacketReader::new(Cursor::new(data.to_vec()));
    pck_rdr.delete_unread_packets();

    let output = Vec::new();
    let mut pck_wtr = PacketWriter::new(Cursor::new(output));

    if let Ok(_) = pck_rdr.read_packet() {
        if let Ok(r) = pck_rdr.read_packet() {
            match r {
                Some(pck) => {
                    let inf = if pck.last_in_stream() {
                        PacketWriteEndInfo::EndStream
                    } else if pck.last_in_page() {
                        PacketWriteEndInfo::EndPage
                    } else {
                        PacketWriteEndInfo::NormalPacket
                    };
                    let stream_serial = pck.stream_serial();
                    let absgp_page = pck.absgp_page();
                    let _ = pck_wtr.write_packet(
                        pck.data, stream_serial, inf, absgp_page
                    );
                }
                None => return,
            }
        }
    }
}

fuzz_target!(|data: &[u8]| {
    harness(data);
});
```

Seed the corpus:
```bash
mkdir fuzz/corpus/fuzz_target_1/
curl -o fuzz/corpus/fuzz_target_1/320x240.ogg \
  https://commons.wikimedia.org/wiki/File:320x240.ogg
```

Run:
```bash
cargo +nightly fuzz run fuzz_target_1
```

Analyze coverage:
```bash
cargo +nightly fuzz coverage fuzz_target_1
./generate_html fuzz_target_1 src/lib.rs
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| "requires nightly" error | Using stable toolchain | Use `cargo +nightly fuzz` |
| Slow fuzzing performance | ASan enabled for safe Rust | Add `--sanitizer none` flag |
| "cannot find binary" | No library crate | Move code from `main.rs` to `lib.rs` |
| Sanitizer compilation issues | Wrong nightly version | Try different nightly: `rustup install nightly-2024-01-01` |
| Low coverage | Missing seed corpus | Add sample inputs to `fuzz/corpus/fuzz_target_1/` |
| Magic value not found | No dictionary | Create dictionary file with magic values |

## Related Skills

### Technique Skills

| Skill | Use Case |
|-------|----------|
| **fuzz-harness-writing** | Structure-aware fuzzing with `arbitrary` crate |
| **address-sanitizer** | Understanding ASan output and configuration |
| **coverage-analysis** | Measuring and improving fuzzing effectiveness |
| **fuzzing-corpus** | Building and managing seed corpora |
| **fuzzing-dictionaries** | Creating dictionaries for format-aware fuzzing |

### Related Fuzzers

| Skill | When to Consider |
|-------|------------------|
| **libfuzzer** | Fuzzing C/C++ code with similar workflow |
| **aflpp** | Multi-core fuzzing or non-Cargo Rust projects |
| **libafl** | Advanced fuzzing research or custom fuzzer development |

## Resources

**[Rust Fuzz Book - cargo-fuzz](https://rust-fuzz.github.io/book/cargo-fuzz.html)**
Official documentation for cargo-fuzz covering installation, usage, and advanced features.

**[arbitrary crate documentation](https://docs.rs/arbitrary/latest/arbitrary/)**
Guide to structure-aware fuzzing with automatic derivation for Rust types.

**[cargo-fuzz GitHub Repository](https://github.com/rust-fuzz/cargo-fuzz)**
Source code, issue tracker, and examples for cargo-fuzz.

# codeql

# CodeQL

CodeQL is a powerful static analysis framework that allows developers and security researchers to query a codebase for specific code patterns. The CodeQL standard libraries implement support for both inter- and intraprocedural control flow and data flow analysis. However, the learning curve for writing custom queries is steep, and documentation for the CodeQL standard libraries is still scant.

## When to Use

**Use CodeQL when:**
- You need interprocedural control flow and data flow queries across the entire codebase
- Fine-grained control over the abstract syntax tree, control flow graph, and data flow graph is required
- You want to prevent introduction of known bugs and security vulnerabilities into the codebase
- You have access to source code and third-party dependencies (and can build compiled languages)
- The bug class requires complex analysis beyond single-file pattern matching

**Consider alternatives when:**
- Single-file pattern matching is sufficient → Consider Semgrep
- You don't have access to source code or can't build the project
- Analysis time is critical (complex queries may take a long time)
- You need to analyze a closed-source repository without a GitHub Advanced Security license
- The language is not supported by CodeQL

## Quick Reference

| Task | Command |
|------|---------|
| Create database (C/C++) | `codeql database create codeql.db --language=cpp --command='make -j8'` |
| Create database (Go) | `codeql database create codeql.db --language=go` |
| Create database (Java/Kotlin) | `codeql database create codeql.db --language=java` |
| Create database (JavaScript/TypeScript) | `codeql database create codeql.db --language=javascript` |
| Create database (Python) | `codeql database create codeql.db --language=python` |
| Analyze database | `codeql database analyze codeql.db --format=sarif-latest --output=results.sarif -- codeql/cpp-queries` |
| List installed packs | `codeql resolve qlpacks` |
| Download query pack | `codeql pack download trailofbits/cpp-queries` |
| Run custom query | `codeql query run --database codeql.db -- path/to/Query.ql` |
| Test custom queries | `codeql test run -- path/to/test/pack/` |

## Installation

### Installing CodeQL

CodeQL can be installed manually or via Homebrew on macOS/Linux.

**Manual Installation:**
Navigate to the [CodeQL release page](https://github.com/github/codeql-action/releases) and download the latest bundle for your architecture. The bundle contains the `codeql` binary, query libraries for supported languages, and pre-compiled queries.

**Using Homebrew:**
```bash
brew install --cask codeql
```

### Keeping CodeQL Up to Date

CodeQL is under active development. Update regularly to benefit from improvements.

**Manual installation:** Download new updates from the [CodeQL release page](https://github.com/github/codeql-action/releases).

**Homebrew installation:**
```bash
brew upgrade codeql
```

### Verification

```bash
codeql --version
```

## Core Workflow

### Step 1: Build a CodeQL Database

To build a CodeQL database, you typically need to be able to build the corresponding codebase. Ensure the codebase is in a clean state (e.g., run `make clean`, `go clean`, or similar).

**For compiled languages (C/C++, Swift):**
```bash
codeql database create codeql.db --language=cpp --command='make -j8'
```

If using CMake or out-of-source builds, add `--source-root` to specify the source file tree root:
```bash
codeql database create codeql.db --language=cpp --source-root=/path/to/source --command='cmake --build build'
```

**For interpreted languages (Python, JavaScript):**
```bash
codeql database create codeql.db --language=python
```

**For languages with auto-detection (Go, Java):**
```bash
codeql database create codeql.db --language=go
```

For complex build systems, use the `--command` argument to pass the build command.

### Step 2: Analyze the Database

Run pre-compiled query packs on the database:

```bash
codeql database analyze codeql.db --format=sarif-latest --output=results.sarif -- codeql/cpp-queries
```

Output formats include SARIF and CSV. SARIF results can be viewed with the [VSCode SARIF Explorer extension](https://marketplace.visualstudio.com/items?itemName=trailofbits.sarif-explorer).

### Step 3: Review Results

SARIF files contain findings with location, severity, and description. Import into your IDE or CI/CD pipeline for review and remediation.

### Installing Third-Party Query Packs

Published query packs are identified by scope/name/version. For example:

```bash
codeql pack download trailofbits/cpp-queries trailofbits/go-queries
```

For Trail of Bits public CodeQL queries, see [trailofbits/codeql-queries](https://github.com/trailofbits/codeql-queries).

## How to Customize

### Writing Custom Queries

CodeQL queries use a declarative, object-oriented language called QL with Java-like syntax and SQL-like query expressions.

**Basic query structure:**
```ql
import cpp

from FunctionCall call
where call.getTarget().getName() = "memcpy"
select call.getLocation(), call.getArgument(0)
```

This selects all expressions passed as the first argument to `memcpy`.

**Creating a custom class:**
```ql
import cpp

class MemcpyCall extends FunctionCall {
  MemcpyCall() {
    this.getTarget().getName() = "memcpy"
  }

  Expr getDestination() {
    result = this.getArgument(0)
  }

  Expr getSource() {
    result = this.getArgument(1)
  }

  Expr getSize() {
    result = this.getArgument(2)
  }
}

from MemcpyCall call
select call.getLocation(), call.getDestination()
```

### Key Syntax Reference

| Syntax/Operator | Description | Example |
|-----------------|-------------|---------|
| `from Type x where P(x) select f(x)` | Query: select f(x) for all x where P(x) is true | `from FunctionCall call where call.getTarget().getName() = "memcpy" select call` |
| `exists(...)` | Existential quantification | `exists(FunctionCall call \| call.getTarget() = fun)` |
| `forall(...)` | Universal quantification | `forall(Expr e \| e = arg.getAChild() \| e.isConstant())` |
| `+` | Transitive closure (1+ times) | `start.getASuccessor+()` |
| `*` | Reflexive transitive closure (0+ times) | `start.getASuccessor*()` |
| `result` | Special variable for method/function output | `result = this.getArgument(0)` |

### Example: Finding Unhandled Errors

```ql
import cpp

/**
 * @name Unhandled error return value
 * @id custom/unhandled-error
 * @description Function calls that return error codes that are not checked
 * @kind problem
 * @problem.severity warning
 * @precision medium
 */

predicate isErrorReturningFunction(Function f) {
  f.getName().matches("%error%") or
  f.getName().matches("%Error%")
}

from FunctionCall call
where
  isErrorReturningFunction(call.getTarget()) and
  not exists(Expr parent |
    parent = call.getParent*() and
    (parent instanceof IfStmt or parent instanceof SwitchStmt)
  )
select call, "Error return value not checked"
```

### Adding Query Metadata

Query metadata is defined in an initial comment:

```ql
/**
 * @name Short name for the issue
 * @id scope/query-name
 * @description Longer description of the issue
 * @kind problem
 * @tags security external/cwe/cwe-123
 * @problem.severity error
 * @precision high
 */
```

**Required fields:**
- `name`: Short string identifying the issue
- `id`: Unique identifier (lowercase letters, numbers, `/`, `-`)
- `description`: Longer description (a few sentences)
- `kind`: Either `problem` or `path-problem`
- `problem.severity`: `error`, `warning`, or `recommendation`
- `precision`: `low`, `medium`, `high`, or `very-high`

**Output format requirements:**
- `problem` queries: Output must be `(Location, string)`
- `path-problem` queries: Output must be `(DataFlow::Node, DataFlow::PathNode, DataFlow::PathNode, string)`

### Testing Custom Queries

Create a test pack with `qlpack.yml`:

```yaml
name: scope/name-test
version: 0.0.1
dependencies:
  codeql-query-pack-to-test: "*"
extractor: cpp
```

Create a test directory (e.g., `MemcpyCall/`) containing:
- `test.c`: Source file with code pattern to detect
- `MemcpyCall.qlref`: Text file with path to the query
- `MemcpyCall.expected`: Expected output

Run tests:
```bash
codeql test run -- path/to/test/pack/
```

If `MemcpyCall.expected` is missing or incorrect, an `MemcpyCall.actual` file is created. Review it, and if correct, rename to `MemcpyCall.expected`.

## Advanced Usage

### Creating New Query Packs

Initialize a query pack:
```bash
codeql pack init <scope>/<name>
```

This creates a `qlpack.yml` file:
```yaml
---
library: false
warnOnImplicitThis: false
name: <scope>/<name>
version: 0.0.1
```

Add standard library dependencies:
```bash
codeql pack add codeql/cpp-all
```

Create a workspace file (`codeql-workspace.yml`) for the CLI to work correctly.

Install dependencies:
```bash
codeql pack install
```

Configure the CLI to find your queries by creating `~/.config/codeql/config`:
```plain
--search-path /full/path/to/your/codeql/root/directory
```

### Recommended Directory Structure

```plain
.
├── codeql-workspace.yml
├── cpp
│   ├── lib
│   │   ├── qlpack.yml
│   │   └── scope
│   │       └── security
│   │           └── someLibrary.qll
│   ├── src
│   │   ├── qlpack.yml
│   │   ├── suites
│   │   │   ├── scope-cpp-code-scanning.qls
│   │   │   └── scope-cpp-security.qls
│   │   └── security
│   │       └── AppSecAnalysis
│   │           ├── AppSecAnalysis.c
│   │           ├── AppSecAnalysis.qhelp
│   │           └── AppSecAnalysis.ql
│   └── test
│       ├── qlpack.yml
│       └── query-tests
│           └── security
│               └── AppSecAnalysis
│                   ├── AppSecAnalysis.c
│                   ├── AppSecAnalysis.expected
│                   └── AppSecAnalysis.qlref
```

### Recursion and Transitive Closures

**Recursive predicate:**
```ql
predicate isReachableFrom(BasicBlock start, BasicBlock end) {
  start = end or isReachableFrom(start.getASuccessor(), end)
}
```

**Using transitive closure (equivalent):**
```ql
predicate isReachableFrom(BasicBlock start, BasicBlock end) {
  end = start.getASuccessor*()
}
```

Use `*` for zero or more applications, `+` for one or more.

### Excluding Individual Files

CodeQL instruments the build process. If object files already exist and are up-to-date, corresponding source files won't be added to the database. This can reduce database size but means CodeQL has only partial knowledge about excluded files and cannot reason about data flow through them.

**Recommendation:** Include third-party libraries and filter issues based on location rather than excluding files during database creation.

### Editor Support

**VSCode:** [CodeQL extension](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-codeql) provides LSP support, syntax highlighting, query running, and AST visualization.

**Neovim:** [codeql.nvim](https://github.com/pwntester/codeql.nvim) provides similar functionality.

**Helix/Other editors:** Use the CodeQL LSP server and [Tree-sitter grammar for CodeQL](https://github.com/tree-sitter/tree-sitter-ql).

**VSCode Quick Query:** Use "CodeQL: Quick Query" command to run single queries against a database.

**Debugging queries:** Add database source to workspace, then use "CodeQL: View AST" to display the AST for individual nodes.

## Configuration

### CodeQL Standard Libraries

CodeQL standard libraries are language-specific. Refer to API documentation:

- [C and C++](https://codeql.github.com/codeql-standard-libraries/cpp/)
- [Go](https://codeql.github.com/codeql-standard-libraries/go/)
- [Java and Kotlin](https://codeql.github.com/codeql-standard-libraries/java/)
- [JavaScript and TypeScript](https://codeql.github.com/codeql-standard-libraries/javascript/)
- [Python](https://codeql.github.com/codeql-standard-libraries/python/)
- [C#](https://codeql.github.com/codeql-standard-libraries/csharp/)
- [Ruby](https://codeql.github.com/codeql-standard-libraries/ruby/)
- [Swift](https://codeql.github.com/codeql-standard-libraries/swift/)

### Supported Languages

CodeQL supports C/C++, C#, Go, Java, Kotlin, JavaScript, TypeScript, Python, Ruby, and Swift. Check [supported languages and frameworks](https://codeql.github.com/docs/codeql-overview/supported-languages-and-frameworks) for details.

## CI/CD Integration

### GitHub Actions

Enable code scanning from "Code security and analysis" in repository settings. Choose default or advanced setup.

**Advanced setup workflow:**
```yaml
name: "CodeQL"

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  schedule:
    - cron: '34 10 * * 6'

jobs:
  analyze:
    name: Analyze
    runs-on: ${{ (matrix.language == 'swift' && 'macos-latest') || 'ubuntu-latest' }}
    timeout-minutes: ${{ (matrix.language == 'swift' && 120) || 360 }}

    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      fail-fast: false
      matrix:
        language: [ 'cpp' ]

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: ${{ matrix.language }}

    - name: Autobuild
      uses: github/codeql-action/autobuild@v3

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v3
      with:
        category: "/language:${{matrix.language}}"
```

For compiled languages, replace autobuild with custom build commands:
```yaml
- run: |
    make -j8
```

### Using Custom Queries in CI

Specify query packs and queries in the "Initialize CodeQL" step:

```yaml
- uses: github/codeql-action/init@v3
  with:
    queries: security-extended,security-and-quality
    packs: trailofbits/cpp-queries
```

For repository-local queries:
```yaml
- uses: github/codeql-action/init@v3
  with:
    queries: ./codeql/UnhandledError.ql
    packs: trailofbits/cpp-queries
```

Note the `.` prefix for repository-relative paths. All queries must be part of a query pack with a `qlpack.yml` file.

### Testing Custom Queries in CI

```yaml
name: Test CodeQL queries

on: [push, pull_request]

jobs:
  codeql-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - id: init
        uses: github/codeql-action/init@v3
      - uses: actions/cache@v4
        with:
          path: ~/.codeql
          key: ${{ runner.os }}-${{ runner.arch }}-${{ steps.init.outputs.codeql-version }}
      - name: Run tests
        run: |
          ${{ steps.init.outputs.codeql-path }} test run ./path/to/query/tests/
```

This workflow caches query extraction and compilation for faster subsequent runs.

## Common Mistakes

| Mistake | Why It's Wrong | Correct Approach |
|---------|----------------|------------------|
| Not building project before creating database | CodeQL won't have complete information | Run `make clean` or equivalent, then build with CodeQL |
| Excluding third-party libraries from database | Prevents interprocedural analysis through library code | Include libraries, filter results by location |
| Using relative imports in query packs | Causes resolution issues | Use absolute imports from standard libraries |
| Not adding query metadata | SARIF output lacks severity, description | Always add metadata comment with required fields |
| Forgetting workspace file | CLI won't find query packs | Create `codeql-workspace.yml` in root directory |

## Limitations

- **Licensing:** Closed-source repositories require GitHub Enterprise or Advanced Security license
- **Build requirement:** Compiled languages must be buildable; no build = incomplete database
- **Performance:** Complex interprocedural queries can take a long time on large codebases
- **Language support:** Limited to CodeQL-supported languages and frameworks
- **Learning curve:** Steep learning curve for writing custom queries; documentation is scant
- **Single-language databases:** Each database is for one language; multi-language projects need multiple databases

## Related Skills

| Skill | When to Use Together |
|-------|---------------------|
| **semgrep** | Use Semgrep first for quick pattern-based analysis, then CodeQL for deeper interprocedural analysis |
| **sarif-parsing** | For processing CodeQL SARIF output in custom CI/CD pipelines |

## Resources

### Trail of Bits Blog Posts on CodeQL

- [Look out! Divergent representations are everywhere!](https://blog.trailofbits.com/2022/11/10/divergent-representations-variable-overflows-c-compiler/)
- [Finding unhandled errors using CodeQL](https://blog.trailofbits.com/2022/01/11/finding-unhandled-errors-using-codeql/)
- [Detecting iterator invalidation with CodeQL](https://blog.trailofbits.com/2020/10/09/detecting-iterator-invalidation-with-codeql/)

### Learning Resources

- [CodeQL zero to hero part 1: The fundamentals of static analysis for vulnerability research](https://github.blog/2023-03-31-codeql-zero-to-hero-part-1-the-fundamentals-of-static-analysis-for-vulnerability-research/)
- [QL language tutorials](https://codeql.github.com/docs/writing-codeql-queries/ql-tutorials/)
- [GitHub Security Lab CodeQL CTFs](https://securitylab.github.com/ctf/)

### Writing Custom CodeQL Queries

- [Practical introduction to CodeQL](https://jorgectf.github.io/blog/post/practical-codeql-introduction/)
- [Sharing security expertise through CodeQL packs (Part I)](https://github.blog/2022-04-19-sharing-security-expertise-through-codeql-packs-part-i/)

### Video Resources

- [Trail of Bits: Introduction to CodeQL - Examples, Tools and CI Integration](https://www.youtube.com/watch?v=rQRlnUQPXDw)
- [Finding Security Vulnerabilities in C/C++ with CodeQL](https://www.youtube.com/watch?v=eAjecQrfv3o)
- [Finding Security Vulnerabilities in JavaScript with CodeQL](https://www.youtube.com/watch?v=pYzfGaLTqC0)
- [Finding Security Vulnerabilities in Java with CodeQL](https://www.youtube.com/watch?v=nvCd0Ee4FgE)

### Using CodeQL for Vulnerability Discovery

- [Clang checkers and CodeQL queries for detecting untrusted pointer derefs and tainted loop conditions](https://www.zerodayinitiative.com/blog/2022/2/22/clang-checkers-and-codeql-queries-for-detecting-untrusted-pointer-derefs-and-tainted-loop-conditions)
- [Heap exploitation with CodeQL](https://github.com/google/security-research/blob/master/analysis/kernel/heap-exploitation/README.md)
- [Interesting kernel objects dashboard](https://lookerstudio.google.com/reporting/68b02863-4f5c-4d85-b3c1-992af89c855c/page/n92nD)

### CodeQL in CI/CD

- [Blue-teaming for Exiv2: adding custom CodeQL queries to code scanning](https://github.blog/2021-11-16-adding-custom-codeql-queries-code-scanning/)
- [Best practices on rolling out code scanning at enterprise scale](https://github.blog/2022-09-28-best-practices-on-rolling-out-code-scanning-at-enterprise-scale/)
- [Fine tuning CodeQL scans using query filters](https://colinsalmcorner.com/fine-tuning-codeql-scans/)

# constant-time-testing

# Constant-Time Testing

Timing attacks exploit variations in execution time to extract secret information from cryptographic implementations. Unlike cryptanalysis that targets theoretical weaknesses, timing attacks leverage implementation flaws - and they can affect any cryptographic code.

## Background

Timing attacks were introduced by [Kocher](https://paulkocher.com/doc/TimingAttacks.pdf) in 1996. Since then, researchers have demonstrated practical attacks on RSA ([Schindler](https://link.springer.com/content/pdf/10.1007/3-540-44499-8_8.pdf)), OpenSSL ([Brumley and Boneh](https://crypto.stanford.edu/~dabo/papers/ssl-timing.pdf)), AES implementations, and even post-quantum algorithms like [Kyber](https://eprint.iacr.org/2024/1049.pdf).

### Key Concepts

| Concept | Description |
|---------|-------------|
| Constant-time | Code path and memory accesses independent of secret data |
| Timing leakage | Observable execution time differences correlated with secrets |
| Side channel | Information extracted from implementation rather than algorithm |
| Microarchitecture | CPU-level timing differences (cache, division, shifts) |

### Why This Matters

Timing vulnerabilities can:
- **Expose private keys** - Extract secret exponents in RSA/ECDH
- **Enable remote attacks** - Network-observable timing differences
- **Bypass cryptographic security** - Undermine theoretical guarantees
- **Persist silently** - Often undetected without specialized analysis

Two prerequisites enable exploitation:
1. **Access to oracle** - Sufficient queries to the vulnerable implementation
2. **Timing dependency** - Correlation between execution time and secret data

### Common Constant-Time Violation Patterns

Four patterns account for most timing vulnerabilities:

```c
// 1. Conditional jumps - most severe timing differences
if(secret == 1) { ... }
while(secret > 0) { ... }

// 2. Array access - cache-timing attacks
lookup_table[secret];

// 3. Integer division (processor dependent)
data = secret / m;

// 4. Shift operation (processor dependent)
data = a << secret;
```

**Conditional jumps** cause different code paths, leading to vast timing differences.

**Array access** dependent on secrets enables cache-timing attacks, as shown in [AES cache-timing research](https://cr.yp.to/antiforgery/cachetiming-20050414.pdf).

**Integer division and shift operations** leak secrets on certain CPU architectures and compiler configurations.

When patterns cannot be avoided, employ [masking techniques](https://link.springer.com/chapter/10.1007/978-3-642-38348-9_9) to remove correlation between timing and secrets.

### Example: Modular Exponentiation Timing Attacks

Modular exponentiation (used in RSA and Diffie-Hellman) is susceptible to timing attacks. RSA decryption computes:

$$ct^{d} \mod{N}$$

where $d$ is the secret exponent. The *exponentiation by squaring* optimization reduces multiplications to $\log{d}$:

$$
\begin{align*}
& \textbf{Input: } \text{base }y,\text{exponent } d=\{d_n,\cdots,d_0\}_2,\text{modulus } N \\
& r = 1 \\
& \textbf{for } i=|n| \text{ downto } 0: \\
& \quad\textbf{if } d_i == 1: \\
& \quad\quad r = r * y \mod{N} \\
& \quad y = y * y \mod{N} \\
& \textbf{return }r
\end{align*}
$$

The code branches on exponent bit $d_i$, violating constant-time principles. When $d_i = 1$, an additional multiplication occurs, increasing execution time and leaking bit information.

Montgomery multiplication (commonly used for modular arithmetic) also leaks timing: when intermediate values exceed modulus $N$, an additional reduction step is required. An attacker constructs inputs $y$ and $y'$ such that:

$$
\begin{align*}
y^2 < y^3 < N \\
y'^2 < N \leq y'^3
\end{align*}
$$

For $y$, both multiplications take time $t_1+t_1$. For $y'$, the second multiplication requires reduction, taking time $t_1+t_2$. This timing difference reveals whether $d_i$ is 0 or 1.

## When to Use

**Apply constant-time analysis when:**
- Auditing cryptographic implementations (primitives, protocols)
- Code handles secret keys, passwords, or sensitive cryptographic material
- Implementing crypto algorithms from scratch
- Reviewing PRs that touch crypto code
- Investigating potential timing vulnerabilities

**Consider alternatives when:**
- Code does not process secret data
- Public algorithms with no secret inputs
- Non-cryptographic timing requirements (performance optimization)

## Quick Reference

| Scenario | Recommended Approach | Skill |
|----------|---------------------|-------|
| Prove absence of leaks | Formal verification | SideTrail, ct-verif, FaCT |
| Detect statistical timing differences | Statistical testing | **dudect** |
| Track secret data flow at runtime | Dynamic analysis | **timecop** |
| Find cache-timing vulnerabilities | Symbolic execution | Binsec, pitchfork |

## Constant-Time Tooling Categories

The cryptographic community has developed four categories of timing analysis tools:

| Category | Approach | Pros | Cons |
|----------|----------|------|------|
| **Formal** | Mathematical proof on model | Guarantees absence of leaks | Complexity, modeling assumptions |
| **Symbolic** | Symbolic execution paths | Concrete counterexamples | Time-intensive path exploration |
| **Dynamic** | Runtime tracing with marked secrets | Granular, flexible | Limited coverage to executed paths |
| **Statistical** | Measure real execution timing | Practical, simple setup | No root cause, noise sensitivity |

### 1. Formal Tools

Formal verification mathematically proves timing properties on an abstraction (model) of code. Tools create a model from source/binary and verify it satisfies specified properties (e.g., variables annotated as secret).

**Popular tools:**
- [SideTrail](https://github.com/aws/s2n-tls/tree/main/tests/sidetrail)
- [ct-verif](https://github.com/imdea-software/verifying-constant-time)
- [FaCT](https://github.com/plsyssec/fact)

**Strengths:** Proof of absence, language-agnostic (LLVM bytecode)
**Weaknesses:** Requires expertise, modeling assumptions may miss real-world issues

### 2. Symbolic Tools

Symbolic execution analyzes how paths and memory accesses depend on symbolic variables (secrets). Provides concrete counterexamples. Focus on cache-timing attacks.

**Popular tools:**
- [Binsec](https://github.com/binsec/binsec)
- [pitchfork](https://github.com/PLSysSec/haybale-pitchfork)

**Strengths:** Concrete counterexamples aid debugging
**Weaknesses:** Path explosion leads to long execution times

### 3. Dynamic Tools

Dynamic analysis marks sensitive memory regions and traces execution to detect timing-dependent operations.

**Popular tools:**
- [Memsan](https://clang.llvm.org/docs/MemorySanitizer.html): [Tutorial](https://crocs-muni.github.io/ct-tools/tutorials/memsan)
- **Timecop** (see below)

**Strengths:** Granular control, targeted analysis
**Weaknesses:** Coverage limited to executed paths

> **Detailed Guidance:** See the **timecop** skill for setup and usage.

### 4. Statistical Tools

Execute code with various inputs, measure elapsed time, and detect inconsistencies. Tests actual implementation including compiler optimizations and architecture.

**Popular tools:**
- **dudect** (see below)
- [tlsfuzzer](https://github.com/tlsfuzzer/tlsfuzzer)

**Strengths:** Simple setup, practical real-world results
**Weaknesses:** No root cause info, noise obscures weak signals

> **Detailed Guidance:** See the **dudect** skill for setup and usage.

## Testing Workflow

```
Phase 1: Static Analysis        Phase 2: Statistical Testing
┌─────────────────┐            ┌─────────────────┐
│ Identify secret │      →     │ Detect timing   │
│ data flow       │            │ differences     │
│ Tool: ct-verif  │            │ Tool: dudect    │
└─────────────────┘            └─────────────────┘
         ↓                              ↓
Phase 4: Root Cause             Phase 3: Dynamic Tracing
┌─────────────────┐            ┌─────────────────┐
│ Pinpoint leak   │      ←     │ Track secret    │
│ location        │            │ propagation     │
│ Tool: Timecop   │            │ Tool: Timecop   │
└─────────────────┘            └─────────────────┘
```

**Recommended approach:**
1. **Start with dudect** - Quick statistical check for timing differences
2. **If leaks found** - Use Timecop to pinpoint root cause
3. **For high-assurance** - Apply formal verification (ct-verif, SideTrail)
4. **Continuous monitoring** - Integrate dudect into CI pipeline

## Tools and Approaches

### Dudect - Statistical Analysis

[Dudect](https://github.com/oreparaz/dudect/) measures execution time for two input classes (fixed vs random) and uses Welch's t-test to detect statistically significant differences.

> **Detailed Guidance:** See the **dudect** skill for complete setup, usage patterns, and CI integration.

#### Quick Start for Constant-Time Analysis

```c
#define DUDECT_IMPLEMENTATION
#include "dudect.h"

uint8_t do_one_computation(uint8_t *data) {
    // Code to measure goes here
}

void prepare_inputs(dudect_config_t *c, uint8_t *input_data, uint8_t *classes) {
    for (size_t i = 0; i < c->number_measurements; i++) {
        classes[i] = randombit();
        uint8_t *input = input_data + (size_t)i * c->chunk_size;
        if (classes[i] == 0) {
            // Fixed input class
        } else {
            // Random input class
        }
    }
}
```

**Key advantages:**
- Simple C header-only integration
- Statistical rigor via Welch's t-test
- Works with compiled binaries (real-world conditions)

**Key limitations:**
- No root cause information when leak detected
- Sensitive to measurement noise
- Cannot guarantee absence of leaks (statistical confidence only)

### Timecop - Dynamic Tracing

[Timecop](https://post-apocalyptic-crypto.org/timecop/) wraps Valgrind to detect runtime operations dependent on secret memory regions.

> **Detailed Guidance:** See the **timecop** skill for installation, examples, and debugging.

#### Quick Start for Constant-Time Analysis

```c
#include "valgrind/memcheck.h"

#define poison(addr, len) VALGRIND_MAKE_MEM_UNDEFINED(addr, len)
#define unpoison(addr, len) VALGRIND_MAKE_MEM_DEFINED(addr, len)

int main() {
    unsigned long long secret_key = 0x12345678;

    // Mark secret as poisoned
    poison(&secret_key, sizeof(secret_key));

    // Any branching or memory access dependent on secret_key
    // will be reported by Valgrind
    crypto_operation(secret_key);

    unpoison(&secret_key, sizeof(secret_key));
}
```

Run with Valgrind:
```bash
valgrind --leak-check=full --track-origins=yes ./binary
```

**Key advantages:**
- Pinpoints exact line of timing leak
- No code instrumentation required
- Tracks secret propagation through execution

**Key limitations:**
- Cannot detect microarchitecture timing differences
- Coverage limited to executed paths
- Performance overhead (runs on synthetic CPU)

## Implementation Guide

### Phase 1: Initial Assessment

**Identify cryptographic code handling secrets:**
- Private keys, exponents, nonces
- Password hashes, authentication tokens
- Encryption/decryption operations

**Quick statistical check:**
1. Write dudect harness for the crypto function
2. Run for 5-10 minutes with `timeout 600 ./ct_test`
3. Monitor t-value: high absolute values indicate leakage

**Tools:** dudect
**Expected time:** 1-2 hours (harness writing + initial run)

### Phase 2: Detailed Analysis

If dudect detects leakage:

**Root cause investigation:**
1. Mark secret variables with Timecop `poison()`
2. Run under Valgrind to identify exact line
3. Review the four common violation patterns
4. Check assembly output for conditional branches

**Tools:** Timecop, compiler output (`objdump -d`)

### Phase 3: Remediation

**Fix the timing leak:**
- Replace conditional branches with constant-time selection (bitwise operations)
- Use constant-time comparison functions
- Replace array lookups with constant-time alternatives or masking
- Verify compiler doesn't optimize away constant-time code

**Re-verify:**
1. Run dudect again for extended period (30+ minutes)
2. Test across different compilers and optimization levels
3. Test on different CPU architectures

### Phase 4: Continuous Monitoring

**Integrate into CI:**
- Add dudect tests to test suite
- Run for fixed duration (5-10 minutes in CI)
- Fail build if leakage detected

See the **dudect** skill for CI integration examples.

## Common Vulnerabilities

| Vulnerability | Description | Detection | Severity |
|---------------|-------------|-----------|----------|
| Secret-dependent branch | `if (secret_bit) { ... }` | dudect, Timecop | CRITICAL |
| Secret-dependent array access | `table[secret_index]` | Timecop, Binsec | HIGH |
| Variable-time division | `result = x / secret` | Timecop | MEDIUM |
| Variable-time shift | `result = x << secret` | Timecop | MEDIUM |
| Montgomery reduction leak | Extra reduction when intermediate > N | dudect | HIGH |

### Secret-Dependent Branch: Deep Dive

**The vulnerability:**
Execution time differs based on whether branch is taken. Common in optimized modular exponentiation (square-and-multiply).

**How to detect with dudect:**
```c
uint8_t do_one_computation(uint8_t *data) {
    uint64_t base = ((uint64_t*)data)[0];
    uint64_t exponent = ((uint64_t*)data)[1]; // Secret!
    return mod_exp(base, exponent, MODULUS);
}

void prepare_inputs(dudect_config_t *c, uint8_t *input_data, uint8_t *classes) {
    for (size_t i = 0; i < c->number_measurements; i++) {
        classes[i] = randombit();
        uint64_t *input = (uint64_t*)(input_data + i * c->chunk_size);
        input[0] = rand(); // Random base
        input[1] = (classes[i] == 0) ? FIXED_EXPONENT : rand(); // Fixed vs random
    }
}
```

**How to detect with Timecop:**
```c
poison(&exponent, sizeof(exponent));
result = mod_exp(base, exponent, modulus);
unpoison(&exponent, sizeof(exponent));
```

Valgrind will report:
```
Conditional jump or move depends on uninitialised value(s)
  at 0x40115D: mod_exp (example.c:14)
```

**Related skill:** **dudect**, **timecop**

## Case Studies

### Case Study: OpenSSL RSA Timing Attack

Brumley and Boneh (2005) extracted RSA private keys from OpenSSL over a network. The vulnerability exploited Montgomery multiplication's variable-time reduction step.

**Attack vector:** Timing differences in modular exponentiation
**Detection approach:** Statistical analysis (precursor to dudect)
**Impact:** Remote key extraction

**Tools used:** Custom timing measurement
**Techniques applied:** Statistical analysis, chosen-ciphertext queries

### Case Study: KyberSlash

Post-quantum algorithm Kyber's reference implementation contained timing vulnerabilities in polynomial operations. Division operations leaked secret coefficients.

**Attack vector:** Secret-dependent division timing
**Detection approach:** Dynamic analysis and statistical testing
**Impact:** Secret key recovery in post-quantum cryptography

**Tools used:** Timing measurement tools
**Techniques applied:** Differential timing analysis

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| Pin dudect to isolated CPU core (`taskset -c 2`) | Reduces OS noise, improves signal detection |
| Test multiple compilers (gcc, clang, MSVC) | Optimizations may introduce or remove leaks |
| Run dudect for extended periods (hours) | Increases statistical confidence |
| Minimize non-crypto code in harness | Reduces noise that masks weak signals |
| Check assembly output (`objdump -d`) | Verify compiler didn't introduce branches |
| Use `-O3 -march=native` in testing | Matches production optimization levels |

### Common Mistakes

| Mistake | Why It's Wrong | Correct Approach |
|---------|----------------|------------------|
| Only testing one input distribution | May miss leaks visible with other patterns | Test fixed-vs-random, fixed-vs-fixed-different, etc. |
| Short dudect runs (< 1 minute) | Insufficient measurements for weak signals | Run 5-10+ minutes, longer for high assurance |
| Ignoring compiler optimization levels | `-O0` may hide leaks present in `-O3` | Test at production optimization level |
| Not testing on target architecture | x86 vs ARM have different timing characteristics | Test on deployment platform |
| Marking too much as secret in Timecop | False positives, unclear results | Mark only true secrets (keys, not public data) |

## Related Skills

### Tool Skills

| Skill | Primary Use in Constant-Time Analysis |
|-------|---------------------------------------|
| **dudect** | Statistical detection of timing differences via Welch's t-test |
| **timecop** | Dynamic tracing to pinpoint exact location of timing leaks |

### Technique Skills

| Skill | When to Apply |
|-------|---------------|
| **coverage-analysis** | Ensure test inputs exercise all code paths in crypto function |
| **ci-integration** | Automate constant-time testing in continuous integration pipeline |

### Related Domain Skills

| Skill | Relationship |
|-------|--------------|
| **crypto-testing** | Constant-time analysis is essential component of cryptographic testing |
| **fuzzing** | Fuzzing crypto code may trigger timing-dependent paths |

## Skill Dependency Map

```
                    ┌─────────────────────────┐
                    │  constant-time-analysis │
                    │     (this skill)        │
                    └───────────┬─────────────┘
                                │
                ┌───────────────┴───────────────┐
                │                               │
                ▼                               ▼
    ┌───────────────────┐           ┌───────────────────┐
    │      dudect       │           │     timecop       │
    │  (statistical)    │           │    (dynamic)      │
    └────────┬──────────┘           └────────┬──────────┘
             │                               │
             └───────────────┬───────────────┘
                             │
                             ▼
              ┌──────────────────────────────┐
              │   Supporting Techniques      │
              │ coverage, CI integration     │
              └──────────────────────────────┘
```

## Resources

### Key External Resources

**[These results must be false: A usability evaluation of constant-time analysis tools](https://www.usenix.org/system/files/sec24fall-prepub-760-fourne.pdf)**
Comprehensive usability study of constant-time analysis tools. Key findings: developers struggle with false positives, need better error messages, and benefit from tool integration. Evaluates FaCT, ct-verif, dudect, and Memsan across multiple cryptographic implementations. Recommends improved tooling UX and better documentation.

**[List of constant-time tools - CROCS](https://crocs-muni.github.io/ct-tools/)**
Curated catalog of constant-time analysis tools with tutorials. Covers formal tools (ct-verif, FaCT), dynamic tools (Memsan, Timecop), symbolic tools (Binsec), and statistical tools (dudect). Includes practical tutorials for setup and usage.

**[Paul Kocher: Timing Attacks on Implementations of Diffie-Hellman, RSA, DSS, and Other Systems](https://paulkocher.com/doc/TimingAttacks.pdf)**
Original 1996 paper introducing timing attacks. Demonstrates attacks on modular exponentiation in RSA and Diffie-Hellman. Essential historical context for understanding timing vulnerabilities.

**[Remote Timing Attacks are Practical (Brumley & Boneh)](https://crypto.stanford.edu/~dabo/papers/ssl-timing.pdf)**
Demonstrates practical remote timing attacks against OpenSSL. Shows network-level timing differences are sufficient to extract RSA keys. Proves timing attacks work in realistic network conditions.

**[Cache-timing attacks on AES](https://cr.yp.to/antiforgery/cachetiming-20050414.pdf)**
Shows AES implementations using lookup tables are vulnerable to cache-timing attacks. Demonstrates practical attacks extracting AES keys via cache timing side channels.

**[KyberSlash: Division Timings Leak Secrets](https://eprint.iacr.org/2024/1049.pdf)**
Recent discovery of timing vulnerabilities in Kyber (NIST post-quantum standard). Shows division operations leak secret coefficients. Highlights that constant-time issues persist even in modern post-quantum cryptography.

### Video Resources

- [Trail of Bits: Constant-Time Programming](https://www.youtube.com/watch?v=vW6wqTzfz5g) - Overview of constant-time programming principles and tools

# coverage-analysis

# Coverage Analysis

Coverage analysis is essential for understanding which parts of your code are exercised during fuzzing. It helps identify fuzzing blockers like magic value checks and tracks the effectiveness of harness improvements over time.

## Overview

Code coverage during fuzzing serves two critical purposes:

1. **Assessing harness effectiveness**: Understand which parts of your application are actually executed by your fuzzing harnesses
2. **Tracking fuzzing progress**: Monitor how coverage changes when updating harnesses, fuzzers, or the system under test (SUT)

Coverage is a proxy for fuzzer capability and performance. While coverage [is not ideal for measuring fuzzer performance](https://arxiv.org/abs/1808.09700) in absolute terms, it reliably indicates whether your harness works effectively in a given setup.

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Coverage instrumentation** | Compiler flags that track which code paths are executed |
| **Corpus coverage** | Coverage achieved by running all test cases in a fuzzing corpus |
| **Magic value checks** | Hard-to-discover conditional checks that block fuzzer progress |
| **Coverage-guided fuzzing** | Fuzzing strategy that prioritizes inputs that discover new code paths |
| **Coverage report** | Visual or textual representation of executed vs. unexecuted code |

## When to Apply

**Apply this technique when:**
- Starting a new fuzzing campaign to establish a baseline
- Fuzzer appears to plateau without finding new paths
- After harness modifications to verify improvements
- When migrating between different fuzzers
- Identifying areas requiring dictionary entries or seed inputs
- Debugging why certain code paths aren't reached

**Skip this technique when:**
- Fuzzing campaign is actively finding crashes
- Coverage infrastructure isn't set up yet
- Working with extremely large codebases where full coverage reports are impractical
- Fuzzer's internal coverage metrics are sufficient for your needs

## Quick Reference

| Task | Command/Pattern |
|------|-----------------|
| LLVM coverage instrumentation (C/C++) | `-fprofile-instr-generate -fcoverage-mapping` |
| GCC coverage instrumentation | `-ftest-coverage -fprofile-arcs` |
| cargo-fuzz coverage (Rust) | `cargo +nightly fuzz coverage <target>` |
| Generate LLVM profile data | `llvm-profdata merge -sparse file.profraw -o file.profdata` |
| LLVM coverage report | `llvm-cov report ./binary -instr-profile=file.profdata` |
| LLVM HTML report | `llvm-cov show ./binary -instr-profile=file.profdata -format=html -output-dir html/` |
| gcovr HTML report | `gcovr --html-details -o coverage.html` |

## Ideal Coverage Workflow

The following workflow represents best practices for integrating coverage analysis into your fuzzing campaigns:

```
[Fuzzing Campaign]
       |
       v
[Generate Corpus]
       |
       v
[Coverage Analysis]
       |
       +---> Coverage Increased? --> Continue fuzzing with larger corpus
       |
       +---> Coverage Decreased? --> Fix harness or investigate SUT changes
       |
       +---> Coverage Plateaued? --> Add dictionary entries or seed inputs
```

**Key principle**: Use the corpus generated *after* each fuzzing campaign to calculate coverage, rather than real-time fuzzer statistics. This approach provides reproducible, comparable measurements across different fuzzing tools.

## Step-by-Step

### Step 1: Build with Coverage Instrumentation

Choose your instrumentation method based on toolchain:

**LLVM/Clang (C/C++):**
```bash
clang++ -fprofile-instr-generate -fcoverage-mapping \
  -O2 -DNO_MAIN \
  main.cc harness.cc execute-rt.cc -o fuzz_exec
```

**GCC (C/C++):**
```bash
g++ -ftest-coverage -fprofile-arcs \
  -O2 -DNO_MAIN \
  main.cc harness.cc execute-rt.cc -o fuzz_exec_gcov
```

**Rust:**
```bash
rustup toolchain install nightly --component llvm-tools-preview
cargo +nightly fuzz coverage fuzz_target_1
```

### Step 2: Create Execution Runtime (C/C++ only)

For C/C++ projects, create a runtime that executes your corpus:

```cpp
// execute-rt.cc
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <stdint.h>

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size);

void load_file_and_test(const char *filename) {
    FILE *file = fopen(filename, "rb");
    if (file == NULL) {
        printf("Failed to open file: %s\n", filename);
        return;
    }

    fseek(file, 0, SEEK_END);
    long filesize = ftell(file);
    rewind(file);

    uint8_t *buffer = (uint8_t*) malloc(filesize);
    if (buffer == NULL) {
        printf("Failed to allocate memory for file: %s\n", filename);
        fclose(file);
        return;
    }

    long read_size = (long) fread(buffer, 1, filesize, file);
    if (read_size != filesize) {
        printf("Failed to read file: %s\n", filename);
        free(buffer);
        fclose(file);
        return;
    }

    LLVMFuzzerTestOneInput(buffer, filesize);

    free(buffer);
    fclose(file);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Usage: %s <directory>\n", argv[0]);
        return 1;
    }

    DIR *dir = opendir(argv[1]);
    if (dir == NULL) {
        printf("Failed to open directory: %s\n", argv[1]);
        return 1;
    }

    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL) {
        if (entry->d_type == DT_REG) {
            char filepath[1024];
            snprintf(filepath, sizeof(filepath), "%s/%s", argv[1], entry->d_name);
            load_file_and_test(filepath);
        }
    }

    closedir(dir);
    return 0;
}
```

### Step 3: Execute on Corpus

**LLVM (C/C++):**
```bash
LLVM_PROFILE_FILE=fuzz.profraw ./fuzz_exec corpus/
```

**GCC (C/C++):**
```bash
./fuzz_exec_gcov corpus/
```

**Rust:**
Coverage data is automatically generated when running `cargo fuzz coverage`.

### Step 4: Process Coverage Data

**LLVM:**
```bash
# Merge raw profile data
llvm-profdata merge -sparse fuzz.profraw -o fuzz.profdata

# Generate text report
llvm-cov report ./fuzz_exec \
  -instr-profile=fuzz.profdata \
  -ignore-filename-regex='harness.cc|execute-rt.cc'

# Generate HTML report
llvm-cov show ./fuzz_exec \
  -instr-profile=fuzz.profdata \
  -ignore-filename-regex='harness.cc|execute-rt.cc' \
  -format=html -output-dir fuzz_html/
```

**GCC with gcovr:**
```bash
# Install gcovr (via pip for latest version)
python3 -m venv venv
source venv/bin/activate
pip3 install gcovr

# Generate report
gcovr --gcov-executable "llvm-cov gcov" \
  --exclude harness.cc --exclude execute-rt.cc \
  --root . --html-details -o coverage.html
```

**Rust:**
```bash
# Install required tools
cargo install cargo-binutils rustfilt

# Create HTML generation script
cat <<'EOF' > ./generate_html
#!/bin/sh
if [ $# -lt 1 ]; then
    echo "Error: Name of fuzz target is required."
    echo "Usage: $0 fuzz_target [sources...]"
    exit 1
fi
FUZZ_TARGET="$1"
shift
SRC_FILTER="$@"
TARGET=$(rustc -vV | sed -n 's|host: ||p')
cargo +nightly cov -- show -Xdemangler=rustfilt \
  "target/$TARGET/coverage/$TARGET/release/$FUZZ_TARGET" \
  -instr-profile="fuzz/coverage/$FUZZ_TARGET/coverage.profdata" \
  -show-line-counts-or-regions -show-instantiations \
  -format=html -o fuzz_html/ $SRC_FILTER
EOF
chmod +x ./generate_html

# Generate HTML report
./generate_html fuzz_target_1 src/lib.rs
```

### Step 5: Analyze Results

Review the coverage report to identify:

- **Uncovered code blocks**: Areas that may need better seed inputs or dictionary entries
- **Magic value checks**: Conditional statements with hardcoded values that block progress
- **Dead code**: Functions that may not be reachable through your harness
- **Coverage changes**: Compare against baseline to track improvements or regressions

## Common Patterns

### Pattern: Identifying Magic Values

**Problem**: Fuzzer cannot discover paths guarded by magic value checks.

**Coverage reveals:**
```cpp
// Coverage shows this block is never executed
if (buf == 0x7F454C46) {  // ELF magic number
    // start parsing buf
}
```

**Solution**: Add magic values to dictionary file:
```
# magic.dict
"\x7F\x45\x4C\x46"
```

### Pattern: Handling Crashing Inputs

**Problem**: Coverage generation fails when corpus contains crashing inputs.

**Before:**
```bash
./fuzz_exec corpus/  # Crashes on bad input, no coverage generated
```

**After:**
```cpp
// Fork before executing to isolate crashes
int main(int argc, char **argv) {
    // ... directory opening code ...

    while ((entry = readdir(dir)) != NULL) {
        if (entry->d_type == DT_REG) {
            pid_t pid = fork();
            if (pid == 0) {
                // Child process - crash won't affect parent
                char filepath[1024];
                snprintf(filepath, sizeof(filepath), "%s/%s", argv[1], entry->d_name);
                load_file_and_test(filepath);
                exit(0);
            } else {
                // Parent waits for child
                waitpid(pid, NULL, 0);
            }
        }
    }
}
```

### Pattern: CMake Integration

**Use Case**: Adding coverage builds to CMake projects.

```cmake
project(FuzzingProject)
cmake_minimum_required(VERSION 3.0)

# Main binary
add_executable(program main.cc)

# Fuzzing binary
add_executable(fuzz main.cc harness.cc)
target_compile_definitions(fuzz PRIVATE NO_MAIN=1)
target_compile_options(fuzz PRIVATE -g -O2 -fsanitize=fuzzer)
target_link_libraries(fuzz -fsanitize=fuzzer)

# Coverage execution binary
add_executable(fuzz_exec main.cc harness.cc execute-rt.cc)
target_compile_definitions(fuzz_exec PRIVATE NO_MAIN)
target_compile_options(fuzz_exec PRIVATE -O2 -fprofile-instr-generate -fcoverage-mapping)
target_link_libraries(fuzz_exec -fprofile-instr-generate)
```

Build:
```bash
cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ .
cmake --build . --target fuzz_exec
```

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| Use LLVM 18+ with `-show-directory-coverage` | Organizes large reports by directory structure instead of flat file list |
| Export to lcov format for better HTML | `llvm-cov export -format=lcov` + `genhtml` provides cleaner per-file reports |
| Compare coverage across campaigns | Store `.profdata` files with timestamps to track progress over time |
| Filter harness code from reports | Use `-ignore-filename-regex` to focus on SUT coverage only |
| Automate coverage in CI/CD | Generate coverage reports automatically after scheduled fuzzing runs |
| Use gcovr 5.1+ for Clang 14+ | Older gcovr versions have compatibility issues with recent LLVM |

### Incremental Coverage Updates

GCC's gcov instrumentation incrementally updates `.gcda` files across multiple runs. This is useful for tracking coverage as you add test cases:

```bash
# First run
./fuzz_exec_gcov corpus_batch_1/
gcovr --html coverage_v1.html

# Second run (adds to existing coverage)
./fuzz_exec_gcov corpus_batch_2/
gcovr --html coverage_v2.html

# Start fresh
gcovr --delete  # Remove .gcda files
./fuzz_exec_gcov corpus/
```

### Handling Large Codebases

For projects with hundreds of source files:

1. **Filter by prefix**: Only generate reports for relevant directories
   ```bash
   llvm-cov show ./fuzz_exec -instr-profile=fuzz.profdata /path/to/src/
   ```

2. **Use directory coverage**: Group by directory to reduce clutter (LLVM 18+)
   ```bash
   llvm-cov show -show-directory-coverage -format=html -output-dir html/
   ```

3. **Generate JSON for programmatic analysis**:
   ```bash
   llvm-cov export -format=lcov > coverage.json
   ```

### Differential Coverage

Compare coverage between two fuzzing campaigns:

```bash
# Campaign 1
LLVM_PROFILE_FILE=campaign1.profraw ./fuzz_exec corpus1/
llvm-profdata merge -sparse campaign1.profraw -o campaign1.profdata

# Campaign 2
LLVM_PROFILE_FILE=campaign2.profraw ./fuzz_exec corpus2/
llvm-profdata merge -sparse campaign2.profraw -o campaign2.profdata

# Compare
llvm-cov show ./fuzz_exec \
  -instr-profile=campaign2.profdata \
  -instr-profile=campaign1.profdata \
  -show-line-counts-or-regions
```

## Anti-Patterns

| Anti-Pattern | Problem | Correct Approach |
|--------------|---------|------------------|
| Using fuzzer-reported coverage for comparisons | Different fuzzers calculate coverage differently, making cross-tool comparison meaningless | Use dedicated coverage tools (llvm-cov, gcovr) for reproducible measurements |
| Generating coverage with optimizations | `-O3` optimizations can eliminate code, making coverage misleading | Use `-O2` or `-O0` for coverage builds |
| Not filtering harness code | Harness coverage inflates numbers and obscures SUT coverage | Use `-ignore-filename-regex` or `--exclude` to filter harness files |
| Mixing LLVM and GCC instrumentation | Incompatible formats cause parsing failures | Stick to one toolchain for coverage builds |
| Ignoring crashing inputs | Crashes prevent coverage generation, hiding real coverage data | Fix crashes first, or use process forking to isolate them |
| Not tracking coverage over time | One-time coverage checks miss regressions and improvements | Store coverage data with timestamps and track trends |

## Tool-Specific Guidance

### libFuzzer

libFuzzer uses LLVM's SanitizerCoverage by default for guiding fuzzing, but you need separate instrumentation for generating reports.

**Build for coverage:**
```bash
clang++ -fprofile-instr-generate -fcoverage-mapping \
  -O2 -DNO_MAIN \
  main.cc harness.cc execute-rt.cc -o fuzz_exec
```

**Execute corpus and generate report:**
```bash
LLVM_PROFILE_FILE=fuzz.profraw ./fuzz_exec corpus/
llvm-profdata merge -sparse fuzz.profraw -o fuzz.profdata
llvm-cov show ./fuzz_exec -instr-profile=fuzz.profdata -format=html -output-dir html/
```

**Integration tips:**
- Don't use `-fsanitize=fuzzer` for coverage builds (it conflicts with profile instrumentation)
- Reuse the same harness function (`LLVMFuzzerTestOneInput`) with a different main function
- Use the `-ignore-filename-regex` flag to exclude harness code from coverage reports
- Consider using llvm-cov's `-show-instantiation` flag for template-heavy C++ code

### AFL++

AFL++ provides its own coverage feedback mechanism, but for detailed reports use standard LLVM/GCC tools.

**Build for coverage with LLVM:**
```bash
clang++ -fprofile-instr-generate -fcoverage-mapping \
  -O2 main.cc harness.cc execute-rt.cc -o fuzz_exec
```

**Build for coverage with GCC:**
```bash
AFL_USE_ASAN=0 afl-gcc -ftest-coverage -fprofile-arcs \
  main.cc harness.cc execute-rt.cc -o fuzz_exec_gcov
```

**Execute and generate report:**
```bash
# LLVM approach
LLVM_PROFILE_FILE=fuzz.profraw ./fuzz_exec afl_output/queue/
llvm-profdata merge -sparse fuzz.profraw -o fuzz.profdata
llvm-cov report ./fuzz_exec -instr-profile=fuzz.profdata

# GCC approach
./fuzz_exec_gcov afl_output/queue/
gcovr --html-details -o coverage.html
```

**Integration tips:**
- Don't use AFL++'s instrumentation (`afl-clang-fast`) for coverage builds
- Use standard compilers with coverage flags instead
- AFL++'s `queue/` directory contains your corpus
- AFL++'s built-in coverage statistics are useful for real-time monitoring but not for detailed analysis

### cargo-fuzz (Rust)

cargo-fuzz provides built-in coverage generation using LLVM tools.

**Install prerequisites:**
```bash
rustup toolchain install nightly --component llvm-tools-preview
cargo install cargo-binutils rustfilt
```

**Generate coverage data:**
```bash
cargo +nightly fuzz coverage fuzz_target_1
```

**Create HTML report script:**
```bash
cat <<'EOF' > ./generate_html
#!/bin/sh
FUZZ_TARGET="$1"
shift
SRC_FILTER="$@"
TARGET=$(rustc -vV | sed -n 's|host: ||p')
cargo +nightly cov -- show -Xdemangler=rustfilt \
  "target/$TARGET/coverage/$TARGET/release/$FUZZ_TARGET" \
  -instr-profile="fuzz/coverage/$FUZZ_TARGET/coverage.profdata" \
  -show-line-counts-or-regions -show-instantiations \
  -format=html -o fuzz_html/ $SRC_FILTER
EOF
chmod +x ./generate_html
```

**Generate report:**
```bash
./generate_html fuzz_target_1 src/lib.rs
```

**Integration tips:**
- Always use the nightly toolchain for coverage
- The `-Xdemangler=rustfilt` flag makes function names readable
- Filter by source files (e.g., `src/lib.rs`) to focus on crate code
- Use `-show-line-counts-or-regions` and `-show-instantiations` for better Rust-specific output
- Corpus is located in `fuzz/corpus/<target>/`

### honggfuzz

honggfuzz works with standard LLVM/GCC coverage instrumentation.

**Build for coverage:**
```bash
# Use standard compiler, not honggfuzz compiler
clang -fprofile-instr-generate -fcoverage-mapping \
  -O2 harness.c execute-rt.c -o fuzz_exec
```

**Execute corpus:**
```bash
LLVM_PROFILE_FILE=fuzz.profraw ./fuzz_exec honggfuzz_workspace/
```

**Integration tips:**
- Don't use `hfuzz-clang` for coverage builds
- honggfuzz corpus is typically in a workspace directory
- Use the same LLVM workflow as libFuzzer

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| `error: no profile data available` | Profile wasn't generated or wrong path | Verify `LLVM_PROFILE_FILE` was set and `.profraw` file exists |
| `Failed to load coverage` | Mismatch between binary and profile data | Rebuild binary with same flags used during execution |
| Coverage reports show 0% | Wrong binary used for report generation | Use the instrumented binary, not the fuzzing binary |
| `no_working_dir_found` error (gcovr) | `.gcda` files in unexpected location | Add `--gcov-ignore-errors=no_working_dir_found` flag |
| Crashes prevent coverage generation | Corpus contains crashing inputs | Filter crashes or use forking approach to isolate failures |
| Coverage decreases after harness change | Harness now skips certain code paths | Review harness logic; may need to support more input formats |
| HTML report is flat file list | Using older LLVM version | Upgrade to LLVM 18+ and use `-show-directory-coverage` |
| `incompatible instrumentation` | Mixing LLVM and GCC coverage | Rebuild everything with same toolchain |

## Related Skills

### Tools That Use This Technique

| Skill | How It Applies |
|-------|----------------|
| **libfuzzer** | Uses SanitizerCoverage for feedback; coverage analysis evaluates harness effectiveness |
| **aflpp** | Uses edge coverage for feedback; detailed analysis requires separate instrumentation |
| **cargo-fuzz** | Built-in `cargo fuzz coverage` command for Rust projects |
| **honggfuzz** | Uses edge coverage; analyze with standard LLVM/GCC tools |

### Related Techniques

| Skill | Relationship |
|-------|--------------|
| **fuzz-harness-writing** | Coverage reveals which code paths harness reaches; guides harness improvements |
| **fuzzing-dictionaries** | Coverage identifies magic value checks that need dictionary entries |
| **corpus-management** | Coverage analysis helps curate corpora by identifying redundant test cases |
| **sanitizers** | Coverage helps verify sanitizer-instrumented code is actually executed |

## Resources

### Key External Resources

**[LLVM Source-Based Code Coverage](https://clang.llvm.org/docs/SourceBasedCodeCoverage.html)**
Comprehensive guide to LLVM's profile instrumentation, including advanced features like branch coverage, region coverage, and integration with existing build systems. Covers compiler flags, runtime behavior, and profile data formats.

**[llvm-cov Command Guide](https://llvm.org/docs/CommandGuide/llvm-cov.html)**
Detailed CLI reference for llvm-cov commands including `show`, `report`, and `export`. Documents all filtering options, output formats, and integration with llvm-profdata.

**[gcovr Documentation](https://gcovr.com/)**
Complete guide to gcovr tool for generating coverage reports from gcov data. Covers HTML themes, filtering options, multi-directory projects, and CI/CD integration patterns.

**[SanitizerCoverage Documentation](https://clang.llvm.org/docs/SanitizerCoverage.html)**
Low-level documentation for LLVM's SanitizerCoverage instrumentation. Explains inline 8-bit counters, PC tables, and how fuzzers use coverage feedback for guidance.

**[On the Evaluation of Fuzzer Performance](https://arxiv.org/abs/1808.09700)**
Research paper examining limitations of coverage as a fuzzing performance metric. Argues for more nuanced evaluation methods beyond simple code coverage percentages.

### Video Resources

Not applicable - coverage analysis is primarily a tooling and workflow topic best learned through documentation and hands-on practice.

# fuzzing-dictionary

# Fuzzing Dictionary

A fuzzing dictionary provides domain-specific tokens to guide the fuzzer toward interesting inputs. Instead of purely random mutations, the fuzzer incorporates known keywords, magic numbers, protocol commands, and format-specific strings that are more likely to reach deeper code paths in parsers, protocol handlers, and file format processors.

## Overview

Dictionaries are text files containing quoted strings that represent meaningful tokens for your target. They help fuzzers bypass early validation checks and explore code paths that would be difficult to reach through blind mutation alone.

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Dictionary Entry** | A quoted string (e.g., `"keyword"`) or key-value pair (e.g., `kw="value"`) |
| **Hex Escapes** | Byte sequences like `"\xF7\xF8"` for non-printable characters |
| **Token Injection** | Fuzzer inserts dictionary entries into generated inputs |
| **Cross-Fuzzer Format** | Dictionary files work with libFuzzer, AFL++, and cargo-fuzz |

## When to Apply

**Apply this technique when:**
- Fuzzing parsers (JSON, XML, config files)
- Fuzzing protocol implementations (HTTP, DNS, custom protocols)
- Fuzzing file format handlers (PNG, PDF, media codecs)
- Coverage plateaus early without reaching deeper logic
- Target code checks for specific keywords or magic values

**Skip this technique when:**
- Fuzzing pure algorithms without format expectations
- Target has no keyword-based parsing
- Corpus already achieves high coverage

## Quick Reference

| Task | Command/Pattern |
|------|-----------------|
| Use with libFuzzer | `./fuzz -dict=./dictionary.dict ...` |
| Use with AFL++ | `afl-fuzz -x ./dictionary.dict ...` |
| Use with cargo-fuzz | `cargo fuzz run fuzz_target -- -dict=./dictionary.dict` |
| Extract from header | `grep -o '".*"' header.h > header.dict` |
| Generate from binary | `strings ./binary \| sed 's/^/"&/; s/$/&"/' > strings.dict` |

## Step-by-Step

### Step 1: Create Dictionary File

Create a text file with quoted strings on each line. Use comments (`#`) for documentation.

**Example dictionary format:**

```conf
# Lines starting with '#' and empty lines are ignored.

# Adds "blah" (w/o quotes) to the dictionary.
kw1="blah"
# Use \\ for backslash and \" for quotes.
kw2="\"ac\\dc\""
# Use \xAB for hex values
kw3="\xF7\xF8"
# the name of the keyword followed by '=' may be omitted:
"foo\x0Abar"
```

### Step 2: Generate Dictionary Content

Choose a generation method based on what's available:

**From LLM:** Prompt ChatGPT or Claude with:
```text
A dictionary can be used to guide the fuzzer. Write me a dictionary file for fuzzing a <PNG parser>. Each line should be a quoted string or key-value pair like kw="value". Include magic bytes, chunk types, and common header values. Use hex escapes like "\xF7\xF8" for binary values.
```

**From header files:**
```bash
grep -o '".*"' header.h > header.dict
```

**From man pages (for CLI tools):**
```bash
man curl | grep -oP '^\s*(--|-)\K\S+' | sed 's/[,.]$//' | sed 's/^/"&/; s/$/&"/' | sort -u > man.dict
```

**From binary strings:**
```bash
strings ./binary | sed 's/^/"&/; s/$/&"/' > strings.dict
```

### Step 3: Pass Dictionary to Fuzzer

Use the appropriate flag for your fuzzer (see Quick Reference above).

## Common Patterns

### Pattern: Protocol Keywords

**Use Case:** Fuzzing HTTP or custom protocol handlers

**Dictionary content:**
```conf
# HTTP methods
"GET"
"POST"
"PUT"
"DELETE"
"HEAD"

# Headers
"Content-Type"
"Authorization"
"Host"

# Protocol markers
"HTTP/1.1"
"HTTP/2.0"
```

### Pattern: Magic Bytes and File Format Headers

**Use Case:** Fuzzing image parsers, media decoders, archive handlers

**Dictionary content:**
```conf
# PNG magic bytes and chunks
png_magic="\x89PNG\r\n\x1a\n"
ihdr="IHDR"
plte="PLTE"
idat="IDAT"
iend="IEND"

# JPEG markers
jpeg_soi="\xFF\xD8"
jpeg_eoi="\xFF\xD9"
```

### Pattern: Configuration File Keywords

**Use Case:** Fuzzing config file parsers (YAML, TOML, INI)

**Dictionary content:**
```conf
# Common config keywords
"true"
"false"
"null"
"version"
"enabled"
"disabled"

# Section headers
"[general]"
"[network]"
"[security]"
```

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| Combine multiple generation methods | LLM-generated keywords + strings from binary covers broad surface |
| Include boundary values | `"0"`, `"-1"`, `"2147483647"` trigger edge cases |
| Add format delimiters | `:`, `=`, `{`, `}` help fuzzer construct valid structures |
| Keep dictionaries focused | 50-200 entries perform better than thousands |
| Test dictionary effectiveness | Run with and without dict, compare coverage |

### Auto-Generated Dictionaries (AFL++)

When using `afl-clang-lto` compiler, AFL++ automatically extracts dictionary entries from string comparisons in the binary. This happens at compile time via the AUTODICTIONARY feature.

**Enable auto-dictionary:**
```bash
export AFL_LLVM_DICT2FILE=auto.dict
afl-clang-lto++ target.cc -o target
# Dictionary saved to auto.dict
afl-fuzz -x auto.dict -i in -o out -- ./target
```

### Combining Multiple Dictionaries

Some fuzzers support multiple dictionary files:

```bash
# AFL++ with multiple dictionaries
afl-fuzz -x keywords.dict -x formats.dict -i in -o out -- ./target
```

## Anti-Patterns

| Anti-Pattern | Problem | Correct Approach |
|--------------|---------|------------------|
| Including full sentences | Fuzzer needs atomic tokens, not prose | Break into individual keywords |
| Duplicating entries | Wastes mutation budget | Use `sort -u` to deduplicate |
| Over-sized dictionaries | Slows fuzzer, dilutes useful tokens | Keep focused: 50-200 most relevant entries |
| Missing hex escapes | Non-printable bytes become mangled | Use `\xXX` for binary values |
| No comments | Hard to maintain and audit | Document sections with `#` comments |

## Tool-Specific Guidance

### libFuzzer

```bash
clang++ -fsanitize=fuzzer,address harness.cc -o fuzz
./fuzz -dict=./dictionary.dict corpus/
```

**Integration tips:**
- Dictionary tokens are inserted/replaced during mutations
- Combine with `-max_len` to control input size
- Use `-print_final_stats=1` to see dictionary effectiveness metrics
- Dictionary entries longer than `-max_len` are ignored

### AFL++

```bash
afl-fuzz -x ./dictionary.dict -i input/ -o output/ -- ./target @@
```

**Integration tips:**
- AFL++ supports multiple `-x` flags for multiple dictionaries
- Use `AFL_LLVM_DICT2FILE` with `afl-clang-lto` for auto-generated dictionaries
- Dictionary effectiveness shown in fuzzer stats UI
- Tokens are used during deterministic and havoc stages

### cargo-fuzz (Rust)

```bash
cargo fuzz run fuzz_target -- -dict=./dictionary.dict
```

**Integration tips:**
- cargo-fuzz uses libFuzzer backend, so all libFuzzer dict flags work
- Place dictionary file in `fuzz/` directory alongside harness
- Reference from harness directory: `cargo fuzz run target -- -dict=../dictionary.dict`

### go-fuzz (Go)

go-fuzz does not have built-in dictionary support, but you can manually seed the corpus with dictionary entries:

```bash
# Convert dictionary to corpus files
grep -o '".*"' dict.txt | while read line; do
    echo -n "$line" | base64 > corpus/$(echo "$line" | md5sum | cut -d' ' -f1)
done

go-fuzz -bin=./target-fuzz.zip -workdir=.
```

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Dictionary file not loaded | Wrong path or format error | Check fuzzer output for dict parsing errors; verify file format |
| No coverage improvement | Dictionary tokens not relevant | Analyze target code for actual keywords; try different generation method |
| Syntax errors in dict file | Unescaped quotes or invalid escapes | Use `\\` for backslash, `\"` for quotes; validate with test run |
| Fuzzer ignores long entries | Entries exceed `-max_len` | Keep entries under max input length, or increase `-max_len` |
| Too many entries slow fuzzer | Dictionary too large | Prune to 50-200 most relevant entries |

## Related Skills

### Tools That Use This Technique

| Skill | How It Applies |
|-------|----------------|
| **libfuzzer** | Native dictionary support via `-dict=` flag |
| **aflpp** | Native dictionary support via `-x` flag; auto-generation with AUTODICTIONARIES |
| **cargo-fuzz** | Uses libFuzzer backend, inherits `-dict=` support |

### Related Techniques

| Skill | Relationship |
|-------|--------------|
| **fuzzing-corpus** | Dictionaries complement corpus: corpus provides structure, dictionary provides keywords |
| **coverage-analysis** | Use coverage data to validate dictionary effectiveness |
| **harness-writing** | Harness structure determines which dictionary tokens are useful |

## Resources

### Key External Resources

**[AFL++ Dictionaries](https://github.com/AFLplusplus/AFLplusplus/tree/stable/dictionaries)**
Pre-built dictionaries for common formats (HTML, XML, JSON, SQL, etc.). Good starting point for format-specific fuzzing.

**[libFuzzer Dictionary Documentation](https://llvm.org/docs/LibFuzzer.html#dictionaries)**
Official libFuzzer documentation on dictionary format and usage. Explains token insertion strategy and performance implications.

### Additional Examples

**[OSS-Fuzz Dictionaries](https://github.com/google/oss-fuzz/tree/master/projects)**
Real-world dictionaries from Google's continuous fuzzing service. Search project directories for `*.dict` files to see production examples.

# fuzzing-obstacles

# Overcoming Fuzzing Obstacles

Codebases often contain anti-fuzzing patterns that prevent effective coverage. Checksums, global state (like time-seeded PRNGs), and validation checks can block the fuzzer from exploring deeper code paths. This technique shows how to patch your System Under Test (SUT) to bypass these obstacles during fuzzing while preserving production behavior.

## Overview

Many real-world programs were not designed with fuzzing in mind. They may:
- Verify checksums or cryptographic hashes before processing input
- Rely on global state (e.g., system time, environment variables)
- Use non-deterministic random number generators
- Perform complex validation that makes it difficult for the fuzzer to generate valid inputs

These patterns make fuzzing difficult because:
1. **Checksums:** The fuzzer must guess correct hash values (astronomically unlikely)
2. **Global state:** Same input produces different behavior across runs (breaks determinism)
3. **Complex validation:** The fuzzer spends effort hitting validation failures instead of exploring deeper code

The solution is conditional compilation: modify code behavior during fuzzing builds while keeping production code unchanged.

### Key Concepts

| Concept | Description |
|---------|-------------|
| SUT Patching | Modifying System Under Test to be fuzzing-friendly |
| Conditional Compilation | Code that behaves differently based on compile-time flags |
| Fuzzing Build Mode | Special build configuration that enables fuzzing-specific patches |
| False Positives | Crashes found during fuzzing that cannot occur in production |
| Determinism | Same input always produces same behavior (critical for fuzzing) |

## When to Apply

**Apply this technique when:**
- The fuzzer gets stuck at checksum or hash verification
- Coverage reports show large blocks of unreachable code behind validation
- Code uses time-based seeds or other non-deterministic global state
- Complex validation makes it nearly impossible to generate valid inputs
- You see the fuzzer repeatedly hitting the same validation failures

**Skip this technique when:**
- The obstacle can be overcome with a good seed corpus or dictionary
- The validation is simple enough for the fuzzer to learn (e.g., magic bytes)
- You're doing grammar-based or structure-aware fuzzing that handles validation
- Skipping the check would introduce too many false positives
- The code is already fuzzing-friendly

## Quick Reference

| Task | C/C++ | Rust |
|------|-------|------|
| Check if fuzzing build | `#ifdef FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION` | `cfg!(fuzzing)` |
| Skip check during fuzzing | `#ifndef FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION return -1; #endif` | `if !cfg!(fuzzing) { return Err(...) }` |
| Common obstacles | Checksums, PRNGs, time-based logic | Checksums, PRNGs, time-based logic |
| Supported fuzzers | libFuzzer, AFL++, LibAFL, honggfuzz | cargo-fuzz, libFuzzer |

## Step-by-Step

### Step 1: Identify the Obstacle

Run the fuzzer and analyze coverage to find code that's unreachable. Common patterns:

1. Look for checksum/hash verification before deeper processing
2. Check for calls to `rand()`, `time()`, or `srand()` with system seeds
3. Find validation functions that reject most inputs
4. Identify global state initialization that differs across runs

**Tools to help:**
- Coverage reports (see coverage-analysis technique)
- Profiling with `-fprofile-instr-generate`
- Manual code inspection of entry points

### Step 2: Add Conditional Compilation

Modify the obstacle to bypass it during fuzzing builds.

**C/C++ Example:**

```c++
// Before: Hard obstacle
if (checksum != expected_hash) {
    return -1;  // Fuzzer never gets past here
}

// After: Conditional bypass
if (checksum != expected_hash) {
#ifndef FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION
    return -1;  // Only enforced in production
#endif
}
// Fuzzer can now explore code beyond this check
```

**Rust Example:**

```rust
// Before: Hard obstacle
if checksum != expected_hash {
    return Err(MyError::Hash);  // Fuzzer never gets past here
}

// After: Conditional bypass
if checksum != expected_hash {
    if !cfg!(fuzzing) {
        return Err(MyError::Hash);  // Only enforced in production
    }
}
// Fuzzer can now explore code beyond this check
```

### Step 3: Verify Coverage Improvement

After patching:

1. Rebuild with fuzzing instrumentation
2. Run the fuzzer for a short time
3. Compare coverage to the unpatched version
4. Confirm new code paths are being explored

### Step 4: Assess False Positive Risk

Consider whether skipping the check introduces impossible program states:

- Does code after the check assume validated properties?
- Could skipping validation cause crashes that cannot occur in production?
- Is there implicit state dependency?

If false positives are likely, consider a more targeted patch (see Common Patterns below).

## Common Patterns

### Pattern: Bypass Checksum Validation

**Use Case:** Hash/checksum blocks all fuzzer progress

**Before:**
```c++
uint32_t computed = hash_function(data, size);
if (computed != expected_checksum) {
    return ERROR_INVALID_HASH;
}
process_data(data, size);
```

**After:**
```c++
uint32_t computed = hash_function(data, size);
if (computed != expected_checksum) {
#ifndef FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION
    return ERROR_INVALID_HASH;
#endif
}
process_data(data, size);
```

**False positive risk:** LOW - If data processing doesn't depend on checksum correctness

### Pattern: Deterministic PRNG Seeding

**Use Case:** Non-deterministic random state prevents reproducibility

**Before:**
```c++
void initialize() {
    srand(time(NULL));  // Different seed each run
}
```

**After:**
```c++
void initialize() {
#ifdef FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION
    srand(12345);  // Fixed seed for fuzzing
#else
    srand(time(NULL));
#endif
}
```

**False positive risk:** LOW - Fuzzer can explore all code paths with fixed seed

### Pattern: Careful Validation Skip

**Use Case:** Validation must be skipped but downstream code has assumptions

**Before (Dangerous):**
```c++
#ifndef FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION
if (!validate_config(&config)) {
    return -1;  // Ensures config.x != 0
}
#endif

int32_t result = 100 / config.x;  // CRASH: Division by zero in fuzzing!
```

**After (Safe):**
```c++
#ifndef FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION
if (!validate_config(&config)) {
    return -1;
}
#else
// During fuzzing, use safe defaults for failed validation
if (!validate_config(&config)) {
    config.x = 1;  // Prevent division by zero
    config.y = 1;
}
#endif

int32_t result = 100 / config.x;  // Safe in both builds
```

**False positive risk:** MITIGATED - Provides safe defaults instead of skipping

### Pattern: Bypass Complex Format Validation

**Use Case:** Multi-step validation makes valid input generation nearly impossible

**Rust Example:**

```rust
// Before: Multiple validation stages
pub fn parse_message(data: &[u8]) -> Result<Message, Error> {
    validate_magic_bytes(data)?;
    validate_structure(data)?;
    validate_checksums(data)?;
    validate_crypto_signature(data)?;

    deserialize_message(data)
}

// After: Skip expensive validation during fuzzing
pub fn parse_message(data: &[u8]) -> Result<Message, Error> {
    validate_magic_bytes(data)?;  // Keep cheap checks

    if !cfg!(fuzzing) {
        validate_structure(data)?;
        validate_checksums(data)?;
        validate_crypto_signature(data)?;
    }

    deserialize_message(data)
}
```

**False positive risk:** MEDIUM - Deserialization must handle malformed data gracefully

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| Keep cheap validation | Magic bytes and size checks guide fuzzer without much cost |
| Use fixed seeds for PRNGs | Makes behavior deterministic while exploring all code paths |
| Patch incrementally | Skip one obstacle at a time and measure coverage impact |
| Add defensive defaults | When skipping validation, provide safe fallback values |
| Document all patches | Future maintainers need to understand fuzzing vs. production differences |

### Real-World Examples

**OpenSSL:** Uses `FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION` to modify cryptographic algorithm behavior. For example, in [crypto/cmp/cmp_vfy.c](https://github.com/openssl/openssl/blob/afb19f07aecc84998eeea56c4d65f5e0499abb5a/crypto/cmp/cmp_vfy.c#L665-L678), certain signature checks are relaxed during fuzzing to allow deeper exploration of certificate validation logic.

**ogg crate (Rust):** Uses `cfg!(fuzzing)` to [skip checksum verification](https://github.com/RustAudio/ogg/blob/5ee8316e6e907c24f6d7ec4b3a0ed6a6ce854cc1/src/reading.rs#L298-L300) during fuzzing. This allows the fuzzer to explore audio processing code without spending effort guessing correct checksums.

### Measuring Patch Effectiveness

After applying patches, quantify the improvement:

1. **Line coverage:** Use `llvm-cov` or `cargo-cov` to see new reachable lines
2. **Basic block coverage:** More fine-grained than line coverage
3. **Function coverage:** How many more functions are now reachable?
4. **Corpus size:** Does the fuzzer generate more diverse inputs?

Effective patches typically increase coverage by 10-50% or more.

### Combining with Other Techniques

Obstacle patching works well with:
- **Corpus seeding:** Provide valid inputs that get past initial parsing
- **Dictionaries:** Help fuzzer learn magic bytes and common values
- **Structure-aware fuzzing:** Use protobuf or grammar definitions for complex formats
- **Harness improvements:** Better harness can sometimes avoid obstacles entirely

## Anti-Patterns

| Anti-Pattern | Problem | Correct Approach |
|--------------|---------|------------------|
| Skip all validation wholesale | Creates false positives and unstable fuzzing | Skip only specific obstacles that block coverage |
| No risk assessment | False positives waste time and hide real bugs | Analyze downstream code for assumptions |
| Forget to document patches | Future maintainers don't understand the differences | Add comments explaining why patch is safe |
| Patch without measuring | Don't know if it helped | Compare coverage before and after |
| Over-patching | Makes fuzzing build diverge too much from production | Minimize differences between builds |

## Tool-Specific Guidance

### libFuzzer

libFuzzer automatically defines `FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION` during compilation.

```bash
# C++ compilation
clang++ -g -fsanitize=fuzzer,address -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION \
    harness.cc target.cc -o fuzzer

# The macro is usually defined automatically by -fsanitize=fuzzer
clang++ -g -fsanitize=fuzzer,address harness.cc target.cc -o fuzzer
```

**Integration tips:**
- The macro is defined automatically; manual definition is usually unnecessary
- Use `#ifdef` to check for the macro
- Combine with sanitizers to detect bugs in newly reachable code

### AFL++

AFL++ also defines `FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION` when using its compiler wrappers.

```bash
# Compilation with AFL++ wrappers
afl-clang-fast++ -g -fsanitize=address target.cc harness.cc -o fuzzer

# The macro is defined automatically by afl-clang-fast
```

**Integration tips:**
- Use `afl-clang-fast` or `afl-clang-lto` for automatic macro definition
- Persistent mode harnesses benefit most from obstacle patching
- Consider using `AFL_LLVM_LAF_ALL` for additional input-to-state transformations

### honggfuzz

honggfuzz also supports the macro when building targets.

```bash
# Compilation
hfuzz-clang++ -g -fsanitize=address target.cc harness.cc -o fuzzer
```

**Integration tips:**
- Use `hfuzz-clang` or `hfuzz-clang++` wrappers
- The macro is available for conditional compilation
- Combine with honggfuzz's feedback-driven fuzzing

### cargo-fuzz (Rust)

cargo-fuzz automatically sets the `fuzzing` cfg option during builds.

```bash
# Build fuzz target (cfg!(fuzzing) is automatically set)
cargo fuzz build fuzz_target_name

# Run fuzz target
cargo fuzz run fuzz_target_name
```

**Integration tips:**
- Use `cfg!(fuzzing)` for runtime checks in production builds
- Use `#[cfg(fuzzing)]` for compile-time conditional compilation
- The fuzzing cfg is only set during `cargo fuzz` builds, not regular `cargo build`
- Can be manually enabled with `RUSTFLAGS="--cfg fuzzing"` for testing

### LibAFL

LibAFL supports the C/C++ macro for targets written in C/C++.

```bash
# Compilation
clang++ -g -fsanitize=address -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION \
    target.cc -c -o target.o
```

**Integration tips:**
- Define the macro manually or use compiler flags
- Works the same as with libFuzzer
- Useful when building custom LibAFL-based fuzzers

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Coverage doesn't improve after patching | Wrong obstacle identified | Profile execution to find actual bottleneck |
| Many false positive crashes | Downstream code has assumptions | Add defensive defaults or partial validation |
| Code compiles differently | Macro not defined in all build configs | Verify macro in all source files and dependencies |
| Fuzzer finds bugs in patched code | Patch introduced invalid states | Review patch for state invariants; consider safer approach |
| Can't reproduce production bugs | Build differences too large | Minimize patches; keep validation for state-critical checks |

## Related Skills

### Tools That Use This Technique

| Skill | How It Applies |
|-------|----------------|
| **libfuzzer** | Defines `FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION` automatically |
| **aflpp** | Supports the macro via compiler wrappers |
| **honggfuzz** | Uses the macro for conditional compilation |
| **cargo-fuzz** | Sets `cfg!(fuzzing)` for Rust conditional compilation |

### Related Techniques

| Skill | Relationship |
|-------|--------------|
| **fuzz-harness-writing** | Better harnesses may avoid obstacles; patching enables deeper exploration |
| **coverage-analysis** | Use coverage to identify obstacles and measure patch effectiveness |
| **corpus-seeding** | Seed corpus can help overcome obstacles without patching |
| **dictionary-generation** | Dictionaries help with magic bytes but not checksums or complex validation |

## Resources

### Key External Resources

**[OpenSSL Fuzzing Documentation](https://github.com/openssl/openssl/tree/master/fuzz)**
OpenSSL's fuzzing infrastructure demonstrates large-scale use of `FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION`. The project uses this macro to modify cryptographic validation, certificate parsing, and other security-critical code paths to enable deeper fuzzing while maintaining production correctness.

**[LibFuzzer Documentation on Flags](https://llvm.org/docs/LibFuzzer.html)**
Official LLVM documentation for libFuzzer, including how the fuzzer defines compiler macros and how to use them effectively. Covers integration with sanitizers and coverage instrumentation.

**[Rust cfg Attribute Reference](https://doc.rust-lang.org/reference/conditional-compilation.html)**
Complete reference for Rust conditional compilation, including `cfg!(fuzzing)` and `cfg!(test)`. Explains compile-time vs. runtime conditional compilation and best practices.

# harness-writing

# Writing Fuzzing Harnesses

A fuzzing harness is the entrypoint function that receives random data from the fuzzer and routes it to your system under test (SUT). The quality of your harness directly determines which code paths get exercised and whether critical bugs are found. A poorly written harness can miss entire subsystems or produce non-reproducible crashes.

## Overview

The harness is the bridge between the fuzzer's random byte generation and your application's API. It must parse raw bytes into meaningful inputs, call target functions, and handle edge cases gracefully. The most important part of any fuzzing setup is the harness—if written poorly, critical parts of your application may not be covered.

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Harness** | Function that receives fuzzer input and calls target code under test |
| **SUT** | System Under Test—the code being fuzzed |
| **Entry point** | Function signature required by the fuzzer (e.g., `LLVMFuzzerTestOneInput`) |
| **FuzzedDataProvider** | Helper class for structured extraction of typed data from raw bytes |
| **Determinism** | Property that ensures same input always produces same behavior |
| **Interleaved fuzzing** | Single harness that exercises multiple operations based on input |

## When to Apply

**Apply this technique when:**
- Creating a new fuzz target for the first time
- Fuzz campaign has low code coverage or isn't finding bugs
- Crashes found during fuzzing are not reproducible
- Target API requires complex or structured inputs
- Multiple related functions should be tested together

**Skip this technique when:**
- Using existing well-tested harnesses from your project
- Tool provides automatic harness generation that meets your needs
- Target already has comprehensive fuzzing infrastructure

## Quick Reference

| Task | Pattern |
|------|---------|
| Minimal C++ harness | `extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size)` |
| Minimal Rust harness | `fuzz_target!(|data: &[u8]| { ... })` |
| Size validation | `if (size < MIN_SIZE) return 0;` |
| Cast to integers | `uint32_t val = *(uint32_t*)(data);` |
| Use FuzzedDataProvider | `FuzzedDataProvider fuzzed_data(data, size);` |
| Extract typed data (C++) | `auto val = fuzzed_data.ConsumeIntegral<uint32_t>();` |
| Extract string (C++) | `auto str = fuzzed_data.ConsumeBytesWithTerminator<char>(32, 0xFF);` |

## Step-by-Step

### Step 1: Identify Entry Points

Find functions in your codebase that:
- Accept external input (parsers, validators, protocol handlers)
- Parse complex data formats (JSON, XML, binary protocols)
- Perform security-critical operations (authentication, cryptography)
- Have high cyclomatic complexity or many branches

Good targets are typically:
- Protocol parsers
- File format parsers
- Serialization/deserialization functions
- Input validation routines

### Step 2: Write Minimal Harness

Start with the simplest possible harness that calls your target function:

**C/C++:**
```cpp
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    target_function(data, size);
    return 0;
}
```

**Rust:**
```rust
#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    target_function(data);
});
```

### Step 3: Add Input Validation

Reject inputs that are too small or too large to be meaningful:

```cpp
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    // Ensure minimum size for meaningful input
    if (size < MIN_INPUT_SIZE || size > MAX_INPUT_SIZE) {
        return 0;
    }
    target_function(data, size);
    return 0;
}
```

**Rationale:** The fuzzer generates random inputs of all sizes. Your harness must handle empty, tiny, huge, or malformed inputs without causing unexpected issues in the harness itself (crashes in the SUT are fine—that's what we're looking for).

### Step 4: Structure the Input

For APIs that require typed data (integers, strings, etc.), use casting or helpers like `FuzzedDataProvider`:

**Simple casting:**
```cpp
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (size != 2 * sizeof(uint32_t)) {
        return 0;
    }

    uint32_t numerator = *(uint32_t*)(data);
    uint32_t denominator = *(uint32_t*)(data + sizeof(uint32_t));

    divide(numerator, denominator);
    return 0;
}
```

**Using FuzzedDataProvider:**
```cpp
#include "FuzzedDataProvider.h"

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    FuzzedDataProvider fuzzed_data(data, size);

    size_t allocation_size = fuzzed_data.ConsumeIntegral<size_t>();
    std::vector<char> str1 = fuzzed_data.ConsumeBytesWithTerminator<char>(32, 0xFF);
    std::vector<char> str2 = fuzzed_data.ConsumeBytesWithTerminator<char>(32, 0xFF);

    concat(&str1[0], str1.size(), &str2[0], str2.size(), allocation_size);
    return 0;
}
```

### Step 5: Test and Iterate

Run the fuzzer and monitor:
- Code coverage (are all interesting paths reached?)
- Executions per second (is it fast enough?)
- Crash reproducibility (can you reproduce crashes with saved inputs?)

Iterate on the harness to improve these metrics.

## Common Patterns

### Pattern: Beyond Byte Arrays—Casting to Integers

**Use Case:** When target expects primitive types like integers or floats

**Implementation:**
```cpp
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    // Ensure exactly 2 4-byte numbers
    if (size != 2 * sizeof(uint32_t)) {
        return 0;
    }

    // Split input into two integers
    uint32_t numerator = *(uint32_t*)(data);
    uint32_t denominator = *(uint32_t*)(data + sizeof(uint32_t));

    divide(numerator, denominator);
    return 0;
}
```

**Rust equivalent:**
```rust
fuzz_target!(|data: &[u8]| {
    if data.len() != 2 * std::mem::size_of::<i32>() {
        return;
    }

    let numerator = i32::from_ne_bytes([data[0], data[1], data[2], data[3]]);
    let denominator = i32::from_ne_bytes([data[4], data[5], data[6], data[7]]);

    divide(numerator, denominator);
});
```

**Why it works:** Any 8-byte input is valid. The fuzzer learns that inputs must be exactly 8 bytes, and every bit flip produces a new, potentially interesting input.

### Pattern: FuzzedDataProvider for Complex Inputs

**Use Case:** When target requires multiple strings, integers, or variable-length data

**Implementation:**
```cpp
#include "FuzzedDataProvider.h"

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    FuzzedDataProvider fuzzed_data(data, size);

    // Extract different types of data
    size_t allocation_size = fuzzed_data.ConsumeIntegral<size_t>();

    // Consume variable-length strings with terminator
    std::vector<char> str1 = fuzzed_data.ConsumeBytesWithTerminator<char>(32, 0xFF);
    std::vector<char> str2 = fuzzed_data.ConsumeBytesWithTerminator<char>(32, 0xFF);

    char* result = concat(&str1[0], str1.size(), &str2[0], str2.size(), allocation_size);
    if (result != NULL) {
        free(result);
    }

    return 0;
}
```

**Why it helps:** `FuzzedDataProvider` handles the complexity of extracting structured data from a byte stream. It's particularly useful for APIs that need multiple parameters of different types.

### Pattern: Interleaved Fuzzing

**Use Case:** When multiple related operations should be tested in a single harness

**Implementation:**
```cpp
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (size < 1 + 2 * sizeof(int32_t)) {
        return 0;
    }

    // First byte selects operation
    uint8_t mode = data[0];

    // Next bytes are operands
    int32_t numbers[2];
    memcpy(numbers, data + 1, 2 * sizeof(int32_t));

    int32_t result = 0;
    switch (mode % 4) {
        case 0:
            result = add(numbers[0], numbers[1]);
            break;
        case 1:
            result = subtract(numbers[0], numbers[1]);
            break;
        case 2:
            result = multiply(numbers[0], numbers[1]);
            break;
        case 3:
            result = divide(numbers[0], numbers[1]);
            break;
    }

    // Prevent compiler from optimizing away the calls
    printf("%d", result);
    return 0;
}
```

**Advantages:**
- Faster to write one harness than multiple individual harnesses
- Single shared corpus means interesting inputs for one operation may be interesting for others
- Can discover bugs in interactions between operations

**When to use:**
- Operations share similar input types
- Operations are logically related (e.g., arithmetic operations, CRUD operations)
- Single corpus makes sense across all operations

### Pattern: Structure-Aware Fuzzing with Arbitrary (Rust)

**Use Case:** When fuzzing Rust code that uses custom structs

**Implementation:**
```rust
use arbitrary::Arbitrary;

#[derive(Debug, Arbitrary)]
pub struct Name {
    data: String
}

impl Name {
    pub fn check_buf(&self) {
        let data = self.data.as_bytes();
        if data.len() > 0 && data[0] == b'a' {
            if data.len() > 1 && data[1] == b'b' {
                if data.len() > 2 && data[2] == b'c' {
                    process::abort();
                }
            }
        }
    }
}
```

**Harness with arbitrary:**
```rust
#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: your_project::Name| {
    data.check_buf();
});
```

**Add to Cargo.toml:**
```toml
[dependencies]
arbitrary = { version = "1", features = ["derive"] }
```

**Why it helps:** The `arbitrary` crate automatically handles deserialization of raw bytes into your Rust structs, reducing boilerplate and ensuring valid struct construction.

**Limitation:** The arbitrary crate doesn't offer reverse serialization, so you can't manually construct byte arrays that map to specific structs. This works best when starting from an empty corpus (fine for libFuzzer, problematic for AFL++).

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| **Start with parsers** | High bug density, clear entry points, easy to harness |
| **Mock I/O operations** | Prevents hangs from blocking I/O, enables determinism |
| **Use FuzzedDataProvider** | Simplifies extraction of structured data from raw bytes |
| **Reset global state** | Ensures each iteration is independent and reproducible |
| **Free resources in harness** | Prevents memory exhaustion during long campaigns |
| **Avoid logging in harness** | Logging is slow—fuzzing needs 100s-1000s exec/sec |
| **Test harness manually first** | Run harness with known inputs before starting campaign |
| **Check coverage early** | Ensure harness reaches expected code paths |

### Structure-Aware Fuzzing with Protocol Buffers

For highly structured input formats, consider using Protocol Buffers as an intermediate format with custom mutators:

```cpp
// Define your input format in .proto file
// Use libprotobuf-mutator to generate valid mutations
// This ensures fuzzer mutates message contents, not the protobuf encoding itself
```

This approach is more setup but prevents the fuzzer from wasting time on unparseable inputs. See [structure-aware fuzzing documentation](https://github.com/google/fuzzing/blob/master/docs/structure-aware-fuzzing.md) for details.

### Handling Non-Determinism

**Problem:** Random values or timing dependencies cause non-reproducible crashes.

**Solutions:**
- Replace `rand()` with deterministic PRNG seeded from fuzzer input:
  ```cpp
  uint32_t seed = fuzzed_data.ConsumeIntegral<uint32_t>();
  srand(seed);
  ```
- Mock system calls that return time, PIDs, or random data
- Avoid reading from `/dev/random` or `/dev/urandom`

### Resetting Global State

If your SUT uses global state (singletons, static variables), reset it between iterations:

```cpp
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    // Reset global state before each iteration
    global_reset();

    target_function(data, size);

    // Clean up resources
    global_cleanup();
    return 0;
}
```

**Rationale:** Global state can cause crashes after N iterations rather than on a specific input, making bugs non-reproducible.

## Practical Harness Rules

Follow these rules to ensure effective fuzzing harnesses:

| Rule | Rationale |
|------|-----------|
| **Handle all input sizes** | Fuzzer generates empty, tiny, huge inputs—harness must handle gracefully |
| **Never call `exit()`** | Calling `exit()` stops the fuzzer process. Use `abort()` in SUT if needed |
| **Join all threads** | Each iteration must run to completion before next iteration starts |
| **Be fast** | Aim for 100s-1000s executions/sec. Avoid logging, high complexity, excess memory |
| **Maintain determinism** | Same input must always produce same behavior for reproducibility |
| **Avoid global state** | Global state reduces reproducibility—reset between iterations if unavoidable |
| **Use narrow targets** | Don't fuzz PNG and TCP in same harness—different formats need separate targets |
| **Free resources** | Prevent memory leaks that cause resource exhaustion during long campaigns |

**Note:** These guidelines apply not just to harness code, but to the entire SUT. If the SUT violates these rules, consider patching it (see the fuzzing obstacles technique).

## Anti-Patterns

| Anti-Pattern | Problem | Correct Approach |
|--------------|---------|------------------|
| **Global state without reset** | Non-deterministic crashes | Reset all globals at start of harness |
| **Blocking I/O or network calls** | Hangs fuzzer, wastes time | Mock I/O, use in-memory buffers |
| **Memory leaks in harness** | Resource exhaustion kills campaign | Free all allocations before returning |
| **Calling `exit()` in SUT** | Stops entire fuzzing process | Use `abort()` or return error codes |
| **Heavy logging in harness** | Reduces exec/sec by orders of magnitude | Disable logging during fuzzing |
| **Too many operations per iteration** | Slows down fuzzer | Keep iterations fast and focused |
| **Mixing unrelated input formats** | Corpus entries not useful across formats | Separate harnesses for different formats |
| **Not validating input size** | Harness crashes on edge cases | Check `size` before accessing `data` |

## Tool-Specific Guidance

### libFuzzer

**Harness signature:**
```cpp
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    // Your code here
    return 0;  // Non-zero return is reserved for future use
}
```

**Compilation:**
```bash
clang++ -fsanitize=fuzzer,address -g harness.cc -o fuzz_target
```

**Integration tips:**
- Use `FuzzedDataProvider.h` for structured input extraction
- Compile with `-fsanitize=fuzzer` to link the fuzzing runtime
- Add sanitizers (`-fsanitize=address,undefined`) to detect more bugs
- Use `-g` for better stack traces when crashes occur
- libFuzzer can start with empty corpus—no seed inputs required

**Running:**
```bash
./fuzz_target corpus_dir/
```

**Resources:**
- [FuzzedDataProvider header](https://github.com/llvm/llvm-project/blob/main/compiler-rt/include/fuzzer/FuzzedDataProvider.h)
- [libFuzzer documentation](https://llvm.org/docs/LibFuzzer.html)

### AFL++

AFL++ supports multiple harness styles. For best performance, use persistent mode:

**Persistent mode harness:**
```cpp
#include <unistd.h>

int main(int argc, char **argv) {
    #ifdef __AFL_HAVE_MANUAL_CONTROL
        __AFL_INIT();
    #endif

    unsigned char buf[MAX_SIZE];

    while (__AFL_LOOP(10000)) {
        // Read input from stdin
        ssize_t len = read(0, buf, sizeof(buf));
        if (len <= 0) break;

        // Call target function
        target_function(buf, len);
    }

    return 0;
}
```

**Compilation:**
```bash
afl-clang-fast++ -g harness.cc -o fuzz_target
```

**Integration tips:**
- Use persistent mode (`__AFL_LOOP`) for 10-100x speedup
- Consider deferred initialization (`__AFL_INIT()`) to skip setup overhead
- AFL++ requires at least one seed input in the corpus directory
- Use `AFL_USE_ASAN=1` or `AFL_USE_UBSAN=1` for sanitizer builds

**Running:**
```bash
afl-fuzz -i seeds/ -o findings/ -- ./fuzz_target
```

### cargo-fuzz (Rust)

**Harness signature:**
```rust
#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    // Your code here
});
```

**With structured input (arbitrary crate):**
```rust
#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: YourStruct| {
    data.check();
});
```

**Creating harness:**
```bash
cargo fuzz init
cargo fuzz add my_target
```

**Integration tips:**
- Use `arbitrary` crate for automatic struct deserialization
- cargo-fuzz wraps libFuzzer, so all libFuzzer features work
- Compile with sanitizers automatically via cargo-fuzz
- Harnesses go in `fuzz/fuzz_targets/` directory

**Running:**
```bash
cargo +nightly fuzz run my_target
```

**Resources:**
- [cargo-fuzz documentation](https://rust-fuzz.github.io/book/cargo-fuzz.html)
- [arbitrary crate](https://github.com/rust-fuzz/arbitrary)

### go-fuzz

**Harness signature:**
```go
// +build gofuzz

package mypackage

func Fuzz(data []byte) int {
    // Call target function
    target(data)

    // Return codes:
    // -1 if input is invalid
    //  0 if input is valid but not interesting
    //  1 if input is interesting (e.g., added new coverage)
    return 0
}
```

**Building:**
```bash
go-fuzz-build
```

**Integration tips:**
- Return 1 for inputs that add coverage (optional—fuzzer can detect automatically)
- Return -1 for invalid inputs to deprioritize similar mutations
- go-fuzz handles persistence automatically

**Running:**
```bash
go-fuzz -bin=./mypackage-fuzz.zip -workdir=fuzz
```

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| **Low executions/sec** | Harness is too slow (logging, I/O, complexity) | Profile harness, remove bottlenecks, mock I/O |
| **No crashes found** | Coverage not reaching buggy code | Check coverage, improve harness to reach more paths |
| **Non-reproducible crashes** | Non-determinism or global state | Remove randomness, reset globals between iterations |
| **Fuzzer exits immediately** | Harness calls `exit()` | Replace `exit()` with `abort()` or return error |
| **Out of memory errors** | Memory leaks in harness or SUT | Free allocations, use leak sanitizer to find leaks |
| **Crashes on empty input** | Harness doesn't validate size | Add `if (size < MIN_SIZE) return 0;` |
| **Corpus not growing** | Inputs too constrained or format too strict | Use FuzzedDataProvider or structure-aware fuzzing |

## Related Skills

### Tools That Use This Technique

| Skill | How It Applies |
|-------|----------------|
| **libfuzzer** | Uses `LLVMFuzzerTestOneInput` harness signature with FuzzedDataProvider |
| **aflpp** | Supports persistent mode harnesses with `__AFL_LOOP` for performance |
| **cargo-fuzz** | Uses Rust-specific `fuzz_target!` macro with arbitrary crate integration |
| **atheris** | Python harness takes bytes, calls Python functions |
| **ossfuzz** | Requires harnesses in specific directory structure for cloud fuzzing |

### Related Techniques

| Skill | Relationship |
|-------|--------------|
| **coverage-analysis** | Measure harness effectiveness—are you reaching target code? |
| **address-sanitizer** | Detects bugs found by harness (buffer overflows, use-after-free) |
| **fuzzing-dictionary** | Provide tokens to help fuzzer pass format checks in harness |
| **fuzzing-obstacles** | Patch SUT when it violates harness rules (exit, non-determinism) |

## Resources

### Key External Resources

**[Split Inputs in libFuzzer - Google Fuzzing Docs](https://github.com/google/fuzzing/blob/master/docs/split-inputs.md)**
Explains techniques for handling multiple input parameters in a single fuzzing harness, including use of magic separators and FuzzedDataProvider.

**[Structure-Aware Fuzzing with Protocol Buffers](https://github.com/google/fuzzing/blob/master/docs/structure-aware-fuzzing.md)**
Advanced technique using protobuf as intermediate format with custom mutators to ensure fuzzer mutates message contents rather than format encoding.

**[libFuzzer Documentation](https://llvm.org/docs/LibFuzzer.html)**
Official LLVM documentation covering harness requirements, best practices, and advanced features.

**[cargo-fuzz Book](https://rust-fuzz.github.io/book/cargo-fuzz.html)**
Comprehensive guide to writing Rust fuzzing harnesses with cargo-fuzz and the arbitrary crate.

### Video Resources

- [Effective File Format Fuzzing](https://www.youtube.com/watch?v=qTTwqFRD1H8) - Conference talk on writing harnesses for file format parsers
- [Modern Fuzzing of C/C++ Projects](https://www.youtube.com/watch?v=x0FQkAPokfE) - Tutorial covering harness design patterns

# libafl

# LibAFL

LibAFL is a modular fuzzing library that implements features from AFL-based fuzzers like AFL++. Unlike traditional fuzzers, LibAFL provides all functionality in a modular and customizable way as a Rust library. It can be used as a drop-in replacement for libFuzzer or as a library to build custom fuzzers from scratch.

## When to Use

| Fuzzer | Best For | Complexity |
|--------|----------|------------|
| libFuzzer | Quick setup, single-threaded | Low |
| AFL++ | Multi-core, general purpose | Medium |
| LibAFL | Custom fuzzers, advanced features, research | High |

**Choose LibAFL when:**
- You need custom mutation strategies or feedback mechanisms
- Standard fuzzers don't support your target architecture
- You want to implement novel fuzzing techniques
- You need fine-grained control over fuzzing components
- You're conducting fuzzing research

## Quick Start

LibAFL can be used as a drop-in replacement for libFuzzer with minimal setup:

```c++
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    // Call your code with fuzzer-provided data
    my_function(data, size);
    return 0;
}
```

Build LibAFL's libFuzzer compatibility layer:
```bash
git clone https://github.com/AFLplusplus/LibAFL
cd LibAFL/libafl_libfuzzer_runtime
./build.sh
```

Compile and run:
```bash
clang++ -DNO_MAIN -g -O2 -fsanitize=fuzzer-no-link libFuzzer.a harness.cc main.cc -o fuzz
./fuzz corpus/
```

## Installation

### Prerequisites

- Clang/LLVM 15-18
- Rust (via rustup)
- Additional system dependencies

### Linux/macOS

Install Clang:
```bash
apt install clang
```

Or install a specific version via apt.llvm.org:
```bash
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 15
```

Configure environment for Rust:
```bash
export RUSTFLAGS="-C linker=/usr/bin/clang-15"
export CC="clang-15"
export CXX="clang++-15"
```

Install Rust:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Install additional dependencies:
```bash
apt install libssl-dev pkg-config
```

For libFuzzer compatibility mode, install nightly Rust:
```bash
rustup toolchain install nightly --component llvm-tools
```

### Verification

Build LibAFL to verify installation:
```bash
cd LibAFL/libafl_libfuzzer_runtime
./build.sh
# Should produce libFuzzer.a
```

## Writing a Harness

LibAFL harnesses follow the same pattern as libFuzzer when using drop-in replacement mode:

```c++
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    // Your fuzzing target code here
    return 0;
}
```

When building custom fuzzers with LibAFL as a Rust library, harness logic is integrated directly into the fuzzer. See the "Writing a Custom Fuzzer" section below for the full pattern.

> **See Also:** For detailed harness writing techniques, see the **harness-writing** technique skill.

## Usage Modes

LibAFL supports two primary usage modes:

### 1. libFuzzer Drop-in Replacement

Use LibAFL as a replacement for libFuzzer with existing harnesses.

**Compilation:**
```bash
clang++ -DNO_MAIN -g -O2 -fsanitize=fuzzer-no-link libFuzzer.a harness.cc main.cc -o fuzz
```

**Running:**
```bash
./fuzz corpus/
```

**Recommended for long campaigns:**
```bash
./fuzz -fork=1 -ignore_crashes=1 corpus/
```

### 2. Custom Fuzzer as Rust Library

Build a fully customized fuzzer using LibAFL components.

**Create project:**
```bash
cargo init --lib my_fuzzer
cd my_fuzzer
cargo add libafl@0.13 libafl_targets@0.13 libafl_bolts@0.13 libafl_cc@0.13 \
  --features "libafl_targets@0.13/libfuzzer,libafl_targets@0.13/sancov_pcguard_hitcounts"
```

**Configure Cargo.toml:**
```toml
[lib]
crate-type = ["staticlib"]
```

## Writing a Custom Fuzzer

> **See Also:** For detailed harness writing techniques, patterns for handling complex inputs,
> and advanced strategies, see the **fuzz-harness-writing** technique skill.

### Fuzzer Components

A LibAFL fuzzer consists of modular components:

1. **Observers** - Collect execution feedback (coverage, timing)
2. **Feedback** - Determine if inputs are interesting
3. **Objective** - Define fuzzing goals (crashes, timeouts)
4. **State** - Maintain corpus and metadata
5. **Mutators** - Generate new inputs
6. **Scheduler** - Select which inputs to mutate
7. **Executor** - Run the target with inputs

### Basic Fuzzer Structure

```rust
use libafl::prelude::*;
use libafl_bolts::prelude::*;
use libafl_targets::{libfuzzer_test_one_input, std_edges_map_observer};

#[no_mangle]
pub extern "C" fn libafl_main() {
    let mut run_client = |state: Option<_>, mut restarting_mgr, _core_id| {
        // 1. Setup observers
        let edges_observer = HitcountsMapObserver::new(
            unsafe { std_edges_map_observer("edges") }
        ).track_indices();
        let time_observer = TimeObserver::new("time");

        // 2. Define feedback
        let mut feedback = feedback_or!(
            MaxMapFeedback::new(&edges_observer),
            TimeFeedback::new(&time_observer)
        );

        // 3. Define objective
        let mut objective = feedback_or_fast!(
            CrashFeedback::new(),
            TimeoutFeedback::new()
        );

        // 4. Create or restore state
        let mut state = state.unwrap_or_else(|| {
            StdState::new(
                StdRand::new(),
                InMemoryCorpus::new(),
                OnDiskCorpus::new(&output_dir).unwrap(),
                &mut feedback,
                &mut objective,
            ).unwrap()
        });

        // 5. Setup mutator
        let mutator = StdScheduledMutator::new(havoc_mutations());
        let mut stages = tuple_list!(StdMutationalStage::new(mutator));

        // 6. Setup scheduler
        let scheduler = IndexesLenTimeMinimizerScheduler::new(
            &edges_observer,
            QueueScheduler::new()
        );

        // 7. Create fuzzer
        let mut fuzzer = StdFuzzer::new(scheduler, feedback, objective);

        // 8. Define harness
        let mut harness = |input: &BytesInput| {
            let buf = input.target_bytes().as_slice();
            libfuzzer_test_one_input(buf);
            ExitKind::Ok
        };

        // 9. Setup executor
        let mut executor = InProcessExecutor::with_timeout(
            &mut harness,
            tuple_list!(edges_observer, time_observer),
            &mut fuzzer,
            &mut state,
            &mut restarting_mgr,
            timeout,
        )?;

        // 10. Load initial inputs
        if state.must_load_initial_inputs() {
            state.load_initial_inputs(
                &mut fuzzer,
                &mut executor,
                &mut restarting_mgr,
                &input_dir
            )?;
        }

        // 11. Start fuzzing
        fuzzer.fuzz_loop(&mut stages, &mut executor, &mut state, &mut restarting_mgr)?;
        Ok(())
    };

    // Launch fuzzer
    Launcher::builder()
        .run_client(&mut run_client)
        .cores(&cores)
        .build()
        .launch()
        .unwrap();
}
```

## Compilation

### Verbose Mode

Manually specify all instrumentation flags:

```bash
clang++-15 -DNO_MAIN -g -O2 \
  -fsanitize-coverage=trace-pc-guard \
  -fsanitize=address \
  -Wl,--whole-archive target/release/libmy_fuzzer.a -Wl,--no-whole-archive \
  main.cc harness.cc -o fuzz
```

### Compiler Wrapper (Recommended)

Create a LibAFL compiler wrapper to handle instrumentation automatically.

**Create `src/bin/libafl_cc.rs`:**
```rust
use libafl_cc::{ClangWrapper, CompilerWrapper, Configuration, ToolWrapper};

pub fn main() {
    let args: Vec<String> = env::args().collect();
    let mut cc = ClangWrapper::new();
    cc.cpp(is_cpp)
      .parse_args(&args)
      .link_staticlib(&dir, "my_fuzzer")
      .add_args(&Configuration::GenerateCoverageMap.to_flags().unwrap())
      .add_args(&Configuration::AddressSanitizer.to_flags().unwrap())
      .run()
      .unwrap();
}
```

**Compile and use:**
```bash
cargo build --release
target/release/libafl_cxx -DNO_MAIN -g -O2 main.cc harness.cc -o fuzz
```

> **See Also:** For detailed sanitizer configuration, common issues, and advanced flags,
> see the **address-sanitizer** and **undefined-behavior-sanitizer** technique skills.

## Running Campaigns

### Basic Run

```bash
./fuzz --cores 0 --input corpus/
```

### Multi-Core Fuzzing

```bash
./fuzz --cores 0,8-15 --input corpus/
```

This runs 9 clients: one on core 0, and 8 on cores 8-15.

### With Options

```bash
./fuzz --cores 0-7 --input corpus/ --output crashes/ --timeout 1000
```

### Text User Interface (TUI)

Enable graphical statistics view:

```bash
./fuzz -tui=1 corpus/
```

### Interpreting Output

| Output | Meaning |
|--------|---------|
| `corpus: N` | Number of interesting test cases found |
| `objectives: N` | Number of crashes/timeouts found |
| `executions: N` | Total number of target invocations |
| `exec/sec: N` | Current execution throughput |
| `edges: X%` | Code coverage percentage |
| `clients: N` | Number of parallel fuzzing processes |

The fuzzer emits two main event types:
- **UserStats** - Regular heartbeat with current statistics
- **Testcase** - New interesting input discovered

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| Use `-fork=1 -ignore_crashes=1` | Continue fuzzing after first crash |
| Use `InMemoryOnDiskCorpus` | Persist corpus across restarts |
| Enable TUI with `-tui=1` | Better visualization of progress |
| Use specific LLVM version | Avoid compatibility issues |
| Set `RUSTFLAGS` correctly | Prevent linking errors |

### Crash Deduplication

Avoid storing duplicate crashes from the same bug:

**Add backtrace observer:**
```rust
let backtrace_observer = BacktraceObserver::owned(
    "BacktraceObserver",
    libafl::observers::HarnessType::InProcess
);
```

**Update executor:**
```rust
let mut executor = InProcessExecutor::with_timeout(
    &mut harness,
    tuple_list!(edges_observer, time_observer, backtrace_observer),
    &mut fuzzer,
    &mut state,
    &mut restarting_mgr,
    timeout,
)?;
```

**Update objective with hash feedback:**
```rust
let mut objective = feedback_and!(
    feedback_or_fast!(CrashFeedback::new(), TimeoutFeedback::new()),
    NewHashFeedback::new(&backtrace_observer)
);
```

This ensures only crashes with unique backtraces are saved.

### Dictionary Fuzzing

Use dictionaries to guide fuzzing toward specific tokens:

**Add tokens from file:**
```rust
let mut tokens = Tokens::new();
if let Some(tokenfile) = &tokenfile {
    tokens.add_from_file(tokenfile)?;
}
state.add_metadata(tokens);
```

**Update mutator:**
```rust
let mutator = StdScheduledMutator::new(
    havoc_mutations().merge(tokens_mutations())
);
```

**Hard-coded tokens example (PNG):**
```rust
state.add_metadata(Tokens::from([
    vec![137, 80, 78, 71, 13, 10, 26, 10], // PNG header
    "IHDR".as_bytes().to_vec(),
    "IDAT".as_bytes().to_vec(),
    "PLTE".as_bytes().to_vec(),
    "IEND".as_bytes().to_vec(),
]));
```

> **See Also:** For detailed dictionary creation strategies and format-specific dictionaries,
> see the **fuzzing-dictionaries** technique skill.

### Auto Tokens

Automatically extract magic values and checksums from the program:

**Enable in compiler wrapper:**
```rust
cc.add_pass(LLVMPasses::AutoTokens)
```

**Load auto tokens in fuzzer:**
```rust
tokens += libafl_targets::autotokens()?;
```

**Verify tokens section:**
```bash
echo "p (uint8_t *)__token_start" | gdb fuzz
```

### Performance Tuning

| Setting | Impact |
|---------|--------|
| Multi-core fuzzing | Linear speedup with cores |
| `InMemoryCorpus` | Faster but non-persistent |
| `InMemoryOnDiskCorpus` | Balanced speed and persistence |
| Sanitizers | 2-5x slowdown, essential for bugs |
| Optimization level `-O2` | Balance between speed and coverage |

### Debugging Fuzzer

Run fuzzer in single-process mode for easier debugging:

```rust
// Replace launcher with direct call
run_client(None, SimpleEventManager::new(monitor), 0).unwrap();

// Comment out:
// Launcher::builder()
//     .run_client(&mut run_client)
//     ...
//     .launch()
```

Then debug with GDB:
```bash
gdb --args ./fuzz --cores 0 --input corpus/
```

## Real-World Examples

### Example: libpng

Fuzzing libpng using LibAFL:

**1. Get source code:**
```bash
curl -L -O https://downloads.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.xz
tar xf libpng-1.6.37.tar.xz
cd libpng-1.6.37/
apt install zlib1g-dev
```

**2. Set compiler wrapper:**
```bash
export FUZZER_CARGO_DIR="/path/to/libafl/project"
export CC=$FUZZER_CARGO_DIR/target/release/libafl_cc
export CXX=$FUZZER_CARGO_DIR/target/release/libafl_cxx
```

**3. Build static library:**
```bash
./configure --enable-shared=no
make
```

**4. Get harness:**
```bash
curl -O https://raw.githubusercontent.com/glennrp/libpng/f8e5fa92b0e37ab597616f554bee254157998227/contrib/oss-fuzz/libpng_read_fuzzer.cc
```

**5. Link fuzzer:**
```bash
$CXX libpng_read_fuzzer.cc .libs/libpng16.a -lz -o fuzz
```

**6. Prepare seeds:**
```bash
mkdir seeds/
curl -o seeds/input.png https://raw.githubusercontent.com/glennrp/libpng/acfd50ae0ba3198ad734e5d4dec2b05341e50924/contrib/pngsuite/iftp1n3p08.png
```

**7. Get dictionary (optional):**
```bash
curl -O https://raw.githubusercontent.com/glennrp/libpng/2fff013a6935967960a5ae626fc21432807933dd/contrib/oss-fuzz/png.dict
```

**8. Start fuzzing:**
```bash
./fuzz --input seeds/ --cores 0 -x png.dict
```

### Example: CMake Project

Integrate LibAFL with CMake build system:

**CMakeLists.txt:**
```cmake
project(BuggyProgram)
cmake_minimum_required(VERSION 3.0)

add_executable(buggy_program main.cc)

add_executable(fuzz main.cc harness.cc)
target_compile_definitions(fuzz PRIVATE NO_MAIN=1)
target_compile_options(fuzz PRIVATE -g -O2)
```

**Build non-instrumented binary:**
```bash
cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ .
cmake --build . --target buggy_program
```

**Build fuzzer:**
```bash
export FUZZER_CARGO_DIR="/path/to/libafl/project"
cmake -DCMAKE_C_COMPILER=$FUZZER_CARGO_DIR/target/release/libafl_cc \
      -DCMAKE_CXX_COMPILER=$FUZZER_CARGO_DIR/target/release/libafl_cxx .
cmake --build . --target fuzz
```

**Run fuzzing:**
```bash
./fuzz --input seeds/ --cores 0
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| No coverage increases | Instrumentation failed | Verify compiler wrapper used, check for `-fsanitize-coverage` |
| Fuzzer won't start | Empty corpus with no interesting inputs | Provide seed inputs that trigger code paths |
| Linker errors with `libafl_main` | Runtime not linked | Use `-Wl,--whole-archive` or `-u libafl_main` |
| LLVM version mismatch | LibAFL requires LLVM 15-18 | Install compatible LLVM version, set environment variables |
| Rust compilation fails | Outdated Rust or Cargo | Update Rust with `rustup update` |
| Slow fuzzing | Sanitizers enabled | Expected 2-5x slowdown, necessary for finding bugs |
| Environment variable interference | `CC`, `CXX`, `RUSTFLAGS` set | Unset after building LibAFL project |
| Cannot attach debugger | Multi-process fuzzing | Run in single-process mode (see Debugging section) |

## Related Skills

### Technique Skills

| Skill | Use Case |
|-------|----------|
| **fuzz-harness-writing** | Detailed guidance on writing effective harnesses |
| **address-sanitizer** | Memory error detection during fuzzing |
| **undefined-behavior-sanitizer** | Undefined behavior detection |
| **coverage-analysis** | Measuring and improving code coverage |
| **fuzzing-corpus** | Building and managing seed corpora |
| **fuzzing-dictionaries** | Creating dictionaries for format-aware fuzzing |

### Related Fuzzers

| Skill | When to Consider |
|-------|------------------|
| **libfuzzer** | Simpler setup, don't need LibAFL's advanced features |
| **aflpp** | Multi-core fuzzing without custom fuzzer development |
| **cargo-fuzz** | Fuzzing Rust projects with less setup |

## Resources

### Official Documentation

- [LibAFL Book](https://aflplus.plus/libafl-book/) - Official handbook with comprehensive documentation
- [LibAFL GitHub](https://github.com/AFLplusplus/LibAFL) - Source code and examples
- [LibAFL API Documentation](https://docs.rs/libafl/latest/libafl/) - Rust API reference

### Examples and Tutorials

- [LibAFL Examples](https://github.com/AFLplusplus/LibAFL/tree/main/fuzzers) - Collection of example fuzzers
- [cargo-fuzz with LibAFL](https://github.com/AFLplusplus/LibAFL/tree/main/fuzzers/fuzz_anything/cargo_fuzz) - Using LibAFL as cargo-fuzz backend
- [Testing Handbook LibAFL Examples](https://github.com/trailofbits/testing-handbook/tree/main/materials/fuzzing/libafl) - Complete working examples from this handbook

# libfuzzer

# libFuzzer

libFuzzer is an in-process, coverage-guided fuzzer that is part of the LLVM project. It's the recommended starting point for fuzzing C/C++ projects due to its simplicity and integration with the LLVM toolchain. While libFuzzer has been in maintenance-only mode since late 2022, it is easier to install and use than its alternatives, has wide support, and will be maintained for the foreseeable future.

## When to Use

| Fuzzer | Best For | Complexity |
|--------|----------|------------|
| libFuzzer | Quick setup, single-project fuzzing | Low |
| AFL++ | Multi-core fuzzing, diverse mutations | Medium |
| LibAFL | Custom fuzzers, research projects | High |
| Honggfuzz | Hardware-based coverage | Medium |

**Choose libFuzzer when:**
- You need a simple, quick setup for C/C++ code
- Project uses Clang for compilation
- Single-core fuzzing is sufficient initially
- Transitioning to AFL++ later is an option (harnesses are compatible)

**Note:** Fuzzing harnesses written for libFuzzer are compatible with AFL++, making it easy to transition if you need more advanced features like better multi-core support.

## Quick Start

```c++
#include <stdint.h>
#include <stddef.h>

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    // Validate input if needed
    if (size < 1) return 0;

    // Call your target function with fuzzer-provided data
    my_target_function(data, size);

    return 0;
}
```

Compile and run:
```bash
clang++ -fsanitize=fuzzer,address -g -O2 harness.cc target.cc -o fuzz
mkdir corpus/
./fuzz corpus/
```

## Installation

### Prerequisites

- LLVM/Clang compiler (includes libFuzzer)
- LLVM tools for coverage analysis (optional)

### Linux (Ubuntu/Debian)

```bash
apt install clang llvm
```

For the latest LLVM version:
```bash
# Add LLVM repository from apt.llvm.org
# Then install specific version, e.g.:
apt install clang-18 llvm-18
```

### macOS

```bash
# Using Homebrew
brew install llvm

# Or using Nix
nix-env -i clang
```

### Windows

Install Clang through Visual Studio. Refer to [Microsoft's documentation](https://learn.microsoft.com/en-us/cpp/build/clang-support-msbuild?view=msvc-170) for setup instructions.

**Recommendation:** If possible, fuzz on a local x86_64 VM or rent one on DigitalOcean, AWS, or Hetzner. Linux provides the best support for libFuzzer.

### Verification

```bash
clang++ --version
# Should show LLVM version information
```

## Writing a Harness

### Harness Structure

The harness is the entry point for the fuzzer. libFuzzer calls the `LLVMFuzzerTestOneInput` function repeatedly with different inputs.

```c++
#include <stdint.h>
#include <stddef.h>

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    // 1. Optional: Validate input size
    if (size < MIN_REQUIRED_SIZE) {
        return 0;  // Reject inputs that are too small
    }

    // 2. Optional: Convert raw bytes to structured data
    // Example: Parse two integers from byte array
    if (size >= 2 * sizeof(uint32_t)) {
        uint32_t a = *(uint32_t*)(data);
        uint32_t b = *(uint32_t*)(data + sizeof(uint32_t));
        my_function(a, b);
    }

    // 3. Call target function
    target_function(data, size);

    // 4. Always return 0 (non-zero reserved for future use)
    return 0;
}
```

### Harness Rules

| Do | Don't |
|----|-------|
| Handle all input types (empty, huge, malformed) | Call `exit()` - stops fuzzing process |
| Join all threads before returning | Leave threads running |
| Keep harness fast and simple | Add excessive logging or complexity |
| Maintain determinism | Use random number generators or read `/dev/random` |
| Reset global state between runs | Rely on state from previous executions |
| Use narrow, focused targets | Mix unrelated data formats (PNG + TCP) in one harness |

**Rationale:**
- **Speed matters:** Aim for 100s-1000s executions per second per core
- **Reproducibility:** Crashes must be reproducible after fuzzing completes
- **Isolation:** Each execution should be independent

### Using FuzzedDataProvider for Complex Inputs

For complex inputs (strings, multiple parameters), use the `FuzzedDataProvider` helper:

```c++
#include <stdint.h>
#include <stddef.h>
#include "FuzzedDataProvider.h"  // From LLVM project

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    FuzzedDataProvider fuzzed_data(data, size);

    // Extract structured data
    size_t allocation_size = fuzzed_data.ConsumeIntegral<size_t>();
    std::vector<char> str1 = fuzzed_data.ConsumeBytesWithTerminator<char>(32, 0xFF);
    std::vector<char> str2 = fuzzed_data.ConsumeBytesWithTerminator<char>(32, 0xFF);

    // Call target with extracted data
    char* result = concat(&str1[0], str1.size(), &str2[0], str2.size(), allocation_size);
    if (result != NULL) {
        free(result);
    }

    return 0;
}
```

Download `FuzzedDataProvider.h` from the [LLVM repository](https://github.com/llvm/llvm-project/blob/main/compiler-rt/include/fuzzer/FuzzedDataProvider.h).

### Interleaved Fuzzing

Use a single harness to test multiple related functions:

```c++
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (size < 1 + 2 * sizeof(int32_t)) {
        return 0;
    }

    uint8_t mode = data[0];
    int32_t numbers[2];
    memcpy(numbers, data + 1, 2 * sizeof(int32_t));

    // Select function based on first byte
    switch (mode % 4) {
        case 0: add(numbers[0], numbers[1]); break;
        case 1: subtract(numbers[0], numbers[1]); break;
        case 2: multiply(numbers[0], numbers[1]); break;
        case 3: divide(numbers[0], numbers[1]); break;
    }

    return 0;
}
```

> **See Also:** For detailed harness writing techniques, patterns for handling complex inputs,
> structure-aware fuzzing, and protobuf-based fuzzing, see the **fuzz-harness-writing** technique skill.

## Compilation

### Basic Compilation

The key flag is `-fsanitize=fuzzer`, which:
- Links the libFuzzer runtime (provides `main` function)
- Enables SanitizerCoverage instrumentation for coverage tracking
- Disables built-in functions like `memcmp`

```bash
clang++ -fsanitize=fuzzer -g -O2 harness.cc target.cc -o fuzz
```

**Flags explained:**
- `-fsanitize=fuzzer`: Enable libFuzzer
- `-g`: Add debug symbols (helpful for crash analysis)
- `-O2`: Production-level optimizations (recommended for fuzzing)
- `-DNO_MAIN`: Define macro if your code has a `main` function

### With Sanitizers

**AddressSanitizer (recommended):**
```bash
clang++ -fsanitize=fuzzer,address -g -O2 -U_FORTIFY_SOURCE harness.cc target.cc -o fuzz
```

**Multiple sanitizers:**
```bash
clang++ -fsanitize=fuzzer,address,undefined -g -O2 harness.cc target.cc -o fuzz
```

> **See Also:** For detailed sanitizer configuration, common issues, ASAN_OPTIONS flags,
> and advanced sanitizer usage, see the **address-sanitizer** and **undefined-behavior-sanitizer**
> technique skills.

### Build Flags

| Flag | Purpose |
|------|---------|
| `-fsanitize=fuzzer` | Enable libFuzzer runtime and instrumentation |
| `-fsanitize=address` | Enable AddressSanitizer (memory error detection) |
| `-fsanitize=undefined` | Enable UndefinedBehaviorSanitizer |
| `-fsanitize=fuzzer-no-link` | Instrument without linking fuzzer (for libraries) |
| `-g` | Include debug symbols |
| `-O2` | Production optimization level |
| `-U_FORTIFY_SOURCE` | Disable fortification (can interfere with ASan) |

### Building Static Libraries

For projects that produce static libraries:

1. Build the library with fuzzing instrumentation:
```bash
export CC=clang CFLAGS="-fsanitize=fuzzer-no-link -fsanitize=address"
export CXX=clang++ CXXFLAGS="$CFLAGS"
./configure --enable-shared=no
make
```

2. Link the static library with your harness:
```bash
clang++ -fsanitize=fuzzer -fsanitize=address harness.cc libmylib.a -o fuzz
```

### CMake Integration

```cmake
project(FuzzTarget)
cmake_minimum_required(VERSION 3.0)

add_executable(fuzz main.cc harness.cc)
target_compile_definitions(fuzz PRIVATE NO_MAIN=1)
target_compile_options(fuzz PRIVATE -g -O2 -fsanitize=fuzzer -fsanitize=address)
target_link_libraries(fuzz -fsanitize=fuzzer -fsanitize=address)
```

Build with:
```bash
cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ .
cmake --build .
```

## Corpus Management

### Creating Initial Corpus

Create a directory for the corpus (can start empty):

```bash
mkdir corpus/
```

**Optional but recommended:** Provide seed inputs (valid example files):

```bash
# For a PNG parser:
cp examples/*.png corpus/

# For a protocol parser:
cp test_packets/*.bin corpus/
```

**Benefits of seed inputs:**
- Fuzzer doesn't start from scratch
- Reaches valid code paths faster
- Significantly improves effectiveness

### Corpus Structure

The corpus directory contains:
- Input files that trigger unique code paths
- Minimized versions (libFuzzer automatically minimizes)
- Named by content hash (e.g., `a9993e364706816aba3e25717850c26c9cd0d89d`)

### Corpus Minimization

libFuzzer automatically minimizes corpus entries during fuzzing. To explicitly minimize:

```bash
mkdir minimized_corpus/
./fuzz -merge=1 minimized_corpus/ corpus/
```

This creates a deduplicated, minimized corpus in `minimized_corpus/`.

> **See Also:** For corpus creation strategies, seed selection, format-specific corpus building,
> and corpus maintenance, see the **fuzzing-corpus** technique skill.

## Running Campaigns

### Basic Run

```bash
./fuzz corpus/
```

This runs until a crash is found or you stop it (Ctrl+C).

### Recommended: Continue After Crashes

```bash
./fuzz -fork=1 -ignore_crashes=1 corpus/
```

The `-fork` and `-ignore_crashes` flags (experimental but widely used) allow fuzzing to continue after finding crashes.

### Common Options

**Control input size:**
```bash
./fuzz -max_len=4000 corpus/
```
Rule of thumb: 2x the size of minimal realistic input.

**Set timeout:**
```bash
./fuzz -timeout=2 corpus/
```
Abort test cases that run longer than 2 seconds.

**Use a dictionary:**
```bash
./fuzz -dict=./format.dict corpus/
```

**Close stdout/stderr (speed up fuzzing):**
```bash
./fuzz -close_fd_mask=3 corpus/
```

**See all options:**
```bash
./fuzz -help=1
```

### Multi-Core Fuzzing

**Option 1: Jobs and workers (recommended):**
```bash
./fuzz -jobs=4 -workers=4 -fork=1 -ignore_crashes=1 corpus/
```
- `-jobs=4`: Run 4 sequential campaigns
- `-workers=4`: Process jobs in parallel with 4 processes
- Test cases are shared between jobs

**Option 2: Fork mode:**
```bash
./fuzz -fork=4 -ignore_crashes=1 corpus/
```

**Note:** For serious multi-core fuzzing, consider switching to AFL++, Honggfuzz, or LibAFL.

### Re-executing Test Cases

**Re-run a single crash:**
```bash
./fuzz ./crash-a9993e364706816aba3e25717850c26c9cd0d89d
```

**Test all inputs in a directory without fuzzing:**
```bash
./fuzz -runs=0 corpus/
```

### Interpreting Output

When fuzzing runs, you'll see statistics like:

```
INFO: Seed: 3517090860
INFO: Loaded 1 modules (9 inline 8-bit counters)
#2      INITED cov: 3 ft: 4 corp: 1/1b exec/s: 0 rss: 26Mb
#57     NEW    cov: 4 ft: 5 corp: 2/4b lim: 4 exec/s: 0 rss: 26Mb
```

| Output | Meaning |
|--------|---------|
| `INITED` | Fuzzing initialized |
| `NEW` | New coverage found, added to corpus |
| `REDUCE` | Input minimized while keeping coverage |
| `cov: N` | Number of coverage edges hit |
| `corp: X/Yb` | Corpus size: X entries, Y total bytes |
| `exec/s: N` | Executions per second |
| `rss: NMb` | Resident memory usage |

**On crash:**
```
==11672== ERROR: libFuzzer: deadly signal
artifact_prefix='./'; Test unit written to ./crash-a9993e364706816aba3e25717850c26c9cd0d89d
0x61,0x62,0x63,
abc
Base64: YWJj
```

The crash is saved to `./crash-<hash>` with the input shown in hex, UTF-8, and Base64.

**Reproducibility:** Use `-seed=<value>` to reproduce a fuzzing campaign (single-core only).

## Fuzzing Dictionary

Dictionaries help the fuzzer discover interesting inputs faster by providing hints about the input format.

### Dictionary Format

Create a text file with quoted strings (one per line):

```conf
# Lines starting with '#' are comments

# Magic bytes
magic="\x89PNG"
magic2="IEND"

# Keywords
"GET"
"POST"
"Content-Type"

# Hex sequences
delimiter="\xFF\xD8\xFF"
```

### Using a Dictionary

```bash
./fuzz -dict=./format.dict corpus/
```

### Generating a Dictionary

**From header files:**
```bash
grep -o '".*"' header.h > header.dict
```

**From man pages:**
```bash
man curl | grep -oP '^\s*(--|-)\K\S+' | sed 's/[,.]$//' | sed 's/^/"&/; s/$/&"/' | sort -u > man.dict
```

**From binary strings:**
```bash
strings ./binary | sed 's/^/"&/; s/$/&"/' > strings.dict
```

**Using LLMs:** Ask ChatGPT or similar to generate a dictionary for your format (e.g., "Generate a libFuzzer dictionary for a JSON parser").

> **See Also:** For advanced dictionary generation, format-specific dictionaries, and
> dictionary optimization strategies, see the **fuzzing-dictionaries** technique skill.

## Coverage Analysis

While libFuzzer shows basic coverage stats (`cov: N`), detailed coverage analysis requires additional tools.

### Source-Based Coverage

**1. Recompile with coverage instrumentation:**
```bash
clang++ -fsanitize=fuzzer -fprofile-instr-generate -fcoverage-mapping harness.cc target.cc -o fuzz
```

**2. Run fuzzer to collect coverage:**
```bash
LLVM_PROFILE_FILE="coverage-%p.profraw" ./fuzz -runs=10000 corpus/
```

**3. Merge coverage data:**
```bash
llvm-profdata merge -sparse coverage-*.profraw -o coverage.profdata
```

**4. Generate coverage report:**
```bash
llvm-cov show ./fuzz -instr-profile=coverage.profdata
```

**5. Generate HTML report:**
```bash
llvm-cov show ./fuzz -instr-profile=coverage.profdata -format=html > coverage.html
```

### Improving Coverage

**Tips:**
- Provide better seed inputs in corpus
- Use dictionaries for format-aware fuzzing
- Check if harness properly exercises target
- Consider structure-aware fuzzing for complex formats
- Run longer campaigns (days/weeks)

> **See Also:** For detailed coverage analysis techniques, identifying coverage gaps,
> systematic coverage improvement, and comparing coverage across fuzzers, see the
> **coverage-analysis** technique skill.

## Sanitizer Integration

### AddressSanitizer (ASan)

ASan detects memory errors like buffer overflows and use-after-free bugs. **Highly recommended for fuzzing.**

**Enable ASan:**
```bash
clang++ -fsanitize=fuzzer,address -g -O2 -U_FORTIFY_SOURCE harness.cc target.cc -o fuzz
```

**Example ASan output:**
```
==1276163==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x6020000c4ab1
WRITE of size 1 at 0x6020000c4ab1 thread T0
    #0 0x55555568631a in check_buf(char*, unsigned long) main.cc:13:25
    #1 0x5555556860bf in LLVMFuzzerTestOneInput harness.cc:7:3
```

**Configure ASan with environment variables:**
```bash
ASAN_OPTIONS=verbosity=1:abort_on_error=1 ./fuzz corpus/
```

**Important flags:**
- `verbosity=1`: Show ASan is active
- `detect_leaks=0`: Disable leak detection (leaks reported at end)
- `abort_on_error=1`: Call `abort()` instead of `_exit()` on errors

**Drawbacks:**
- 2-4x slowdown
- Requires ~20TB virtual memory (disable memory limits: `-rss_limit_mb=0`)
- Best supported on Linux

> **See Also:** For comprehensive ASan configuration, common pitfalls, symbolization,
> and combining with other sanitizers, see the **address-sanitizer** technique skill.

### UndefinedBehaviorSanitizer (UBSan)

UBSan detects undefined behavior like integer overflow, null pointer dereference, etc.

**Enable UBSan:**
```bash
clang++ -fsanitize=fuzzer,undefined -g -O2 harness.cc target.cc -o fuzz
```

**Combine with ASan:**
```bash
clang++ -fsanitize=fuzzer,address,undefined -g -O2 harness.cc target.cc -o fuzz
```

### MemorySanitizer (MSan)

MSan detects uninitialized memory reads. More complex to use (requires rebuilding all dependencies).

```bash
clang++ -fsanitize=fuzzer,memory -g -O2 harness.cc target.cc -o fuzz
```

### Common Sanitizer Issues

| Issue | Solution |
|-------|----------|
| ASan slows fuzzing too much | Use `-fsanitize-recover=address` for non-fatal errors |
| Out of memory | Set `ASAN_OPTIONS=rss_limit_mb=0` or `-rss_limit_mb=0` |
| Stack exhaustion | Increase stack size: `ASAN_OPTIONS=stack_size=8388608` |
| False positives with `_FORTIFY_SOURCE` | Use `-U_FORTIFY_SOURCE` flag |
| MSan reports in dependencies | Rebuild all dependencies with `-fsanitize=memory` |

## Real-World Examples

### Example 1: Fuzzing libpng

libpng is a widely-used library for reading/writing PNG images. Bugs can lead to security issues.

**1. Get source code:**
```bash
curl -L -O https://downloads.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.xz
tar xf libpng-1.6.37.tar.xz
cd libpng-1.6.37/
```

**2. Install dependencies:**
```bash
apt install zlib1g-dev
```

**3. Compile with fuzzing instrumentation:**
```bash
export CC=clang CFLAGS="-fsanitize=fuzzer-no-link -fsanitize=address"
export CXX=clang++ CXXFLAGS="$CFLAGS"
./configure --enable-shared=no
make
```

**4. Get a harness (or write your own):**
```bash
curl -O https://raw.githubusercontent.com/glennrp/libpng/f8e5fa92b0e37ab597616f554bee254157998227/contrib/oss-fuzz/libpng_read_fuzzer.cc
```

**5. Prepare corpus and dictionary:**
```bash
mkdir corpus/
curl -o corpus/input.png https://raw.githubusercontent.com/glennrp/libpng/acfd50ae0ba3198ad734e5d4dec2b05341e50924/contrib/pngsuite/iftp1n3p08.png
curl -O https://raw.githubusercontent.com/glennrp/libpng/2fff013a6935967960a5ae626fc21432807933dd/contrib/oss-fuzz/png.dict
```

**6. Link and compile fuzzer:**
```bash
clang++ -fsanitize=fuzzer -fsanitize=address libpng_read_fuzzer.cc .libs/libpng16.a -lz -o fuzz
```

**7. Run fuzzing campaign:**
```bash
./fuzz -close_fd_mask=3 -dict=./png.dict corpus/
```

### Example 2: Simple Division Bug

Harness that finds a division-by-zero bug:

```c++
#include <stdint.h>
#include <stddef.h>

double divide(uint32_t numerator, uint32_t denominator) {
    // Bug: No check if denominator is zero
    return numerator / denominator;
}

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if(size != 2 * sizeof(uint32_t)) {
        return 0;
    }

    uint32_t numerator = *(uint32_t*)(data);
    uint32_t denominator = *(uint32_t*)(data + sizeof(uint32_t));

    divide(numerator, denominator);

    return 0;
}
```

Compile and fuzz:
```bash
clang++ -fsanitize=fuzzer harness.cc -o fuzz
./fuzz
```

The fuzzer will quickly find inputs causing a crash.

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| Start with single-core, switch to AFL++ for multi-core | libFuzzer harnesses work with AFL++ |
| Use dictionaries for structured formats | 10-100x faster bug discovery |
| Close file descriptors with `-close_fd_mask=3` | Speed boost if SUT writes output |
| Set reasonable `-max_len` | Prevents wasted time on huge inputs |
| Run for days/weeks, not minutes | Coverage plateaus take time to break |
| Use seed corpus from test suites | Starts fuzzing from valid inputs |

### Structure-Aware Fuzzing

For highly structured inputs (e.g., complex protocols, file formats), use libprotobuf-mutator:

- Define input structure using Protocol Buffers
- libFuzzer mutates protobuf messages (structure-preserving mutations)
- Harness converts protobuf to native format

See [structure-aware fuzzing documentation](https://github.com/google/fuzzing/blob/master/docs/structure-aware-fuzzing.md) for details.

### Custom Mutators

libFuzzer allows custom mutators for specialized fuzzing:

```c++
extern "C" size_t LLVMFuzzerCustomMutator(uint8_t *Data, size_t Size,
                                          size_t MaxSize, unsigned int Seed) {
    // Custom mutation logic
    return new_size;
}

extern "C" size_t LLVMFuzzerCustomCrossOver(const uint8_t *Data1, size_t Size1,
                                            const uint8_t *Data2, size_t Size2,
                                            uint8_t *Out, size_t MaxOutSize,
                                            unsigned int Seed) {
    // Custom crossover logic
    return new_size;
}
```

### Performance Tuning

| Setting | Impact |
|---------|--------|
| `-close_fd_mask=3` | Closes stdout/stderr, speeds up fuzzing |
| `-max_len=<reasonable_size>` | Avoids wasting time on huge inputs |
| `-timeout=<seconds>` | Detects hangs, prevents stuck executions |
| Disable ASan for baseline | 2-4x speed boost (but misses memory bugs) |
| Use `-jobs` and `-workers` | Limited multi-core support |
| Run on Linux | Best platform support and performance |

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| No crashes found after hours | Poor corpus, low coverage | Add seed inputs, use dictionary, check harness |
| Very slow executions/sec (<100) | Target too complex, excessive logging | Optimize target, use `-close_fd_mask=3`, reduce logging |
| Out of memory | ASan's 20TB virtual memory | Set `-rss_limit_mb=0` to disable RSS limit |
| Fuzzer stops after first crash | Default behavior | Use `-fork=1 -ignore_crashes=1` to continue |
| Can't reproduce crash | Non-determinism in harness/target | Remove random number generation, global state |
| Linking errors with `-fsanitize=fuzzer` | Missing libFuzzer runtime | Ensure using Clang, check LLVM installation |
| GCC project won't compile with Clang | GCC-specific code | Switch to AFL++ with `gcc_plugin` instead |
| Coverage not improving | Corpus plateau | Run longer, add dictionary, improve seeds, check coverage report |
| Crashes but ASan doesn't trigger | Memory error not detected without ASan | Recompile with `-fsanitize=address` |

## Related Skills

### Technique Skills

| Skill | Use Case |
|-------|----------|
| **fuzz-harness-writing** | Detailed guidance on writing effective harnesses, structure-aware fuzzing, and FuzzedDataProvider usage |
| **address-sanitizer** | Memory error detection configuration, ASAN_OPTIONS, and troubleshooting |
| **undefined-behavior-sanitizer** | Detecting undefined behavior during fuzzing |
| **coverage-analysis** | Measuring fuzzing effectiveness and identifying untested code paths |
| **fuzzing-corpus** | Building and managing seed corpora, corpus minimization strategies |
| **fuzzing-dictionaries** | Creating format-specific dictionaries for faster bug discovery |

### Related Fuzzers

| Skill | When to Consider |
|-------|------------------|
| **aflpp** | When you need serious multi-core fuzzing, or when libFuzzer coverage plateaus |
| **honggfuzz** | When you want hardware-based coverage feedback on Linux |
| **libafl** | When building custom fuzzers or conducting fuzzing research |

## Resources

### Official Documentation

- [LLVM libFuzzer Documentation](https://llvm.org/docs/LibFuzzer.html) - Official reference
- [libFuzzer Tutorial by Google](https://github.com/google/fuzzing/blob/master/tutorial/libFuzzerTutorial.md) - Step-by-step guide
- [SanitizerCoverage](https://clang.llvm.org/docs/SanitizerCoverage.html) - Coverage instrumentation details

### Advanced Topics

- [Structure-Aware Fuzzing with libprotobuf-mutator](https://github.com/google/fuzzing/blob/master/docs/structure-aware-fuzzing.md)
- [Split Inputs in libFuzzer](https://github.com/google/fuzzing/blob/master/docs/split-inputs.md)
- [FuzzedDataProvider Header](https://github.com/llvm/llvm-project/blob/main/compiler-rt/include/fuzzer/FuzzedDataProvider.h)

### Example Projects

- [OSS-Fuzz](https://github.com/google/oss-fuzz) - Continuous fuzzing for open-source projects (many libFuzzer examples)
- [AFL++ Dictionary Collection](https://github.com/AFLplusplus/AFLplusplus/tree/stable/dictionaries) - Reusable dictionaries

# ossfuzz

# OSS-Fuzz

[OSS-Fuzz](https://google.github.io/oss-fuzz/) is an open-source project developed by Google that provides free distributed infrastructure for continuous fuzz testing. It streamlines the fuzzing process and facilitates simpler modifications. While only select projects are accepted into OSS-Fuzz, the project's core is open-source, allowing anyone to host their own instance for private projects.

## Overview

OSS-Fuzz provides a simple CLI framework for building and starting harnesses or calculating their coverage. Additionally, OSS-Fuzz can be used as a service that hosts static web pages generated from fuzzing outputs such as coverage information.

### Key Concepts

| Concept | Description |
|---------|-------------|
| **helper.py** | CLI script for building images, building fuzzers, and running harnesses locally |
| **Base Images** | Hierarchical Docker images providing build dependencies and compilers |
| **project.yaml** | Configuration file defining project metadata for OSS-Fuzz enrollment |
| **Dockerfile** | Project-specific image with build dependencies |
| **build.sh** | Script that builds fuzzing harnesses for your project |
| **Criticality Score** | Metric used by OSS-Fuzz team to evaluate project acceptance |

## When to Apply

**Apply this technique when:**
- Setting up continuous fuzzing for an open-source project
- Need distributed fuzzing infrastructure without managing servers
- Want coverage reports and bug tracking integrated with fuzzing
- Testing existing OSS-Fuzz harnesses locally
- Reproducing crashes from OSS-Fuzz bug reports

**Skip this technique when:**
- Project is closed-source (unless hosting your own OSS-Fuzz instance)
- Project doesn't meet OSS-Fuzz's criticality score threshold
- Need proprietary or specialized fuzzing infrastructure
- Fuzzing simple scripts that don't warrant infrastructure

## Quick Reference

| Task | Command |
|------|---------|
| Clone OSS-Fuzz | `git clone https://github.com/google/oss-fuzz` |
| Build project image | `python3 infra/helper.py build_image --pull <project>` |
| Build fuzzers with ASan | `python3 infra/helper.py build_fuzzers --sanitizer=address <project>` |
| Run specific harness | `python3 infra/helper.py run_fuzzer <project> <harness>` |
| Generate coverage report | `python3 infra/helper.py coverage <project>` |
| Check helper.py options | `python3 infra/helper.py --help` |

## OSS-Fuzz Project Components

OSS-Fuzz provides several publicly available tools and web interfaces:

### Bug Tracker

The [bug tracker](https://issues.oss-fuzz.com/issues?q=status:open) allows you to:
- Check bugs from specific projects (initially visible only to maintainers, later [made public](https://google.github.io/oss-fuzz/getting-started/bug-disclosure-guidelines/))
- Create new issues and comment on existing ones
- Search for similar bugs across **all projects** to understand issues

### Build Status System

The [build status system](https://oss-fuzz-build-logs.storage.googleapis.com/index.html) helps track:
- Build statuses of all included projects
- Date of last successful build
- Build failures and their duration

### Fuzz Introspector

[Fuzz Introspector](https://oss-fuzz-introspector.storage.googleapis.com/index.html) displays:
- Coverage data for projects enrolled in OSS-Fuzz
- Hit frequency for covered code
- Performance analysis and blocker identification

Read [this case study](https://github.com/ossf/fuzz-introspector/blob/main/doc/CaseStudies.md) for examples and explanations.

## Step-by-Step: Running a Single Harness

You don't need to host the whole OSS-Fuzz platform to use it. The helper script makes it easy to run individual harnesses locally.

### Step 1: Clone OSS-Fuzz

```bash
git clone https://github.com/google/oss-fuzz
cd oss-fuzz
python3 infra/helper.py --help
```

### Step 2: Build Project Image

```bash
python3 infra/helper.py build_image --pull <project-name>
```

This downloads and builds the base Docker image for the project.

### Step 3: Build Fuzzers with Sanitizers

```bash
python3 infra/helper.py build_fuzzers --sanitizer=address <project-name>
```

**Sanitizer options:**
- `--sanitizer=address` for [AddressSanitizer](https://appsec.guide/docs/fuzzing/techniques/asan/) with [LeakSanitizer](https://github.com/google/sanitizers/wiki/AddressSanitizerLeakSanitizer)
- Other sanitizers available (language support varies)

**Note:** Fuzzers are built to `/build/out/<project-name>/` containing the harness executables, dictionaries, corpus, and crash files.

### Step 4: Run the Fuzzer

```bash
python3 infra/helper.py run_fuzzer <project-name> <harness-name> [<fuzzer-args>]
```

The helper script automatically runs any missed steps if you skip them.

### Step 5: Coverage Analysis (Optional)

First, [install gsutil](https://cloud.google.com/storage/docs/gsutil_install) (skip gcloud initialization).

```bash
python3 infra/helper.py build_fuzzers --sanitizer=coverage <project-name>
python3 infra/helper.py coverage <project-name>
```

Use `--no-corpus-download` to use only local corpus. The command generates and hosts a coverage report locally.

See [official OSS-Fuzz documentation](https://google.github.io/oss-fuzz/advanced-topics/code-coverage/) for details.

## Common Patterns

### Pattern: Running irssi Example

**Use Case:** Testing OSS-Fuzz setup with a simple enrolled project

```bash
# Clone and navigate to OSS-Fuzz
git clone https://github.com/google/oss-fuzz
cd oss-fuzz

# Build and run irssi fuzzer
python3 infra/helper.py build_image --pull irssi
python3 infra/helper.py build_fuzzers --sanitizer=address irssi
python3 infra/helper.py run_fuzzer irssi irssi-fuzz
```

**Expected Output:**
```
INFO:__main__:Running: docker run --rm --privileged --shm-size=2g --platform linux/amd64 -i -e FUZZING_ENGINE=libfuzzer -e SANITIZER=address -e RUN_FUZZER_MODE=interactive -e HELPER=True -v /private/tmp/oss-fuzz/build/out/irssi:/out -t gcr.io/oss-fuzz-base/base-runner run_fuzzer irssi-fuzz.
Using seed corpus: irssi-fuzz_seed_corpus.zip
/out/irssi-fuzz -rss_limit_mb=2560 -timeout=25 /tmp/irssi-fuzz_corpus -max_len=2048 < /dev/null
INFO: Running with entropic power schedule (0xFF, 100).
INFO: Seed: 1531341664
INFO: Loaded 1 modules   (95687 inline 8-bit counters): 95687 [0x1096c80, 0x10ae247),
INFO: Loaded 1 PC tables (95687 PCs): 95687 [0x10ae248,0x1223eb8),
INFO:      719 files found in /tmp/irssi-fuzz_corpus
INFO: seed corpus: files: 719 min: 1b max: 170106b total: 367969b rss: 48Mb
#720        INITED cov: 409 ft: 1738 corp: 640/163Kb exec/s: 0 rss: 62Mb
#762        REDUCE cov: 409 ft: 1738 corp: 640/163Kb lim: 2048 exec/s: 0 rss: 63Mb L: 236/2048 MS: 2 ShuffleBytes-EraseBytes-
```

### Pattern: Enrolling a New Project

**Use Case:** Adding your project to OSS-Fuzz (or private instance)

Create three files in `projects/<your-project>/`:

**1. project.yaml** - Project metadata:
```yaml
homepage: "https://github.com/yourorg/yourproject"
language: c++
primary_contact: "your-email@example.com"
main_repo: "https://github.com/yourorg/yourproject"
fuzzing_engines:
  - libfuzzer
sanitizers:
  - address
  - undefined
```

**2. Dockerfile** - Build dependencies:
```dockerfile
FROM gcr.io/oss-fuzz-base/base-builder
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    libtool \
    pkg-config
RUN git clone --depth 1 https://github.com/yourorg/yourproject
WORKDIR yourproject
COPY build.sh $SRC/
```

**3. build.sh** - Build harnesses:
```bash
#!/bin/bash -eu
./autogen.sh
./configure --disable-shared
make -j$(nproc)

# Build harnesses
$CXX $CXXFLAGS -std=c++11 -I. \
    $SRC/yourproject/fuzz/harness.cc -o $OUT/harness \
    $LIB_FUZZING_ENGINE ./libyourproject.a

# Copy corpus and dictionary if available
cp $SRC/yourproject/fuzz/corpus.zip $OUT/harness_seed_corpus.zip
cp $SRC/yourproject/fuzz/dictionary.dict $OUT/harness.dict
```

## Docker Images in OSS-Fuzz

Harnesses are built and executed in Docker containers. All projects share a runner image, but each project has its own build image.

### Image Hierarchy

Images build on each other in this sequence:

1. **[base_image](https://github.com/google/oss-fuzz/blob/master/infra/base-images/base-image/Dockerfile)** - Specific Ubuntu version
2. **[base_clang](https://github.com/google/oss-fuzz/tree/master/infra/base-images/base-clang)** - Clang compiler; based on `base_image`
3. **[base_builder](https://github.com/google/oss-fuzz/tree/master/infra/base-images/base-builder)** - Build dependencies; based on `base_clang`
   - Language-specific variants: [`base_builder_go`](https://github.com/google/oss-fuzz/tree/master/infra/base-images/base-builder-go), etc.
   - See [/oss-fuzz/infra/base-images/](https://github.com/google/oss-fuzz/tree/master/infra/base-images) for full list
4. **Your project Docker image** - Project-specific dependencies; based on `base_builder` or language variant

### Runner Images (Used Separately)

- **[base_runner](https://github.com/google/oss-fuzz/tree/master/infra/base-images/base-runner)** - Executes harnesses; based on `base_clang`
- **[base_runner_debug](https://github.com/google/oss-fuzz/tree/master/infra/base-images/base-runner-debug)** - With debug tools; based on `base_runner`

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| **Don't manually copy source code** | Project Dockerfile likely already pulls latest version |
| **Check existing projects** | Browse [oss-fuzz/projects](https://github.com/google/oss-fuzz/tree/master/projects) for examples |
| **Keep harnesses in separate repo** | Like [curl-fuzzer](https://github.com/curl/curl-fuzzer) - cleaner organization |
| **Use specific compiler versions** | Base images provide consistent build environment |
| **Install dependencies in Dockerfile** | May require approval for OSS-Fuzz enrollment |

### Criticality Score

OSS-Fuzz uses a [criticality score](https://github.com/ossf/criticality_score) to evaluate project acceptance. See [this example](https://github.com/google/oss-fuzz/pull/11444#issuecomment-1875907472) for how scoring works.

Projects with lower scores may still be added to private OSS-Fuzz instances.

### Hosting Your Own Instance

Since OSS-Fuzz is open-source, you can host your own instance for:
- Private projects not eligible for public OSS-Fuzz
- Projects with lower criticality scores
- Custom fuzzing infrastructure needs

## Anti-Patterns

| Anti-Pattern | Problem | Correct Approach |
|--------------|---------|------------------|
| **Manually pulling source in build.sh** | Doesn't use latest version | Let Dockerfile handle git clone |
| **Copying code to OSS-Fuzz repo** | Hard to maintain, violates separation | Reference external harness repo |
| **Ignoring base image versions** | Build inconsistencies | Use provided base images and compilers |
| **Skipping local testing** | Wastes CI resources | Use helper.py locally before PR |
| **Not checking build status** | Unnoticed build failures | Monitor build status page regularly |

## Tool-Specific Guidance

### libFuzzer

OSS-Fuzz primarily uses libFuzzer as the fuzzing engine for C/C++ projects.

**Harness signature:**
```c++
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    // Your fuzzing logic
    return 0;
}
```

**Build in build.sh:**
```bash
$CXX $CXXFLAGS -std=c++11 -I. \
    harness.cc -o $OUT/harness \
    $LIB_FUZZING_ENGINE ./libproject.a
```

**Integration tips:**
- Use `$LIB_FUZZING_ENGINE` variable provided by OSS-Fuzz
- Include `-fsanitize=fuzzer` is handled automatically
- Link against static libraries when possible

### AFL++

OSS-Fuzz supports AFL++ as an alternative fuzzing engine.

**Enable in project.yaml:**
```yaml
fuzzing_engines:
  - afl
  - libfuzzer
```

**Integration tips:**
- AFL++ harnesses work alongside libFuzzer harnesses
- Use persistent mode for better performance
- OSS-Fuzz handles engine-specific compilation flags

### Atheris (Python)

For Python projects with C extensions.

**Example from [cbor2 integration](https://github.com/google/oss-fuzz/pull/11444):**

**Harness:**
```python
import atheris
import sys
import cbor2

@atheris.instrument_func
def TestOneInput(data):
    fdp = atheris.FuzzedDataProvider(data)
    try:
        cbor2.loads(data)
    except (cbor2.CBORDecodeError, ValueError):
        pass

def main():
    atheris.Setup(sys.argv, TestOneInput)
    atheris.Fuzz()

if __name__ == "__main__":
    main()
```

**Build in build.sh:**
```bash
pip3 install .
for fuzzer in $(find $SRC -name 'fuzz_*.py'); do
  compile_python_fuzzer $fuzzer
done
```

**Integration tips:**
- Use `compile_python_fuzzer` helper provided by OSS-Fuzz
- See [Continuously Fuzzing Python C Extensions](https://blog.trailofbits.com/2024/02/23/continuously-fuzzing-python-c-extensions/) blog post

### Rust Projects

**Enable in project.yaml:**
```yaml
language: rust
fuzzing_engines:
  - libfuzzer
sanitizers:
  - address  # Only AddressSanitizer supported for Rust
```

**Build in build.sh:**
```bash
cargo fuzz build -O --debug-assertions
cp fuzz/target/x86_64-unknown-linux-gnu/release/fuzz_target_1 $OUT/
```

**Integration tips:**
- [Rust supports only AddressSanitizer with libfuzzer](https://google.github.io/oss-fuzz/getting-started/new-project-guide/rust-lang/#projectyaml)
- Use cargo-fuzz for local development
- OSS-Fuzz handles Rust-specific compilation

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| **Build fails with missing dependencies** | Dependencies not in Dockerfile | Add `apt-get install` or equivalent in Dockerfile |
| **Harness crashes immediately** | Missing input validation | Add size checks in harness |
| **Coverage is 0%** | Harness not reaching target code | Verify harness actually calls target functions |
| **Build timeout** | Complex build process | Optimize build.sh, consider parallel builds |
| **Sanitizer errors in build** | Incompatible flags | Use flags provided by OSS-Fuzz environment variables |
| **Cannot find source code** | Wrong working directory in Dockerfile | Set WORKDIR or use absolute paths |

## Related Skills

### Tools That Use This Technique

| Skill | How It Applies |
|-------|----------------|
| **libfuzzer** | Primary fuzzing engine used by OSS-Fuzz |
| **aflpp** | Alternative fuzzing engine supported by OSS-Fuzz |
| **atheris** | Used for fuzzing Python projects in OSS-Fuzz |
| **cargo-fuzz** | Used for Rust projects in OSS-Fuzz |

### Related Techniques

| Skill | Relationship |
|-------|--------------|
| **coverage-analysis** | OSS-Fuzz generates coverage reports via helper.py |
| **address-sanitizer** | Default sanitizer for OSS-Fuzz projects |
| **fuzz-harness-writing** | Essential for enrolling projects in OSS-Fuzz |
| **corpus-management** | OSS-Fuzz maintains corpus for enrolled projects |

## Resources

### Key External Resources

**[OSS-Fuzz Official Documentation](https://google.github.io/oss-fuzz/)**
Comprehensive documentation covering enrollment, harness writing, and troubleshooting for the OSS-Fuzz platform.

**[Getting Started Guide](https://google.github.io/oss-fuzz/getting-started/accepting-new-projects/)**
Step-by-step process for enrolling new projects into OSS-Fuzz, including requirements and approval process.

**[cbor2 OSS-Fuzz Integration PR](https://github.com/google/oss-fuzz/pull/11444)**
Real-world example of enrolling a Python project with C extensions into OSS-Fuzz. Shows:
- Initial proposal and project introduction
- Criticality score evaluation
- Complete implementation (project.yaml, Dockerfile, build.sh, harnesses)

**[Fuzz Introspector Case Studies](https://github.com/ossf/fuzz-introspector/blob/main/doc/CaseStudies.md)**
Examples and explanations of using Fuzz Introspector to analyze coverage and identify fuzzing blockers.

### Video Resources

Check OSS-Fuzz documentation for workshop recordings and tutorials on enrollment and harness development.

# ruzzy

# Ruzzy

Ruzzy is a coverage-guided fuzzer for Ruby built on libFuzzer. It enables fuzzing both pure Ruby code and Ruby C extensions with sanitizer support for detecting memory corruption and undefined behavior.

## When to Use

Ruzzy is currently the only production-ready coverage-guided fuzzer for Ruby.

**Choose Ruzzy when:**
- Fuzzing Ruby applications or libraries
- Testing Ruby C extensions for memory safety issues
- You need coverage-guided fuzzing for Ruby code
- Working with Ruby gems that have native extensions

## Quick Start

Set up environment:
```bash
export ASAN_OPTIONS="allocator_may_return_null=1:detect_leaks=0:use_sigaltstack=0"
```

Test with the included toy example:
```bash
LD_PRELOAD=$(ruby -e 'require "ruzzy"; print Ruzzy::ASAN_PATH') \
    ruby -e 'require "ruzzy"; Ruzzy.dummy'
```

This should quickly find a crash demonstrating that Ruzzy is working correctly.

## Installation

### Platform Support

Ruzzy supports Linux x86-64 and AArch64/ARM64. For macOS or Windows, use the [Dockerfile](https://github.com/trailofbits/ruzzy/blob/main/Dockerfile) or [development environment](https://github.com/trailofbits/ruzzy#developing).

### Prerequisites

- Linux x86-64 or AArch64/ARM64
- Recent version of clang (tested back to 14.0.0, latest release recommended)
- Ruby with gem installed

### Installation Command

Install Ruzzy with clang compiler flags:

```bash
MAKE="make --environment-overrides V=1" \
CC="/path/to/clang" \
CXX="/path/to/clang++" \
LDSHARED="/path/to/clang -shared" \
LDSHAREDXX="/path/to/clang++ -shared" \
    gem install ruzzy
```

**Environment variables explained:**
- `MAKE`: Overrides make to respect subsequent environment variables
- `CC`, `CXX`, `LDSHARED`, `LDSHAREDXX`: Ensure proper clang binaries are used for latest features

### Troubleshooting Installation

If installation fails, enable debug output:

```bash
RUZZY_DEBUG=1 gem install --verbose ruzzy
```

### Verification

Verify installation by running the toy example (see Quick Start section).

## Writing a Harness

### Fuzzing Pure Ruby Code

Pure Ruby fuzzing requires two scripts due to Ruby interpreter implementation details.

**Tracer script (`test_tracer.rb`):**

```ruby
# frozen_string_literal: true

require 'ruzzy'

Ruzzy.trace('test_harness.rb')
```

**Harness script (`test_harness.rb`):**

```ruby
# frozen_string_literal: true

require 'ruzzy'

def fuzzing_target(input)
  # Your code to fuzz here
  if input.length == 4
    if input[0] == 'F'
      if input[1] == 'U'
        if input[2] == 'Z'
          if input[3] == 'Z'
            raise
          end
        end
      end
    end
  end
end

test_one_input = lambda do |data|
  fuzzing_target(data)
  return 0
end

Ruzzy.fuzz(test_one_input)
```

Run with:

```bash
LD_PRELOAD=$(ruby -e 'require "ruzzy"; print Ruzzy::ASAN_PATH') \
    ruby test_tracer.rb
```

### Fuzzing Ruby C Extensions

C extensions can be fuzzed with a single harness file, no tracer needed.

**Example harness for msgpack (`fuzz_msgpack.rb`):**

```ruby
# frozen_string_literal: true

require 'msgpack'
require 'ruzzy'

test_one_input = lambda do |data|
  begin
    MessagePack.unpack(data)
  rescue Exception
    # We're looking for memory corruption, not Ruby exceptions
  end
  return 0
end

Ruzzy.fuzz(test_one_input)
```

Run with:

```bash
LD_PRELOAD=$(ruby -e 'require "ruzzy"; print Ruzzy::ASAN_PATH') \
    ruby fuzz_msgpack.rb
```

### Harness Rules

| Do | Don't |
|----|-------|
| Catch Ruby exceptions if testing C extensions | Let Ruby exceptions crash the fuzzer |
| Return 0 from test_one_input lambda | Return other values |
| Keep harness deterministic | Use randomness or time-based logic |
| Use tracer script for pure Ruby | Skip tracer for pure Ruby code |

> **See Also:** For detailed harness writing techniques, patterns for handling complex inputs,
> and advanced strategies, see the **fuzz-harness-writing** technique skill.

## Compilation

### Installing Gems with Sanitizers

When installing Ruby gems with C extensions for fuzzing, compile with sanitizer flags:

```bash
MAKE="make --environment-overrides V=1" \
CC="/path/to/clang" \
CXX="/path/to/clang++" \
LDSHARED="/path/to/clang -shared" \
LDSHAREDXX="/path/to/clang++ -shared" \
CFLAGS="-fsanitize=address,fuzzer-no-link -fno-omit-frame-pointer -fno-common -fPIC -g" \
CXXFLAGS="-fsanitize=address,fuzzer-no-link -fno-omit-frame-pointer -fno-common -fPIC -g" \
    gem install <gem-name>
```

### Build Flags

| Flag | Purpose |
|------|---------|
| `-fsanitize=address,fuzzer-no-link` | Enable AddressSanitizer and fuzzer instrumentation |
| `-fno-omit-frame-pointer` | Improve stack trace quality |
| `-fno-common` | Better compatibility with sanitizers |
| `-fPIC` | Position-independent code for shared libraries |
| `-g` | Include debug symbols |

## Running Campaigns

### Environment Setup

Before running any fuzzing campaign, set ASAN_OPTIONS:

```bash
export ASAN_OPTIONS="allocator_may_return_null=1:detect_leaks=0:use_sigaltstack=0"
```

**Options explained:**
1. `allocator_may_return_null=1`: Skip common low-impact allocation failures (DoS)
2. `detect_leaks=0`: Ruby interpreter leaks data, ignore these for now
3. `use_sigaltstack=0`: Ruby recommends disabling sigaltstack with ASan

### Basic Run

```bash
LD_PRELOAD=$(ruby -e 'require "ruzzy"; print Ruzzy::ASAN_PATH') \
    ruby harness.rb
```

**Note:** `LD_PRELOAD` is required for sanitizer injection. Unlike `ASAN_OPTIONS`, do not export it as it may interfere with other programs.

### With Corpus

```bash
LD_PRELOAD=$(ruby -e 'require "ruzzy"; print Ruzzy::ASAN_PATH') \
    ruby harness.rb /path/to/corpus
```

### Passing libFuzzer Options

All libFuzzer options can be passed as arguments:

```bash
LD_PRELOAD=$(ruby -e 'require "ruzzy"; print Ruzzy::ASAN_PATH') \
    ruby harness.rb /path/to/corpus -max_len=1024 -timeout=10
```

See [libFuzzer options](https://llvm.org/docs/LibFuzzer.html#options) for full reference.

### Reproducing Crashes

Re-run a crash case by passing the crash file:

```bash
LD_PRELOAD=$(ruby -e 'require "ruzzy"; print Ruzzy::ASAN_PATH') \
    ruby harness.rb ./crash-253420c1158bc6382093d409ce2e9cff5806e980
```

### Interpreting Output

| Output | Meaning |
|--------|---------|
| `INFO: Running with entropic power schedule` | Fuzzing campaign started |
| `ERROR: AddressSanitizer: heap-use-after-free` | Memory corruption detected |
| `SUMMARY: libFuzzer: fuzz target exited` | Ruby exception occurred |
| `artifact_prefix='./'; Test unit written to ./crash-*` | Crash input saved |
| `Base64: ...` | Base64 encoding of crash input |

## Sanitizer Integration

### AddressSanitizer (ASan)

Ruzzy includes a pre-compiled AddressSanitizer library:

```bash
LD_PRELOAD=$(ruby -e 'require "ruzzy"; print Ruzzy::ASAN_PATH') \
    ruby harness.rb
```

Use ASan for detecting:
- Heap buffer overflows
- Stack buffer overflows
- Use-after-free
- Double-free
- Memory leaks (disabled by default in Ruzzy)

### UndefinedBehaviorSanitizer (UBSan)

Ruzzy also includes UBSan:

```bash
LD_PRELOAD=$(ruby -e 'require "ruzzy"; print Ruzzy::UBSAN_PATH') \
    ruby harness.rb
```

Use UBSan for detecting:
- Signed integer overflow
- Null pointer dereferences
- Misaligned memory access
- Division by zero

### Common Sanitizer Issues

| Issue | Solution |
|-------|----------|
| Ruby interpreter leak warnings | Use `ASAN_OPTIONS=detect_leaks=0` |
| Sigaltstack conflicts | Use `ASAN_OPTIONS=use_sigaltstack=0` |
| Allocation failure spam | Use `ASAN_OPTIONS=allocator_may_return_null=1` |
| LD_PRELOAD interferes with tools | Don't export it; set inline with ruby command |

> **See Also:** For detailed sanitizer configuration, common issues, and advanced flags,
> see the **address-sanitizer** and **undefined-behavior-sanitizer** technique skills.

## Real-World Examples

### Example: msgpack-ruby

Fuzzing the msgpack MessagePack parser for memory corruption.

**Install with sanitizers:**

```bash
MAKE="make --environment-overrides V=1" \
CC="/path/to/clang" \
CXX="/path/to/clang++" \
LDSHARED="/path/to/clang -shared" \
LDSHAREDXX="/path/to/clang++ -shared" \
CFLAGS="-fsanitize=address,fuzzer-no-link -fno-omit-frame-pointer -fno-common -fPIC -g" \
CXXFLAGS="-fsanitize=address,fuzzer-no-link -fno-omit-frame-pointer -fno-common -fPIC -g" \
    gem install msgpack
```

**Harness (`fuzz_msgpack.rb`):**

```ruby
# frozen_string_literal: true

require 'msgpack'
require 'ruzzy'

test_one_input = lambda do |data|
  begin
    MessagePack.unpack(data)
  rescue Exception
    # We're looking for memory corruption, not Ruby exceptions
  end
  return 0
end

Ruzzy.fuzz(test_one_input)
```

**Run:**

```bash
export ASAN_OPTIONS="allocator_may_return_null=1:detect_leaks=0:use_sigaltstack=0"
LD_PRELOAD=$(ruby -e 'require "ruzzy"; print Ruzzy::ASAN_PATH') \
    ruby fuzz_msgpack.rb
```

### Example: Pure Ruby Target

Fuzzing pure Ruby code with a custom parser.

**Tracer (`test_tracer.rb`):**

```ruby
# frozen_string_literal: true

require 'ruzzy'

Ruzzy.trace('test_harness.rb')
```

**Harness (`test_harness.rb`):**

```ruby
# frozen_string_literal: true

require 'ruzzy'
require_relative 'my_parser'

test_one_input = lambda do |data|
  begin
    MyParser.parse(data)
  rescue StandardError
    # Expected exceptions from malformed input
  end
  return 0
end

Ruzzy.fuzz(test_one_input)
```

**Run:**

```bash
export ASAN_OPTIONS="allocator_may_return_null=1:detect_leaks=0:use_sigaltstack=0"
LD_PRELOAD=$(ruby -e 'require "ruzzy"; print Ruzzy::ASAN_PATH') \
    ruby test_tracer.rb
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Installation fails | Wrong clang version or path | Verify clang path, use clang 14.0.0+ |
| `cannot open shared object file` | LD_PRELOAD not set | Set LD_PRELOAD inline with ruby command |
| Fuzzer immediately exits | Missing corpus directory | Create corpus directory or pass as argument |
| No coverage progress | Pure Ruby needs tracer | Use tracer script for pure Ruby code |
| Leak detection spam | Ruby interpreter leaks | Set `ASAN_OPTIONS=detect_leaks=0` |
| Installation debug needed | Compilation errors | Use `RUZZY_DEBUG=1 gem install --verbose ruzzy` |

## Related Skills

### Technique Skills

| Skill | Use Case |
|-------|----------|
| **fuzz-harness-writing** | Detailed guidance on writing effective harnesses |
| **address-sanitizer** | Memory error detection during fuzzing |
| **undefined-behavior-sanitizer** | Detecting undefined behavior in C extensions |
| **libfuzzer** | Understanding libFuzzer options (Ruzzy is built on libFuzzer) |

### Related Fuzzers

| Skill | When to Consider |
|-------|------------------|
| **libfuzzer** | When fuzzing Ruby C extension code directly in C/C++ |
| **aflpp** | Alternative approach for fuzzing Ruby by instrumenting Ruby interpreter |

## Resources

### Key External Resources

**[Introducing Ruzzy, a coverage-guided Ruby fuzzer](https://blog.trailofbits.com/2024/03/29/introducing-ruzzy-a-coverage-guided-ruby-fuzzer/)**
Official Trail of Bits blog post announcing Ruzzy, covering motivation, architecture, and initial results.

**[Ruzzy GitHub Repository](https://github.com/trailofbits/ruzzy)**
Source code, additional examples, and development instructions.

**[libFuzzer Documentation](https://llvm.org/docs/LibFuzzer.html)**
Since Ruzzy is built on libFuzzer, understanding libFuzzer options and behavior is valuable.

**[Fuzzing Ruby C extensions](https://github.com/trailofbits/ruzzy#fuzzing-ruby-c-extensions)**
Detailed guide on fuzzing C extensions with compilation flags and examples.

**[Fuzzing pure Ruby code](https://github.com/trailofbits/ruzzy#fuzzing-pure-ruby-code)**
Detailed guide on the tracer pattern required for pure Ruby fuzzing.

# semgrep

# Semgrep

Semgrep is a highly efficient static analysis tool for finding low-complexity bugs and locating specific code patterns. Because of its ease of use, no need to build the code, multiple built-in rules, and convenient creation of custom rules, it is usually the first tool to run on an audited codebase. Furthermore, Semgrep's integration into the CI/CD pipeline makes it a good choice for ensuring code quality.

**Key benefits:**
- Prevents re-entry of known bugs and security vulnerabilities
- Enables large-scale code refactoring, such as upgrading deprecated APIs
- Easily added to CI/CD pipelines
- Custom Semgrep rules mimic the semantics of actual code
- Allows for secure scanning without sharing code with third parties
- Scanning usually takes minutes (not hours/days)
- Easy to use and accessible for both developers and security professionals

## When to Use

**Use Semgrep when:**
- Looking for bugs with easy-to-identify patterns
- Analyzing single files (intraprocedural analysis)
- Detecting systemic bugs (multiple instances across codebase)
- Enforcing secure defaults and code standards
- Performing rapid initial security assessment
- Scanning code without building it first

**Consider alternatives when:**
- Multiple files are required for analysis → Consider Semgrep Pro Engine or CodeQL
- Complex flow analysis is needed → Consider CodeQL
- Advanced taint tracking across files → Consider CodeQL or Semgrep Pro
- Custom in-house framework analysis → May need specialized tooling

## Quick Reference

| Task | Command |
|------|---------|
| Scan with auto-detection | `semgrep --config auto` |
| Scan with specific ruleset | `semgrep --config="p/trailofbits"` |
| Scan with custom rules | `semgrep -f /path/to/rules` |
| Output to SARIF format | `semgrep -c p/default --sarif --output scan.sarif` |
| Test custom rules | `semgrep --test` |
| Disable metrics | `semgrep --metrics=off --config=auto` |
| Filter by severity | `semgrep --config=auto --severity ERROR` |
| Show dataflow traces | `semgrep --dataflow-traces -f rule.yml` |

## Installation

### Prerequisites

- Python 3.7 or later (for pip installation)
- macOS, Linux, or Windows
- Homebrew (optional, for macOS/Linux)

### Install Steps

**Via Python Package Installer:**

```bash
python3 -m pip install semgrep
```

**Via Homebrew (macOS/Linux):**

```bash
brew install semgrep
```

**Via Docker:**

```bash
docker pull returntocorp/semgrep
```

### Keeping Semgrep Updated

```bash
# Check current version
semgrep --version

# Update via pip
python3 -m pip install --upgrade semgrep

# Update via Homebrew
brew upgrade semgrep
```

### Verification

```bash
semgrep --version
```

## Core Workflow

### Step 1: Initial Scan

Start with an auto-configuration scan to evaluate Semgrep's effectiveness:

```bash
semgrep --config auto
```

**Important:** Auto mode submits metrics online. To disable:

```bash
export SEMGREP_SEND_METRICS=off
# OR
semgrep --metrics=off --config auto
```

### Step 2: Select Targeted Rulesets

Use the [Semgrep Registry](https://semgrep.dev/explore) to select rulesets:

```bash
# Security-focused rulesets
semgrep --config="p/trailofbits"
semgrep --config="p/cwe-top-25"
semgrep --config="p/owasp-top-ten"

# Language-specific
semgrep --config="p/javascript"

# Multiple rulesets
semgrep --config="p/trailofbits" --config="p/r2c-security-audit"
```

### Step 3: Review and Triage Results

Filter results by severity:

```bash
semgrep --config=auto --severity ERROR
```

Use output formats for easier analysis:

```bash
# SARIF for VS Code SARIF Explorer
semgrep -c p/default --sarif --output scan.sarif

# JSON for automation
semgrep -c p/default --json --output scan.json
```

### Step 4: Configure Ignored Files

Create `.semgrepignore` file to exclude paths:

```
# Ignore specific files/directories
path/to/ignore/file.ext
path_to_ignore/

# Ignore by extension
*.ext

# Include .gitignore patterns
:include .gitignore
```

**Note:** By default, Semgrep skips `/tests`, `/test`, and `/vendors` folders.

## How to Customize

### Writing Custom Rules

Semgrep rules are YAML files with pattern-matching syntax. Basic structure:

```yaml
rules:
  - id: rule-id
    languages: [go]
    message: Some message
    severity: ERROR # INFO / WARNING / ERROR
    pattern: test(...)
```

### Running Custom Rules

```bash
# Single file
semgrep --config custom_rule.yaml

# Directory of rules
semgrep --config path/to/rules/
```

### Key Syntax Reference

| Syntax/Operator | Description | Example |
|-----------------|-------------|---------|
| `...` | Match zero or more arguments/statements | `func(..., arg=value, ...)` |
| `$X`, `$VAR` | Metavariable (captures and tracks values) | `$FUNC($INPUT)` |
| `<... ...>` | Deep expression operator (nested matching) | `if <... user.is_admin() ...>:` |
| `pattern-inside` | Match only within context | Pattern inside a loop |
| `pattern-not` | Exclude specific patterns | Negative matching |
| `pattern-either` | Logical OR (any pattern matches) | Multiple alternatives |
| `patterns` | Logical AND (all patterns match) | Combined conditions |
| `metavariable-pattern` | Nested metavariable constraints | Constrain captured values |
| `metavariable-comparison` | Compare metavariable values | `$X > 1337` |

### Example: Detecting Insecure Request Verification

```yaml
rules:
  - id: requests-verify-false
    languages: [python]
    message: requests.get with verify=False disables SSL verification
    severity: WARNING
    pattern: requests.get(..., verify=False, ...)
```

### Example: Taint Mode for SQL Injection

```yaml
rules:
  - id: sql-injection
    mode: taint
    pattern-sources:
      - pattern: request.args.get(...)
    pattern-sinks:
      - pattern: cursor.execute($QUERY)
    pattern-sanitizers:
      - pattern: int(...)
    message: Potential SQL injection with unsanitized user input
    languages: [python]
    severity: ERROR
```

### Testing Custom Rules

Create test files with annotations:

```python
# ruleid: requests-verify-false
requests.get(url, verify=False)

# ok: requests-verify-false
requests.get(url, verify=True)
```

Run tests:

```bash
semgrep --test ./path/to/rules/
```

For autofix testing, create `.fixed` files (e.g., `test.py` → `test.fixed.py`):

```bash
semgrep --test
# Output: 1/1: ✓ All tests passed
#         1/1: ✓ All fix tests passed
```

## Configuration

### Configuration File

Semgrep doesn't require a central config file. Configuration is done via:
- Command-line flags
- Environment variables
- `.semgrepignore` for path exclusions

### Ignore Patterns

Create `.semgrepignore` in repository root:

```
# Ignore directories
tests/
vendor/
node_modules/

# Ignore file types
*.min.js
*.generated.go

# Include .gitignore patterns
:include .gitignore
```

### Suppressing False Positives

Add inline comments to suppress specific findings:

```python
# nosemgrep: rule-id
risky_function()
```

**Best practices:**
- Specify the exact rule ID (not generic `# nosemgrep`)
- Explain why the rule is disabled
- Report false positives to improve rules

### Metadata in Custom Rules

Include metadata for better context:

```yaml
rules:
  - id: example-rule
    metadata:
      cwe: "CWE-89"
      confidence: HIGH
      likelihood: MEDIUM
      impact: HIGH
      subcategory: vuln
    # ... rest of rule
```

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| Use `--time` flag | Identifies slow rules and files for optimization |
| Limit ellipsis usage | Reduces false positives and improves performance |
| Use `pattern-inside` for context | Creates clearer, more focused findings |
| Enable autocomplete | Speeds up command-line workflow |
| Use `focus-metavariable` | Highlights specific code locations in output |

### Scanning Non-Standard Extensions

Force language interpretation for unusual file extensions:

```bash
semgrep --config=/path/to/config --lang python --scan-unknown-extensions /path/to/file.xyz
```

### Dataflow Tracing

Use `--dataflow-traces` to understand how values flow to findings:

```bash
semgrep --dataflow-traces -f taint_rule.yml test.py
```

Example output:

```
Taint comes from:
  test.py
    2┆ data = get_user_input()

This is how taint reaches the sink:
  test.py
    3┆ return output(data)
```

### Polyglot File Scanning

Scan embedded languages (e.g., JavaScript in HTML):

```yaml
rules:
  - id: eval-in-html
    languages: [html]
    message: eval in JavaScript
    patterns:
      - pattern: <script ...>$Y</script>
      - metavariable-pattern:
          metavariable: $Y
          language: javascript
          patterns:
            - pattern: eval(...)
    severity: WARNING
```

### Constant Propagation

Match instances where metavariables hold specific values:

```yaml
rules:
  - id: high-value-check
    languages: [python]
    message: $X is higher than 1337
    patterns:
      - pattern: function($X)
      - metavariable-comparison:
          metavariable: $X
          comparison: $X > 1337
    severity: WARNING
```

### Autofix Feature

Add automatic fixes to rules:

```yaml
rules:
  - id: ioutil-readdir-deprecated
    languages: [golang]
    message: ioutil.ReadDir is deprecated. Use os.ReadDir instead.
    severity: WARNING
    pattern: ioutil.ReadDir($X)
    fix: os.ReadDir($X)
```

Preview fixes without applying:

```bash
semgrep -f rule.yaml --dryrun --autofix
```

Apply fixes:

```bash
semgrep -f rule.yaml --autofix
```

### Performance Optimization

Analyze performance:

```bash
semgrep --config=auto --time
```

Optimize rules:
1. Use `paths` to narrow file scope
2. Minimize ellipsis usage
3. Use `pattern-inside` to establish context first
4. Remove unnecessary metavariables

### Managing Third-Party Rules

Use [semgrep-rules-manager](https://github.com/iosifache/semgrep-rules-manager/) to collect third-party rules:

```bash
pip install semgrep-rules-manager
mkdir -p $HOME/custom-semgrep-rules
semgrep-rules-manager --dir $HOME/custom-semgrep-rules download
semgrep -f $HOME/custom-semgrep-rules
```

## CI/CD Integration

### GitHub Actions

#### Recommended Approach

1. Full scan on main branch with broad rulesets (scheduled)
2. Diff-aware scanning for pull requests with focused rules
3. Block PRs with unresolved findings (once mature)

#### Example Workflow

```yaml
name: Semgrep
on:
  pull_request: {}
  push:
    branches: ["master", "main"]
  schedule:
    - cron: '0 0 1 * *' # Monthly

jobs:
  semgrep-schedule:
    if: ((github.event_name == 'schedule' || github.event_name == 'push' || github.event.pull_request.merged == true)
        && github.actor != 'dependabot[bot]')
    name: Semgrep default scan
    runs-on: ubuntu-latest
    container:
      image: returntocorp/semgrep
    steps:
      - name: Checkout main repository
        uses: actions/checkout@v4
      - run: semgrep ci
        env:
          SEMGREP_RULES: p/default

  semgrep-pr:
    if: (github.event_name == 'pull_request' && github.actor != 'dependabot[bot]')
    name: Semgrep PR scan
    runs-on: ubuntu-latest
    container:
      image: returntocorp/semgrep
    steps:
      - uses: actions/checkout@v4
      - run: semgrep ci
        env:
          SEMGREP_RULES: >
            p/cwe-top-25
            p/owasp-top-ten
            p/r2c-security-audit
            p/trailofbits
```

#### Adding Custom Rules in CI

**Rules in same repository:**

```yaml
env:
  SEMGREP_RULES: p/default custom-semgrep-rules-dir/
```

**Rules in private repository:**

```yaml
env:
  SEMGREP_PRIVATE_RULES_REPO: semgrep-private-rules
steps:
  - name: Checkout main repository
    uses: actions/checkout@v4
  - name: Checkout private custom Semgrep rules
    uses: actions/checkout@v4
    with:
      repository: ${{ github.repository_owner }}/${{ env.SEMGREP_PRIVATE_RULES_REPO }}
      token: ${{ secrets.SEMGREP_RULES_TOKEN }}
      path: ${{ env.SEMGREP_PRIVATE_RULES_REPO }}
  - run: semgrep ci
    env:
      SEMGREP_RULES: ${{ env.SEMGREP_PRIVATE_RULES_REPO }}
```

### Testing Rules in CI

```yaml
name: Test Semgrep rules

on: [push, pull_request]

jobs:
  semgrep-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: "3.11"
          cache: "pip"
      - run: python -m pip install -r requirements.txt
      - run: semgrep --test --test-ignore-todo ./path/to/rules/
```

## Common Mistakes

| Mistake | Why It's Wrong | Correct Approach |
|---------|----------------|------------------|
| Using `--config auto` on private code | Sends metadata to Semgrep servers | Use `--metrics=off` or specific rulesets |
| Forgetting `.semgrepignore` | Scans excluded directories like `/vendor` | Create `.semgrepignore` file |
| Not testing rules with false positives | Rules generate noise | Add `# ok:` test cases |
| Using generic `# nosemgrep` | Makes code review harder | Use `# nosemgrep: rule-id` with explanation |
| Overusing ellipsis `...` | Degrades performance and accuracy | Use specific patterns when possible |
| Not including metadata in rules | Makes triage difficult | Add CWE, confidence, impact fields |

## Limitations

- **Single-file analysis:** Cannot track data flow across files without Semgrep Pro Engine
- **No build required:** Cannot analyze compiled code or resolve dynamic dependencies
- **Pattern-based:** May miss vulnerabilities requiring deep semantic understanding
- **Limited taint tracking:** Complex taint analysis is still evolving
- **Custom frameworks:** In-house proprietary frameworks may not be well-supported

## Related Skills

| Skill | When to Use Together |
|-------|---------------------|
| **codeql** | For cross-file taint tracking and complex data flow analysis |
| **sarif-parsing** | For processing Semgrep SARIF output in pipelines |

## Resources

### Key External Resources

**[Trail of Bits public Semgrep rules](https://github.com/trailofbits/semgrep-rules)**
Community-contributed Semgrep rules for security audits, with contribution guidelines and quality standards.

**[Semgrep Registry](https://semgrep.dev/explore)**
Official registry of Semgrep rules, searchable by language, framework, and security category.

**[Semgrep Playground](https://semgrep.dev/playground/new)**
Interactive online tool for writing and testing Semgrep rules. Use "simple mode" for easy pattern combination.

**[Learn Semgrep Syntax](https://semgrep.dev/learn)**
Comprehensive guide on Semgrep rule-writing fundamentals.

**[Trail of Bits Blog: How to introduce Semgrep to your organization](https://blog.trailofbits.com/2024/01/12/how-to-introduce-semgrep-to-your-organization/)**
Seven-step plan for organizational adoption of Semgrep, including pilot testing, evangelization, and CI/CD integration.

**[Trail of Bits Blog: Discovering goroutine leaks with Semgrep](https://blog.trailofbits.com/2021/11/08/discovering-goroutine-leaks-with-semgrep/)**
Real-world example of writing custom rules to detect Go-specific issues.

### Video Resources

- [Introduction to Semgrep - Trail of Bits Webinar](https://www.youtube.com/watch?v=yKQlTbVlf0Q)
- [Detect complex code patterns using semantic grep](https://www.youtube.com/watch?v=IFRp2Y3cqOw)
- [Semgrep part 1 - Embrace Secure Defaults, Block Anti-patterns and more](https://www.youtube.com/watch?v=EIjoqwT53E4)
- [Semgrep Weekly Wednesday Office Hours: Modifying Rules to Reduce False Positives](https://www.youtube.com/watch?v=VSL44ZZ7EvY)
- [Raining CVEs On WordPress Plugins With Semgrep | Nullcon Goa 2022](https://www.youtube.com/watch?v=RvKLn2ofMAo)

# testing-handbook-generator

# Testing Handbook Skill Generator

Generate and maintain Claude Code skills from the Trail of Bits Testing Handbook.

## When to Use

**Invoke this skill when:**
- Creating new security testing skills from handbook content
- User mentions "testing handbook", "appsec.guide", or asks about generating skills
- Bulk skill generation or refresh is needed

**Do NOT use for:**
- General security testing questions (use the generated skills)
- Non-handbook skill creation

## Handbook Location

The skill needs the Testing Handbook repository. See [discovery.md](discovery.md) for full details.

**Quick reference:** Check `./testing-handbook`, `../testing-handbook`, `~/testing-handbook` → ask user → clone as last resort.

**Repository:** `https://github.com/trailofbits/testing-handbook`

## Workflow Overview

```
Phase 0: Setup              Phase 1: Discovery
┌─────────────────┐        ┌─────────────────┐
│ Locate handbook │   →    │ Analyze handbook│
│ - Find or clone │        │ - Scan sections │
│ - Confirm path  │        │ - Classify types│
└─────────────────┘        └─────────────────┘
         ↓                          ↓
Phase 3: Generation        Phase 2: Planning
┌─────────────────┐        ┌─────────────────┐
│ TWO-PASS GEN    │   ←    │ Generate plan   │
│ Pass 1: Content │        │ - New skills    │
│ Pass 2: X-refs  │        │ - Updates       │
│ - Write to gen/ │        │ - Present user  │
└─────────────────┘        └─────────────────┘
         ↓
Phase 4: Testing           Phase 5: Finalize
┌─────────────────┐        ┌─────────────────┐
│ Validate skills │   →    │ Post-generation │
│ - Run validator │        │ - Update README │
│ - Test activation│       │ - Update X-refs │
│ - Fix issues    │        │ - Self-improve  │
└─────────────────┘        └─────────────────┘
```

## Scope Restrictions

**ONLY modify these locations:**
- `plugins/testing-handbook-skills/skills/[skill-name]/*` - Generated skills (as siblings to testing-handbook-generator)
- `plugins/testing-handbook-skills/skills/testing-handbook-generator/*` - Self-improvement
- Repository root `README.md` - Add generated skills to table

**NEVER modify or analyze:**
- Other plugins (`plugins/property-based-testing/`, `plugins/static-analysis/`, etc.)
- Other skills outside this plugin

Do not scan or pull into context any skills outside of `testing-handbook-skills/`. Generate skills based solely on handbook content and resources referenced from it.

## Quick Reference

### Section → Skill Type Mapping

| Handbook Section | Skill Type | Template |
|------------------|------------|----------|
| `/static-analysis/[tool]/` | Tool Skill | tool-skill.md |
| `/fuzzing/[lang]/[fuzzer]/` | Fuzzer Skill | fuzzer-skill.md |
| `/fuzzing/techniques/` | Technique Skill | technique-skill.md |
| `/crypto/[tool]/` | Domain Skill | domain-skill.md |
| `/web/[tool]/` | Tool Skill | tool-skill.md |

### Skill Candidate Signals

| Signal | Indicates |
|--------|-----------|
| `_index.md` with `bookCollapseSection: true` | Major tool/topic |
| Numbered files (00-, 10-, 20-) | Structured content |
| `techniques/` subsection | Methodology content |
| `99-resources.md` or `91-resources.md` | Has external links |

### Exclusion Signals

| Signal | Action |
|--------|--------|
| `draft: true` in frontmatter | Skip section |
| Empty directory | Skip section |
| Template/placeholder file | Skip section |
| GUI-only tool (e.g., `web/burp/`) | Skip section (Claude cannot operate GUI tools) |

## Decision Tree

**Starting skill generation?**

```
├─ Need to analyze handbook and build plan?
│  └─ Read: discovery.md
│     (Handbook analysis methodology, plan format)
│
├─ Spawning skill generation agents?
│  └─ Read: agent-prompt.md
│     (Full prompt template, variable reference, validation checklist)
│
├─ Generating a specific skill type?
│  └─ Read appropriate template:
│     ├─ Tool (Semgrep, CodeQL) → templates/tool-skill.md
│     ├─ Fuzzer (libFuzzer, AFL++) → templates/fuzzer-skill.md
│     ├─ Technique (harness, coverage) → templates/technique-skill.md
│     └─ Domain (crypto, web) → templates/domain-skill.md
│
├─ Validating generated skills?
│  └─ Run: scripts/validate-skills.py
│     Then read: testing.md for activation testing
│
├─ Finalizing after generation?
│  └─ See: Post-Generation Tasks below
│     (Update main README, update Skills Cross-Reference, self-improvement)
│
└─ Quick generation from specific section?
   └─ Use Quick Reference above, apply template directly
```

## Two-Pass Generation (Phase 3)

Generation uses a **two-pass approach** to solve forward reference problems (skills referencing other skills that don't exist yet).

### Pass 1: Content Generation (Parallel)

Generate all skills in parallel **without** the Related Skills section:

```
Pass 1 - Generating 5 skills in parallel:
├─ Agent 1: libfuzzer (fuzzer) → skills/libfuzzer/SKILL.md
├─ Agent 2: aflpp (fuzzer) → skills/aflpp/SKILL.md
├─ Agent 3: semgrep (tool) → skills/semgrep/SKILL.md
├─ Agent 4: harness-writing (technique) → skills/harness-writing/SKILL.md
└─ Agent 5: wycheproof (domain) → skills/wycheproof/SKILL.md

Each agent uses: pass=1 (content only, Related Skills left empty)
```

**Pass 1 agents:**
- Generate all sections EXCEPT Related Skills
- Leave a placeholder: `## Related Skills\n\n<!-- PASS2: populate after all skills exist -->`
- Output report includes `references: DEFERRED`

### Pass 2: Cross-Reference Population (Sequential)

After all Pass 1 agents complete, run Pass 2 to populate Related Skills:

```
Pass 2 - Populating cross-references:
├─ Read all generated skill names from skills/*/SKILL.md
├─ For each skill, determine related skills based on:
│   ├─ related_sections from discovery (handbook structure)
│   ├─ Skill type relationships (fuzzers → techniques)
│   └─ Explicit mentions in content
└─ Update each SKILL.md's Related Skills section
```

**Pass 2 process:**
1. Collect all generated skill names: `ls -d skills/*/SKILL.md`
2. For each skill, identify related skills using the mapping from discovery
3. Edit each SKILL.md to replace the placeholder with actual links
4. Validate cross-references exist (no broken links)

### Agent Prompt Template

See **[agent-prompt.md](agent-prompt.md)** for the full prompt template with:
- Variable substitution reference (including `pass` variable)
- Pre-write validation checklist
- Hugo shortcode conversion rules
- Line count splitting rules
- Error handling guidance
- Output report format

### Collecting Results

After Pass 1: Aggregate output reports, verify all skills generated.
After Pass 2: Run validator to check cross-references.

### Handling Agent Failures

If an agent fails or produces invalid output:

| Failure Type | Detection | Recovery Action |
|--------------|-----------|-----------------|
| Agent crashed | No output report | Re-run single agent with same inputs |
| Validation failed | Output report shows errors | Check gaps/warnings, manually patch or re-run |
| Wrong skill type | Content doesn't match template | Re-run with corrected `type` parameter |
| Missing content | Output report lists gaps | Accept if minor, or provide additional `related_sections` |
| Pass 2 broken ref | Validator shows missing skill | Check if skill was skipped, update reference |

**Important:** Do NOT re-run the entire parallel batch for a single agent failure. Fix individual failures independently.

### Single-Skill Regeneration

To regenerate a single skill without re-running the entire batch:

```
# Regenerate single skill (Pass 1 - content only)
"Use testing-handbook-generator to regenerate the {skill-name} skill from section {section_path}"

# Example:
"Use testing-handbook-generator to regenerate the libfuzzer skill from section fuzzing/c-cpp/10-libfuzzer"
```

**Regeneration workflow:**
1. Re-read the handbook section for fresh content
2. Apply the appropriate template
3. Write to `skills/{skill-name}/SKILL.md` (overwrites existing)
4. Re-run Pass 2 for that skill only to update cross-references
5. Run validator on the single skill: `uv run scripts/validate-skills.py --skill {skill-name}`

## Output Location

Generated skills are written to:
```
skills/[skill-name]/SKILL.md
```

Each skill gets its own directory for potential supporting files (as siblings to testing-handbook-generator).

## Quality Checklist

Before delivering generated skills:

- [ ] All handbook sections analyzed (Phase 1)
- [ ] Plan presented to user before generation (Phase 2)
- [ ] Parallel agents launched - one per skill (Phase 3)
- [ ] Templates applied correctly per skill type
- [ ] Validator passes: `uv run scripts/validate-skills.py`
- [ ] Activation testing passed - see [testing.md](testing.md)
- [ ] Main `README.md` updated with generated skills table
- [ ] `README.md` Skills Cross-Reference graph updated
- [ ] Self-improvement notes captured
- [ ] User notified with summary

## Post-Generation Tasks

### 1. Update Main README

After generating skills, update the repository's main `README.md` to list them.

**Format:** Add generated skills to the same "Available Plugins" table, directly after `testing-handbook-skills`. Use plain text `testing-handbook-generator` as the author (no link).

**Example:**

```markdown
| Plugin | Description | Author |
|--------|-------------|--------|
| ... other plugins ... |
| [testing-handbook-skills](plugins/testing-handbook-skills/) | Meta-skill that generates skills from the Testing Handbook | Paweł Płatek |
| [libfuzzer](plugins/testing-handbook-skills/skills/libfuzzer/) | Coverage-guided fuzzing with libFuzzer for C/C++ | testing-handbook-generator |
| [aflpp](plugins/testing-handbook-skills/skills/aflpp/) | Multi-core fuzzing with AFL++ | testing-handbook-generator |
| [semgrep](plugins/testing-handbook-skills/skills/semgrep/) | Fast static analysis for finding bugs | testing-handbook-generator |
```

### 2. Update Skills Cross-Reference

After generating skills, update the `README.md`'s **Skills Cross-Reference** section with the mermaid graph showing skill relationships.

**Process:**
1. Read each generated skill's `SKILL.md` and extract its `## Related Skills` section
2. Build the mermaid graph with nodes grouped by skill type (Fuzzers, Techniques, Tools, Domain)
3. Add edges based on the Related Skills relationships:
   - Solid arrows (`-->`) for primary technique dependencies
   - Dashed arrows (`-.->`) for alternative tool suggestions
4. Replace the existing mermaid code block in README.md

**Edge classification:**
| Relationship | Arrow Style | Example |
|--------------|-------------|---------|
| Fuzzer → Technique | `-->` | `libfuzzer --> harness-writing` |
| Tool → Tool (alternative) | `-.->` | `semgrep -.-> codeql` |
| Fuzzer → Fuzzer (alternative) | `-.->` | `libfuzzer -.-> aflpp` |
| Technique → Technique | `-->` | `harness-writing --> coverage-analysis` |

**Validation:** After updating, run `validate-skills.py` to verify all referenced skills exist.

### 3. Self-Improvement

After each generation run, reflect on what could improve future runs.

**Capture improvements to:**
- Templates (missing sections, better structure)
- Discovery logic (missed patterns, false positives)
- Content extraction (shortcodes not handled, formatting issues)

**Update process:**
1. Note issues encountered during generation
2. Identify patterns that caused problems
3. Update relevant files:
   - `SKILL.md` - Workflow, decision tree, quick reference updates
   - `templates/*.md` - Template improvements
   - `discovery.md` - Detection logic updates
   - `testing.md` - New validation checks
4. Document the improvement in commit message

**Example self-improvement:**
```
Issue: libFuzzer skill missing sanitizer flags table
Fix: Updated templates/fuzzer-skill.md to include ## Compiler Flags section
```

## Example Usage

### Full Discovery and Generation

```
User: "Generate skills from the testing handbook"

1. Locate handbook (check common locations, ask user, or clone)
2. Read discovery.md for methodology
3. Scan handbook at {handbook_path}/content/docs/
4. Build candidate list with types
5. Present plan to user
6. On approval, generate each skill using appropriate template
7. Validate generated skills
8. Update main README.md with generated skills table
9. Update README.md Skills Cross-Reference graph from Related Skills sections
10. Self-improve: note any template/discovery issues for future runs
11. Report results
```

### Single Section Generation

```
User: "Create a skill for the libFuzzer section"

1. Read /testing-handbook/content/docs/fuzzing/c-cpp/10-libfuzzer/
2. Identify type: Fuzzer Skill
3. Read templates/fuzzer-skill.md
4. Extract content, apply template
5. Write to skills/libfuzzer/SKILL.md
6. Validate and report
```

## Tips

**Do:**
- Always present plan before generating
- Use appropriate template for skill type
- Preserve code blocks exactly
- Validate after generation

**Don't:**
- Generate without user approval
- Skip fetching non-video external resources (use WebFetch)
- Fetch video URLs (YouTube, Vimeo - titles only)
- Include handbook images directly
- Skip validation step
- Exceed 500 lines per SKILL.md

---

**For first-time use:** Start with [discovery.md](discovery.md) to understand the handbook analysis process.

**For template reference:** See [templates/](templates/) directory for skill type templates.

**For validation:** See [testing.md](testing.md) for quality assurance methodology.

# wycheproof

# Wycheproof

Wycheproof is an extensive collection of test vectors designed to verify the correctness of cryptographic implementations and test against known attacks. Originally developed by Google, it is now a community-managed project where contributors can add test vectors for specific cryptographic constructions.

## Background

### Key Concepts

| Concept | Description |
|---------|-------------|
| Test vector | Input/output pair for validating crypto implementation correctness |
| Test group | Collection of test vectors sharing attributes (key size, IV size, curve) |
| Result flag | Indicates if test should pass (valid), fail (invalid), or is acceptable |
| Edge case testing | Testing for known vulnerabilities and attack patterns |

### Why This Matters

Cryptographic implementations are notoriously difficult to get right. Even small bugs can:
- Expose private keys
- Allow signature forgery
- Enable message decryption
- Create consensus problems when different implementations accept/reject the same inputs

Wycheproof has found vulnerabilities in major libraries including OpenJDK's SHA1withDSA, Bouncy Castle's ECDHC, and the elliptic npm package.

## When to Use

**Apply Wycheproof when:**
- Testing cryptographic implementations (AES-GCM, ECDSA, ECDH, RSA, etc.)
- Validating that crypto code handles edge cases correctly
- Verifying implementations against known attack vectors
- Setting up CI/CD for cryptographic libraries
- Auditing third-party crypto code for correctness

**Consider alternatives when:**
- Testing for timing side-channels (use constant-time testing tools instead)
- Finding new unknown bugs (use fuzzing instead)
- Testing custom/experimental cryptographic algorithms (Wycheproof only covers established algorithms)

## Quick Reference

| Scenario | Recommended Approach | Notes |
|----------|---------------------|-------|
| AES-GCM implementation | Use `aes_gcm_test.json` | 316 test vectors across 44 test groups |
| ECDSA verification | Use `ecdsa_*_test.json` for specific curves | Tests signature malleability, DER encoding |
| ECDH key exchange | Use `ecdh_*_test.json` | Tests invalid curve attacks |
| RSA signatures | Use `rsa_*_test.json` | Tests padding oracle attacks |
| ChaCha20-Poly1305 | Use `chacha20_poly1305_test.json` | Tests AEAD implementation |

## Testing Workflow

```
Phase 1: Setup                 Phase 2: Parse Test Vectors
┌─────────────────┐          ┌─────────────────┐
│ Add Wycheproof  │    →     │ Load JSON file  │
│ as submodule    │          │ Filter by params│
└─────────────────┘          └─────────────────┘
         ↓                            ↓
Phase 4: CI Integration        Phase 3: Write Harness
┌─────────────────┐          ┌─────────────────┐
│ Auto-update     │    ←     │ Test valid &    │
│ test vectors    │          │ invalid cases   │
└─────────────────┘          └─────────────────┘
```

## Repository Structure

The Wycheproof repository is organized as follows:

```text
┣ 📜 README.md       : Project overview
┣ 📂 doc             : Documentation
┣ 📂 java            : Java JCE interface testing harness
┣ 📂 javascript      : JavaScript testing harness
┣ 📂 schemas         : Test vector schemas
┣ 📂 testvectors     : Test vectors
┗ 📂 testvectors_v1  : Updated test vectors (more detailed)
```

The essential folders are `testvectors` and `testvectors_v1`. While both contain similar files, `testvectors_v1` includes more detailed information and is recommended for new integrations.

## Supported Algorithms

Wycheproof provides test vectors for a wide range of cryptographic algorithms:

| Category | Algorithms |
|----------|------------|
| **Symmetric Encryption** | AES-GCM, AES-EAX, ChaCha20-Poly1305 |
| **Signatures** | ECDSA, EdDSA, RSA-PSS, RSA-PKCS1 |
| **Key Exchange** | ECDH, X25519, X448 |
| **Hashing** | HMAC, HKDF |
| **Curves** | secp256k1, secp256r1, secp384r1, secp521r1, ed25519, ed448 |

## Test File Structure

Each JSON test file tests a specific cryptographic construction. All test files share common attributes:

```json
"algorithm"         : The name of the algorithm tested
"schema"            : The JSON schema (found in schemas folder)
"generatorVersion"  : The version number
"numberOfTests"     : The total number of test vectors in this file
"header"            : Detailed description of test vectors
"notes"             : In-depth explanation of flags in test vectors
"testGroups"        : Array of one or multiple test groups
```

### Test Groups

Test groups group sets of tests based on shared attributes such as:
- Key sizes
- IV sizes
- Public keys
- Curves

This classification allows extracting tests that meet specific criteria relevant to the construction being tested.

### Test Vector Attributes

#### Shared Attributes

All test vectors contain four common fields:

- **tcId**: Unique identifier for the test vector within a file
- **comment**: Additional information about the test case
- **flags**: Descriptions of specific test case types and potential dangers (referenced in `notes` field)
- **result**: Expected outcome of the test

The `result` field can take three values:

| Result | Meaning |
|--------|---------|
| **valid** | Test case should succeed |
| **acceptable** | Test case is allowed to succeed but contains non-ideal attributes |
| **invalid** | Test case should fail |

#### Unique Attributes

Unique attributes are specific to the algorithm being tested:

| Algorithm | Unique Attributes |
|-----------|-------------------|
| AES-GCM | `key`, `iv`, `aad`, `msg`, `ct`, `tag` |
| ECDH secp256k1 | `public`, `private`, `shared` |
| ECDSA | `msg`, `sig`, `result` |
| EdDSA | `msg`, `sig`, `pk` |

## Implementation Guide

### Phase 1: Add Wycheproof to Your Project

**Option 1: Git Submodule (Recommended)**

Adding Wycheproof as a git submodule ensures automatic updates:

```bash
git submodule add https://github.com/C2SP/wycheproof.git
```

**Option 2: Fetch Specific Test Vectors**

If submodules aren't possible, fetch specific JSON files:

```bash
#!/bin/bash

TMP_WYCHEPROOF_FOLDER=".wycheproof/"
TEST_VECTORS=('aes_gcm_test.json' 'aes_eax_test.json')
BASE_URL="https://raw.githubusercontent.com/C2SP/wycheproof/master/testvectors_v1/"

# Create wycheproof folder
mkdir -p $TMP_WYCHEPROOF_FOLDER

# Request all test vector files if they don't exist
for i in "${TEST_VECTORS[@]}"; do
  if [ ! -f "${TMP_WYCHEPROOF_FOLDER}${i}" ]; then
    curl -o "${TMP_WYCHEPROOF_FOLDER}${i}" "${BASE_URL}${i}"
    if [ $? -ne 0 ]; then
      echo "Failed to download ${i}"
      exit 1
    fi
  fi
done
```

### Phase 2: Parse Test Vectors

Identify the test file for your algorithm and parse the JSON:

**Python Example:**

```python
import json

def load_wycheproof_test_vectors(path: str):
    testVectors = []
    try:
        with open(path, "r") as f:
            wycheproof_json = json.loads(f.read())
    except FileNotFoundError:
        print(f"No Wycheproof file found at: {path}")
        return testVectors

    # Attributes that need hex-to-bytes conversion
    convert_attr = {"key", "aad", "iv", "msg", "ct", "tag"}

    for testGroup in wycheproof_json["testGroups"]:
        # Filter test groups based on implementation constraints
        if testGroup["ivSize"] < 64 or testGroup["ivSize"] > 1024:
            continue

        for tv in testGroup["tests"]:
            # Convert hex strings to bytes
            for attr in convert_attr:
                if attr in tv:
                    tv[attr] = bytes.fromhex(tv[attr])
            testVectors.append(tv)

    return testVectors
```

**JavaScript Example:**

```javascript
const fs = require('fs').promises;

async function loadWycheproofTestVectors(path) {
  const tests = [];

  try {
    const fileContent = await fs.readFile(path);
    const data = JSON.parse(fileContent.toString());

    data.testGroups.forEach(testGroup => {
      testGroup.tests.forEach(test => {
        // Add shared test group properties to each test
        test['pk'] = testGroup.publicKey.pk;
        tests.push(test);
      });
    });
  } catch (err) {
    console.error('Error reading or parsing file:', err);
    throw err;
  }

  return tests;
}
```

### Phase 3: Write Testing Harness

Create test functions that handle both valid and invalid test cases.

**Python/pytest Example:**

```python
import pytest
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

tvs = load_wycheproof_test_vectors("wycheproof/testvectors_v1/aes_gcm_test.json")

@pytest.mark.parametrize("tv", tvs, ids=[str(tv['tcId']) for tv in tvs])
def test_encryption(tv):
    try:
        aesgcm = AESGCM(tv['key'])
        ct = aesgcm.encrypt(tv['iv'], tv['msg'], tv['aad'])
    except ValueError as e:
        # Implementation raised error - verify test was expected to fail
        assert tv['result'] != 'valid', tv['comment']
        return

    if tv['result'] == 'valid':
        assert ct[:-16] == tv['ct'], f"Ciphertext mismatch: {tv['comment']}"
        assert ct[-16:] == tv['tag'], f"Tag mismatch: {tv['comment']}"
    elif tv['result'] == 'invalid' or tv['result'] == 'acceptable':
        assert ct[:-16] != tv['ct'] or ct[-16:] != tv['tag']

@pytest.mark.parametrize("tv", tvs, ids=[str(tv['tcId']) for tv in tvs])
def test_decryption(tv):
    try:
        aesgcm = AESGCM(tv['key'])
        decrypted_msg = aesgcm.decrypt(tv['iv'], tv['ct'] + tv['tag'], tv['aad'])
    except ValueError:
        assert tv['result'] != 'valid', tv['comment']
        return
    except InvalidTag:
        assert tv['result'] != 'valid', tv['comment']
        assert 'ModifiedTag' in tv['flags'], f"Expected 'ModifiedTag' flag: {tv['comment']}"
        return

    assert tv['result'] == 'valid', f"No invalid test case should pass: {tv['comment']}"
    assert decrypted_msg == tv['msg'], f"Decryption mismatch: {tv['comment']}"
```

**JavaScript/Mocha Example:**

```javascript
const assert = require('assert');

function testFactory(tcId, tests) {
  it(`[${tcId + 1}] ${tests[tcId].comment}`, function () {
    const test = tests[tcId];
    const ed25519 = new eddsa('ed25519');
    const key = ed25519.keyFromPublic(toArray(test.pk, 'hex'));

    let sig;
    if (test.result === 'valid') {
      sig = key.verify(test.msg, test.sig);
      assert.equal(sig, true, `[${test.tcId}] ${test.comment}`);
    } else if (test.result === 'invalid') {
      try {
        sig = key.verify(test.msg, test.sig);
      } catch (err) {
        // Point could not be decoded
        sig = false;
      }
      assert.equal(sig, false, `[${test.tcId}] ${test.comment}`);
    }
  });
}

// Generate tests for all test vectors
for (var tcId = 0; tcId < tests.length; tcId++) {
  testFactory(tcId, tests);
}
```

### Phase 4: CI Integration

Ensure test vectors stay up to date by:

1. **Using git submodules**: Update submodule in CI before running tests
2. **Fetching latest vectors**: Run fetch script before test execution
3. **Scheduled updates**: Set up weekly/monthly updates to catch new test vectors

## Common Vulnerabilities Detected

Wycheproof test vectors are designed to catch specific vulnerability patterns:

| Vulnerability | Description | Affected Algorithms | Example CVE |
|---------------|-------------|---------------------|-------------|
| Signature malleability | Multiple valid signatures for same message | ECDSA, EdDSA | CVE-2024-42459 |
| Invalid DER encoding | Accepting non-canonical DER signatures | ECDSA | CVE-2024-42460, CVE-2024-42461 |
| Invalid curve attacks | ECDH with invalid curve points | ECDH | Common in many libraries |
| Padding oracle | Timing leaks in padding validation | RSA-PKCS1 | Historical OpenSSL issues |
| Tag forgery | Accepting modified authentication tags | AES-GCM, ChaCha20-Poly1305 | Various implementations |

### Signature Malleability: Deep Dive

**Problem:** Implementations that don't validate signature encoding can accept multiple valid signatures for the same message.

**Example (EdDSA):** Appending or removing zeros from signature:
```text
Valid signature:   ...6a5c51eb6f946b30d
Invalid signature: ...6a5c51eb6f946b30d0000  (should be rejected)
```

**How to detect:**
```python
# Add signature length check
if len(sig) != 128:  # EdDSA signatures must be exactly 64 bytes (128 hex chars)
    return False
```

**Impact:** Can lead to consensus problems when different implementations accept/reject the same signatures.

**Related Wycheproof tests:**
- EdDSA: tcId 37 - "removing 0 byte from signature"
- ECDSA: tcId 06 - "Legacy: ASN encoding of r misses leading 0"

## Case Study: Elliptic npm Package

This case study demonstrates how Wycheproof found three CVEs in the popular elliptic npm package (3000+ dependents, millions of weekly downloads).

### Overview

The [elliptic](https://www.npmjs.com/package/elliptic) library is an elliptic-curve cryptography library written in JavaScript, supporting ECDH, ECDSA, and EdDSA. Using Wycheproof test vectors on version 6.5.6 revealed multiple vulnerabilities:

- **CVE-2024-42459**: EdDSA signature malleability (appending/removing zeros)
- **CVE-2024-42460**: ECDSA DER encoding - invalid bit placement
- **CVE-2024-42461**: ECDSA DER encoding - leading zero in length field

### Methodology

1. **Identify supported curves**: ed25519 for EdDSA
2. **Find test vectors**: `testvectors_v1/ed25519_test.json`
3. **Parse test vectors**: Load JSON and extract tests
4. **Write test harness**: Create parameterized tests
5. **Run tests**: Identify failures
6. **Analyze root causes**: Examine implementation code
7. **Propose fixes**: Add validation checks

### Key Findings

**EdDSA Issue (CVE-2024-42459):**
- Missing signature length validation
- Allowed trailing zeros in signatures
- Fix: Add `if(sig.length !== 128) return false;`

**ECDSA Issue 1 (CVE-2024-42460):**
- Missing check for first bit being zero in DER-encoded r and s values
- Fix: Add `if ((data[p.place] & 128) !== 0) return false;`

**ECDSA Issue 2 (CVE-2024-42461):**
- DER length field accepted leading zeros
- Fix: Add `if(buf[p.place] === 0x00) return false;`

### Impact

All three vulnerabilities allowed multiple valid signatures for a single message, leading to consensus problems across implementations.

**Lessons learned:**
- Wycheproof catches subtle encoding bugs
- Reusable test harnesses pay dividends
- Test vector comments and flags help diagnose issues
- Even popular libraries benefit from systematic test vector validation

## Advanced Usage

### Tips and Tricks

| Tip | Why It Helps |
|-----|--------------|
| Filter test groups by parameters | Focus on test vectors relevant to your implementation constraints |
| Use test vector flags | Understand specific vulnerability patterns being tested |
| Check the `notes` field | Get detailed explanations of flag meanings |
| Test both encrypt/decrypt and sign/verify | Ensure bidirectional correctness |
| Run tests in CI | Catch regressions and benefit from new test vectors |
| Use parameterized tests | Get clear failure messages with tcId and comment |

### Common Mistakes

| Mistake | Why It's Wrong | Correct Approach |
|---------|----------------|------------------|
| Only testing valid cases | Misses vulnerabilities where invalid inputs are accepted | Test all result types: valid, invalid, acceptable |
| Ignoring "acceptable" result | Implementation might have subtle bugs | Treat acceptable as warnings worth investigating |
| Not filtering test groups | Wastes time on unsupported parameters | Filter by keySize, ivSize, etc. based on your implementation |
| Not updating test vectors | Miss new vulnerability patterns | Use submodules or scheduled fetches |
| Testing only one direction | Encrypt/sign might work but decrypt/verify fails | Test both operations |

## Related Skills

### Tool Skills

| Skill | Primary Use in Wycheproof Testing |
|-------|-----------------------------------|
| **pytest** | Python testing framework for parameterized tests |
| **mocha** | JavaScript testing framework for test generation |
| **constant-time-testing** | Complement Wycheproof with timing side-channel testing |
| **cryptofuzz** | Fuzz-based crypto testing to find additional bugs |

### Technique Skills

| Skill | When to Apply |
|-------|---------------|
| **coverage-analysis** | Ensure test vectors cover all code paths in crypto implementation |
| **property-based-testing** | Test mathematical properties (e.g., encrypt/decrypt round-trip) |
| **fuzz-harness-writing** | Create harnesses for crypto parsers (complements Wycheproof) |

### Related Domain Skills

| Skill | Relationship |
|-------|--------------|
| **crypto-testing** | Wycheproof is a key tool in comprehensive crypto testing methodology |
| **fuzzing** | Use fuzzing to find bugs Wycheproof doesn't cover (new edge cases) |

## Skill Dependency Map

```
                    ┌─────────────────────┐
                    │    wycheproof       │
                    │   (this skill)      │
                    └──────────┬──────────┘
                               │
           ┌───────────────────┼───────────────────┐
           │                   │                   │
           ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  pytest/mocha   │ │ constant-time   │ │   cryptofuzz    │
│ (test framework)│ │   testing       │ │   (fuzzing)     │
└────────┬────────┘ └────────┬────────┘ └────────┬────────┘
         │                   │                   │
         └───────────────────┼───────────────────┘
                             │
                             ▼
              ┌──────────────────────────┐
              │   Technique Skills       │
              │ coverage, harness, PBT   │
              └──────────────────────────┘
```

## Resources

### Official Repository

**[Wycheproof GitHub Repository](https://github.com/C2SP/wycheproof)**

The official repository contains:
- All test vectors in `testvectors/` and `testvectors_v1/`
- JSON schemas in `schemas/`
- Reference implementations in Java and JavaScript
- Documentation in `doc/`

### Real-World Examples

**[pycryptodome](https://pypi.org/project/pycryptodome/)**

The pycryptodome library integrates Wycheproof test vectors in their test suite, demonstrating best practices for Python crypto implementations.

### Community Resources

- [C2SP Community](https://c2sp.org/) - Cryptographic specifications and standards community maintaining Wycheproof
- Wycheproof issues tracker - Report bugs in test vectors or suggest new constructions

## Summary

Wycheproof is an essential tool for validating cryptographic implementations against known attack vectors and edge cases. By integrating Wycheproof test vectors into your testing workflow:

1. Catch subtle encoding and validation bugs
2. Prevent signature malleability issues
3. Ensure consistent behavior across implementations
4. Benefit from community-contributed test vectors
5. Protect against known cryptographic vulnerabilities

The investment in writing a reusable testing harness pays dividends through continuous validation as new test vectors are added to the Wycheproof repository.
