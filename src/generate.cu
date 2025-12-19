#include <stdio.h>
#include <iostream>
#include <vector>
#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>
#include "common.hpp"
#include "kernel.cuh"


int main(int argc, char* argv[]) {
    int width, height = 0;

    for (int i = 0; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg.rfind("--x=", 0) == 0) {
            width = std::atoi(arg.substr(4).c_str());
        } else if (arg.rfind("--y=", 0) == 0) {
            height = std::atoi(arg.substr(4).c_str());
        }
    }

    int max_iter = 1000;

    // Scale x to be in (-2.00 to 0.47) 
    std::vector<float> xSpace = linspace(-2.00, 0.47, width); 
    
    // Same for y in (-1.12, 1.12)
    std::vector<float> ySpace = linspace(-1.12, 1.12, height);

    std::vector<RGB> palette = make_palette(max_iter);

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

    save_image(result, width, height);

}