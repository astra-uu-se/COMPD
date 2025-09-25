# Version history

Note: The changes reference equations and sections from the article

## Version 1.21 (Sept 25 2025)

Minor fixes:
- added a warning when the number of wells per line is =< 0
- a couple of counting tensors were renamed (removed `min_dist` from the name as these tensors are not used during the calculation of the minimal distances)

## Version 1.2 (Sept 24 2025)

Optional constraints reworked to be more nuanced/consistent:

- if a half (top/bottom/right/left) has fewer or an equal number of wells than its number of rows/columns, then all_different is applied (same as before),
- if a half (top/bottom/right/left) has a greater number of wells than its number of rows/columns, then the global cardinality constraint (gcc) is applied to ensure that there is at least one well per row/column in this half.

Thus, we'll first split existing flags emptywells_controls_compounds_concentrations_on_different_* (which correspond) into:

- emptywells_controls_compounds_concentrations_on_different_rows_top     (top, all_different)
- emptywells_controls_compounds_concentrations_on_different_rows_top_gcc (top, gcc)
- emptywells_controls_compounds_concentrations_on_different_rows_btm     (bottom, all_different)
- emptywells_controls_compounds_concentrations_on_different_rows_btm_gcc (bottom, gcc)
- emptywells_controls_compounds_concentrations_on_different_columns_lft     (left, all_different)
- emptywells_controls_compounds_concentrations_on_different_columns_lft_gcc (left, gcc)
- emptywells_controls_compounds_concentrations_on_different_columns_rgt     (right, all_different)
- emptywells_controls_compounds_concentrations_on_different_columns_rgt_gcc (right, gcc)

Same with flags emptywells_controls_compounds_concentrations_on_different_*_all_plates

This behaviour should:

- reduce the number of situations when the model is unsatisfiable due to optional constraints
- ensure that every row/column is covered if there are too many wells with the criteria set (previously, it was not enforced)
- the previous point, potentially, can lead to increased performance as the number of potential well placements is reduced (this point must be tested)

These changes replace Equations 7-11 with a more sophisticated set of constraints. They also slightly update Equations 12 and 13

Note: the resulting behaviour still depends on the placement of wells between the quadrants. Thus, if the division of wells is unbalanced, then some rows/columns in one half could be empty, while the other half would have 2+ wells per row/column.

## Version 1.1.1 (Sept 23 2025)

1. Now, the flag `inner_empty_edge` is not hard-coded, and instead depends on the optional input parameter `inner_empty_edge_input`. i.e. the data file now determines what kind of borders the model must use.


## Version 1.1 (Sept 22 2025)


1. Changes in the handling of fake edge wells:
	- the threshold on the maximum number of wells within a criteria set to activate the fake edge wells for the criteria set is increased from 4 to 6 (see end of Section 4.2);
	- the number of fake edge wells is increased from 8 to 16 (f = 16, see Section 4.5);
	- coordinates of fake edge wells are also adjusted, by moving them one row/column away from the plate line (updates Equation 14)

2. Adjusted the optimization criteria to give more weight to the minimal distances within criteria sets that contain controls. i.e. it should result in the optimization process that priotitizes the placement of controls first. COMPD's main strength, according to the evaluation, is the placement of control wells given enough time. Thus, it would be prudent to capitalize on this strength and ensure that even if the optimization process is interrupted early, we still get a layout with satisfactory placement controls.

## Version 1.0 (July 2025)

Initial version. Corresponds to the article (tbd)
