import numpy as np
import math

t = 500

#g = -8407.734 + 130.955151 * t - 26.9182 * t * math.log(t) + 0.00125156 * t * t - 0.00000442605 * t * t * t + 38568 * (1 / t)
g = 24874 - 14.74 * t
print (g)
