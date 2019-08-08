import numpy as np
import math
import matplotlib.pyplot as plt

xvalues = []
y1values = []
y2values = []
y3values = []
x = -10

while (x < 10.01):
    y1 = (-math.tanh(x)+1)/2
    y2 = ((math.tanh(x+5)+1)/2) + (-(math.tanh(x-3)+1)/2)
    y3 = (math.tanh(x)+1)/2
    xvalues.append(x)
    y1values.append(y1)
    y2values.append(y2)
    y3values.append(y3)
    x = x + 0.01

plt.plot(xvalues, y1values, label = r'$\alpha-{U}$')
#plt.plot(xvalues, y2values, label = 'Phase 2')
plt.plot(xvalues, y3values, label = r'$NdAs$')
plt.xlabel('Distance')
plt.ylabel('Phase')
plt.legend()
plt.show()
