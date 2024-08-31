#include <string>


class WaffleSolver {


  private:
  int rows;
  // NOTE: we appear to have an extra col in our solution because we add an 
  //  column full of zeroes for the prefix sum
  int cols;
  // buffer stores 2D matrix
  int *input_mat;
  int pair_list_len;

  // List of best things for each column combo 
  int *all_pair_best;

  int *cuda_device_input_mat;
  int *cuda_device_pair_list;
  // Allocate buffer for all pairs of cols (weight, start, end)
  int *cuda_device_all_pair_best;



  public:

  void setup(std::string filename);

  void cuda_malloc_memcpy();

  // NOTE if you actually need the values returned we can deal with that later
  int solve();
};