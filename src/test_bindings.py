import mandelbrot
import matplotlib.pyplot as plt

# Use CUDA (default)
img_gpu = mandelbrot.generate(1920, 1080, use_cuda=True)

# Use CPU
img_cpu = mandelbrot.generate(1920, 1080, use_cuda=False)

# Compare performance
import time

start = time.time()
img = mandelbrot.generate(1920, 1080, use_cuda=True)
print(f"GPU: {time.time() - start:.3f}s")

start = time.time()
img = mandelbrot.generate(1920, 1080, use_cuda=False)
print(f"CPU: {time.time() - start:.3f}s")

plt.imshow(img)
plt.show()