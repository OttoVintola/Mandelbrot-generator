#include "common.hpp"
#include <cstdlib>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stbi_image_write.h"


std::vector<float> linspace(float from, float to, int elements) {
    std::vector<float> result(elements);
    if (elements == 0) return result;
    if (elements == 1) { result[0] = from; return result; }
    float inc = (to - from) / (elements - 1);
    for (int i = 0; i < elements; ++i) result[i] = from + i * inc;
    return result;
}

std::vector<RGB> make_palette(int max_iter) {
    std::vector<RGB> palette(max_iter);
    for (int i = 0; i < max_iter; ++i) {
        palette[i] = {
            static_cast<uint8_t>(i % 256),
            static_cast<uint8_t>((i * 5) % 256),
            static_cast<uint8_t>((i * 13) % 256)
        };
    }
    return palette;
}

void convert_to_strided(const std::vector<RGB> &pixels, uint8_t* data, int width, int height) {
    for (int j = 0; j < height; ++j) {
        for (int i = 0; i < width; ++i) {
            const RGB& c = pixels[j*width + i];

            data[(j*width + i)*3 + 0] = c.r;
            data[(j*width + i)*3 + 1] = c.g;
            data[(j*width + i)*3 + 2] = c.b;
        }
    }
}


void save_image(const std::vector<RGB> &pixels, int width, int height) {
    int channels = 3;
    uint8_t* data = (uint8_t*)malloc(width*height*sizeof(uint8_t)*3);

    convert_to_strided(pixels, data, width, height);
    stbi_write_png("output.png", width, height, channels, data, width * channels);

    free(data);
}
