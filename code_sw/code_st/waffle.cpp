#include <stdio.h>
#include <fstream>
#include <iostream>

#include "waffle.h"


// **************************************** //
// ************ Class Functions *********** //
// **************************************** //

void WaffleSolver::setup(std::string input_filename) {

  std::ifstream fin(input_filename);

  if(!fin) {
    std::cerr << "Unable to open file: " << input_filename << ".\n";
  }

  fin >> rows >> cols;

  cols = cols + 1;

  input_mat = new int[rows * cols];

  for(int i = 0; i < rows; i++) {
    input_mat[i * cols] = 0;
    for(int j = 1; j < cols; j++) {
      fin >> input_mat[i * cols + j];
    }
  }

  fin.close();
}

void WaffleSolver::cuda_malloc_memcpy() {

}

int WaffleSolver::solve() {
  // Take prefix sums
  for(int row = 0; row < rows; row++) {
    int curr = input_mat[row * cols];
    for(int col = 1; col < cols; col++) {
      curr = curr + input_mat[row * cols + col];
      input_mat[row * cols + col] = curr;
    }
  }


  // Do mcss's and reduction
  // {val, ubound, bbound, lbound, rbound}
  int best_global[] = {0, 0, 0, 0, 0};
  for(int start_col = 0; start_col < cols; start_col++) {
    for(int end_col = start_col+1; end_col < cols; end_col++) {
      int best[] = {0,0,0};
      int curr[] = {0,0,0};
      for(int row = 0; row < rows; row++) {
        int temp_val = input_mat[row * cols + end_col] - input_mat[row * cols + start_col];
        // std::cout << "[[[  " << temp_val << "  ]]] , " << start_col << "," << end_col << "," << row << std::endl;

        curr[0] += temp_val;
        curr[2] = row;
        if(curr[0] < 0) {
          curr[0] = 0;
          curr[1] = row+1;
          curr[2] = row+1;
        } else if(curr[0] > best[0]) {
          best[0] = curr[0];
          best[1] = curr[1];
          best[2] = curr[2];
        }
      }
      if(best[0] > best_global[0]) {
        best_global[0] = best[0];
        best_global[1] = best[1];
        best_global[2] = best[2];
        best_global[3] = start_col;
        best_global[4] = end_col;
      }
    }
  }

  return best_global[0];
}
