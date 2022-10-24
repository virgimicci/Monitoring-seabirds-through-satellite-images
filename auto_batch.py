# -*- coding: utf-8 -*-
"""
Created on Wed Oct 19 10:09:03 2022

@author: chiara salv ☺
@title: Automatic processing
"""

# Libraries and modules
import folder_manag as fm
#...che sarebbe lo script che ho creato.
# In questo script viene importato come modulo.
import os
import argparse as ap
# oppure, per importare direttamente tutti i suoi moduli,
# senza doverlo sempre richiamare nel codice, 
# from argparse import *
# Stesso discorso vale per folder_manag!

# - - - - - - - - - - - - - - - - - - - - - - - 

p = ap.ArgumentParser()

# Input directory/path
p.add_argument('-input_Data_Dir',
     required = True,
     help = 'Write the Input directiory of datas',
     metavar = '<string>')

# Output directory/path
p.add_argument('-output_Data_Dir',
     required = True,
     help = 'Write the Output directory of datas',
     metavar = '<string>')

# Snap graph directory/path
p.add_argument('-snap_graph_Dir',
     required = True,
     help = 'Write the directory of the SNAP graph',
     metavar = '<string>')

'''
# Expression directory/path 
p.add_argument('-expression_Dir',
     required = True,
     help = 'Expression',
     metavar = '<string>')

# Water Salinity and Temperature
p.add_argument('-water_salinity',
     required = True,
     help = 'Water salinity',
     metavar = '<string>')

p.add_argument('-water_temperature',
     required = True,
     help = 'Water temperature',
     metavar = '<string>')
'''

# Extention of input data
p.add_argument('-input_Data_Extention',
     required = True,
     help = 'Write the extension of Input data',
     metavar = '<string>')

# Extention of output data
p.add_argument('-output_Data_Extention',
     required = True,
     help = 'Write the extension of Output data',
     metavar = '<string>')


# Parametri
prmts = vars(p.parse_args())
input_Data_Dir = prmts['input_Data_Dir']
output_Data_Dir = prmts['output_Data_Dir']
snap_graph_Dir = prmts['snap_graph_Dir']
#expression_Dir = prmts['expression_Dir']
#water_salinity = prmts['water_salinity']
#water_temperature = prmts['water_temperature']
input_Data_Extention = prmts['input_Data_Extention']
output_Data_Extention = prmts['output_Data_Extention']

print('input_Data_Dir = ', input_Data_Dir) 
print('output_Data_Dir = ', output_Data_Dir)
print('snap_graph_Dir = ', snap_graph_Dir)
#print('expression_Dir = ', expression_Dir)
#print('water_salinity = ', water_salinity)
#print('water_temperature = ', water_temperature)
print('input_Data_Extention = ', input_Data_Extention)
print('output_Data_Extention = ', output_Data_Extention)

directories = fm.create_fold(input_Data_Dir, output_Data_Dir)
print('Directories: {}'.format(directories))

os.chdir(input_Data_Dir)
for dirs in directories: 
    print(dirs)
    os.chdir(input_Data_Dir)
    datas = fm.file_names_in_dir(dirs, input_Data_Extention)
    
    for d in datas: 
        input_Data_Dir1 = input_Data_Dir + '/' + dirs[2:len(dirs)] + '/' + d
        output_Data_Dir1 = output_Data_Dir + '/' + dirs[2:len(dirs)] + '/' + d
        #print('gpt \''  + snap_graph_Dir + '\' -Pin=\'' + input_Data_Dir + '\' -Pout=\''+ output_Data_Dir + output_Data_Extention + '\'\n')
        print ("gpt \""  + snap_graph_Dir +"\" -Pin=\""+ input_Data_Dir1 + "\" -Pout=\""+ output_Data_Dir1 + output_Data_Extention + "\"\n")
        # sintassi STANDARD, SE SCRIVE COSì E BASTA SENNò DA ERRORE 



