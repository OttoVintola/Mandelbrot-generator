#include <stdio.h>
#include <iostream>

// Mandelbrot set renderer
int main(int argc, char* argv[]) {

    int x, y = 0;

    for (int i = 0; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg.rfind("--x=", 0) == 0) {
            x = std::atoi(arg.substr(4).c_str());
        } else if (arg.rfind("--y=", 0) == 0) {
            y = std::atoi(arg.substr(4).c_str());
        }
    }

    for (int i = 0; i < y; ++i) {
        for (int j = 0; j < x; ++j) {
            

        }
    }
}