% Copyright 2021 PLAID Authors.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
%
% Description:  A microplate layout randomizator
%
% Authors: Ramiz GINDULLIN (ramiz.gindullin@it.uu.se)
% Version: 1.0
% Last Revision: February 2025
%

include "globals.mzn";

function int: compound_index(int: cmpds, string: cmpd, array[int] of string: cmpds_names) =
                            min([i | i in 1..cmpds where cmpd = cmpds_names[i]]);

function var int: distance_manhattan(array[1..2] of var int: P1, array[1..2] of var int: P2) =
                            abs(P1[1] - P2[1]) + abs(P1[2] - P2[2]);

function var int: calculate_line_index(bool: edge_type, int: edge_size, int: line_size, var int: line, var int: coordinate) =
         if edge_type then (line - 1) * (2 * edge_size + line_size) + edge_size + coordinate
                      else (line - 1) *                  line_size  + edge_size + coordinate endif;


%%%% Input Data  %%%%

%% Information about 
%constraints %%
bool: allow_empty_wells;
bool: replicates_on_different_plates;
bool: replicates_on_same_plate;
bool: concentrations_on_different_rows;
bool: concentrations_on_different_columns;

%% Information about the layout %%
int: horizontal_cell_lines;
int: vertical_cell_lines;
int: size_empty_edge;
bool: inner_empty_edge = true; % Question - what does it do?

%% Compounds %%
int: compounds; %% number of drugs/compounds
array [1..compounds] of int: compound_replicates;
int: replicates = max(compound_replicates++[0]);
array [1..compounds] of int: compound_concentrations;
int: max_compound_concentrations = max(compound_concentrations++[0]);

array[1..compounds] of string: compound_names;
array[1..compounds,1..max_compound_concentrations] of string: compound_concentration_names;

%% Combinations (Deprecated) %%
int: combinations;
int: combination_concentrations;
array[1..combinations] of string: combination_names;
array[1..combination_concentrations] of string: combination_concentration_names;

%% Information about controls %%
int: num_controls;
array [1..num_controls] of int: control_replicates; 
array [1..num_controls] of int: control_concentrations;
int: max_control_concentrations = max(control_concentrations++[0]);
array[1..num_controls,1..max_control_concentrations] of string: control_concentration_names;
array[1..num_controls] of string: control_names;

int: total_controls = sum([control_concentrations[i]*control_replicates[i] | i in 1..num_controls]);

%% Plate size / number of wells
int: num_rows;
int: num_cols;
opt int: size_corner_empty_wells;
int: num_corner_empty_wells = size_corner_empty_wells default 0;

%% Deprecated
array[int] of string: compound_concentration_indicators;

%%% Testing %%%
opt bool: testing = false;
opt bool: print_all = false;
bool: debugging = testing /\ print_all default false;
%bool: enforce = false;
opt int: swap_search;
opt bool: sorted_compounds;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Datafile validation %%%
constraint assert(compounds >= 0,"Invalid datafile: Number of compounds cannot be less than zero.");
constraint assert(combinations >= 0,"Invalid datafile: Number of combinations cannot be less than zero.");
constraint assert(num_controls >= 0,"Invalid datafile: Number of controls should not be less than zero.");
constraint assert(vertical_cell_lines > 0,"Invalid datafile: Number of cell lines should be larger than zero.");
constraint assert(horizontal_cell_lines > 0,"Invalid datafile: Number of cell lines should be larger than zero.");
constraint assert(num_rows_line > 0,"Invalid datafile: Number of rows should be larger than zero.");
constraint assert(num_cols_line > 0,"Invalid datafile: Number of columns should be larger than zero.");
%constraint assert(compounds==0 \/ min(compound_replicates) > 0,"Invalid datafile: Number of replicates should be larger than zero.");
%constraint assert(compounds==0 \/ min(compound_concentrations) > 0,"Invalid datafile: Number of concentrations should be larger than zero.");
constraint assert((replicates_on_different_plates /\ replicates_on_same_plate) == false,"Invalid datafile: replicates cannot be both on the same plate and on different plates");
% Next two ctrs are unapplicable to the current model
%constraint assert(num_rows_line mod 2 == 0, "Invalid datafile: Currently we only support plate sizes that have an inner area with an even number of rows.");
%constraint assert(num_cols_line mod 2 == 0, "Invalid datafile: Currently we only support plate sizes that have an inner area with an even number of columns." );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Calculating dimensions of a line %%%
int: num_rows_line = if inner_empty_edge
                   then floor(num_rows / horizontal_cell_lines) - 2 * size_empty_edge
                   else floor((num_rows - 2 * size_empty_edge) / horizontal_cell_lines) endif;
