import sys
from pyhugin91 import *
import pandas
import numpy

# Read in data directly to Python
bn_structure_nodes = pandas.read_excel("Data/BN_Layouts/test_nodes.xlsx").fillna("")
bn_structure_edges = pandas.read_excel("Data/BN_Layouts/test_edges.xlsx").fillna("")

bn_structure_edges_internal = bn_structure_edges.loc[bn_structure_edges['type'] == "internal"].reset_index()
bn_structure_edges_external = bn_structure_edges.loc[bn_structure_edges['type'] == "external"].reset_index()

# How many APIs do we want to create instances for?
API_instance_n = 2

# First, we want to create a list of classes from values in the Type
# a list is an ordered group of unnamed variables
bn_classes_list = bn_structure_nodes['class'].unique().tolist()

# Create a class collection to contain our various classes
bn_class_collection = ClassCollection()

# Create classes dynamically
for c in range(len(bn_classes_list)):
  try:
    temp_class = "class_" + bn_classes_list[c]
    print(temp_class)
    vars() [temp_class] = Class(bn_class_collection)
    eval(temp_class).set_name(temp_class)
  except:
    print("class name must be string")

# Create nodes dynamically within the appropriate classes
# We need to create class-internal edges first
# Then lay out the instances of classes
# THEN create class-external edges

# practically speaking, that means
# create all nodes
# create non-master class edges
# create master instances
# create master edges

# I want to make this into a function, but I tried and couldn't get it to work
# Something about making the nodes created in the function scope globally accessible
# May return to the issue later.

# CREATE ALL NODES
for c in range(len(bn_structure_nodes)):
  # CREATE TEMP VARIABLES FROM DF
  # Assign to Class
  temp_node_class = "class_" + bn_structure_nodes.loc[c]['class']
  print("class: " + temp_node_class)
  # Assign node name/variable name
  temp_node_variable = "node_" + bn_structure_nodes.loc[c]['ID']
  print("variable name: " + temp_node_variable)
  # Assign category: CHANCE, etc.
  temp_node_category = 'CATEGORY.' + bn_structure_nodes.loc[c]['CATEGORY']
  print(temp_node_category)
  # Assign kind: DISCRETE, etc.
  temp_node_kind = 'KIND.'+ bn_structure_nodes.loc[c]['KIND']
  print(temp_node_kind)
  # Assign subtype: LABEL, NUMBER, INTERVAL, etc.
  temp_node_subtype = 'SUBTYPE.' + bn_structure_nodes.loc[c]['SUBTYPE']
  print(temp_node_subtype)
  # Assign label (full/display name)
  temp_node_label = bn_structure_nodes.loc[c]['Label']
  print("label: " + temp_node_label)
  # Set number of states
  temp_node_states = bn_structure_nodes.loc[c]['n_states']
  print("States: " + str(temp_node_states))
  # Create a list from comma-seperated states, or skip this step if NaN
  if bn_structure_nodes.loc[c]['states']== '':
    temp_states_list = ""
    print("no state names found") 
  else:
    temp_states_list = [x.strip(' ') for x in bn_structure_nodes.loc[c]['states'].split(',')]
    print("State names: " + str(temp_states_list))
  
  # CREATE THE NODE
  # evaluate temp variables inside Node() with eval()
  # there's almost certainly a better way to do this, but I don't know what it is
  vars() [temp_node_variable] = Node(eval(temp_node_class), 
                                   category=eval(temp_node_category), 
                                   kind=eval(temp_node_kind), 
                                   subtype=eval(temp_node_subtype))
  print (temp_node_variable + " successfully created")
  # SET ATTRIBUTES FROM TEMP VARIABLES
  # name
  eval(temp_node_variable).set_name(temp_node_variable)
  # label
  eval(temp_node_variable).set_label(temp_node_label)
  # number of states
  eval(temp_node_variable).set_number_of_states(temp_node_states)
  # now set state values (numeric nodes) or labels (everything else)
  # If the column's blank, skip for now
  if not temp_states_list == "":
    s = 0
    for s in range(temp_node_states):
      print("s = " + str(s))
      if temp_node_subtype == "SUBTYPE.NUMBER":
        eval(temp_node_variable).set_state_value(s, float(temp_states_list[s]))
      else:
        eval(temp_node_variable).set_state_label(s, temp_states_list[s])
  # If the node's an output or input, set it as such
  if bn_structure_nodes.loc[c]['IO'] == "input":
    eval(temp_node_variable).add_to_inputs()
    print("Add to input.")
  if bn_structure_nodes.loc[c]['IO'] == "output":
    eval(temp_node_variable).add_to_outputs()
    print("Add to output.")
  print("---------------------------")

