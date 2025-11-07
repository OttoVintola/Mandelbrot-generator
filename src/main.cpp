#include <stdio.h>
#include <iostream>
#include <vector>
#include <cstdio>


void vector_print(const std::vector<float>& v) {
    for (const auto& x : v)
        std::cout << x << " ";
    std::cout << std::endl;
}


std::vector<float> linspace(float from, float to, int elements) {
    std::vector<float> result(elements);
    
    if (elements == 0) return result;
    if (elements == 1) {
        result.push_back(from);
    }

    float inc = (to - from) / (elements - 1);

    for (int i = 0; i < elements; ++i) {
        result[i] = inc;
    }

    return result;

}

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

    int xDom = 500;
    int yDom = 500;

    // Scale x to be in (-2.00 to 0.47)
    std::vector<float> xSpace = linspace(-2.00, 0.47, xDom);
    
    // Same for y in (-1.12, 1.12)
    std::vector<float> ySpace = linspace(-1.12, 1.12, yDom);


    for (int i = 0; i < yDom; ++i) {
        for (int j = 0; j < xDom; ++j) {
            float x, y = 0.0;

            int iter = 0;
            int max_iter = 1000;

            while ((x*x + y*y <= 4) && (iter < max_iter)) {
                float xtemp = x*x - y*y + xSpace[j];


            }


        }
    }

}