int: num_cols_line = if inner_empty_edge
                   then floor(num_cols / vertical_cell_lines) - 2 * size_empty_edge
                   else floor((num_cols - 2 * size_empty_edge) / vertical_cell_lines) endif;

constraint assert((2*num_corner_empty_wells <= max([num_rows_line, num_cols_line])),
                   "Size of corners exceeds dimension/-s if the plate:\nnumber of rows per line = \(num_rows_line)\nnumber of columns per line = \(num_cols_line)\nthe size of a corner = \(num_corner_empty_wells)");


%%% Model Parameters - tune to change performance / quality of a solution %%%
% TODO: rewrite this block (and the corresponding part later) to be more clear (an easy fix)
int: num_wells_set_criteria              = if num_total_wells_line < 300 then 90   else 120  endif;
float: num_threshold_min_dist_criteria   = if num_total_wells_line < 300 then 0.45 else 0.35 endif;
float: num_threshold_use_fake_edge_wells = if num_total_wells_line < 300 then 0.15 else 0.1  endif; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%-------------------PREPROCESSING - plate and quadrant distribution--------------------------

% calculate the number of forced empty wells both per quadrant and per line
int: num_forced_empty_wells_quadrant = num_corner_empty_wells * num_corner_empty_wells;
int: num_forced_empty_wells_total = 4 * num_forced_empty_wells_quadrant;

int: num_total_wells_line = num_rows_line * num_cols_line - num_forced_empty_wells_total;

%% Number of wells needed. Note that plates might not be full
int: num_total_wells = sum([compound_concentrations[i]*compound_replicates[i] | i in 1..compounds]) + total_controls; 

%% Number of plates needed
%% max is used to avoid division-by-zero errors
int: num_plates_lines = max(ceil(num_total_wells / num_total_wells_line), 1);

int: num_empty_wells = num_total_wells_line * num_plates_lines - num_total_wells;

%%%%% Data validation %%%%%
constraint assert(num_empty_wells >= 0, "Model ERROR! Inner empty wells is negative. This should never happen!");
constraint assert(((not allow_empty_wells) -> (num_empty_wells = 0)), "The number of inner empty wells is \(num_empty_wells) while none are allowed.\n");
constraint assert(num_total_wells > 0, "Invalid data: the plates cannot be completely empty.");
constraint assert(num_total_wells_line > 0, "Invalid data: There are no wells on the plate.");
constraint assert(min(compound_concentrations++[0]) <= num_total_wells_line, "Invalid data: Number of concentrations does not fit in one plate. If you think this is a mistake, please contact the development team.");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

int: len_emptywells_controls_compounds = 1 + sum(control_concentrations) + sum(compound_concentrations);

% IMPORTANT: We assume that controls and compounds are placed sequentially. i.e. we can't have ["ctrs", "comp", "ctrs"] or ["comp 1", "comp 2", "comp 1"] etc
%   A reasonable assumption, as these arrays are generated authomatically
%   BUT! If this assumption is broken then some of the later logic will be broken. Namely WRT array "emptywells_controls_compounds_criteria_ordered"
array[1..len_emptywells_controls_compounds] of string: emptywells_controls_compounds_categories =
         ["ew"] ++ ["ctrs" | i in 1..sum(control_concentrations)] ++ ["comp" | i in 1..sum(compound_concentrations)];
array[1..2,1..len_emptywells_controls_compounds] of string: emptywells_controls_compounds_names_concentrations =
         array2d(1..2,1..len_emptywells_controls_compounds,
                 ["ew"] ++
                 [control_names[i] | i in 1..num_controls, j in 1..control_concentrations[i]] ++
                 [compound_names[i] | i in 1..compounds, j in 1..compound_concentrations[i]] ++
                 [""] ++
                 [control_concentration_names[i,j] | i in 1..num_controls, j in 1..control_concentrations[i]] ++
                 [compound_concentration_names[i,j] | i in 1..compounds, j in 1..compound_concentrations[i]]
                 );

