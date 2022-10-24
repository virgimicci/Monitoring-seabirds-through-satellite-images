# -*- coding: utf-8 -*-
"""
Created on Wed Oct 19 09:29:27 2022

@author: chiara salv ☺
@title: Folder Manager
"""

# Libraries and modules
import os # operative system module

# - - - - - - - - - - - - - - - - - - - - - - - 

# Functions
'''
1. 
Questa funzione prende come input una directiory
e restituisce tutte le sue sottodirectory.
'''
def get_directory(el_in_dir):
    for el in os.walk(el_in_dir):
        return [el[0]]
    

'''
2.
Questa funzione copia la struttura di una data cartella
e restituisce tutti i 'path' delle sottodirectories.
'''
def create_fold(el_in_dir, el_out_dir):
    os.chdir(el_in_dir)
    directories = get_directory('.') # richiamo la funzione...
    os.chdir(el_out_dir)
    for dirs in directories:
        if not os.path.exists(dirs):
            os.makedirs(dirs)
        else:
            pass
    return directories


'''
3. 
Questa funzione restituisce il nome di tutti i files all'interno
di una cartella che hanno un'estenzione specifica.
'''
def file_names_in_dir(el_in_dir, file_extention):
    current_wdir = os.getcwd()
    os.chdir(el_in_dir)
    data = [el for el in os.listdir(".") if el.endswith(file_extention)]
    # questo tipo di sintassi non mi piace PER NIENTE, 
    # ma pare non ci sia altro modo...
    os.chdir(current_wdir)
    return data

    
    
    

