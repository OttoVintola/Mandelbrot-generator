#include <pybind11/pybind11.h>
#include <pybind11/numpy.h>
#include "common.hpp"
#include "pybind_core.cuh"

namespace py = pybind11;

py::array_t<uint8_t> generate_mandelbrot(int width, int height, int max_iter,
                                          float x_min, float x_max,
                                          float y_min, float y_max,
                                          bool use_cuda) {

    std::vector<float> xSpace = linspace(x_min, x_max, width);
    std::vector<float> ySpace = linspace(y_min, y_max, height);
    std::vector<RGB> palette = make_palette(max_iter);

    std::vector<RGB> result;
    if (use_cuda) {
        result = generate_gpu(width, height, max_iter, xSpace, ySpace, palette);
    } else {
        result = generate_cpu(width, height, max_iter, xSpace, ySpace, palette);
    }

    auto numpy_result = py::array_t<uint8_t>({height, width, 3});
    auto buf = numpy_result.mutable_unchecked<3>();

    for (int j = 0; j < height; ++j) {
        for (int i = 0; i < width; ++i) {
            const RGB& c = result[j * width + i];
            buf(j, i, 0) = c.r;
            buf(j, i, 1) = c.g;
            buf(j, i, 2) = c.b;
        }
    }

    return numpy_result;
}

PYBIND11_MODULE(mandelbrot, m) {
    m.def("generate", &generate_mandelbrot,
          "Generate a Mandelbrot set image",
          py::arg("width") = 1920,
          py::arg("height") = 1080,
          py::arg("max_iter") = 1000,
          py::arg("x_min") = -2.0f,
          py::arg("x_max") = 0.47f,
          py::arg("y_min") = -1.12f,
          py::arg("y_max") = 1.12f,
          py::arg("use_cuda") = true);
}