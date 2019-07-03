import numpy as np
import math
import matplotlib.pyplot as plt

alpha = 0.2
w = 5

xvalues = []
yvalues = []
y1values = []
i = 0
while (i < 1000):

    it = (alpha * 1.414 * i) / (math.sqrt(w))
    ie = (i * math.sqrt(w)) / (3 * 1.414)
    xvalues.append(i)
    yvalues.append(it)
    y1values.append(ie)
    i = i + 0.01

plt.plot(xvalues, yvalues, label = 'Interfacial thickness')
plt.plot(xvalues, y1values, label = 'Interfacial energy')
plt.legend()
plt.xlabel('Gradient energy coefficient')
plt.ylabel('Interfacial properties')
plt.title('Kim-Kim-Suzuki model')
plt.show()
