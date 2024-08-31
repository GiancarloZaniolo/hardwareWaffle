

# python3 gen_matrix.py -f ../tests/sample_mat.txt


import os
from argparse import ArgumentParser
import random

parser = ArgumentParser()
parser.add_argument("-m","--max_val", default="16384", help="max possible val in the array")
parser.add_argument("-r","--rows", default="256", help="number of rows")
parser.add_argument("-c","--cols", default="512", help="number of columns")
parser.add_argument("-f","--file", default="", help="output file", required=True)

args = parser.parse_args()

max_val = int(args.max_val, 10)
rows = int(args.rows, 10)
cols = int(args.cols, 10) 
filename = args.file


file = open(filename,"w")

file.write(str(rows) + " " + str(cols) + " \n")

for i in range(rows):
  construct = ""
  for j in range(cols):
    random_num = random.randint(-max_val,max_val)
    construct += str(random_num) + " "
  file.write(construct + "\n")



