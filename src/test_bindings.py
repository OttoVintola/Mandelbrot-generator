import mandelbrot
import matplotlib.pyplot as plt

# Compare performance
import time

start = time.time()
img = mandelbrot.generate(2000, 2000, use_cuda=True)
print(f"GPU: {time.time() - start:.3f}s")

start = time.time()
img = mandelbrot.generate(2000, 2000, use_cuda=False)
print(f"CPU: {time.time() - start:.3f}s")