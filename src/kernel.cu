#include <cuda_runtime.h>
#include "kernel.cuh"

int divup(int a, int b) {
    return (a + b - 1) / b;
}

__global__ void generate(int width, int height, int max_iter,
                         const float* xSpace, const float* ySpace,
                         const RGB* palette, RGB* result) {

    int i = threadIdx.x + blockIdx.x * blockDim.x;
    int j = threadIdx.y + blockIdx.y * blockDim.y;

    if (i >= width || j >= height) return;

    float x = 0.0f;
    float y = 0.0f;
    int iter = 0;

    float cx = xSpace[i];
    float cy = ySpace[j];

    while ((x * x + y * y <= 4.0f) && (iter < max_iter)) {
        float xtemp = x * x - y * y + cx;
        y = 2.0f * x * y + cy;
        x = xtemp;
        ++iter;
    }

    result[width * j + i] = palette[iter];
}