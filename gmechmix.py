import numpy as np
import matplotlib.pyplot as plt
import math

xa = 0.01
g0a = 700
g0b = 400
omega = 40
xvalues = []
yvalues = []
while (xa < 1):
    gm = math.tanh(xa+1)*math.log(1-xa)
    xvalues.append(xa)
    yvalues.append(gm)
    xa = xa + 0.01
plt.plot(xvalues, yvalues)
plt.xlabel('Composition')
plt.ylabel('Gibbs energy')
plt.show()
