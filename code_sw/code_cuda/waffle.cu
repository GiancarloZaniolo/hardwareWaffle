#include <stdio.h>
#include <fstream>
#include <iostream>

#include <cuda.h>
#include <cuda_runtime.h>
#include "waffle.h"

// #include <unistd.h>
// #include <stdlib.h>
// #include <iomanip>


#define DIM_OF_BLOCK 512

// Constants for use on GPU
struct GlobalConstants {
  int rows;
  int cols;
  int *input_mat;
  int pair_list_len;
  int *pair_list;
  int *all_pair_best;
};

__constant__ GlobalConstants cu_glob_const_params;


// **************************************** //
// ************** OUR KERNELS ************* //
// **************************************** //


// Create the prefix sum array
__global__ void kernel_sum_prefix(int max_row) {
  int row = blockIdx.x * blockDim.x + threadIdx.x;
  if(row >= max_row) {
    return;
  }

  int cols = cu_glob_const_params.cols;
  int *input_mat = cu_glob_const_params.input_mat;

  // Sum prefixes for my row:
  int curr = input_mat[row * cols];
  for(int col = 1; col < cols; col++) {
    curr = curr + input_mat[row * cols + col];
    input_mat[row * cols + col] = curr;
  }

}


__device__ int getRowCuda(int idx) {
  // I hope we don't get weird floating point rounding error lol
    return (-1 + ((int)sqrtf((float)(1+8*idx)))) / 2;
}

__device__ int rowToIdxCuda(int row) {
    return ((row * (row + 1)) / 2);
}


// Generage MCSS values for all of the pairs
__global__ void find_best_each_combo(int max_idx) {
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if(idx >= max_idx) {
    return;
  }

  int rows = cu_glob_const_params.rows;
  int cols = cu_glob_const_params.cols;
  int *input_mat = cu_glob_const_params.input_mat;
  int *all_pair_best = cu_glob_const_params.all_pair_best;


  // Calculate based on idx
  int temp = getRowCuda(idx);
  int temp2 = rowToIdxCuda(temp);
  int start_col = (cols - 1) - temp - 1;
  int end_col = (cols - 1) - (idx - temp2);


  // Calculate mcss as you go

  // Maybe this can be registers lol
  int best[] = {-1, -1, -1};
  int curr[] = {0, 0, -1};
  for(int row = 0; row < rows; row++) {
    int this_val = input_mat[row * cols + end_col] - input_mat[row * cols + start_col];

    curr[0] += this_val;
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
  all_pair_best[idx * 3] = best[0];
  all_pair_best[idx * 3 + 1] = best[1];
  all_pair_best[idx * 3 + 2] = best[2];
}


// For debugging purposes
__global__ void debug_vars() {
  int pair_list_len = cu_glob_const_params.pair_list_len;
  int *pair_list = cu_glob_const_params.pair_list;

  printf("CUDA PAIR LIST\n");
  for(int i = 0; i < (pair_list_len / 2); i++) {
    printf("(%d,(%d,%d)) ",i,pair_list[i*2],pair_list[i*2+1]);
  }
  printf("\n");
}


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

  pair_list_len = ((cols - 1) * cols)/2;

  all_pair_best = new int[(pair_list_len * 3)];
}


void WaffleSolver::cuda_malloc_memcpy() {
  cudaMalloc(&cuda_device_input_mat, sizeof(int) * rows * cols);
  cudaMalloc(&cuda_device_all_pair_best, sizeof(int) * ((pair_list_len) * 3));

  cudaMemcpy(cuda_device_input_mat, input_mat, sizeof(int) * rows * cols, 
    cudaMemcpyHostToDevice);

  GlobalConstants params;
  params.rows = rows;
  params.cols = cols;
  params.input_mat = cuda_device_input_mat;
  params.pair_list_len = pair_list_len;
  params.pair_list = cuda_device_pair_list;
  params.all_pair_best = cuda_device_all_pair_best;

  cudaMemcpyToSymbol(cu_glob_const_params, &params, sizeof(GlobalConstants));
}

// Basic helpers for solve()
int getRow(int idx) {
  // I hope we don't get weird floating point rounding error lol
    return (-1 + ((int)sqrtf((float)(1+8*idx)))) / 2;
}

int rowToIdx(int row) {
    return ((row * (row + 1)) / 2);
}

int WaffleSolver::solve() {
  
  dim3 block_dim_prefix(DIM_OF_BLOCK);
  int grid_dim_amnt_prefix = (rows + DIM_OF_BLOCK - 1) / DIM_OF_BLOCK;
  dim3 grid_dim_prefix(grid_dim_amnt_prefix);
  kernel_sum_prefix<<<grid_dim_prefix, block_dim_prefix>>>(rows);

  dim3 block_dim_best_combo(DIM_OF_BLOCK);
  int grid_dim_amnt_best_combo = (pair_list_len + DIM_OF_BLOCK - 1) / DIM_OF_BLOCK;
  dim3 grid_dim_best_combo(grid_dim_amnt_best_combo);
  find_best_each_combo<<<grid_dim_amnt_best_combo, block_dim_best_combo>>>(pair_list_len);
  
  // Do reduction on uniprocessor, may be faster than kernel launch
  cudaMemcpy(all_pair_best, cuda_device_all_pair_best, sizeof(int) * pair_list_len * 3, cudaMemcpyDeviceToHost);

  int best_val = -1;
  int best_idx = -1;
  for(int i = 0; i < pair_list_len; i++) {
    if(all_pair_best[i * 3] > best_val) {
      best_val = all_pair_best[i * 3];
      best_idx = i;
    }
  }

  // Calculate columns from index
  int temp = getRow(best_idx);
  int temp2 = rowToIdx(temp);
  int start_col = (cols - 1) - temp - 1;
  int end_col = (cols - 1) - (best_idx - temp2);
  
  return best_val;
}