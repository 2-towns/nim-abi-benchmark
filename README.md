# ABI Encoding/Decoding Benchmark

This document presents benchmark results comparing the performance of two Nim libraries for Ethereum ABI encoding and decoding:

- **contractabi**: The Codex ABI implementation.
- **web3**: The ABI implementation from the Nim web3 library.

# Run

```bash
nimble install
nimble c -r  src/nim_abi_benchmark.nim
```

## Summary

The benchmarks measure the time (in milliseconds) taken to encode and decode various data types and structures. For each test, the relative performance of `web3` compared to `contractabi` is reported.

### Key Findings

- **Primitive Types**:
    - Encoding and decoding `uint16` is slightly faster in `contractabi` than in `web3`.
- **Strings**:
    - For small strings, `web3` is faster at encoding and decoding.
    - For large strings, `web3` is significantly faster (over 4x) than `contractabi`.
- **Byte Arrays**:
    - Encoding small arrays (`array[0..31, byte]`) is faster in `contractabi`, but for larger arrays (`array[0..1023, byte]`), `web3` is much faster.
- **Custom Types**:
    - Encoding and decoding custom types and complex structures (e.g., `CustomType`, `StorageDeal`) is consistently faster in `web3`, with speedups ranging from 1.7x to over 3x.

## Detailed Results

| Data Type / Operation                | contractabi (ms) | web3 (ms) | web3 vs contractabi |
|--------------------------------------|------------------|-----------|---------------------|
| Encoding uint16                      | 533              | 692       | 1.30x slower        |
| Decoding uint16                      | 302              | 311       | 1.03x slower        |
| Encoding string (small)              | 901              | 759       | 1.19x faster        |
| Decoding string (small)              | 486              | 471       | 1.03x faster        |
| Encoding string (large)              | 20877            | 4921      | 4.24x faster        |
| Decoding string (large)              | 8727             | 6314      | 1.38x faster        |
| Encoding array[0..31, byte]          | 295              | 725       | 2.46x slower        |
| Decoding array[0..31, byte]          | 276              | 354       | 1.28x slower        |
| Encoding array[0..1023, byte]        | 4262             | 825       | 5.16x faster        |
| Decoding array[0..1023, byte]        | 2511             | 1853      | 1.35x faster        |
| Encoding CustomType                  | 3749             | 1147      | 3.27x faster        |
| Decoding CustomType                  | 1214             | 680       | 1.78x faster        |
| Encoding StorageDeal                 | 7051             | 2346      | 3.01x faster        |
| Decoding StorageDeal                 | 2660             | 1444      | 1.84x faster        |

## Conclusion

- The `web3` ABI implementation generally outperforms `contractabi`, especially for large data structures and complex types.
- For small primitive types, the performance difference is negligible or slightly in favor of `contractabi`.
- For most practical use cases, especially those involving large or complex data, `web3` is recommended for better performance.
