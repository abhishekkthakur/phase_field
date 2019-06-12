import numpy as np
import csv

with open('c_only_F_50.csv') as csv_file:
	csv_reader = csv.reader(csv_file, delimiter = ',')
	f_values = []
	count = 0
	for row in csv_reader:
		f_values.append(row[4])
		count = count + 1

del (f_values[0])
#print (len(f_values))
print (count)

summation = 0
for item in f_values:
	data = float(item)
	summation = summation + data

print (summation)
