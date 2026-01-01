# Mandelbrot Generator


## Motivation
This repository was born after reading Mario Antoine Aoun’s article about model collapse for generative models in the Communications of the ACM [[1](https://cacm.acm.org/opinion/how-generative-models-are-ruining-themselves/)]. Mario concludes the article by proposing a challenge for generative models to learn to depict images of the Mandelbrot set. The idea behind the challenge is that generative models will *never* be able to comprehend the complex dynamics of the Mandelbrot set. 

## Mandelbrot set

The Mandelbrot set [[2](https://en.wikipedia.org/wiki/Mandelbrot_set)] was investigated by numerous mathematicians but was first visualized by Benoit Mandelbrot [[3](https://en.wikipedia.org/wiki/Benoit_Mandelbrot)]. The set is defined as the set of complex numbers $c$ for which the function $f_c(z) = z^2 + c$ remains bounded when iterated from $z=0$. Points in the complex plane are colored based on the speed of divergence when iterating the function. 

## Results

The hardware used for benchmarking was an NVIDIA GeForce GTX 1060 with 6GB of VRAM and an Intel(R) Core(TM) i7-4770K CPU @ 3.50GHz. 

The naive version implemented in C++ is significantly slower than the CUDA implementation (no surprise there). The following graph shows the time taken to generate images of increasing resolution for both implementations. **Note** the wildly different x- and y-axes. 

<p align="center">
  <img src="./results/cpu-graph.png" width="45%" />
  <img src="./results/gpu-graph.png" width="45%" />
</p>

Benchmarking the C++ and CUDA versions against the Python version found in Wikipedia [[4](https://en.wikipedia.org/wiki/Mandelbrot_set#Computer_drawings)] shows that switching the language to C++ provides a roughly **13x speedup**, while using a GPU provides a **240x speedup**. 

The code from wikipedia is able to generate a 2000x2000 image at ```max_iterations=1000``` in roughly 116 seconds, while the C++ and CUDA versions can achieve this in 0.470 and 9.1 seconds. The aforementioned can be verified by running the ```test_bindings.py``` script. 

The following image shows a Mandelbrot set generated at a resolution of 4000x4000 pixels using the CUDA implementation.

![Mandelbrot set at 4000x4000 resolution](output.png)

## Python Bindings

The CUDA/C++ code is additionally binded to python through [Pybind11](https://pybind11.readthedocs.io/en/stable/). To compile the bindings to the ```mandelbrot-venv``` use the following build command:

```bash
nvcc -shared -Xcompiler -fPIC \
    -o src/mandelbrot-venv/lib/python3.12/site-packages/mandelbrot$(src/mandelbrot-venv/bin/python3 -c "import sysconfig; print(sysconfig.get_config_var('EXT_SUFFIX'))") \
    src/bindings.cu src/pybind_core.cu src/kernel.cu src/common.cpp \
    $(src/mandelbrot-venv/bin/python3 -m pybind11 --includes)
```

Then the functions can be called normally and visualized through ```matplotlib```:

```python
import mandelbrot
import matplotlib.pyplot as plt


img_gpu = mandelbrot.generate(2000, 2000, use_cuda=True)
print(img_gpu.shape)

plt.imshow(img_gpu)
plt.show()
```
This prints: (2000, 2000, 3).

To use the CPU version, switch the ```use_cuda``` flag to ```False``` because it defaults to ```True```. 

## Repository contents

```bash
📁 Mandelbrot-generator
├── 📁 bash
│   ├── 📄 cpu-benchmark.sh
│   └── 📄 gpu-benchmark.sh
├── 📁 results
│   ├── 📄 cpu-graph.png
│   ├── 📄 cpu-timings.csv
│   ├── 📄 gpu-graph.png
│   └── 📄 timings.csv
├── 📁 src
│   ├── 🎛️ benchmark.cu
│   ├── 🎛️ bindings.cu
│   ├── 💻 common.cpp
│   ├── 📄 common.hpp
│   ├── 🐍 figures.py
│   ├── 💻 generate.cpp
│   ├── 🎛️ generate.cu
│   ├── 🎛️ kernel.cu
│   ├── 🧩 kernel.cuh
│   ├── 🎛️ pybind_core.cu
│   ├── 🧩 pybind_core.cuh
│   ├── 📄 stbi_image_write.h
│   ├── 🐍 test_bindings.py
├── 📄 output.png
└── 📘 README.md
```


## References

1. Mario Antoine Aoun. "How Generative Models Are Ruining Themselves." Communications of the ACM, vol. 68, no. 10, Oct 2025, pp. 6–7. DOI: 10.1145/3748642.

2. "Mandelbrot set." Wikipedia, The Free Encyclopedia. Wikipedia, The Free Encyclopedia, last visited June 10, 2024. https://en.wikipedia.org/wiki/Mandelbrot_set.

3. "Benoit Mandelbrot." Wikipedia, The Free Encyclopedia. Wikipedia, The Free Encyclopedia, last visited June 10, 2024. https://en.wikipedia.org/wiki/Benoit_Mandelbrot.
