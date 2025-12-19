#include <opencv2/opencv.hpp>
#include "common.hpp"

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
    cv::imwrite("output.png", img);
}