% collect all quantitites before assigning them between plates / lines
array[1..len_emptywells_controls_compounds] of int: emptywells_controls_compounds_qtys_total =
                 [num_empty_wells] ++
                 [control_replicates[i] | i in 1..num_controls, j in 1..control_concentrations[i]] ++
                 [compound_replicates[i] | i in 1..compounds, j in 1..compound_concentrations[i]];

% these parameters are only used for replicates_on_same_plate strategy when num_plates_lines > 1
int: compounds_per_plate_min = floor(compounds div num_plates_lines);
int: compounds_per_plate_mod = compounds mod num_plates_lines;
int: emptywells_controls_num = 1 + sum(control_concentrations);
array[1..compounds] of 1..num_plates_lines: compounds_on_plates_lines =
                       [p | p in 1..num_plates_lines, i in 1..(compounds_per_plate_min + (compounds_per_plate_mod >= p))];
array[1..num_plates_lines] of int: compounds_per_plates_lines_total =
                       [sum([compound_replicates[i] * compound_concentrations[i]
                             | i in 1..compounds where compounds_on_plates_lines[i] = p])
                        | p in 1..num_plates_lines];
constraint assert((replicates_on_same_plate /\ (num_plates_lines > 1)) ->
                  (forall(i in 1..num_plates_lines)(compounds_per_plates_lines_total[i] <= num_total_wells_line)),
                  "Model ERROR! Default behavior for compounds_on_plates_lines strategy assigns too many replicates on one plate.\n\(show2d(emptywells_controls_compounds_names_concentrations))\n\(show(emptywells_controls_compounds_qtys_total))\n");
array[1..num_plates_lines] of int: available_wells_per_plates_lines_total =
                       [num_total_wells_line - compounds_per_plates_lines_total[p] | p in 1..num_plates_lines];
int: available_wells_per_plates_lines_total_sum = sum(available_wells_per_plates_lines_total);
int: emptywells_controls_compounds_first_non_zero =
                 min([i | i in 1..len_emptywells_controls_compounds
                          where emptywells_controls_compounds_qtys_total[i] > 0]);

% this list is only used for randomized strategy when num_plates_lines > 1
array[int] of int: emptywells_controls_compound_randomized =
      if (num_plates_lines = 1) \/ replicates_on_same_plate \/ replicates_on_different_plates then []
      else arg_sort([cauchy(0,2) | i in 1..num_plates_lines*num_total_wells_line]) endif;


