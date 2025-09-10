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


import os.path
import subprocess
import time
from libraries.utilities import save_plaid_layout, save_plaid_screening_layout, create_random_layout_screening

# functions:
def get_config_file(path, config):
    return path + config + '.mpc'

def run_cmd(minizinc_path, project_path,
            solver_config_name, model_files_list, data_directory, data_file):
    solver_config = get_config_file(project_path, solver_config_name)
    model_file = ''
    for model in model_files_list:
        model_file += project_path + model + '.mzn '
    data_file = data_directory + data_file
    cmd = minizinc_path + ' --param-file-no-push ' + solver_config + ' ' + model_file + data_file
    process = subprocess.Popen([cmd], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    #retval = process.wait()
    output, _ = process.communicate()
    output = output.decode('utf-8').strip()
    process.kill()
    return output

# for COMPD layouts
def extract_info(data_text):
    rows = 16
    cols = 24
    lines = data_text.rsplit('\n')
    
    for i in range(len(lines)):
        if lines[i] == "start printing":
            i_start = i + 1
        if lines[i] == "end printing":
            i_end = i
    res = [0 for i in range((rows-2)*(cols-2))]
    for i in range(i_start, i_end):
        if lines[i][:10] == 'printing: ':
            res_i = [int(x) for x in lines[i][10:].rsplit(',')]
            res[(res_i[1]-1)*(cols-2) + res_i[2] - 1] = res_i[0]
    return res

# can be used for PLAID layouts, if there is a need to regenerate them
def extract_info_plaid(data_text):
    for line in data_text.rsplit('\n'):
        if line[:6] == 'Plate:':
            res = line[6:]
    return res

def paths():
    # list relevant paths:
    minizinc_path = '/Applications/MiniZincIDE.app/Contents/Resources/minizinc'
    project_path = 'compd-files/'
    return minizinc_path, project_path

def run_config(config, model_files_list,
               data_directory = 'dzn-files/screening/',
               npy_directory = 'layouts/screening_COMPD_layouts',
               num_max = 40):
    (minizinc_path, project_path) = paths()

    os.makedirs(os.path.dirname(npy_directory + '/'), exist_ok = True)

    data_file_list = [each for each in os.listdir(data_directory) if each.endswith('.dzn')]

    print('data_file_list = ', data_file_list)
    
    print(config + ':')

    times = [[0 for i in range(num_max)] for j in range(len(data_file_list))]
    r = -1

    for data_file in data_file_list:
        r += 1
        for k in range(num_max):
            t_start = time.perf_counter()
            cmd_to_str = run_cmd(minizinc_path, project_path,
                                 config, model_files_list, data_directory, data_file)
            #array_string = extract_info_plaid(cmd_to_str)
            array_nums = extract_info(cmd_to_str)
            t_end = time.perf_counter()
            #print(data_file, t_end - t_start, array_string[:10])
            times[r][k] = t_end - t_start
            save_plaid_screening_layout(str(k+1).zfill(2),
                                        array_nums,
                                        16, 24, 1,
                                        npy_directory)
        
    print('finished')
    for t in times:
        print(t)


def run_config_d_r(config, model_files_list,
                   data_directory = 'dzn-files/compounds/',
                   npy_directory = 'layouts/compounds_COMPD_layouts',
                   num_max = 20):
    (minizinc_path, project_path) = paths()

    os.makedirs(os.path.dirname(npy_directory + '/'), exist_ok = True)

    #data_file_list = [each for each in os.listdir(data_directory) if each.endswith('.dzn')]

    #print('data_file_list = ', data_file_list)
    
    print(config + ':')

    concentrations_list = [6, 8, 12]
    replicates_list = [1, 2, 3]
    

    times = [[0 for i in range(num_max)] for j in range(len(concentrations_list) * len(replicates_list))]
    r = -1

    for concentrations in concentrations_list:
        for replicates in replicates_list:
            r += 1
            compounds = (14*22-20)//(concentrations*replicates)
            
            data_file = 'compounds-validation-' + str(compounds)+'-'+str(concentrations)+'-'+str(replicates) + '.dzn'
            print(data_file,':')
            
            for k in range(num_max):
                t_start = time.perf_counter()
                cmd_to_str = run_cmd(minizinc_path, project_path,
                                     config, model_files_list, data_directory, data_file)
                array_nums = extract_info(cmd_to_str)
                t_end = time.perf_counter()
                times[r][k] = t_end - t_start
#def save_plaid_layout(plate_id, layout_array, num_rows=16, num_columns=24, compounds=36, concentrations=4, replicates=2, size_empty_edge=1, neg_controls=20,directory="layouts/compounds_PLAID_layouts"):                
                save_plaid_layout(str(k+1).zfill(2),
                                  array_nums,
                                  16, 24, compounds, concentrations, replicates, 1, 20,
                                  npy_directory)
        
    print('finished')
    for t in times:
        print(t)