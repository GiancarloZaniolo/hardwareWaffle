#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <chrono>
#include <string>
#include <iomanip>
#include <vector>
#include <unistd.h>

#include "waffle.h"


int main(int argc, char* argv[]) {
  // TIME TAKEN TO PARSE ARGS
  const auto args_read_start = std::chrono::steady_clock::now();

  std::string input_filename;

  int opt;
  // NOTE: string has format "f:n:b:" for all the cmdline flags 
  while((opt = getopt(argc, argv, "f:")) != -1) {
    switch (opt) {
      case 'f':
        input_filename = optarg;
        break;
      default:
      // TODO add to this in case of added arguments
        std::cerr << "Usage: " << argv[0] << " -f input_filename\n";
        exit(EXIT_FAILURE);
    }
  }

  // Check for validity of options
  if(input_filename.empty()) {
    std::cerr << "Usage: " << argv[0] << " -f input_filename\n";
        exit(EXIT_FAILURE);
  }

  const double args_read_time = 
    std::chrono::duration_cast<std::chrono::duration<double>>
    (std::chrono::steady_clock::now() - args_read_start).count();


  // TIME TAKEN DURING SETUP; parsing input and creating the pairs list
  const auto init_start = std::chrono::steady_clock::now();

  WaffleSolver solver;

  solver.setup(input_filename);

  const double init_time = 
    std::chrono::duration_cast<std::chrono::duration<double>>
    (std::chrono::steady_clock::now() - init_start).count();


  // TIME TAKEN TO MEMCPY
  const auto memcpy_start = std::chrono::steady_clock::now();

  solver.cuda_malloc_memcpy();

  const double memcpy_time = 
    std::chrono::duration_cast<std::chrono::duration<double>>
    (std::chrono::steady_clock::now() - memcpy_start).count();


  // TIME TAKEN TO SOLVE
  const auto compute_start = std::chrono::steady_clock::now();

  solver.solve();

  const double compute_time = 
    std::chrono::duration_cast<std::chrono::duration<double>>
    (std::chrono::steady_clock::now() - compute_start).count();

  std::cout << "Timings" << std::endl;
  std::cout << "Argument read time: " << args_read_time << std::endl;
  std::cout << "Setup time (includes making pairs): " << init_time << std::endl;
  std::cout << "Memcpy time: " << memcpy_time << std::endl;
  std::cout << "Solvin time: " << compute_time << std::endl;



  return 0;
}