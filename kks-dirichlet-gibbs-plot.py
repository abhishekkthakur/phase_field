import numpy as np
import math
import matplotlib.pyplot as plt

xvalues = []
y1values = []
y2values = []

i = 0
while (i < 1):
  y1 = 10*i*i
  y2 = 10*(i-1)*(i-1)
  xvalues.append(i)
  y1values.append(y1)
  y2values.append(y2)
  i = i+0.001

plt.plot(xvalues, y1values, label = 'Phase 1')
plt.plot(xvalues, y2values, label = 'Phase 2')
plt.legend()
plt.show()
