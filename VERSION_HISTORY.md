# Version history

Note: The listed changes reference equations and sections from the article

## Version 1.3.0 (Nov 20 2025)
- updated the constraint model. I replaced the constraints in equation (15) of the original article with. Instead of using criteria-set-minimal-distance-variable = min(the-list-of-distances-in-the-criteria-set), COMPD now uses a set of constraints criteria-set-minimal-distance-variable =< distance-in-the-criteria-set for each distance. It reduces the memory consumption by ~5-10% and, in some cases and solvers, slightly reduces the solution time

## Version 1.2.9 (Nov 14 2025)
- refactoring: applying the same approach of helper functions introduced in 1.2.8 to the domain and all optional constraints. Benefits - readability and encapsulated logic. Significantly reduced number of lines

## Version 1.2.8 (Nov 14 2025)
- minor refactoring: introduced three helper functions to encapsulate common logic for calculating arrays emptywells_controls_compounds_concentrations_on_different_* (reduction by ~60 lines)

## Version 1.2.7 (Nov 14 2025)
- further minor refactoring to slightly reduce the number of lines (not that much) and make the code slightly more readable (removing well_included_by_optional_constraints since it's possible to simply use negation of well_excluded_by_optional_constraints)
- fixed an old bug that was present since 1.0: constraint that iterated over materials and used well_excluded_by_optional_constraints (or its equivalent in 1.0), was incorrectly passing a criteria set index instead of a material index. In most cases, it did not produce a serious violation of optional constraints, but it was still an error in logic which the model was supposed to obey.

## Version 1.2.6 (Nov 13 2025)
- further minor refactoring to slightly reduce the number of lines (not that much) and make the code slightly more readable (introducing functions well_excluded_by_optional_constraints and well_included_by_optional_constraints)
- fixed a cosmetic bug introduced in 1.2.5 when some debugging information was printed despite the debugging flag being false

## Version 1.2.5 (Nov 13 2025)
- further minor refactoring to slightly reduce the number of lines (not that much) and make the code slightly more readable

## Version 1.2.4 (Nov 13 2025)

- minor refactoring: rewrote some of the conditions for the optional constraints to be more concise and direct, without changing their structure or behavior
- Added a couple of commentaries


## Version 1.2.3 (Oct 2 2025)

Minor fixes (to handle rare edge cases):
- `min_dist_edges` is now guaranteed to be a positive integer (otherwise it conflicted with domains of distance variables)
- generalized the previous fix, where instead of checking the number of rows/columns, it takes an already existing flag `use_quadrant_distribution` (for simplicity)

## Version 1.2.2 (Oct 2 2025)

Minor fixes (to handle rare edge cases):
- fixing an upper limit for GCC optional constraint when applied on multiple plates (otherwise it can be too restrictive)
- if the number of rows/columns is equal to 1, then set the respective flags for optional constraints to `false` (to not put unnecessary constraints in this situation)
- A few lines of text are aligned in a more consistent manner

## Version 1.2.1 (Sept 25 2025)

Minor fixes:
- added a warning when the number of wells per line is =< 0 (otherwise the model stopped without explanation)
- a couple of counting tensors were renamed (removed `min_dist` from their names, as these tensors are not used during the calculation of the minimal distances)

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
