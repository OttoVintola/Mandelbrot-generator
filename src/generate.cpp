#include <stdio.h>
#include <iostream>
#include <vector>
#include <cstdio>
#include "common.hpp"


// Mandelbrot set renderer
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

    // colors 
    std::vector<RGB> result;

    int max_iter = 1000;

    // Scale x to be in (-2.00 to 0.47)
    std::vector<float> xSpace = linspace(-2.00, 0.47, width);
    
    // Same for y in (-1.12, 1.12)
    std::vector<float> ySpace = linspace(-1.12, 1.12, height);

    std::vector<RGB> palette = make_palette(max_iter);

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
        RGB color = palette[iter];
        result.push_back(color);
        }
    }
    save_image(result, width, height);    

}