import numpy as np
import matplotlib.pyplot as plt

time = []
gibbs = []
with open('gibbs_energydata.dat', 'r') as f:
	data = f.readlines()
	for i in data:
		value = i.split('\n')
		value = value[0]
		value = value.split('\t')
		t = float(value[0])
		g = float(value[2])
		time.append(t)
		gibbs.append(g)

plt.plot(time[:5], gibbs[:5])
plt.xlabel('Time')
plt.ylabel('Gibbs energy')
plt.show()
