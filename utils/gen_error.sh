#!/bin/bash
# Script designed to loop generating random board of a given size until an error
#  is found. In practice, I have found it to generally be better to make boards
#  of more targeted sizes, as edge cases are easier to come by.


cd "$(dirname "$0")"

# Define your two scripts
script0="python3 ../utils/gen_matrix.py -f ../tests/sample_mat3.txt -m 1000 -r 1000 -c 500" 
script1="../code/waffle -f ../tests/sample_mat3.txt"
script2="python3 checker.py -f ../tests/sample_mat3.txt"

# Loop forever
while true; do
    $($script0)
    echo "generated"
    # Run both scripts and capture their output
    output1=$($script1)
    echo $output1

    output2=$($script2)
    echo $output2

    # Compare the output of the two scripts
    if [ "$output1" != "$output2" ]; then
        echo "Outputs are different, breaking the loop"
        break
    fi
    
    # Optionally, add a delay before the next iteration
    sleep 1
done
