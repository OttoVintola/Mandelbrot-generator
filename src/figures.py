import matplotlib.pyplot as plt
import scienceplots
import polars as pl
import numpy as np

plt.style.use(['science', 'ieee'])

data = pl.read_csv("../results/timings.csv", has_header=True)
x = data['x'].to_numpy()
time = data['time (ms)'].to_numpy()

fig, ax = plt.subplots()
ax.plot(x, time, label="Measured", color="lightblue")

n0 = x[0]
t0 = time[0]
on = t0 * (x / n0)
on2 = t0 * (x / n0) ** 2
onlogn = on * np.log(on)

ax.plot(x, on, label=r"$O(n)$", color="green", linestyle="--")
ax.plot(x, on2, label=r"$O(n^2)$", color="red", linestyle="--")
ax.plot(x, onlogn, label=r"$O(nlog(n))$", color="purple", linestyle="--")

ax.set_ylabel("Time (ms)")
ax.set_xscale("log", base=2)
ax.set_xticks(x)
ax.get_xaxis().set_major_formatter(plt.ScalarFormatter())


ax.set_xlabel("Input Size (pixels)")
ax.legend()

plt.savefig("../results/graph.png")
plt.show()
