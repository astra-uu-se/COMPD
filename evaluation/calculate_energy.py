#    The contents of this file are subject to the Mozilla Public License
#    Version  2.0  (the "License"); you may not use this file except in
#    compliance with the License. You may obtain a copy of the License at:
#
#    http://www.mozilla.org/MPL/
#
#    Software  distributed  under  the License is distributed on an "AS
#    IS"  basis,  WITHOUT  WARRANTY  OF  ANY  KIND,  either  express or
#    implied.
#
# Purpose: Calculate Fruchterman-Reingold energy of a complete graph / a microplate layout
# Author : Ramiz Gindullin, Uppsala University

import os

letters_capital = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
letters_inline  = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

def evaluate_file(file_path):
    with open(file_path,'r') as myfile:
        plates = {}
        lines = myfile.readlines()
        if len(lines) <= 1:
            return -1
        elif lines[0] == '% Time limit exceeded!\n':
            return -1
        for line in lines[1:]:
            cols = line.rsplit(',')
            if cols[0] in plates:
                if cols[2] in plates[cols[0]]:
                    plates[cols[0]][cols[2]].append(transform_coordinate(cols[1]))
                else:
                    plates[cols[0]][cols[2]] = [transform_coordinate(cols[1])]
            else:
                plates[cols[0]] = {cols[2]: [transform_coordinate(cols[1])]}
        total_energy = 0
        for plate in plates:
            for graph in plates[plate]:
                total_energy += calculate_fg_energy(plates[plate][graph])
        return total_energy

def transform_coordinate(well):
    row = 0
    for i in range(len(well)):
        symbol = well[i]
        if symbol in letters_capital:
            row += letters_capital.index(symbol)
        elif symbol in letters_inline:
            row = letters_inline.index(symbol) + (row + 1) * len(letters_inline)
        else:
            col = int(well[i:])
            return [row, col]

def calculate_fg_energy(coordinates):
    sum_cubes = 0
    sum_edges = 0
    prod_dist = 1
    num_vert_pairs = 0
    k = len(coordinates)
    for i in range(0, k - 1):
        for j in range(i + 1, k):
            d_ij = calculate_distance(coordinates[i],
                                      coordinates[j])
            sum_cubes += d_ij**3
            sum_edges += d_ij
            prod_dist *= d_ij
            num_vert_pairs += 1
    if num_vert_pairs == 0:
        return 0
    else:
        return (sum_cubes / sum_edges)**(1/3) / prod_dist**(1/num_vert_pairs)

def calculate_distance(coordinate1, coordinate2):
    return ((coordinate1[0] - coordinate2[0])**2 +
            (coordinate1[1] - coordinate2[1])**2)**(1/2)


project_path = 'csv/'
csv_directories = ['gecode8cNoTO_config_plate-design',
                   'gecode8c_config_plate-optimizer-model',
                   'chuffed_config_plate-optimizer-model',
                   'randomized_warmstart',
                   'chuffed_config_plate-randomizer']

for csv_directory in csv_directories:
    print(csv_directory)
    data_file_list = [each for each in os.listdir(project_path + csv_directory + '/') if each.endswith('.csv')]
    for data_file in data_file_list:
        #if data_file == 'pl-example47.csv':
        print(data_file, ',', evaluate_file(project_path + csv_directory + '/' + data_file))
    print('')


# For testing purposes
if False:
    all_letters = [l for l in letters_capital]
    for l1 in letters_capital:
        for l2 in letters_inline:
            all_letters.append(l1 + l2)

    for well in all_letters:
                                             # add '1' because it is expected input
        print(well, transform_coordinate(well + '1'))


# For testing purposes
if False:
    coordinates1 = [[1,1],[1,4],[1,7],
                    [2,3],[2,8],
                    [3,1],[3,4],[3,6],
                    [4,3],[4,8],
                    [5,1],[5,4],[5,6],
                    [6,2],[6,5],
                    [7,1],[7,3],[7,4],
                    [8,2],[8,8]]
    coordinates2 = [[1,1],[1,4],[1,7],
                    [2,3],[2,8],
                    [3,1],[3,4],[3,6],
                    [4,3],[4,8],
                    [5,1],[5,4],[5,7],
                    [6,2],[6,6],
                    [7,1],[7,7],
                    [8,2],[8,5],[8,8]]
    print(calculate_fg_energy(coordinates1))
    print(calculate_fg_energy(coordinates2))
    print()
    print(calculate_fg_energy([[1,1],[8,8]]))
    print(calculate_fg_energy([[3,3],[6,6]]))
    print(calculate_fg_energy([[6,3],[6,6]]))
