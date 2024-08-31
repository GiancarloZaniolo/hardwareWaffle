# hardwareWaffle

This repository contains implementations of one of CMU's algorithms labs which is accelerated using both hardware (systemVerilog/implemented for the FPGA) and software (CUDA code).

The code in this repository was written by Giancarlo Zaniolo and Devdutt Nadkarni

This source code accompanies our in-depth analysis, seen [here](gzaniolo.github.io/hardwareWaffle.analysis.html).

Here are what the directories are for:


- `code_hw/`
  - `hardwareWaffle/` - Our implementation intended to run on an fpga
  - `numbers/` - A small SV implementation of a 7-segment display for a VGA screen, intended for demonstration purposes
  - `spectrum/` - Hardware implementations not meant for the FPGA
    - `min_parallel/` - An implementation with minimal parallelism - only one operation per cycle
    - `double_bw/` - An implementation with double the mcss bandwidth of our FPGA-oriented implementation
    - `max_parallel/` - An implementation that solves the problem purely combinationally
- `code_sw/`
  - `code_cuda/` - Our CUDA implementation
  - `code_st/` - Our single-threaded C++ implementation
- `tests/` - A directory containing simple test cases to try our implementations on
- `utils/` - Contains utility scripts used to generate test cases and verify correctness of our other implementations
      


