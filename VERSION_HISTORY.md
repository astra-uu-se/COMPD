# Version history

## Version 1.1.1

1. Now, the flag `inner_empty_edge` is not hard-coded, and instead depends on the optional input parameter `inner_empty_edge_input`. i.e. the data file now determines what kind of borders the model must use.


## Version 1.1


1. Changes in the handling of fake edge wells:
	- the threshold on the maximum number of wells within a criteria set to activate the fake edge wells for the criteria set is increased from 4 to 6;
	- the number of fake edge wells is increased from 8 to 16;
	- coordinates of fake edge wells are also adjusted (by moving them one row/column away from the plate line)

2. Adjusted the optimization criteria to give more weight to the minimal distances within criteria sets that contain controls. i.e. it should result in the optimization process that priotitizes the placement of controls first. COMPD's main strength, according to the evaluation, is the placement of control wells given enough time. Thus, it would be prudent to capitalize on this strength and ensure that even if the optimization process is interrupted early, we still get a layout with satisfactory placement controls.
