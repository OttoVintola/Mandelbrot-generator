#pragma once
#include <vector>
#include <cstdint>
#include <cuda_runtime.h>
#include <iostream>

struct RGB {
    uint8_t r, g, b;
};

std::vector<float> linspace(float from, float to, int elements);
std::vector<RGB> make_palette(int max_iter);
void save_image(const std::vector<RGB>& pixels, int width, int height);

static inline void check(cudaError_t err, const char* context) {
    if (err != cudaSuccess) {
        std::cerr << "CUDA error: " << context << ": "
                  << cudaGetErrorString(err) << std::endl;
        std::exit(EXIT_FAILURE);
    }
}

#define CHECK(x) check(x, #x)