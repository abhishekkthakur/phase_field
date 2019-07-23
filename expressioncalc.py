import numpy as np
import math
import matplotlib.pyplot as plt

T = 300

#g = -3407.734 + 130.955151 * t - 26.9182 * t * math.log(t) + 0.00125156 * t * t - 0.00000442605 * t * t * t + 38568 * (1 / t)
#g = -7902.93 + 111.10239*T - 27.0858*T*math.log(T) + 0.000556125*T*T - 0.0000026923*T*T*T + 34887*(1/T)
#g = 17603.553 + 107.471069*T - 23.3144*T*math.log(T) - 0.00271613*T*T + 11600*(1/T)
#print (g)

x1values = []
y1values = []
x2values = []
y2values = []
y3values = []
xnd = 0.251
xas = 0.0
while (xnd < 0.43):
    xas = xnd
    gp1mm = (1-xnd-xas)*-57515.479353 + xnd*5000 + xas*5000
    gp2mm = (1-xnd-xas)*-52515.479353 + xnd*-75207.7147891 + xas*-30594.038534
    gp1id = 8.314*300*((1-xnd-xas)*math.log(1-xnd-xas) + xnd*math.log(xnd) + xas*math.log(xas))
    gp2id = 0.5*8.314*300*(2*(1-xnd-xas)*math.log(2*(1-xnd-xas)) + (1-2*(1-xnd-xas))*math.log(1-2*(1-xnd-xas)))
    gp1ex = (1-xnd-xas)*xnd*4.17 + (1-xnd-xas)*xas*-1.04 + xnd*xas*-3.225
    gp2ex = (1-xnd-xas)*xnd*0.51 + (1-xnd-xas)*xas*6.76 + xnd*xas*16.65
    gp1 = gp1mm + gp1id + gp1ex
    gp2 = gp2mm + gp2id + gp2ex
    x1values.append(xnd)
    y1values.append(gp1)
    x2values.append(xas)
    y2values.append(gp2)
    xnd = xnd + 0.01

#print (y2values[])
plt.plot(x1values[:], y1values[:])
plt.plot(x2values[:], y2values[:])
plt.show()
