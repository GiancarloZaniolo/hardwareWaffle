#! /usr/bin/env python3
''' Create the input waffle
'''
from argparse import ArgumentParser
from itertools import count
from random import randint
import math

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


        for ind in range(rows):

            mat_cur = [randint(-max_val, max_val) for r in range(depth)]
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

if __name__ == "__main__":
    main()
