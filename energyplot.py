import numpy as np
import matplotlib.pyplot as plt

xvalues = []
yvalues = []

with open('kks_example_dirichlet_out.dat') as f:
    lines = f.readlines()
    for line in lines:
        a = line.strip()
        a = a.split('\t')
        data1 = float(a[0])
        data2 = float(a[2])
        xvalues.append(data1)
        yvalues.append(data2)

plt.plot(xvalues, yvalues)
plt.xlabel('Time')
plt.ylabel('Gibbs energy')
plt.show()
