import matplotlib.pyplot as plt
import scienceplots
import polars as pl
import numpy as np

plt.style.use(['science', 'ieee'])

# GPU Graph
gpu_data = pl.read_csv("../results/timings.csv", has_header=True)
x = gpu_data['x'].to_numpy()
time = gpu_data['time (ms)'].to_numpy()

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

plt.savefig("../results/gpu-graph.png")
plt.show()

# Make CPU graph
cpu_data = pl.read_csv("../results/cpu-timings.csv", has_header=True)
x_cpu = cpu_data['x'].to_numpy()
time_cpu = cpu_data['time (ms)'].to_numpy()
fig, ax = plt.subplots()

ax.plot(x_cpu, time_cpu, label="Measured", color="lightblue")
n0_cpu = x_cpu[0]
t0_cpu = time_cpu[0]
on_cpu = t0_cpu * (x_cpu / n0_cpu)
on2_cpu = t0_cpu * (x_cpu / n0_cpu) ** 2
onlogn_cpu = on_cpu * np.log(on_cpu)
ax.plot(x_cpu, on_cpu, label=r"$O(n)$", color="green", linestyle="--")
ax.plot(x_cpu, on2_cpu, label=r"$O(n^2)$", color="red", linestyle="--")
ax.plot(x_cpu, onlogn_cpu, label=r"$O(nlog(n))$", color="purple", linestyle="--")

ax.set_ylabel("Time (ms)")
ax.set_xscale("log", base=2)
ax.set_xticks(x_cpu)
ax.get_xaxis().set_major_formatter(plt.ScalarFormatter())
ax.set_xlabel("Input Size (pixels)")
ax.legend()
plt.savefig("../results/cpu-graph.png")
plt.show()