# BUILD INTERNAL EDGES
for e in range(len(bn_structure_edges_internal)):
  # CREATE TEMP VARIABLES FROM DF
  temp_parent_node = "node_" + bn_structure_edges_internal.loc[e]['parent']
  print("parent: " + temp_parent_node)
  temp_child_node = "node_" + bn_structure_edges_internal.loc[e]['child_node']
  print("child: " + temp_child_node)
  # CREATE EDGES BY ASSIGNING PARENTS TO NODES
  try:
    eval(temp_child_node).add_parent(eval(temp_parent_node))
    print("edge created")
  except:
    print("edge failed")


# BUILD MASTER NETWORK WITH CLASS INSTANCES
# Create Instances Dynamically
bn_instances_list = []

for c in range(len(bn_classes_list)):
# Don't create a master class in the master class
    print(c)
    print(bn_classes_list[c])
    if bn_classes_list[c] == "master":
        print("aborted successfully")
# If the class name is API, we may want to create multiple instances
    else:
        temp_instance = "class_" + bn_classes_list[c]
        temp_instance_name = "instance_" + temp_instance + "_" + str(c)
        vars() [temp_instance_name] = class_master.new_instance(eval(temp_instance))
        eval(temp_instance).set_name(temp_instance)
        print(temp_instance_name + " created")
        # add instance to a list of instances
        bn_instances_list.append(temp_instance_name)


# BUILD EXTERNAL EDGES
for e in range(len(bn_structure_edges_external)):
    # CREATE TEMP VARIABLES FROM DF
    temp_parent_node = "node_" + bn_structure_edges_external.loc[e]['parent']
    print("parent: " + temp_parent_node)
    temp_child_node = "node_" + bn_structure_edges_external.loc[e]['child']
    print("child: " + temp_child_node)
    # GET INSTANCE FROM NODE NAME AND LIST
    # I don't immediately know how to handle this - simple enough to grab the name
    # from the list, but how can we approach having multiple instances of the same node?
    temp_node_instance = eval(temp_child_node).get_home_class()
    # CREATE EDGES BY ASSIGNING INPUT NODES TO OUTPUT NODES IN INSTANCES
    try:
        eval(temp_node_instance).set_input(eval(temp_parent_node), eval(temp_child_node))
        print("edge created")
    except:
        print("edge failed")


# save as net files
# class_API.save_as_net("BN/API_Output/class_API.net")
# class_spatial.save_as_net("BN/API_Output/class_spatial.net")
bn_class_collection.save_as_net("BN/API_Output/bn_class_collection.net")

        # build expression for C
        # modelC = Model(nodeC)
        # modelC.set_expression(0, "A + B")

        # tables
        # tableA = nodeA.get_table()
        # tableA.set_data([0.1, 0.2, 0.7])

        # tableB = nodeB.get_table()
        # tableB.set_data([0.2, 0.2, 0.6])

        # save as net-file
        # domain.save_as_net("test_python_bn.net")

        # compile
        # domain.compile()

        # print node marginals
    #     for node in domain.get_nodes():
    #         print(node.get_label())
    #         for i in range(node.get_number_of_states()):
    #             print("-{} {}".format(node.get_state_label(i), node.get_belief(i)))
    # except HuginException:
    #     print("A Hugin Exception was raised!")
    #     raise
    # finally:
    #     if domain is not None:
    #         domain.delete()

        

# Run the Build And Propagate example
# __name__ is a special Python variable that evaluates to the name of the current module
# if __name__ == "__main__" is a guard used to only run the code when your module
# is the main program. 
# So we keep it, rather than risk the (admittedly unlikely) contingency where something breaks.

# if __name__ == "__main__":
#     bap()
