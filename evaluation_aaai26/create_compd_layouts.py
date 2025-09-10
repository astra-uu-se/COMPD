#    The contents of this file are subject to the Mozilla Public License
#    Version  2.0  (the "License"); you may not use this file except in
#    compliance with the License. You may obtain a copy of the License at:
#
#    http://www.mozilla.org/MPL/
#
#    Software  distributed  under  the License is distributed on an "AS
#    IS"  basis,  WITHOUT  WARRANTY  OF  ANY  KIND,  either  express or
#    implied.
#
# Purpose: EXECUTE THE EVALUATION AND RECORD ITS RESULTS
# Author : Ramiz Gindullin, Uppsala University


from generate_layouts_utilities import run_config

run_config('cpsat_config', ['plate-optimizer-model',
                            'plate-optimizer-strategy-default',
                            'plate-optimizer-output-screenings'])

