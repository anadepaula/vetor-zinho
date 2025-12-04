import random
from math import ceil
from itertools import islice
import logging
import datetime

from generate_assembly_file import create_files


logging.basicConfig(level=logging.INFO)

SEED = 13
RANDOM_NUMBERS_RANGE = 1000

def random_generator(range):
    while True:
        yield random.randrange(range)

def generate_array(max_range):
    randgen = random_generator(RANDOM_NUMBERS_RANGE)
    array = list(islice(randgen, max_range))
    array.sort()
    logging.info(f"array of size {size}: {array}")
    return array

def shuffle_array(array, shuffle_percent):
    array_length = len(array)
    randgen = random_generator(array_length)
    switches = ceil(shuffle_percent * array_length)
    for _ in range(switches):
        i, j = islice(randgen, 2)
        array[i], array[j] = array[j], array[i]
    logging.info(f"array of size {array_length}, switching elements {switches} times. result: {array}")

if __name__ == '__main__':
    logging.info(f"starting random number generator using seed {SEED}")
    random.seed(SEED)

    array_sizes = [5, 10, 25, 50, 100, 200]
    shuffle_percents = [.25, .5, 1, 2, 5]

    arrays_to_sort = {}
    for size in array_sizes:
        base_array = generate_array(size)
        arrays_to_sort[size] = {
            0: base_array,
            -1: list(reversed(base_array))
        }

        for shuffleness in shuffle_percents:
            array = base_array.copy()
            shuffle_array(array, shuffleness)
            arrays_to_sort[size][shuffleness] = array
    
    sorting_algorithms_templates = [
        'bubble_sort_template.asm',
        'selection_sort_template.asm',
    ]

    now = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

    for template_file in sorting_algorithms_templates:
        output_file = template_file.replace("template", now)

        logging.info(f"saving file as {output_file}")
        
        create_files(arrays_to_sort, template_file, output_file)