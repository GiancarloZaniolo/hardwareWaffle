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


  public:

  void setup(std::string filename);

  void cuda_malloc_memcpy();

  // NOTE if you actually need the values returned we can deal with that later
  int solve();
};