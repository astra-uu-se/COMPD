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
# Purpose: GIVE COMPD DOSE-RESPONSE LAYOUTS DISTINCT NAMES FROM PLAID LAYOUTS
# Author : Ramiz Gindullin, Uppsala University

import os

npy_directory = 'layouts/compounds_COMPD_layouts'

for file_old in os.listdir(npy_directory):
    if file_old.endswith('.npy'):
        print(file_old, 'plate_layout_40' + file_old[15:])
        os.rename(os.path.join(npy_directory, file_old),  os.path.join(npy_directory, 'plate_layout_40' + file_old[15:]))
