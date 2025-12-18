#pragma once
#include <vector>
#include <cstdint>

struct RGB {
    uint8_t r, g, b;
};

std::vector<float> linspace(float from, float to, int elements);
std::vector<RGB> make_palette(int max_iter);
void save_image(const std::vector<RGB>& pixels, int width, int height);