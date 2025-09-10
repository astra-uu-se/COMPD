

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SCREENINGS TEST PRINT %%%
%output ["Plate:" ++ 
%         show([if emptywells_controls_compounds_indices_ordered[p,k] = 1
%            then 0
%          elseif emptywells_controls_compounds_indices_ordered[p,k] in 2..1 + sum(control_concentrations)
%            then emptywells_controls_compounds_indices_ordered[p,k] + sum(compound_concentrations) - sum(control_concentrations) + 1
%            else emptywells_controls_compounds_indices_ordered[p,k] - sum(control_concentrations) - 1
%           endif
%              | p in 1..num_plates_lines, 
%                r in 1..num_rows_line, c in 1..num_cols_line,
%                k in 1..num_total_wells_line
%                where r = emptywells_controls_compounds_coordinates[p,k,1] /\
%                      c = emptywells_controls_compounds_coordinates[p,k,2]
%              ]
%             )];
output ["start printing\n"];
output ["printing: \(if emptywells_controls_compounds_indices_ordered[p,k] = 1
            then 0
          elseif emptywells_controls_compounds_indices_ordered[p,k] in 2..1 + sum(control_concentrations)
            then emptywells_controls_compounds_indices_ordered[p,k] + sum(compound_concentrations) - sum(control_concentrations) + 1
            else emptywells_controls_compounds_indices_ordered[p,k] - sum(control_concentrations) - 1
           endif),"
           ++
           "\(emptywells_controls_compounds_coordinates[p,k,1]),"
           ++
           "\(emptywells_controls_compounds_coordinates[p,k,2])\n"
              | p in 1..num_plates_lines, 
                k in 1..num_total_wells_line
                where emptywells_controls_compounds_indices_ordered[p,k] > 1
              ];
output ["end printing\n"];
