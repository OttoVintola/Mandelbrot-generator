#include "common.hpp"

int divup(int a, int b);
static inline void check(cudaError_t err, const char* context);
__global__ void generate(int width, int height, int max_iter,
                         const float* xSpace, const float* ySpace,
                         const RGB* palette, RGB* result);