
import os
from argparse import ArgumentParser

# ARG PARSE

parser = ArgumentParser()
parser.add_argument("-f","--file", default="", help="input matrix file")
# parser.add_argument("-r","--result", default="", help="input matrix file")

args = parser.parse_args()

mat_filename = args.file
# res_filename = args.result




# PARSE MATRIX FILE

mat_file = open(mat_filename, "r")


mat = []

lines = mat_file.readlines()
size_line = lines[0].strip().split(" ")
rows = int(size_line[0])
cols = int(size_line[1])
lines = lines[1:]

for line in lines:
  vals = line.strip().split(" ")
  acc = []
  for val in vals:
    acc.append(int(val))

  mat.append(acc)


# MATRIX FILE CHECKS

if len(mat) != rows:
  print(f"INCORRECT NUM OF ROWS!!: Has len {len(mat)} and not {rows}")

for i in range(len(mat)):
  if len(mat[i]) != cols:
    print(f"ROWS INCORRECT LENGTH!!: Row {i} has len {len(mat[i])} and not {cols}")
    quit()


# CALCULATE PREFIX ARRAYS

mat_prefs = []
for row in mat:
  acc_val = 0
  acc = [acc_val]
  
  for val in row:
    acc_val += val
    acc.append(acc_val)

  mat_prefs.append(acc)


# Calculate all possible combinations of indices

idx_combs = [(0,0)]

for i in range(len(mat_prefs[0])):
  for j in range(i+1,len(mat_prefs[0])):
    idx_combs.append((i,j))



# Create array that has differences between all combination of indices of rows

# NOTE: this step effectively does a transpose
diffs_arr = []
for (col1,col2) in idx_combs:
  acc = []
  for i in range(len(mat_prefs)):
    acc.append(mat_prefs[i][col2] - mat_prefs[i][col1])
  diffs_arr.append(acc)



# Calculate MCSS over each combination array to find the best final rect.

def mcss(arr):
  # NOTE: returns (weight,start,end), where start and end are inclusive?
  best = (-1,-1,-1)
  curr = [0, 0, -1]
  for i in range(len(arr)):
    curr[0] += arr[i] 
    curr[2] = i 
    if curr[0] < 0:
      curr = [0,i+1,i+1]
    elif curr[0] > best[0]:
      best = tuple(curr)

  return best

best = ((-1,-1,-1),-1)
for i in range(len(diffs_arr)):
  # NOTE: tuple is of form ((weight,start,end),diffs_arr idx)

  curr = mcss(diffs_arr[i])
  if curr[0] > best[0][0]:
    best = (curr,i)

# translate best to coords

final_sum = best[0][0]
final_top = best[0][1]
final_bot = best[0][2]
final_l = idx_combs[best[1]][0]
final_r = idx_combs[best[1]][1]-1

print(f"BEST SUM: {final_sum} TOP: {final_top} BOT: {final_bot} LEFT: {final_l} RIGHT: {final_r}")
