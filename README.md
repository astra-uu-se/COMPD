# COMPD
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Constraint Optimization of MicroPlate Designs

This is a constraint optimization model written in MiniZinc. It is used for effective microplate layout generation and improves on [PLAID](https://github.com/pharmbio/plaid/) in several crucial ways:

 - improved performance on larger microplates and dramatically decreased resource consumption,
 - COMPD generates more effective layouts on larger microplates
 - COMPD supports more microplate templates:
   - plate lines with an odd number of rows and/or columns,
   - forcing corners to be empty
- flexible approach to spreading the materials of the same type, i.e. the thresholds for minimum possible distances are not hard-coded and, instead, are found dynamically.

The full explanation can be found in the paper "Constraint Optimization of MicroPlate Designs" (TBD: link and DOI)

To test, you can use the `*.dzn` files from `evaluation/regression-tests` directory or a small example from `https://github.com/pharmbio/plaid/blob/main/small-example.dzn`

To make the workflow with COMPD more fluid and intuitive, you can use [GUI-for-MiniZinc-microplates-models](https://github.com/astra-uu-se/GUI-for-MiniZinc-microplates-models).


## Evaluation
The directory `evaluation` contains instructions on how to execute the evaluation section of the paper. Note that the current version of [plate-optimizer.mzn](https://github.com/astra-uu-se/COMPD/blob/main/plate-optimizer.mzn) can differ from the [version](https://github.com/astra-uu-se/COMPD/blob/main/evaluation_aaai26/compd-files/plate-optimizer-model.mzn) used in the evaluation (as it was updated since).


## Credits

COMPD is developed by [Ramiz Gindullin](https://orcid.org/0000-0003-4947-9641) and [Maria Andreina Francisco Rodriguez](https://orcid.org/0000-0001-8745-9858).

Paper (TBD add link) can be used to cite COMPD.

## License
COMPD has an Apache 2.0 LICENSE. The COMPD team accepts no responsibility or liability for the use of COMPD or any direct or indirect damages arising out of its use.
