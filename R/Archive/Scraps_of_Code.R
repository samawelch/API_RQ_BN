# ## 5.3 CPT Generator
# 
# ```{r sumRQ_CTP_generator}
# 
# # Generate a vector of CPT column names using a fairly prolix set of looped if statements 
# 
# CPT_colnames_tibble <- tibble("Name" = c("0-1", "1-10", "10-100", "100-1000", "1000-10000", "10000-inf"))
# CPT_colnames <- rep(c("None", "Low", "Medium", "High"), each = 15)
# for (j in 1:length(CPT_colnames)) {
#     # Append Year to string
#     if (j%%15 %in% 1:3) {
#         CPT_colnames[j] <- str_glue(CPT_colnames[j], "_2010")
#     }
#     else if (j%%15 %in% 4:6) {
#         CPT_colnames[j] <- str_glue(CPT_colnames[j], "_2020")
#     }
#     else if (j%%15 %in% 7:9) {
#         CPT_colnames[j] <- str_glue(CPT_colnames[j], "_2030")
#     }
#     else if (j%%15 %in% 10:12) {
#         CPT_colnames[j] <- str_glue(CPT_colnames[j], "_2040")
#     }
#     else if (j%%15 %in% c(0, 13, 14)) {
#         CPT_colnames[j] <- str_glue(CPT_colnames[j], "_2050")
#     }
#     # Append SSB Pop. Scenario to string
#     if (j%%3 == 1) {
#         CPT_colnames[j] <- str_glue(CPT_colnames[j], "_Low")
#     }
#     else if (j%%3 == 2) {
#         CPT_colnames[j] <- str_glue(CPT_colnames[j], "_Main")
#     }
#     else if (j%%3 == 0) {
#         CPT_colnames[j] <- str_glue(CPT_colnames[j], "_High")
#     }
#     # Add to tibble as a new column
#     CPT_colnames_tibble <- CPT_colnames_tibble %>%
#         mutate((!!CPT_colnames[j]) := 0)
# }
# 
# CPT_colnames_tibble 
# 
# 
# 
# # Note to self: This works now (checked with 1 API), but you may need to tweak the range of years & scenarios,
# # as JMO suggests fewer are needed
# 
# # I broke this by changing the format of sales weight data. not important right now, may fix later.
# # for (i in 1:length(summed_APIs)) {
# #   
# #   API_Name <- summed_APIs[i]
# #   
# #   temp_name <- as.character(str_glue("CPT_{API_Name}"))
# # 
# # temp_output_distribution <- Hugin_Data_Output %>% filter(API_Name == summed_APIs[i]) %>% 
# #   select(c(2:4, 16:21)) %>% 
# #   mutate(Scenario = str_glue("{WWTP_Scenario}_{Year}_{Population_Scenario}")) %>% 
# #   select(-(1:3)) %>% 
# #   t() %>% 
# #   as_tibble()
# # 
# # colnames(temp_output_distribution) <- temp_output_distribution[7, ]
# # 
# # temp_output_distribution <- temp_output_distribution[1:6, ]   
# # 
# # 
# #   assign(x = temp_name, value = temp_output_distribution)
# #   
# #   write_csv(x = temp_output_distribution, file = paste0("Data/Hugin/CPTs/", temp_name, ".csv"))
# # }
# 
# ```
# 
# # 6. Hugin Python API
# 
# ## 6.1 BN Structure Import in R?
# 
# Let's assume we want to format our BNs as a table of nodes, and a table of edges?
# 
# ```{r bn_structure_import, eval=FALSE}
# library(reticulate)
# API_LM_variables <- r_to_py(LMs_API)
# print("test")
# ```
# 
# ## 6.1 BN Structure Import in Python
# 
# Note: I had a hell of a time getting this to work without throwing an SSL error. The eventual solution was to install Anaconda, and tell RStudio to use that as the environment in Global Options > Python
# 
# I then copied the .py and .dll from C:/Program Files/Hugin Expert/HUGIN 9.1 (x64)/HDE9.1Python/Lib to C:/Users/[USER]/anaconda3/Lib
# 
# Below is a copied example from the Hugin 9.1 Python API documentation (it's pretty sparse.)
# What we need to do now is work out how to automate the construction of BNs using this!
#     
#     Important note: sometimes the Python console stops printing error messages. If this happens, restart the session.
# 
# ```{python test, eval=FALSE}
# import sys
# from pyhugin91 import *
#     import pandas
# import numpy
# import re
# 
# # Import dataframes from R
# API_LM_variables = r.API_LM_variables
# API_weight_classes = API_LM_variables.loc[:, 'weight_class'].unique()
# 
# # Read in data directly to Python
# bn_structure_nodes = pandas.read_excel("Data/BN_Layouts/test_nodes.xlsx").fillna("")
# bn_structure_edges = pandas.read_excel("Data/BN_Layouts/test_edges.xlsx").fillna("")
# 
# bn_structure_edges_internal = bn_structure_edges.loc[bn_structure_edges['type'] == "internal"].reset_index()
# bn_structure_edges_external = bn_structure_edges.loc[bn_structure_edges['type'] == "external"].reset_index()
# 
# # First, we want to create a list of classes from values in the Type
# # a list is an ordered group of unnamed variables
# bn_classes_list = bn_structure_nodes['class'].unique().tolist()
# 
# # Create a class collection to contain our various classes
# bn_class_collection = ClassCollection()
# 
# # Create classes dynamically
# for c in range(len(bn_classes_list)):
#     temp_class = "class_" + bn_classes_list[c]
# # For class API, loop creation over API_weight_classes
# # Removed RN as I'm doing this manually
# # if bn_classes_list[c] == "API":
# #     for w in API_weight_classes:
# #         temp_class = "class_" + bn_classes_list[c] + "_" + w
# #         print(temp_class)
# #         vars() [temp_class] = Class(bn_class_collection)
# #         eval(temp_class).set_name(temp_class)
# #     continue
# # else:
# # There's probably a clever way to avoid repeating code, but I'm in a hurry
# print(temp_class)
# vars() [temp_class] = Class(bn_class_collection)
# eval(temp_class).set_name(temp_class)
# 
# 
# 
# # Create nodes dynamically within the appropriate classes
# # We need to create class-internal edges first
# # Then lay out the instances of classes
# # THEN create class-external edges
# 
# # practically speaking, that means
# # create all nodes
# # create non-master class edges
# # create master instances
# # create master edges
# 
# # I want to make this into a function, but I tried and couldn't get it to work
# # Something about making the nodes created in the function scope globally accessible
# # May return to the issue later.
# 
# # CREATE ALL NODES
# for c in range(len(bn_structure_nodes)):
#     # CREATE TEMP VARIABLES FROM DF
#     # Assign to Class
#     temp_node_class = "class_" + bn_structure_nodes.loc[c]['class']
# print("class: " + temp_node_class)
# # Assign node name/variable name
# temp_node_variable = "node_" + bn_structure_nodes.loc[c]['ID']
# print("variable name: " + temp_node_variable)
# # Assign category: CHANCE, etc.
# temp_node_category = 'CATEGORY.' + bn_structure_nodes.loc[c]['CATEGORY']
# print(temp_node_category)
# # Assign kind: DISCRETE, etc.
# temp_node_kind = 'KIND.'+ bn_structure_nodes.loc[c]['KIND']
# print(temp_node_kind)
# # Assign subtype: LABEL, NUMBER, INTERVAL, etc.
# temp_node_subtype = 'SUBTYPE.' + bn_structure_nodes.loc[c]['SUBTYPE']
# print(temp_node_subtype)
# # Assign label (full/display name)
# temp_node_label = bn_structure_nodes.loc[c]['Label']
# print("label: " + temp_node_label)
# # CREATE API Nodes
# # Gonna do this by hand with light/med/high for the time being
# # if temp_node_class == "class_API":
# #     print("class_API if statement executed")
# #     for w in API_weight_classes
# #         temp_node_class = (temp_node_class + "_" + w)
# #         temp_node_variable = re.sub('API_weight', ('API_' + w + '_'), temp_node_variable
# # Set number of states
# temp_node_states = bn_structure_nodes.loc[c]['n_states']
# print("States: " + str(temp_node_states))
# # Create a list from comma-seperated states, or skip this step if NaN
# if bn_structure_nodes.loc[c]['states']== '':
#     temp_states_list = ""
# print("no state names found") 
# else:
#     temp_states_list = [x.strip(' ') for x in bn_structure_nodes.loc[c]['states'].split(',')]
# print("State names: " + str(temp_states_list))
# # CREATE THE NODE
# # evaluate temp variables inside Node() with eval()
# # there's almost certainly a better way to do this, but I don't know what it is
# vars() [temp_node_variable] = Node(eval(temp_node_class), 
#                                    category=eval(temp_node_category), 
#                                    kind=eval(temp_node_kind), 
#                                    subtype=eval(temp_node_subtype))
# print (temp_node_variable + " successfully created")
# # SET ATTRIBUTES FROM TEMP VARIABLES
# # name
# eval(temp_node_variable).set_name(temp_node_variable)
# # label
# eval(temp_node_variable).set_label(temp_node_label)
# # number of states
# eval(temp_node_variable).set_number_of_states(temp_node_states)
# # now set state values (numeric nodes) or labels (everything else)
# # If the column's blank, skip for now
# if not temp_states_list == "":
#     s = 0
# for s in range(temp_node_states):
#     print("s = " + str(s))
# if temp_node_subtype == 'SUBTYPE.NUMBER':
#     eval(temp_node_variable).set_state_value(s, float(temp_states_list[s]))
# else:
#     eval(temp_node_variable).set_state_label(s, temp_states_list[s])
# # If the node's an output or input, set it as such
# if bn_structure_nodes.loc[c]['IO'] == "input":
#     eval(temp_node_variable).add_to_inputs()
# print("Add to input.")
# if bn_structure_nodes.loc[c]['IO'] == "output":
#     eval(temp_node_variable).add_to_outputs()
# print("Add to output.")
# print("---------------------------")
# 
# 
# 
# # BUILD INTERNAL EDGES
# for e in range(len(bn_structure_edges_internal)):
#     # CREATE TEMP VARIABLES FROM DF
#     temp_parent_node = "node_" + bn_structure_edges_internal.loc[e]['parent']
# print("parent: " + temp_parent_node)
# temp_child_node = "node_" + bn_structure_edges_internal.loc[e]['child_node']
# print("child: " + temp_child_node)
# # CREATE EDGES BY ASSIGNING PARENTS TO NODES
# try:
#     eval(temp_child_node).add_parent(eval(temp_parent_node))
# print("edge created")
# except:
#     print("edge failed")
# 
# 
# # BUILD MASTER NETWORK WITH CLASS INSTANCES
# # Create Instances Dynamically
# bn_instances_list = []
# 
# for c in range(len(bn_classes_list)):
#     # Don't create a master class in the master class
#     print(c)
# print(bn_classes_list[c])
# if bn_classes_list[c] == "master":
#     print("aborted successfully")
# # If the class name is API, we may want to create multiple instances
# else:
#     temp_instance = "class_" + bn_classes_list[c]
# temp_instance_name = "instance_" + temp_instance + "_" + str(c)
# vars() [temp_instance_name] = class_master.new_instance(eval(temp_instance))
# eval(temp_instance).set_name(temp_instance)
# print(temp_instance_name + " created")
# # add instance to a list of instances
# bn_instances_list.append(temp_instance_name)
# 
# 
# # BUILD EXTERNAL EDGES
# for e in range(len(bn_structure_edges_external)):
#     # CREATE TEMP VARIABLES FROM DF
#     temp_parent_node = "node_" + bn_structure_edges_external.loc[e]['parent']
# print("parent: " + temp_parent_node)
# temp_child_node = "node_" + bn_structure_edges_external.loc[e]['child']
# print("child: " + temp_child_node)
# # GET INSTANCE FROM NODE NAME AND LIST
# # I don't immediately know how to handle this - simple enough to grab the name
# # from the list, but how can we approach having multiple instances of the same node?
# temp_node_instance = eval(temp_child_node).get_home_class()
# # CREATE EDGES BY ASSIGNING INPUT NODES TO OUTPUT NODES IN INSTANCES
# try:
#     eval(temp_node_instance).set_input(eval(temp_parent_node), eval(temp_child_node))
# print("edge created")
# except:
#     print("edge failed")
# 
# # save as net files
# bn_class_collection.save_as_net("BN/API_Output/bn_class_collection.net")
# 
# ```
# 
# 
# ## 7.1 Joint & Mixture Toxicity
# 
# Hugin isn't capable of summing any more than 4 APIs without crashing... I probably need to consult 
# with supervisors before making any permanent decisions, but we can at least start implementation with
# four.
# 
# ```{r hugin_SumRQ_datafile}
# summed_APIs <- Interesting_APIs[1:4]
# 
# Hugin_SumRQ_Data_File <- Hugin_Data_Output %>% 
#   filter(API_Name %in% summed_APIs) %>% 
#   select(-(5:15)) %>% 
#   # Rename some variables and columns for easier name generation when pivoting
#   mutate(API_Name = rep(1:4, each = 60)) %>% 
#   rename_with(.cols = 5:10,
#               .fn = ~str_extract(string = ., pattern = "[0-9]+-[0-9a-z]+")) %>% 
#   pivot_wider(names_from = API_Name,
#               values_from = c(`0-1`, 
#                               `1-10`, 
#                               `10-100`, 
#                               `100-1000`, 
#                               `1000-10000`, 
#                               `10000-inf`),
#               values_fill = NA,
#               names_glue = "P(RQ_SW_API{API_Name}={.value})") %>% 
#   crossing(RQ_Threshhold = c(10, 100, 1000, 10000)) %>% 
#   mutate(`P(Sum_RQ=0-1)` = NA,
#          `P(Sum_RQ=1-10)` = NA,
#          `P(Sum_RQ=10-100)` = NA,
#          `P(Sum_RQ=100-1000)` = NA,
#          `P(Sum_RQ=1000-10000)` = NA,
#          `P(Sum_RQ=10000-100000)` = NA,
#          `P(Sum_RQ=100000-inf)` = NA,
#          `P(Threshold_Exceedence=true)` = NA)
#                                     
# write_csv(x = Hugin_SumRQ_Data_File, file = "Data/Hugin/R_to_Hugin_SumRQ_datafile.csv", na = "")
# 
# ```
# ```{r misc_maps}
# # ggplot(data = Norway_counties_shapefile, mapping = aes(x = long, 
# #                                 y = lat)) + 
# #   geom_polygon(color = "grey",
# #              size = 0.1,
# #              aes(group = group,
# #                  fill = Population)) +
# #   geom_point(data = Waterbase_WWTP_Norway,
# #              alpha = 0.5,
# #              aes(size = cap,
# #                  colour = treatment,
# #                  shape = RW))
# 
# # How do UWWD aggregations and kommuner compare?
# # Agglos_WWTP_Coords <- Waterbase_Agglomerations_Norway %>% 
# #   left_join(y = Waterbase_WWTP_Norway, by = "WWTP_Code")
# # 
# # ggplot(data = Norway_counties_shapefile, mapping = aes(x = long, 
# #                                                     y = lat)) + 
# #   geom_polygon(color = "grey",
# #                size = 0.1,
# #                aes(group = group,
# #                    fill = Population)) +
# #   geom_point(data = Agglos_WWTP_Coords,
# #              alpha = 0.5,
# #              aes(colour = aucAggName))
# 
# # Map of Norway w/ SimpleMap city coordinates
# # Cities of 50,000+ only
# # Norway_Cities %>% filter(population > 50000) %>% 
# #   summarise(sum(population))
# # This covers only 2.1 million people, not even half of the population
# # Removing the filter covers 4.3 million people, which is better...
# 
# # ggplot(data = spl_map_Norway_pop2020, mapping = aes(x = long, 
# #                                                     y = lat)) + 
# #   geom_polygon(color = "grey",
# #                fill = "white",
# #                size = 0.1,
# #                aes(group = group)) +
# #   geom_point(data = Norway_Cities %>% filter(population > 50000),
# #              alpha = 1,
# #              aes(size = population,
# #                  colour = admin_name)) +
# #   geom_text_repel(data = Norway_Cities %>% filter(population > 50000), 
# #                   mapping = aes(label = city))
# ```
# 
# ```{r various_PECs}
# # Various PECs
# Various_PECs <- ggplot(data = Hugin_Data_Output,
#        mapping = aes(x = Year,
#                      y = `[MEAN](PEC_Inf_H_gL)`,
#                      colour = Population_Scenario,
#                      shape = Population_Scenario)) +
#   geom_point() +
#   geom_path() +
#   facet_wrap(facets = vars(API_Name), ncol = 4, scales = "free") +
#   scale_color_discrete(breaks = c("Low", "Main", "High")) +
#   scale_shape_discrete(breaks = c("Low", "Main", "High"))
# 
# Various_PECs
# 
# ```
# 
# ```{r various_RQs}
# 
# # RQ by year, scenario & API
# RQ_by_Year_Scen_API <- ggplot(data = Hugin_Data_Output %>% filter(WWTP_Scenario == "Low"),
#        mapping = aes(x = Year,
#                      y = `[MEAN](RQ_SW)`,
#                      colour = Population_Scenario,
#                      shape = Population_Scenario)) +
#   geom_point() +
#   geom_path() +
#   facet_wrap(facets = vars(API_Name), ncol = 4, scales = "free")
# #  scale_shape_discrete(breaks = c("Low", "Main", "High"))
# 
# RQ_by_Year_Scen_API
# 
# ```
