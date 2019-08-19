import numpy as np
import matplotlib.pyplot as plt

xvalues = [50, 100, 200]
yvalues = [-6.363, -13.199, -26.869]

plt.scatter(xvalues, yvalues)
plt.plot(xvalues, yvalues)
plt.xlabel('System Size')
plt.ylabel('Total Energy')
plt.xlim(0, 210)
plt.ylim(-30, 10)
plt.show()
