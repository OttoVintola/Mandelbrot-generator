#include <stdio.h>
#include <iostream>
#include <vector>
#include <cstdio>
#include <opencv2/opencv.hpp>
#include <cstdlib>
#include <cuda_runtime.h>

static inline void check(cudaError_t err, const char* context) {
    if (err != cudaSuccess) {
        std::cerr << "CUDA error: " << context << ": "
            << cudaGetErrorString(err) << std::endl;
        std::exit(EXIT_FAILURE);
    }
}

#define CHECK(x) check(x, #x)

struct RGB {
    uint8_t r, g, b;
};

int divup(int a, int b) {
    return (a + b - 1)/b;
};

std::vector<float> linspace(float from, float to, int elements) {
    std::vector<float> result(elements);

    if (elements == 0) return result;
    if (elements == 1) {
        result[0] = from;
        return result;
    }

    float inc = (to - from) / (elements - 1);

    for (int i = 0; i < elements; ++i) {
        result[i] = from + i * inc;
    }

    return result;
}


std::vector<RGB> make_palette(int max_iter) {
    std::vector<RGB> palette(max_iter);

    for (int i = 0; i < max_iter; ++i) {
        palette[i] = {
            uint8_t(i % 256),
            uint8_t((i * 5) % 256),
            uint8_t((i * 13) % 256)
        };
    }

    return palette;
}



void save_image(const std::vector<RGB> &pixels, int width, int height) {

    cv::Mat img(height, width, CV_8UC3);
    for (int i = 0; i < height; ++i) {
        for (int j = 0; j < width; ++j) {
            const RGB& c = pixels[i * width + j];
            img.at<cv::Vec3b>(i, j) = {
                static_cast<uint8_t>(c.b * 255),
                static_cast<uint8_t>(c.g * 255),
                static_cast<uint8_t>(c.r * 255)
            };
        }
    }
    bool success = cv::imwrite("output.png", img);
    if (success) {
        std::cout << "Success" << std::endl;
    } else {
        std::cout << "Failure" << std::endl;
    }

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

        float cx = xSpace[j];
        float cy = ySpace[i];


        while ((x*x + y*y <= 4) && (iter < max_iter)) {
            float xtemp = x*x - y*y + cx;
            y = 2*x*y + cy;
            x = xtemp;
            ++iter;
        }

        RGB color = palette[iter];
        result[width*i + j] = color;

}


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

    // Call CUDA 
    cudaStream_t stream = 0;
    size_t nSRAMBytesPerBlock = 0;

    dim3 blockSize(16, 16);
    dim3 gridSize( divup(width, blockSize.x), divup(height, blockSize.y) );


    RGB* d_result = NULL;
    CHECK(cudaMalloc( (void**)&d_result, width*height*sizeof(RGB)));

    // Mem for xSpace and ySpace
    float* xPtr = NULL;
    CHECK(cudaMalloc( (void**)&xPtr, width*height*sizeof(float))); 
    CHECK(cudaMemcpy( xPtr, xSpace.data(), width*height*sizeof(float), cudaMemcpyHostToDevice));

    float* yPtr = NULL;
    CHECK(cudaMalloc( (void**)&yPtr, width*height*sizeof(float)));
    CHECK(cudaMemcpy( yPtr, ySpace.data(), width*height*sizeof(float), cudaMemcpyHostToDevice));

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