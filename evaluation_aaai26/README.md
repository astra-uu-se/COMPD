# COMPD evaluation

This is the source code to replicate the evaluation in the article TODO

The evaluation is based on [PLAID evaluation](https://github.com/pharmbio/plaid/tree/multiplate-poc/simulations), thus random and PLAID layouts in the 

Note: we require Python 3.xx to be installed. The package `matplotlib` must have a version no greater than 3.7.3 for compatibility.





## Step 1 - acquire the layouts

Either:

  1. Uncompress the file `layouts.zip` (these are layouts which we used in the evaluation), or
  2. Download [random and PLAID layouts](https://github.com/pharmbio/plaid/tree/multiplate-poc/simulations/layouts) and generate COMPD layouts with commands:

     ```
     python3 create_compd_layouts.py
     python3 create_compd_layouts_dose_response.py
     ```
## Step 2 - perform the experiments

  1. Execute Jupyter notebooks `dose-response-experiments.ipynb` and `screening-experiments.ipynb`.
  2. Create empty directories:
     - `generated-data\dose-response`
     - `generated-data\quality-assessment-metrics`
     - `generated-data\screening`
     - `generated-plots\dose-response-supplement`
     - `generated-plots\PLAID-bioseminar-plots-2021`
     - `generated-plots\plate-layouts`
     - `generated-plots\quality-assessment-metrics`
     - `screening-supplement`
     - `latex-tables`
  3. Execute remaining Jupyter notebooks. Note that in the notebooks, the citation of a specific article figure is done according to the PLAID article. Consult the supplement of the AAI26 article with correct mapping to the newly generated figures.

## Step 3 - update the supplementary materials

We only provide the source code for the document. Use figures from the `generated-plots` directory.
