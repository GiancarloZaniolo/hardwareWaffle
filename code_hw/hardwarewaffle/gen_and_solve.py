#! /usr/bin/env python3
''' Create the input waffle
'''
from argparse import ArgumentParser
from itertools import count
from random import randint
import math
import numpy as np
from math import inf
maxint=inf
def maxSubArraySum(a,size):
      
    max_so_far = 0
    max_ending_here = 0
      
    for i in range(0, size):
        max_ending_here = max_ending_here + a[i]
        if (max_so_far < max_ending_here):
            max_so_far = max_ending_here
 
        if max_ending_here < 0:
            max_ending_here = 0  
    return max_so_far
  
# Driver function to check the above function 
def main():
    all_bram_file = "genvars_are_stupid.txt"
    parser = ArgumentParser(description="Generate Block Rams")
    parser.add_argument("depth", default="512",
                        help="how many ints are in a block ram?")
    parser.add_argument("bits", default="32",
                        help="how many bits are there in a word?")
    parser.add_argument("max_val", default="",
                        help="what is the maximum absolute value in a word?")
    parser.add_argument("rows", default="256",
                        help="how many rows are there?")
    args = parser.parse_args()
    depth = int(args.depth, 10)
    max_val = int(args.max_val, 10)
    bits_in_word = int(args.bits, 10)
    rows = int(args.rows, 10)
    header_template = (
        "DEPTH = {depth};\n"
        "WIDTH = {width};\n"
        "ADDRESS_RADIX = HEX;\n"
        "DATA_RADIX = HEX;\n\n"
        "CONTENT BEGIN\n\n")

    footer_template = "\nEND;"

    with open(all_bram_file, "w") as genvar_out:
        genvar_out.write("localparam string mifs[" + str(rows) + "] = \n")
        genvar_out.write("\'{ \n")
        array_2d = np.empty((rows, depth), dtype=int)

        # Fill the array with random integer values
        for row_index in range(rows):
            mat_cur = [randint(-max_val, max_val) for _ in range(depth)]
            array_2d[row_index, :] = mat_cur


        for ind in range(rows):

            mat_cur = array_2d[ind, :]
            file_name = "bram_" + str(ind) + ".mif"
            if (ind == (rows - 1)): 
              genvar_out.write(file_name + "\n")
            else:
              genvar_out.write(file_name + ",\n")

            with open(file_name, "w") as fout:
                addr_counter = count(0)
                #TODO make generalizeable
                data_lines = [
                                  "{:04x} : {:08x};".format(next(addr_counter), (e + (1 << 32)) % (1 << 32) if e < 0 else e)
                                  for e in mat_cur
                              ]
                fout.write(
                    header_template.format(depth=depth, width=bits_in_word) +
                    "\n".join(data_lines) +
                    footer_template)
        
        genvar_out.write("}; \n")
        

        print(f"Matrix files created: {rows} block rams,  {depth} words per block ram, {bits_in_word} bits per word\n")
        prefix_sum_array = np.cumsum(array_2d, axis=1)

        max_sum = 0
        for i in range(depth):
          temp = prefix_sum_array[:, i]
          temp_sum = maxSubArraySum(temp,len(temp))

          if(temp_sum  > max_sum):
            max_sum = temp_sum
          for j in range(i):
            temp = prefix_sum_array[:, i] - prefix_sum_array[:, j]
            temp_sum = maxSubArraySum(temp,len(temp))

            if(temp_sum  > max_sum):
              max_sum = temp_sum
          if (i % 32 == 0):
            print ("progress:" + str(i/depth))
        print("max syrup should be", max_sum)
        genvar_out.write("max syrup should be " + str(max_sum) + "\n")


if __name__ == "__main__":
    main()
