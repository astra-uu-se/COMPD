# COMPD (Constraint Optimization of MicroPlate Designs)
This repository contains materials to reproduce the evaluation section of the submitted paper "Constraint Optimization of MicroPlate Designs" (link and DOI to be added)

The materials include:

1. The test dataset (in the folder `regression-tests\`)
2. Model files for PLAID, COMPD and randomized layouts
3. Scripts and configuration files to run computational experiments and evaluate generated layouts
4. Generated layouts for PLAID and COMPD, randomized layouts


# The test dataset
The data files are placed in the folder `regression-tests\`. Some of the examples are taken from https://github.com/pharmbio/plaid/tree/main/regression-tests and renamed. The list of matches between the old filenames and the new filenames is in the end of this readme text (section 'Dataset matching')


# Model files

The repository contains the following model files written in MiniZinc format (https://www.minizinc.org/):

- for randomized layouts:
	- `plate-randomizer.mzn` to generate a randomized layout
- for PLAID:
	- `plate-design.mzn` to generate a layout. Source: https://github.com/pharmbio/plaid/blob/9bc23c5e0ec4c966b8ba4f6e549a8fe87d9a737f/plate-design.mzn (the version from Oct 11, 2024)
	- `layout_predicates.mzn`, contains predicates used by `plate-design.mzn`. Source: https://github.com/pharmbio/plaid/blob/33367a41c9a0902c2855e706692c8c8863dfa964/layout_predicates.mzn (the version from Aug 14, 2024)
- for COMPD:
	- `plate-optimizer.mzn`, the full package, generates a layout from a data file and outputs it in the format compatible with *.csv files
	- `plate-optimizer-model.mzn`, contains only the constraints and pre-calculculations from `plate-optimizer.mzn`, i.e. equations (4)--(20) from the article
	- `plate-optimizer-strategy-default.mzn`, contains only the optimization criteria from `plate-optimizer.mzn` and the default search strategy. Requires to be used together with `plate-optimizer-model.mzn`. For future testing, alternative search strategies could be introduced in different files, while retaining the compatibility with `plate-optimizer-model.mzn` and `plate-optimizer-output.mzn`.
	- `plate-optimizer-output.mzn`, to output the produced microplate layout either in a *.csv file compatible format or output debugging information.
	- `plate-optimizer-output-warm-start.mzn`, outputs all the variables required for the warm start. Requires to be used together with `plate-optimizer-model.mzn`
	- `plate-optimizer-strategy-generated.mzn`, generated authomatically by a script after running `plate-optimizer-model.mzn` and `plate-optimizer-output-warm-start.mzn`. This model file is ran together with `plate-optimizer-model.mzn` and `plate-optimizer-output.mzn` and uses warm start variables for Chuffed.


# Executing computational experiments

To execute the computational experiments first install and configure Python (version 3.7.0 or later), MiniZinc (version 2.8.0 or later). Make sure that the versions of installed solvers, GeCode and Chuffed, match the versions written in the configuration files `chuffed_config.mpc`, `chuffedWS_config.mpc`, `gecode8c_config`, `gecode8cNoTO_config` and `gecode8cWS_config.mpc` respectively.

Then:

1. Open a bash shell and position yourself in the directory containing files `calculate_energy.py`, `run_evaluation_cfg_chuffed_d.py`, `run_evaluation_cfg_gecode_d.py`, `run_evaluation_cfg_random_warm_chuffed.py`, `run_evaluation_cfg_random.py`, `run_evaluation.py` 
2. Modify the file paths in `run_evaluation.py` and `calculate_energy.py`, if needed
3. Execute the following commands, sequentially or in parallel, to generate layouts for all models/strategies:
	1. `time python3 run_evaluation_cfg_random.py` to generate randomized layouts (1 thread). The layouts will be stored in the directory `csv/chuffed_config_plate-randomizer/`
	2. `time python3 run_evaluation_cfg_gecode8c_plaid.py` to generate layouts with PLAID (8 threads). The layouts will be stored in the directory `gecode8cNoTO_config_plate-design/`
	3. `time python3 run_evaluation_cfg_gecode_d.py` to generate layouts with COMPD strategy 1 (8 threads). The layouts will be stored in the directory `csv/gecode8c_config_plate-optimizer-model/`
	4. `time python3 run_evaluation_cfg_chuffed_d.py` to generate layouts with COMPD strategy 2 (1 thread). The layouts will be stored in the directory `csv/chuffed_config_plate-optimizer-model/`
	5. `time python3 run_evaluation_cfg_random_warm_chuffed.py` to generate layouts with COMPD strategy 3 (8 threads). The layouts will be stored in the directory `csv/randomized_warmstart/`
4. Execute the following command to calculate cumulative Fruchterman and Reingold energy for every generated layout:
	`time python3 calculate_energy.py`

The results that are presented in the article are stored in the file `all results.ods`


# Dataset matching

Old names are taken from https://github.com/pharmbio/plaid/tree/main/regression-tests

New names are used in the article. They are sorted in the order of increasing difficulty

| Old name                   | New name       |
| -------------------------- | -------------- |
| 2020-09-30-jonne-slack     | test-plate-043 |
| 2020-10-08-jonne-slack     | test-plate-047 |
| 2020-11-13-jonne-slack     | test-plate-029 |
| compounds-10-9-3           | test-plate-044 |
| dose-response-20-3-1       | test-plate-048 |
| dose-response-20-3-2       | test-plate-046 |
| dose-response-20-3-3       | test-plate-045 |
| jonne-1plate               | test-plate-051 |
| jonne-2plates              | test-plate-059 |
| jonne-3plates              | test-plate-062 |
| jonne-4plates              | test-plate-064 |
| OASIS\_DILI_ECP\_1dose     | test-plate-065 |
| OASIS\_DILI_ECP\_1plates   | test-plate-052 |
| OASIS\_DILI_ECP\_2plates   | test-plate-060 |
| pl-example01               | test-plate-033 |
| pl-example02               | test-plate-041 |
| pl-example03               | test-plate-020 |
| pl-example04-jonne-doubled | test-plate-054 |
| pl-example05               | test-plate-022 |
| pl-example06               | test-plate-023 |
| pl-example07               | test-plate-008 |
| pl-example08               | test-plate-028 |
| pl-example09               | test-plate-025 |
| pl-example10               | test-plate-034 |
| pl-example11               | test-plate-055 |
| pl-example12               | test-plate-011 |
| pl-example13               | test-plate-024 |
| pl-example14               | test-plate-015 |
| pl-example15               | test-plate-006 |
| pl-example16               | test-plate-018 |
| pl-example17               | test-plate-021 |
| pl-example18               | test-plate-017 |
| pl-example19               | test-plate-030 |
| pl-example20               | test-plate-037 |
| pl-example21               | test-plate-016 |
| pl-example22               | test-plate-007 |
| pl-example23               | test-plate-056 |
| pl-example24               | test-plate-058 |
| pl-example25               | test-plate-027 |
| pl-example27               | test-plate-032 |
| pl-example28               | test-plate-035 |
| pl-example29               | test-plate-026 |
| pl-example30               | test-plate-013 |
| pl-example35               | test-plate-042 |
| pl-example36               | test-plate-002 |
| pl-example37               | test-plate-004 |
| pl-example38               | test-plate-031 |
| pl-example39               | test-plate-019 |
| pl-example42               | test-plate-038 |
| pl-example43               | test-plate-001 |
| pl-example44               | test-plate-057 |
| pl-example45               | test-plate-050 |
| pl-example46               | test-plate-053 |
| pl-example47               | test-plate-061 |
| pl-example48               | test-plate-063 |
| pl-example49               | test-plate-039 |
| pl-example50               | test-plate-036 |
| pl-example51               | test-plate-040 |
| pl-example52               | test-plate-003 |
| pl-example53               | test-plate-010 |
| pl-example54               | test-plate-005 |
| pl-example55               | test-plate-012 |
| pl-example56               | test-plate-009 |
| screening-8-8-1            | test-plate-049 |