% Divide materials between plates depending on the strategy
array[1..num_plates_lines, 1..len_emptywells_controls_compounds] of int: emptywells_controls_compounds_qtys =
     if num_plates_lines = 1
   then array2d(1..1, 1..len_emptywells_controls_compounds, emptywells_controls_compounds_qtys_total)

  elseif replicates_on_same_plate
      % currently this strategy is done in a simplified way - with an assumption that all compounds have equal total number of replicates
      % thus it's fairly trivial to split them between plates/lines.
      % If this assumption is broken, then bugs are possible and even expected
      % An alternative to somehow ameliorate this problem is to do a presolving a subproblem separately, but currently we dont do it
      % A python script and a separate model file should be easy enough to create
   then array2d(1..num_plates_lines, 1..len_emptywells_controls_compounds,
                [if i <= emptywells_controls_num
               then % this segment is an attempt to write a generalized formula that tries to spread out empty wells and controls
                    % more or less proportional to the available free space (i.e. everything except compounds)
                    % we check every column from emptywells_controls_compounds_first_non_zero (in case if there are no empty wells) to the last control
                    % first column, i.e. emptywells_controls_compounds_first_non_zero, is calculated by substracting quantities from every other columns on the same row (i.e. plate)
                    % every control column j uses floor(nb_replicates[j] * plate_space[i] / sum(plate_space) for plates i = 1..num_plates_lines-1.
                    % and plate i = num_plates_lines is the remaining number of nb_replicates[j].
                    %
                    % NOTE: in certain circumstances it can fail and produce negative qualities. e,g,:
                    % We have 5 plates with free spaces [2, 2, 2, 8, 8] (i.e. we have 22 free wells in total) and we need to place
                    % 2 empty wells and 20 controls. The current version produces the following distribution:
                    % [|  1,  1    % plate 1
                    %  |  1,  1    % plate 2
                    %  |  1,  1    % plate 3
                    %  |  1,  7    % plate 4
                    %  | -2, 10 |] % plate 5
                    % instead of, say:
                    % [|  0,  2    % plate 1
                    %  |  0,  2    % plate 2
                    %  |  0,  2    % plate 3
                    %  |  1,  7    % plate 4
                    %  |  1,  7 |] % plate 5
                    % There is no obvious way how to modify the current algorithm. The best course of action --
                    % set this pre-calculation as a separate constraint problem, solve it and use the result as an imput file.
                    % Likely as specialized Python script is required.
                    
                         % We calculate first column on the last plate:
                      if p = num_plates_lines /\ i = emptywells_controls_compounds_first_non_zero
                    then emptywells_controls_compounds_qtys_total[i] -
                         sum(p1 in 1..num_plates_lines-1)
                            (available_wells_per_plates_lines_total[p1] -
                             sum(i1 in emptywells_controls_compounds_first_non_zero + 1..emptywells_controls_num)
                                (floor((emptywells_controls_compounds_qtys_total[i1] * available_wells_per_plates_lines_total[p1]) /
                                       available_wells_per_plates_lines_total_sum)))
                         % We calculate remaining columns on the last plate:
                  elseif p = num_plates_lines /\ i > emptywells_controls_compounds_first_non_zero
                    then emptywells_controls_compounds_qtys_total[i] -
                         sum(p1 in 1..num_plates_lines-1)
                            (floor((emptywells_controls_compounds_qtys_total[i] * available_wells_per_plates_lines_total[p1]) /
                                   available_wells_per_plates_lines_total_sum))
                         % We calculate first column on every plate except the last one:
                  elseif i = emptywells_controls_compounds_first_non_zero /\ p < num_plates_lines
                    then available_wells_per_plates_lines_total[p] -
                         sum(i1 in emptywells_controls_compounds_first_non_zero + 1..emptywells_controls_num)
                            (floor((emptywells_controls_compounds_qtys_total[i1] * available_wells_per_plates_lines_total[p]) /
                             available_wells_per_plates_lines_total_sum))
                         % We calculate remaining columns on every plate except the last one:
                         % NOTE - we put this branch last in case if there's only one column to distribute,
                         % meaning this case will be covered by previous branches expicitly making
                         % sure that all allocated plate line space is used.
                         % If this branch is called earlier - it's not necessarily to be the case
                    else floor((emptywells_controls_compounds_qtys_total[i] * available_wells_per_plates_lines_total[p]) /
                               available_wells_per_plates_lines_total_sum)
                    endif
                 % and here the compounds are placed in accordance with the list emptywells_controls_compounds_names_concentrations
             elseif compounds_on_plates_lines[compound_index(compounds,
                                                             emptywells_controls_compounds_names_concentrations[1,i],
                                                             compound_names)] = p
               then emptywells_controls_compounds_qtys_total[i]
               else 0
              endif
                 | p in 1..num_plates_lines, i in 1..len_emptywells_controls_compounds]
                )

  elseif replicates_on_different_plates
      % strategy where everything is spread out more or less evenly between the plates
      % e.g. if we have emptywells_controls_compounds_qtys_total = [1, 3, 9, 7] corresponding to ['ew', 'ctr', 'cmp1', 'cmp2']
      % which we want to split between 4 plates. To do this we "create" vector:
      % ['ew',   'ctr',  'ctr',   'ctr', 'cmp1', 'cmp1', 'cmp1', 'cmp1', 'cmp1', 'cmp1',
      %  'cmp1', 'cmp1', 'cmp1', 'cmp2', 'cmp2', 'cmp2', 'cmp2', 'cmp2', 'cmp2', 'cmp2']
      % and then take 1st, 5th,  9th, etc elements for plate 1 (i.e. i mod 4 = 1)
      %               2nd, 6th, 10th, etc elements for plate 2 (i.e. i mod 4 = 2)
      %               3nd, 7th, 11th, etc elements for plate 3 (i.e. i mod 4 = 3)
      %               4nd, 8th, 12th, etc elements for plate 4 (i.e. i mod 4 = 0)
      % and aggregate the results to construct:
      % emptywells_controls_compounds_qtys = [| 0, 1, 2, 2
      %                                       | 1, 0, 3, 1
      %                                       | 0, 1, 2, 2
      %                                       | 0, 1, 2, 2
      %                                       |]
   then array2d(1..num_plates_lines, 1..len_emptywells_controls_compounds,
                [sum(j in sum(k in 1..i - 1)(emptywells_controls_compounds_qtys_total[k]) + 1
                            ..sum(k in 1..i)(emptywells_controls_compounds_qtys_total[k]))
                    (((j mod num_plates_lines) = p - 1))
                 | p in 1..num_plates_lines, i in 1..len_emptywells_controls_compounds]
                )

      % If both flages are set to false, we, currently, use randomized strategy
   else array2d(1..num_plates_lines, 1..len_emptywells_controls_compounds,
                [sum(j in sum(k in 1..i - 1)(emptywells_controls_compounds_qtys_total[k]) + 1
                            ..sum(k in 1..i)(emptywells_controls_compounds_qtys_total[k]))
                    (((emptywells_controls_compound_randomized[j] mod num_plates_lines) = p - 1))
                 | p in 1..num_plates_lines, i in 1..len_emptywells_controls_compounds]
                )
        endif;

constraint assert(forall(p in 1..num_plates_lines, i in 1..len_emptywells_controls_compounds)
                        (emptywells_controls_compounds_qtys[p,i] >= 0),
                  "Model ERROR! Negative assigned quantities of materials detected:\n" ++ show2d(emptywells_controls_compounds_qtys) ++ "\n"  ++ show(emptywells_controls_compounds_qtys_total) ++ "\nRecommendations: choose a different strategy (set 'replicates_on_same_plate = false' and, if needed, set 'replicates_on_different_plates = true')");

array[int] of int: emptywells_controls_compounds_indices                      = [i | i in 1..len_emptywells_controls_compounds];
% emptywells_controls_compounds_indices - a short-hand index to make modeling easier

%%%%%%% Detecting some unsatisfiable cases & Data validation %%%%%%%%%%
% this one to be enabled later, if needed
%constraint assert(ceil(sum(compound_replicates)/numplates)*min(compound_concentrations++[infinity]) + sum([floor(control_concentrations[i]*control_replicates[i]/numplates) | i in 1..num_controls]) <= inner_plate_size, "Invalid data: the design is unsatisfiable. It is not possible to divide the compounds and controls evenly across the plates. (E01)");  
                                                                
% this one to be enabled later, if needed
%constraint assert((floor(sum(compound_replicates)/numplates)-1)*min(compound_concentrations++[infinity]) + max_compound_concentrations + sum([floor(control_concentrations[i]*control_replicates[i]/numplates) | i in 1..num_controls]) <= inner_plate_size, "Invalid data: the design is unsatisfiable. It is not possible to divide the compounds and controls evenly across the plates. (E02)");  
constraint forall(i in 1..num_plates_lines)
           (assert(sum(row(emptywells_controls_compounds_qtys,i)) = num_total_wells_line, "Model ERROR! Number of variables for wells in a line \(i) does not match!\n\(sum(row(emptywells_controls_compounds_qtys,i))) != \(num_total_wells_line)\n"));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


array[1..num_plates_lines, 1..num_total_wells_line] of int: emptywells_controls_compounds_indices_ordered =
                             % Perform a test for non-negative values
                            if forall(p in 1..num_plates_lines, i in 1..len_emptywells_controls_compounds)
                                     (emptywells_controls_compounds_qtys[p,i] >= 0)
                             % If passed - calculate the matrix properly
                          then array2d(1..num_plates_lines, 1..num_total_wells_line,
                                       [emptywells_controls_compounds_indices[i] | p in 1..num_plates_lines,
                                                                                   i in 1..len_emptywells_controls_compounds,
                                                                                   j in 1..emptywells_controls_compounds_qtys[p,i]])
                             % If not passed, because of faulty pre-calculations, put dummy data and let an assert output the error
                          else array2d(1..num_plates_lines, 1..num_total_wells_line,
                                       [1 | p in 1..num_plates_lines, i in 1..num_total_wells_line])
                         endif;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%-------------------CONSTRAINT MODEL (for randomizator)--------------------------
% TODO!!!! a proper ranodmization that does not take several minutes to perform. i.e. remove all the stuff related to quadrants and such (it overomplicates things)
% PLACEMENT VARIABLES:
array[1..num_plates_lines, 1..num_total_wells_line] of 1..num_rows_line: x =
      array2d(1..num_plates_lines, 1..num_total_wells_line,
              [i | p in 1..num_plates_lines, i in 1..num_rows_line, j in 1..num_cols_line
                   where (((i <= num_corner_empty_wells) \/ (i >= num_rows_line - num_corner_empty_wells + 1))
                           -> (j in num_corner_empty_wells + 1..num_cols_line - num_corner_empty_wells))
                   ]);
array[1..num_plates_lines, 1..num_total_wells_line] of 1..num_cols_line: y =
      array2d(1..num_plates_lines, 1..num_total_wells_line,
              [j | p in 1..num_plates_lines, i in 1..num_rows_line, j in 1..num_cols_line
                   where (((i <= num_corner_empty_wells) \/ (i >= num_rows_line - num_corner_empty_wells + 1))
                           -> (j in num_corner_empty_wells + 1..num_cols_line - num_corner_empty_wells))
                   ]);

%constraint forall(p in 1..num_plates_lines, q in 1..4)
%           (all_different([wells_line_lex_all_different_substitute[p,i] | i in 1..num_total_wells_line]));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


array[1..num_plates_lines, 1..num_total_wells_line] of var int: random_indices::no_output;

constraint forall(p in 1..num_plates_lines)
                 ([random_indices[p,k] | k in 1..num_total_wells_line] = arg_sort([cauchy(0,2) | i in 1..num_total_wells_line]));

solve satisfy;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CSV Ouput %%%

array[int] of string: letters_capital = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
array[int] of string: letters_inline  = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
array[int] of string: letters = letters_capital ++ [letters_capital[i] ++ letters_inline[j] | i in 1..length(letters_capital), j in 1..length(letters_inline)];

output [if not debugging then "plateID,well,cmpdname,CONCuM,cmpdnum,VOLuL\n" else "" endif];

output [if not debugging then "plate_\(p),"
 ++ letters[fix(calculate_line_index(inner_empty_edge, size_empty_edge, num_rows_line, h, x[p,fix(random_indices[p,k])]))]
 ++ if fix(calculate_line_index(inner_empty_edge, size_empty_edge, num_cols_line, v, y[p,fix(random_indices[p,k])])) < 10
      then "0" else "" endif
 ++ "\(calculate_line_index(inner_empty_edge, size_empty_edge, num_cols_line, v, y[p,fix(random_indices[p,k])]))"
 ++ ","
 ++ emptywells_controls_compounds_names_concentrations[1,emptywells_controls_compounds_indices_ordered[p,fix(random_indices[p,k])]]
 ++ ","
 ++ emptywells_controls_compounds_names_concentrations[2,emptywells_controls_compounds_indices_ordered[p,fix(random_indices[p,k])]]
 ++ ","
 ++ emptywells_controls_compounds_names_concentrations[1,emptywells_controls_compounds_indices_ordered[p,fix(random_indices[p,k])]]
 ++ "_"
 ++ emptywells_controls_compounds_names_concentrations[2,emptywells_controls_compounds_indices_ordered[p,fix(random_indices[p,k])]]
 ++ "\n" else "" endif | p in 1..num_plates_lines, k in 1..num_total_wells_line,
                         h in 1..horizontal_cell_lines, v in 1..vertical_cell_lines
                         where fix(emptywells_controls_compounds_indices_ordered[p,random_indices[p,k]]) > 1];
                             % fix(emptywells_controls_compounds_indices_ordered[p,k]) = 1]; % output only empty wells

output ["criteria function = -1000\n"];
