

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Debugging output %%%
output [if debugging then "[num_rows, num_cols, num_corner_empty_wells, horizontal_cell_lines, vertical_cell_lines] = \([num_rows, num_cols, num_corner_empty_wells, horizontal_cell_lines, vertical_cell_lines])\n\n" else "" endif];

output [if debugging then "[num_rows_line, num_cols_line, num_total_wells_line, num_total_wells, num_plates_lines, num_empty_wells] = \([num_rows_line, num_cols_line, num_total_wells_line, num_total_wells, num_plates_lines, num_empty_wells])\n\n" else "" endif];

output [if debugging then "len_emptywells_controls_compounds = \(len_emptywells_controls_compounds)\n\n" else "" endif];

output [if debugging then "emptywells_controls_compounds_categories =\n" else "" endif];
output [if debugging then show(emptywells_controls_compounds_categories) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "emptywells_controls_compounds_names_concentrations =\n" else "" endif];
output [if debugging then show2d(emptywells_controls_compounds_names_concentrations) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "[replicates_on_different_plates, replicates_on_same_plate] = \([replicates_on_different_plates, replicates_on_same_plate])\n\n" else "" endif];

output [if debugging then "[compounds_per_plate_min, compounds_per_plate_mod, emptywells_controls_num] = \([compounds_per_plate_min, compounds_per_plate_mod, emptywells_controls_num])\n\n" else "" endif];

output [if debugging then "compounds_on_plates_lines =\n" else "" endif];
output [if debugging then show(compounds_on_plates_lines) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "compounds_per_plates_lines_total =\n" else "" endif];
output [if debugging then show(compounds_per_plates_lines_total) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "available_wells_per_plates_lines_total =\n" else "" endif];
output [if debugging then show(available_wells_per_plates_lines_total) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "emptywells_controls_compounds_qtys_total =\n" else "" endif];
output [if debugging then show(emptywells_controls_compounds_qtys_total) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "emptywells_controls_compounds_qtys =\n" else "" endif];
output [if debugging then show2d(emptywells_controls_compounds_qtys) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "emptywells_controls_compounds_qtys (per replicate, for verification) =\n" else "" endif];
output [if debugging then show([sum(p in 1..num_plates_lines)(emptywells_controls_compounds_qtys[p,i])
        | i in 1..len_emptywells_controls_compounds]) else "" endif];
output [if debugging then "\n\n" else "" endif];
        
output [if debugging then "emptywells_controls_compounds_qtys (per plate line, for verification) =\n" else "" endif];
output [if debugging then show([num_total_wells_line] ++ [sum(i in 1..len_emptywells_controls_compounds)(emptywells_controls_compounds_qtys[p,i])
              | p in 1..num_plates_lines]) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "emptywells_controls_compounds_concentrations_on_different_rows =\n" else "" endif];
output [if debugging then show2d(emptywells_controls_compounds_concentrations_on_different_rows) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "emptywells_controls_compounds_concentrations_on_different_columns =\n" else "" endif];
output [if debugging then show2d(emptywells_controls_compounds_concentrations_on_different_columns) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "emptywells_controls_compounds_concentrations_on_different_rows_all_plates =\n" else "" endif];
output [if debugging then show(emptywells_controls_compounds_concentrations_on_different_rows_all_plates) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "emptywells_controls_compounds_concentrations_on_different_columns_all_plates =\n" else "" endif];
output [if debugging then show(emptywells_controls_compounds_concentrations_on_different_columns_all_plates) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "num_criteria_set_line =\n" else "" endif];
output [if debugging then show2d(num_criteria_set_line) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "[num_criteria_sets, len_min_dist_criteria, num_edges_wells] = \([num_criteria_sets, len_min_dist_criteria, num_edges_wells])\n\n" else "" endif];

