



def parse_file(filename):
  lines_per_dump = 5

  file = open(filename, "r")

  count = 0
  lines = file.readlines()
  idx = 0

  setup_total = 0
  memcpy_total = 0
  compute_total = 0
  for line in lines:
    # setup line
    if idx % lines_per_dump == 2:
      words = line.split(" ")
      setup_total += float(words[5].strip())

    # memcpy line
    if idx % lines_per_dump == 3:
      words = line.split(" ")
      memcpy_total += float(words[2].strip())


    # compute line
    if idx % lines_per_dump == 4:
      words = line.split(" ")
      compute_total += float(words[2].strip())

    if idx % lines_per_dump == 4:
      count += 1
    idx += 1

  things = (setup_total/count, memcpy_total/count, compute_total / count)
  print("(Setup, Memcpy, Compute)")
  print(things)
  print("Total:")
  print((setup_total + memcpy_total + compute_total) / count)
  print("")
  return 

print("main results:")
parse_file("../dumps/dump_main.txt")

print("old results:")
parse_file("../dumps/dump_old_rows_calculation.txt")

print("st results:")
parse_file("../dumps/dump_main_st.txt")
