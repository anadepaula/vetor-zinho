from jinja2 import Environment, FileSystemLoader, BaseLoader


ARRAY_BLOCKS_BASE_TEMPLATE = """
    array_{{ block }}_block:
        la $a0, array_{{ block }}
        lw $a1, array_length_{{ block }}
        la $a2, array_name_{{ block }}
        la $s7, array_{{ next_block }}_block
        j sort
"""
ARRAY_LENGTH_TEMPLATE = """
array_length_{{ array_index }}: {{ size }}
"""
ARRAY_DEFINITION_TEMPLATE = """
array_{{ array_index }}: .word {{ array }}
array_name_{{ array_index }}: .asciiz "array n={{ size }}, sortedness={{ sortedness }}"
"""

def create_arrays_definition_string(arrays):
    array_indexes = []
    arrays_definition = []
    arrays_length = []
    env = Environment(loader=BaseLoader)
    array_blocks_template = env.from_string(ARRAY_DEFINITION_TEMPLATE)
    array_length_template = env.from_string(ARRAY_LENGTH_TEMPLATE)

    for i, (size, sortedness_arrays) in enumerate(arrays.items(), start=1):
        for j, (sortedness, array) in enumerate(sortedness_arrays.items(), start=1):
            array_index = f"{i}{j}"
            array_indexes.append(array_index)

            array_definition_data = {
                "array": ', '.join(map(str, array)),
                "array_index": array_index,
                "size": size,
                "sortedness": sortedness,
            }
            array_definition = array_blocks_template.render(array_definition_data)
            arrays_definition.append(array_definition)
            array_length = array_length_template.render(array_definition_data)
            arrays_length.append(array_length)
    
    arrays_definition = arrays_length + arrays_definition
    return array_indexes, arrays_definition

def create_arrays_blocks_string(array_indexes):
    blocks_pairs = list(zip(array_indexes, array_indexes[1:]))
    blocks_pairs.append((array_indexes[-1],"end"))
    arrays_blocks = []

    array_block_template = Environment(
        loader=BaseLoader
    ).from_string(
        ARRAY_BLOCKS_BASE_TEMPLATE
    )

    for block, next_block in blocks_pairs:
        arrays_blocks_data = {
            "block": block,
            "next_block": next_block,
        }
        array_block = array_block_template.render(arrays_blocks_data)
        arrays_blocks.append(array_block)
    
    return arrays_blocks

def insert_arrays_in_assembly_file(arrays_definition, arrays_blocks, template_file, output_file):
    array_blocks_template = Environment(
        loader=FileSystemLoader('.')
    ).get_template(template_file)

    data = {
        'arrays_definition': "".join(arrays_definition),
        'arrays_blocks': "\n".join(arrays_blocks)
    }

    code = array_blocks_template.render(data)

    
    with open(output_file, "w") as f:
        f.write(code)

def create_files(arrays_to_sort, template_file, output_file):
    array_indexes, arrays_definition = create_arrays_definition_string(arrays_to_sort)
    arrays_blocks = create_arrays_blocks_string(array_indexes)
    insert_arrays_in_assembly_file(arrays_definition, arrays_blocks, template_file, output_file)