output [if debugging then "emptywells_controls_compounds_criteria_sets =\n" else "" endif];
output [if debugging then show2d(emptywells_controls_compounds_criteria_sets) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "use_min_dist_criteria =\n" else "" endif];
output [if debugging then show2d(use_min_dist_criteria) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "use_fake_edge_wells =\n" else "" endif];
output [if debugging then show2d(use_fake_edge_wells) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "min_dist_criteria_counts =\n" else "" endif];
output [if debugging then show2d(min_dist_criteria_counts) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "min_dist_criteria_lengths =\n" else "" endif];
output [if debugging then show2d(min_dist_criteria_lengths) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "min_dist_criteria_lengths_line =\n" else "" endif];
output [if debugging then show(min_dist_criteria_lengths_line) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "min_dist_criteria_counts_starts =\n" else "" endif];
output [if debugging then show2d(min_dist_criteria_counts_starts) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "min_dist_criteria_counts_ends =\n" else "" endif];
output [if debugging then show2d(min_dist_criteria_counts_ends) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "min_dist_quadrant_criteria_counts =\n" else "" endif];
output [if debugging then show3d(min_dist_quadrant_criteria_counts) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "min_dist_quadrant_on_different_rows_columns =\n" else "" endif];
output [if debugging then show3d(min_dist_quadrant_on_different_rows_columns) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "distances_edges_controls_compounds_plates_match =\n" else "" endif];
output [if debugging then show(distances_edges_controls_compounds_plates_match) else "" endif];
output [if debugging then "\n\n" else "" endif];

output [if debugging then "distances_edges_controls_compounds_sets_match =\n" else "" endif];
output [if debugging then show(distances_edges_controls_compounds_sets_match) else "" endif];
output [if debugging then "\n\n" else "" endif];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CSV Ouput %%%

array[int] of string: letters_capital = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
array[int] of string: letters_inline  = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
array[int] of string: letters = letters_capital ++ [letters_capital[i] ++ letters_inline[j] | i in 1..length(letters_capital), j in 1..length(letters_inline)];

output [if not debugging then "plateID,well,cmpdname,CONCuM,cmpdnum,VOLuL\n" else "" endif];

output [if not debugging then "plate_\(p),"
 ++ letters[fix(calculate_line_index(inner_empty_edge, size_empty_edge, num_rows_line, h, emptywells_controls_compounds_coordinates[p,k,1]))]
 ++ if fix(calculate_line_index(inner_empty_edge, size_empty_edge, num_cols_line, v, emptywells_controls_compounds_coordinates[p,k,2])) < 10
      then "0" else "" endif
 ++ "\(calculate_line_index(inner_empty_edge, size_empty_edge, num_cols_line, v, emptywells_controls_compounds_coordinates[p,k,2]))"
 ++ ","
 ++ emptywells_controls_compounds_names_concentrations[1,emptywells_controls_compounds_indices_ordered[p,k]]
 ++ ","
 ++ emptywells_controls_compounds_names_concentrations[2,emptywells_controls_compounds_indices_ordered[p,k]]
 ++ ","
 ++ emptywells_controls_compounds_names_concentrations[1,emptywells_controls_compounds_indices_ordered[p,k]]
 ++ "_"
 ++ emptywells_controls_compounds_names_concentrations[2,emptywells_controls_compounds_indices_ordered[p,k]]
 ++ "\n" else "" endif | p in 1..num_plates_lines, k in 1..num_total_wells_line,
                         h in 1..horizontal_cell_lines, v in 1..vertical_cell_lines
                         where fix(emptywells_controls_compounds_indices_ordered[p,k]) > 1];
                             % fix(emptywells_controls_compounds_indices_ordered[p,k]) = 1]; % output only empty wells

output ["criteria function = "];
output ["\(- min_distance * 1000 - sum(distances_edges_controls_compounds_minimum))\n"];
output [if debugging then show([min_distance] ++ distances_edges_controls_compounds_minimum) else "" endif];
output [if debugging then "\n" else "" endif];
