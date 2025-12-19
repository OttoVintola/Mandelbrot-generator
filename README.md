# Mandelbrot Generator


## Motivation
This repository was born after reading Mario Antoine Aoun’s article about model collapse for generative models in the Communications of the ACM [[1](https://cacm.acm.org/opinion/how-generative-models-are-ruining-themselves/)]. Mario concludes the article by proposing a challenge for generative models to learn to depict images of the Mandelbrot set. The idea behind the challenge is that generative models will *never* be able to comprehend the complex dynamics of the Mandelbrot set. 

## Mandelbrot set

The Mandelbrot set [[2](https://en.wikipedia.org/wiki/Mandelbrot_set)] was investigated by numerous mathematicians but was first visualized by Benoit Mandelbrot [[3](https://en.wikipedia.org/wiki/Benoit_Mandelbrot)]. The set is defined as the set of complex numbers $c$ for which the function $f_c(z) = z^2 + c$ remains bounded when iterated from $z=0$. Points in the complex plane are colored based on the speed of divergence when iterating the function. 

## Results

The hardware used for benchmarking was an NVIDIA GeForce GTX 1060 with 6GB of VRAM and an Intel(R) Core(TM) i7-4770K CPU @ 3.50GHz. 

The naive version implemented in C++ is significantly slower than the CUDA implementation (no surprise there). The following graph shows the time taken to generate images of increasing resolution for both implementations.

<p align="center">
  <img src="./results/cpu-graph.png" width="45%" />
  <img src="./results/gpu-graph.png" width="45%" />
</p>

The following image shows a Mandelbrot set generated at a resolution of 4096x4096 pixels using the CUDA implementation.

![Mandelbrot set at 4096x4096 resolution](output.png)


## Repository contents

```bash
📁 Mandelbrot-generator
├── 📁 bash
│   └── 📄 benchmark.sh
├── 📁 results
│   ├── 📄 graph.png
│   └── 📄 timings.csv
├── 📁 src
│   ├── 📁 mandelbrot-venv
│   ├── 🎛️ benchmark.cu
│   ├── 💻 common.cpp
│   ├── 📄 common.hpp
│   ├── 🐍 figures.py
│   ├── 💻 generate.cpp
│   ├── 🎛️ generate.cu
│   ├── 🎛️ kernel.cu
│   └── 🧩 kernel.cuh
└── 📘 README.md
```


## References

1. Mario Antoine Aoun. "How Generative Models Are Ruining Themselves." Communications of the ACM, vol. 66, no. 5, May 2023, pp. 18–20. DOI: 10.1145/3584232.

2. "Mandelbrot set." Wikipedia, The Free Encyclopedia. Wikipedia, The Free Encyclopedia, last visited June 10, 2024. https://en.wikipedia.org/wiki/Mandelbrot_set.

3. "Benoit Mandelbrot." Wikipedia, The Free Encyclopedia. Wikipedia, The Free Encyclopedia, last visited June 10, 2024. https://en.wikipedia.org/wiki/Benoit_Mandelbrot.
