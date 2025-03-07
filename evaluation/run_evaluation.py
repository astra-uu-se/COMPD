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


import math
import os.path
import subprocess

# functions:
def get_config_file(path, config):
    return path + config + '.mpc'

def run_cmd(minizinc_path, project_path, timeout_set,
            solver_config_name, model_files_list, data_directory, data_file):
    solver_config = get_config_file(project_path, solver_config_name)
    model_file = ''
    for model in model_files_list:
        model_file += project_path + model + '.mzn '
    data_file = project_path + data_directory + data_file
    cmd = minizinc_path + ' --param-file-no-push ' + solver_config + ' ' + model_file + data_file
    process = subprocess.Popen([cmd], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    #retval = process.wait()
    output, _ = process.communicate()
    output = output.decode('utf-8').strip()
    process.kill()
    return output

def gen_wrm(minizinc_path, project_path, solver_config_name,
            model_file_main, model_file_warm_output, model_file_main_strategy,
            data_directory, data_file):
    #step 1 - run randomized search
    #step 2 - read the output
    #step 3 - if there's parsable output generate model_file_main_strategy with warm start variables
    #         otherwise generate default model_file_main_strategy
    solver_config = get_config_file(project_path, solver_config_name)
    model_file = ''
    for model in [model_file_main, model_file_warm_output]:
        model_file += project_path + model + '.mzn '
    data_file = project_path + data_directory + data_file
    cmd = minizinc_path + ' --param-file-no-push ' + solver_config + ' ' + model_file + data_file
    process = subprocess.Popen([cmd], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, _ = process.communicate()
    output = output.decode('utf-8').strip()
    process.kill()
    (is_extracted, warm_starts) = extract_warm_starts(output)
    
    with open(project_path + model_file_main_strategy + '.mzn', 'w') as main_strategy_file:
        if is_extracted:
            strs =['solve::seq_search([warm_start(array1d(emptywells_controls_compounds_coordinates), ',
                   '), warm_start(array1d(wells_line_lex_all_different_substitute), ',
                   '), warm_start(min_dist_criteria_vars, ',
                   '), warm_start(distances_edges_controls_compounds_minimum, ',
                   '), warm_start([min_distance], ',
                   ')]) minimize - min_distance * 1000 - sum(distances_edges_controls_compounds_minimum);']
            main_strategy_file.write(strs[0] + warm_starts[0] +
                                     strs[1] + warm_starts[1] +
                                     strs[2] + warm_starts[2] +
                                     strs[3] + warm_starts[3] +
                                     strs[4] + warm_starts[4] +
                                     strs[5])
        else:
            main_strategy_file.write('solve minimize - min_distance * 1000 - sum(distances_edges_controls_compounds_minimum);')
        main_strategy_file.close()
    


def extract_data(data_text):
    #print(data_text) # disable - for testing purposes only
    data_text_lines = data_text.rsplit('\n')
    # default values
    solution = '0'
    time_elapsed = '0'
    # see if default values can be overwritten
    for line in data_text_lines:
        if line == 'plateID,well,cmpdname,CONCuM,cmpdnum,VOLuL':
            solution = '1' # to catch the cases for the satisfaction model
        if line[:20] == 'criteria function = ':
            solution = line[21:]
        if line[:16] == '% time elapsed: ':
            time_elapsed = line[16:-2]
    return solution, time_elapsed

def extract_warm_starts(data_text):
    #print(data_text)
    is_extracted = False
    warm_starts = ['' for i in range(5)]
    data_text_lines = data_text.rsplit('\n')
    for line in data_text_lines:
        if line[:5] == 'w1 = ':
            warm_starts[0] = line[5:]
        if line[:5] == 'w2 = ':
            warm_starts[1] = line[5:]
        if line[:5] == 'w3 = ':
            warm_starts[2] = line[5:]
        if line[:5] == 'w4 = ':
            warm_starts[3] = line[5:]
        if line[:5] == 'w5 = ':
            warm_starts[4] = line[5:]
        if line[:20] == 'criteria function = ':
            is_extracted = True
    #print(is_extracted, warm_starts)
    return is_extracted, warm_starts

def extract_info(data_text):
    for line in data_text.rsplit('\n'):
        if line[:4] == 'info':
            return line[4:]

def extract_timeout(path, config):
    with open(get_config_file(path, config),'r') as myfile:
        for line in myfile:
            if line.strip()[:14] == '"time-limit": ':
                return int(math.ceil(int(line.strip()[14:]) / 1000))
    return 0 # return default value

def extract_csv_text(text):
    s, e = 0, 0
    lines = text.split('\n')
    for i in range(len(lines)):
        if lines[i] == 'plateID,well,cmpdname,CONCuM,cmpdnum,VOLuL':
            s = i
        if lines[i][:17] == 'criteria function' or lines[i][:1] == '%' or lines[i] == '----------' or lines[i] == 'finished':
            if e <= s:
                e = i
    return [line + '\n' for line in lines[s:e]]


def paths():
    # list relevant paths:
    minizinc_path = '/Applications/MiniZincIDE.app/Contents/Resources/minizinc'
    project_path = ''
    data_directory = 'regression-tests/'
    csv_directory = 'csv/'
    return minizinc_path, project_path, data_directory, csv_directory

def run_config(config, model_files_list):
    (minizinc_path, project_path, data_directory, csv_directory) = paths()

    timeout_set = extract_timeout(project_path, config) # deprecated functionality

    data_file_list = [each for each in os.listdir(project_path + data_directory) if each.endswith('.dzn')]
    print('data_file_list = ', data_file_list)
    
    csv_config = project_path + csv_directory + config + '_' + model_files_list[0]
    csv_config_dir = csv_config + '/'
    
    os.makedirs(os.path.dirname(csv_config_dir), exist_ok = True)
    
    config_stats = open(csv_config + '.csv', 'w')
    config_stats.write('DznFile,Solution,Time\n')
    
    print(config + ', ' + str(timeout_set) + 's')

    for data_file in data_file_list:
        if data_file != 'pl-example18.dzn': # for test purposes
            None #continue
        cmd_to_str = run_cmd(minizinc_path, project_path, timeout_set,
                             config, model_files_list, data_directory, data_file)
        criteria, running_time = extract_data(cmd_to_str)
        print(criteria, data_file)
        
        if criteria == '0':
            config_stats.write(data_file + ',No,' + running_time + '\n')
        else:
            config_stats.write(data_file + ',Yes,' + running_time + '\n')
        
         # if 'timeout_set == 0' then we're using satisfaction model
        if criteria != 0 or timeout_set == 0:
            csv_text = extract_csv_text(cmd_to_str)
            with open(csv_config_dir + data_file[:-3] + 'csv', 'w') as csv_file:
                csv_file.writelines(csv_text)
                csv_file.close()
    config_stats.close()
    print('finished')

def run_warm_search_config(config_random,
                           config_optim,
                           model_file_main,
                           model_file_warm_output,
                           model_file_main_strategy,
                           model_file_main_output
                           ):
    (minizinc_path, project_path, data_directory, csv_directory) = paths()
    
    timeout_set = extract_timeout(project_path, config_random) # deprecated functionality
    
    data_file_list = [each for each in os.listdir(project_path + data_directory) if each.endswith('.dzn')]
    print('data_file_list = ', data_file_list)
    
    csv_config = project_path + csv_directory + 'randomized_warmstart'
    csv_config_dir = csv_config + '/'
    
    os.makedirs(os.path.dirname(csv_config_dir), exist_ok = True)
    
    config_stats = open(csv_config + '.csv', 'w')
    config_stats.write('DznFile,Solution,Time\n')
    
    print('randomized_warmstart, (300+600)s')

    for data_file in data_file_list:
        if data_file != 'OASIS_DILI_ECP_3plates.dzn': # for test purposes
            None #continue
        gen_wrm(minizinc_path, project_path, config_random,
                model_file_main, model_file_warm_output, model_file_main_strategy,
                data_directory, data_file)
        cmd_to_str = run_cmd(minizinc_path, project_path, timeout_set,
                             config_optim, [model_file_main, model_file_main_strategy, model_file_main_output],
                             data_directory, data_file)
        criteria, running_time = extract_data(cmd_to_str)
        print(criteria, data_file)
        
        if criteria == '0':
            config_stats.write(data_file + ',No,' + running_time + '\n')
        else:
            config_stats.write(data_file + ',Yes,' + running_time + '\n')
        
         # if 'timeout_set == 0' then we're using satisfaction model
        if criteria != 0 or timeout_set == 0:
            csv_text = extract_csv_text(cmd_to_str)
            with open(csv_config_dir + data_file[:-3] + 'csv', 'w') as csv_file:
                csv_file.writelines(csv_text)
                csv_file.close()
    config_stats.close()
    print('finished')
    
def run_info(config, model_files_list):
    (minizinc_path, project_path, data_directory, csv_directory) = paths()

    timeout_set = extract_timeout(project_path, config) # deprecated functionality

    data_file_list = [each for each in os.listdir(project_path + data_directory) if each.endswith('.dzn')]
    print('data_file_list = ', data_file_list)
    
    csv_config = project_path + csv_directory + config + '_' + model_files_list[0]
    csv_config_dir = csv_config + '/'
        
    print(config + ', ' + str(timeout_set) + 's')

    for data_file in data_file_list:
        cmd_to_str = run_cmd(minizinc_path, project_path, timeout_set,
                             config, model_files_list, data_directory, data_file)
        print(data_file, extract_info(cmd_to_str))
    print('finished')
