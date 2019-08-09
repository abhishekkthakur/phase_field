import numpy as np
import matplotlib.pyplot as plt
import math

T = 300

# This is for G0Nd_p2
#G = -7902.93 + 111.10239*T - 27.0858*T*math.log(T) + 0.556125e-03*T*T - 2.6923e-06*T*T*T + 34887/T

# This is for G0As_p2
#G = -17603.553 + 107.471069*T - 23.3144*T*math.log(T) - 2.71613e-03*T*T + 11600/T

# This is for G0U_p3
#G = -752.767 + 131.5381*T - 27.5152*T*math.log(T) - 8.35595e-03*T*T + 0.967907e-06*T*T*T + 204611/T

# This is for G0As_p3
G = -17603.553 + 106.111069*T - 23.3144*T*math.log(T) - 2.71613e-03*T*T + 11600/T

print (G)
