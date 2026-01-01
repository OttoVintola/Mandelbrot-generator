#include "pybind_core.cuh"
#include "kernel.cuh"
#include <cuda_runtime.h>


std::vector<RGB> generate_cpu(int width, int height, int max_iter,
                              const std::vector<float>& xSpace,
                              const std::vector<float>& ySpace,
                              const std::vector<RGB>& palette) {
    std::vector<RGB> result;
    result.reserve(width * height);

    for (int i = 0; i < width; ++i) {
        for (int j = 0; j < height; ++j) {
            float x = 0.0f;
            float y = 0.0f;
            int iter = 0;

            while ((x*x + y*y <= 4) && (iter < max_iter)) {
                float xtemp = x*x - y*y + xSpace[j];
                y = 2*x*y + ySpace[i];
                x = xtemp;
                ++iter;
            }
            result.push_back(palette[iter < max_iter ? iter : max_iter - 1]);
        }
    }
    return result;
}


std::vector<RGB> generate_gpu(int width, int height, int max_iter,
                              const std::vector<float>& xSpace,
                              const std::vector<float>& ySpace,
                              const std::vector<RGB>& palette) {

    cudaStream_t stream = 0;
    size_t nSRAMBytesPerBlock = 0;

    dim3 blockSize(16, 16);
    dim3 gridSize( divup(width, blockSize.x), divup(height, blockSize.y) );

    RGB* d_result = NULL;
    CHECK(cudaMalloc( (void**)&d_result, width*height*sizeof(RGB)));

    // Mem for xSpace and ySpace
    float* xPtr = NULL;
    CHECK(cudaMalloc( (void**)&xPtr, width*sizeof(float))); 
    CHECK(cudaMemcpy( xPtr, xSpace.data(), width*sizeof(float), cudaMemcpyHostToDevice));

    float* yPtr = NULL;
    CHECK(cudaMalloc( (void**)&yPtr, height*sizeof(float)));
    CHECK(cudaMemcpy( yPtr, ySpace.data(), height*sizeof(float), cudaMemcpyHostToDevice));

    RGB* d_palette = NULL;
    CHECK(cudaMalloc( (void**)&d_palette, max_iter*sizeof(RGB)));
    CHECK(cudaMemcpy( d_palette, palette.data(), max_iter*sizeof(RGB), cudaMemcpyHostToDevice));

    generate<<<gridSize, blockSize, nSRAMBytesPerBlock, stream>>>(width, height, max_iter, xPtr, yPtr, d_palette, d_result);

    std::vector<RGB> result(width*height);

    CHECK(cudaMemcpy(result.data(), d_result, width*height*sizeof(RGB), cudaMemcpyDeviceToHost));
    CHECK(cudaFree(d_result));
    CHECK(cudaFree(xPtr));
    CHECK(cudaFree(yPtr));
    CHECK(cudaFree(d_palette));

    return result;
}