#include <stdio.h>
#include <iostream>
#include <vector>
#include <cstdlib>
#include <string>
#include <cuda_runtime.h>
#include "common.hpp"
#include "kernel.cuh"


int main(int argc, char* argv[]) {
    int width = 0, height = 0;
    int runs = 20;

    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg.rfind("--x=", 0) == 0)
            width = std::atoi(arg.substr(4).c_str());
        else if (arg.rfind("--y=", 0) == 0)
            height = std::atoi(arg.substr(4).c_str());
        else if (arg.rfind("--runs=", 0) == 0)
            runs = std::atoi(arg.substr(7).c_str());
    }


    const int max_iter = 1000;

    std::vector<float> xSpace = linspace(-2.00, 0.47, width);
    std::vector<float> ySpace = linspace(-1.12, 1.12, height);
    std::vector<RGB> palette = make_palette(max_iter);
    std::vector<RGB> result(width * height);


    cudaStream_t stream = 0;
    size_t nSRAMBytesPerBlock = 0;

    dim3 blockSize(16, 16);
    dim3 gridSize(divup(width, blockSize.x),
                  divup(height, blockSize.y));

    float *xPtr = nullptr, *yPtr = nullptr;
    RGB *d_palette = nullptr, *d_result = nullptr;

    CHECK(cudaMalloc(&xPtr, width * sizeof(float)));
    CHECK(cudaMalloc(&yPtr, height * sizeof(float)));
    CHECK(cudaMalloc(&d_palette, max_iter * sizeof(RGB)));
    CHECK(cudaMalloc(&d_result, width * height * sizeof(RGB)));

    CHECK(cudaMemcpy(xPtr, xSpace.data(), width * sizeof(float), cudaMemcpyHostToDevice));
    CHECK(cudaMemcpy(yPtr, ySpace.data(), height * sizeof(float), cudaMemcpyHostToDevice));
    CHECK(cudaMemcpy(d_palette, palette.data(), max_iter * sizeof(RGB), cudaMemcpyHostToDevice));

    // warm up for JIT overhead
    for (int i = 0; i < 3; ++i) {
        generate<<<gridSize, blockSize, nSRAMBytesPerBlock, stream>>>(width, height, max_iter,
                                          xPtr, yPtr, d_palette, d_result);
    }
    CHECK(cudaDeviceSynchronize());

    
    cudaEvent_t start, stop;
    CHECK(cudaEventCreate(&start));
    CHECK(cudaEventCreate(&stop));


    CHECK(cudaEventRecord(start));
    // Do actual runs
    for (int i = 0; i < runs; ++i) {
        generate<<<gridSize, blockSize, nSRAMBytesPerBlock, stream>>>(width, height, max_iter,
                                          xPtr, yPtr, d_palette, d_result);
    }
    CHECK(cudaEventRecord(stop));
    CHECK(cudaEventSynchronize(stop));

    float elapsed_ms = 0.0f;
    CHECK(cudaEventElapsedTime(&elapsed_ms, start, stop));

    float avg_ms = elapsed_ms / runs;

    // output csv
    std::cout << width << "," << height << "," << avg_ms << std::endl;


    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    cudaFree(xPtr);
    cudaFree(yPtr);
    cudaFree(d_palette);
    cudaFree(d_result);

    return 0;
}