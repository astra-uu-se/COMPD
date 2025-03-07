solve::seq_search([int_search(array1d(emptywells_controls_compounds_coordinates), input_order, indomain_random),
                   int_search(array1d(wells_line_lex_all_different_substitute), input_order, indomain_min),
                   int_search(min_dist_criteria_vars, input_order, indomain_min),
                   int_search(distances_edges_controls_compounds_minimum, input_order, indomain_min),
                   int_search([min_distance], input_order, indomain_min)
                   ]
                  ) satisfy;


output ["w1 = \(array1d(emptywells_controls_compounds_coordinates))\n"];
output ["w2 = \(array1d(wells_line_lex_all_different_substitute))\n"];
output ["w3 = \(min_dist_criteria_vars)\n"];
output ["w4 = \(distances_edges_controls_compounds_minimum)\n"];
output ["w5 = \([min_distance])\n"];

output ["criteria function = "];
output ["\(- min_distance * 1000 - sum(distances_edges_controls_compounds_minimum))\n"];