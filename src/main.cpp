#include <stdio.h>
#include <iostream>
#include <vector>
#include <cstdio>
#include <opencv2/opencv.hpp>



struct RGB {
    uint8_t r, g, b;
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
    std::vector<RGB> palette;

    for (int i = 0; i < max_iter; ++i) {
        RGB color;
        color.r = i % 256;
        color.g = (i * 5) % 256;
        color.b = (i * 13) % 256;
        palette.push_back(color);
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

    // TODO: Make these into arguments
    int xDom = 500;
    int yDom = 500;
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