#include <vector>
#include "common.hpp"

// CPU implementation
std::vector<RGB> generate_cpu(int width, int height, int max_iter,
                              const std::vector<float>& xSpace,
                              const std::vector<float>& ySpace,
                              const std::vector<RGB>& palette);

// GPU implementation (only available when compiled with CUDA)
std::vector<RGB> generate_gpu(int width, int height, int max_iter,
                              const std::vector<float>& xSpace,
                              const std::vector<float>& ySpace,
                              const std::vector<RGB>& palette);

