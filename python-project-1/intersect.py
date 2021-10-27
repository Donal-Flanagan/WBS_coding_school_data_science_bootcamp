def get_intersection(set_1, set_2):
    '''This module returns the intersection of two sets'''
    if type(set_1) != set():
        set_1 =  set(set_1)
    if type(set_2) != set():
        set_2 =  set(set_2)
    return set_1.intersection(set_2)