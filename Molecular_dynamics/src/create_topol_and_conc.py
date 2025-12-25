#!/usr/bin/env python
# coding: utf-8

# In[1]:


#get_ipython().system('~/scwrl4/Scwrl4 -i relaxed_model_1_pred_0.pdb -o sfGFP.pdb -h > /dev/null')


# In[2]:


pdbCode = 'structure_complex'


# In[3]:


downloaded_pdb = pdbCode+'.pdb'


# In[4]:


# Check & Fix PDB
# Import module
from biobb_model.model.fix_side_chain import fix_side_chain

# Create prop dict and inputs/outputs
fixed_pdb = pdbCode + '_fixed.pdb'

# Create and launch bb
fix_side_chain(input_pdb_path=downloaded_pdb,
             output_pdb_path=fixed_pdb)


## In[5]:
#
#
## Create system topology
## Import module
#from biobb_gromacs.gromacs.pdb2gmx import pdb2gmx
#
## Create inputs/outputs
#output_pdb2gmx_gro = pdbCode+'_pdb2gmx.gro'
#output_pdb2gmx_top_zip = pdbCode+'_pdb2gmx_top.zip'
#
## Create and launch bb
#pdb2gmx(input_pdb_path=fixed_pdb,
#        output_gro_path=output_pdb2gmx_gro,
#        output_top_zip_path=output_pdb2gmx_top_zip)
#
#
## In[6]:
#
#
## Editconf: Create solvent box
## Import module
#from biobb_gromacs.gromacs.editconf import editconf
#
## Create prop dict and inputs/outputs
#output_editconf_gro = pdbCode+'_editconf.gro'
#
#prop = {
#    'box_type': 'cubic',
#    'distance_to_molecule': 1.0
#}
#
##Create and launch bb
#editconf(input_gro_path=output_pdb2gmx_gro,
#         output_gro_path=output_editconf_gro,
#         properties=prop)
#
#
## In[7]:
#
#
## Solvate: Fill the box with water molecules
#from biobb_gromacs.gromacs.solvate import solvate
#
## Create prop dict and inputs/outputs
#output_solvate_gro = pdbCode+'_solvate.gro'
#output_solvate_top_zip = pdbCode+'_solvate_top.zip'
#
## Create and launch bb
#solvate(input_solute_gro_path=output_editconf_gro,
#        output_gro_path=output_solvate_gro,
#        input_top_zip_path=output_pdb2gmx_top_zip,
#        output_top_zip_path=output_solvate_top_zip)
#
#
## In[8]:
#
#
## Grompp: Creating portable binary run file for ion generation
#from biobb_gromacs.gromacs.grompp import grompp
#
## Create prop dict and inputs/outputs
#output_gppion_tpr = pdbCode+'_gppion.tpr'
#prop = {
#    'simulation_type': 'minimization',
#    'maxwarn': 1
#}
#
## Create and launch bb
#grompp(input_gro_path=output_solvate_gro,
#       input_top_zip_path=output_solvate_top_zip,
#       output_tpr_path=output_gppion_tpr,
#       properties=prop)
#
#
## In[9]:
#
#
## Genion: Adding ions to neutralize the system
#from biobb_gromacs.gromacs.genion import genion
#
## Create prop dict and inputs/outputs
#
#output_genion_gro = pdbCode+'_genion_.gro'
#output_genion_top_zip = pdbCode+'_genion_top.zip'
#
## output_genion_gro = pdbCode+'genion_test.gro'
## output_genion_top_zip = pdbCode+'_genion_test_top.zip'
## prop={
##     'neutral':True
#
## }
#prop = { 'concentration': 0.15, 'replaced_group': 'SOL', 'neutral':True }
## Create and launch bb
#genion(input_tpr_path=output_gppion_tpr,
#       output_gro_path=output_genion_gro,
#       input_top_zip_path=output_solvate_top_zip,
#       output_top_zip_path=output_genion_top_zip,
#       properties=prop)
#
#
## In[10]:
#
#
## Grompp: Creating portable binary run file for mdrun
#from biobb_gromacs.gromacs.grompp import grompp
#
## Create prop dict and inputs/outputs
#output_gppmin_tpr = pdbCode+'_gppmin.tpr'
#prop = {
#    'mdp':{
#        'emtol':'500',
#        'nsteps':'5000'
#    },
#    'simulation_type': 'minimization'
#}
#
## Create and launch bb
#grompp(input_gro_path=output_genion_gro,
#       input_top_zip_path=output_genion_top_zip,
#       output_tpr_path=output_gppmin_tpr,
#       properties=prop)
#
#
## In[11]:
#
#
## Mdrun: Running minimization
#from biobb_gromacs.gromacs.mdrun import mdrun
#
## Create prop dict and inputs/outputs
#output_min_trr = pdbCode+'_min.trr'
#output_min_gro = pdbCode+'_min.gro'
#output_min_edr = pdbCode+'_min.edr'
#output_min_log = pdbCode+'_min.log'
#
#
#
## Create and launch bb
#mdrun(input_tpr_path=output_gppmin_tpr,
#      output_trr_path=output_min_trr,
#      output_gro_path=output_min_gro,
#      output_edr_path=output_min_edr,
#      output_log_path=output_min_log)
#
#
## In[12]:
#
#
## GMXEnergy: Getting system energy by time
#from biobb_analysis.gromacs.gmx_energy import gmx_energy
#
## Create prop dict and inputs/outputs
#output_min_ene_xvg = pdbCode+'_min_ene.xvg'
#prop = {
#    'terms':  ["Potential"]
#}
#
## Create and launch bb
#gmx_energy(input_energy_path=output_min_edr,
#          output_xvg_path=output_min_ene_xvg,
#          properties=prop)
#
#
#
## Grompp: Creating portable binary run file for NVT Equilibration
#from biobb_gromacs.gromacs.grompp import grompp
#
## Create prop dict and inputs/outputs
#output_gppnvt_tpr = pdbCode+'_gppnvt.tpr'
#prop = {
#    'mdp':{
#        'nsteps': 5000,
#        'dt': 0.002,
#        'Define': '-DPOSRES',
#        #'tc_grps': "DNA Water_and_ions" # NOTE: uncomment this line if working with DNA
#    },
#    'simulation_type': 'nvt'
#}
#
## Create and launch bb
#grompp(input_gro_path=output_min_gro,
#       input_top_zip_path=output_genion_top_zip,
#       output_tpr_path=output_gppnvt_tpr,
#       properties=prop)
#
#
## In[15]:
#
#
## Mdrun: Running Equilibration NVT
#from biobb_gromacs.gromacs.mdrun import mdrun
#
## Create prop dict and inputs/outputs
#output_nvt_trr = pdbCode+'_nvt.trr'
#output_nvt_gro = pdbCode+'_nvt.gro'
#output_nvt_edr = pdbCode+'_nvt.edr'
#output_nvt_log = pdbCode+'_nvt.log'
#output_nvt_cpt = pdbCode+'_nvt.cpt'
#
## Create and launch bb
#mdrun(input_tpr_path=output_gppnvt_tpr,
#      output_trr_path=output_nvt_trr,
#      output_gro_path=output_nvt_gro,
#      output_edr_path=output_nvt_edr,
#      output_log_path=output_nvt_log,
#      output_cpt_path=output_nvt_cpt)
#
#
## In[16]:
#
#
## GMXEnergy: Getting system temperature by time during NVT Equilibration
#from biobb_analysis.gromacs.gmx_energy import gmx_energy
#
## Create prop dict and inputs/outputs
#output_nvt_temp_xvg = pdbCode+'_nvt_temp.xvg'
#prop = {
#    'terms':  ["Temperature"]
#}
#
## Create and launch bb
#gmx_energy(input_energy_path=output_nvt_edr,
#          output_xvg_path=output_nvt_temp_xvg,
#          properties=prop)
#
#
## In[17]:
#
#
## Grompp: Creating portable binary run file for NPT System Equilibration
#from biobb_gromacs.gromacs.grompp import grompp
#
## Create prop dict and inputs/outputs
#output_gppnpt_tpr = pdbCode+'_gppnpt.tpr'
#prop = {
#    'mdp':{
#        'nsteps':'5000',
#        #'tc_grps': "DNA Water_and_ions" # NOTE: uncomment this line if working with DNA
#    },
#    'simulation_type': 'npt'
#}
#
## Create and launch bb
#grompp(input_gro_path=output_nvt_gro,
#       input_top_zip_path=output_genion_top_zip,
#       output_tpr_path=output_gppnpt_tpr,
#       input_cpt_path=output_nvt_cpt,
#       properties=prop)
#
#
## In[19]:
#
#
## Mdrun: Running NPT System Equilibration
#from biobb_gromacs.gromacs.mdrun import mdrun
#
## Create prop dict and inputs/outputs
#output_npt_trr = pdbCode+'_npt.trr'
#output_npt_gro = pdbCode+'_npt.gro'
#output_npt_edr = pdbCode+'_npt.edr'
#output_npt_log = pdbCode+'_npt.log'
#output_npt_cpt = pdbCode+'_npt.cpt'
#
## Create and launch bb
#mdrun(input_tpr_path=output_gppnpt_tpr,
#      output_trr_path=output_npt_trr,
#      output_gro_path=output_npt_gro,
#      output_edr_path=output_npt_edr,
#      output_log_path=output_npt_log,
#      output_cpt_path=output_npt_cpt)
#
#
## In[20]:
#
#
## GMXEnergy: Getting system pressure and density by time during NPT Equilibration
#from biobb_analysis.gromacs.gmx_energy import gmx_energy
#
## Create prop dict and inputs/outputs
#output_npt_pd_xvg = pdbCode+'_npt_PD.xvg'
#prop = {
#    'terms':  ["Pressure","Density"]
#}
#
## Create and launch bb
#gmx_energy(input_energy_path=output_npt_edr,
#          output_xvg_path=output_npt_pd_xvg,
#          properties=prop)
#
#
## In[21]:
#
#
## In[22]:
#
#
## Grompp: Creating portable binary run file for mdrun
#from biobb_gromacs.gromacs.grompp import grompp
#
## Create prop dict and inputs/outputs
#output_gppmd_tpr = pdbCode+'_gppmd.tpr'
#prop = {
#    'mdp':{
#        'nsteps':'5000000000',
#        #'tc_grps': "DNA Water_and_ions" # NOTE: uncomment this line if working with DNA
#    },
#    'simulation_type': 'free'
#}
#
## Create and launch bb
#grompp(input_gro_path=output_npt_gro,
#       input_top_zip_path=output_genion_top_zip,
#       output_tpr_path=output_gppmd_tpr,
#       input_cpt_path=output_npt_cpt,
#       properties=prop)
#
#
## In[23]:
#
#
### Mdrun: Running free dynamics
##from biobb_gromacs.gromacs.mdrun import mdrun
##
### Create prop dict and inputs/outputs
##output_md_trr = pdbCode+'_md.trr'
##output_md_gro = pdbCode+'_md.gro'
##output_md_edr = pdbCode+'_md.edr'
##output_md_log = pdbCode+'_md.log'
##output_md_cpt = pdbCode+'_md.cpt'
##
### Create and launch bb
##mdrun(input_tpr_path=output_gppmd_tpr,
##      output_trr_path=output_md_trr,
##      output_gro_path=output_md_gro,
##      output_edr_path=output_md_edr,
##      output_log_path=output_md_log,
##      output_cpt_path=output_md_cpt)
##
##
##
##
### GMXRms: Computing Root Mean Square deviation to analyse structural stability
###         RMSd against minimized and equilibrated snapshot (backbone atoms)
##
##from biobb_analysis.gromacs.gmx_rms import gmx_rms
##
### Create prop dict and inputs/outputs
##output_rms_first = pdbCode+'_rms_first.xvg'
##prop = {
##    'selection':  'Backbone',
##    #'selection': 'non-Water'
##}
##
### Create and launch bb
##gmx_rms(input_structure_path=output_gppmd_tpr,
##         input_traj_path=output_md_trr,
##         output_xvg_path=output_rms_first,
##          properties=prop)
##
##
### In[25]:
##
##
### GMXRms: Computing Root Mean Square deviation to analyse structural stability
###         RMSd against experimental structure (backbone atoms)
##
##from biobb_analysis.gromacs.gmx_rms import gmx_rms
##
### Create prop dict and inputs/outputs
##output_rms_exp = pdbCode+'_rms_exp.xvg'
##prop = {
##    'selection':  'Backbone',
##    #'selection': 'non-Water'
##}
##
### Create and launch bb
##gmx_rms(input_structure_path=output_gppmin_tpr,
##         input_traj_path=output_md_trr,
##         output_xvg_path=output_rms_exp,
##          properties=prop)
##
##
### In[26]:
##
##
### In[27]:
##
##
### GMXRgyr: Computing Radius of Gyration to measure the protein compactness during the free MD simulation
##
##from biobb_analysis.gromacs.gmx_rgyr import gmx_rgyr
##
### Create prop dict and inputs/outputs
##output_rgyr = pdbCode+'_rgyr.xvg'
##prop = {
##    'selection':  'Backbone'
##}
##
### Create and launch bb
##gmx_rgyr(input_structure_path=output_gppmin_tpr,
##         input_traj_path=output_md_trr,
##         output_xvg_path=output_rgyr,
##          properties=prop)
##
##
### In[28]:
##
##
### In[29]:
##
##
### GMXImage: "Imaging" the resulting trajectory
###           Removing water molecules and ions from the resulting structure
##from biobb_analysis.gromacs.gmx_image import gmx_image
##
### Create prop dict and inputs/outputs
##output_imaged_traj = pdbCode+'_imaged_traj.trr'
##prop = {
##    'center_selection':  'Protein',
##    'output_selection': 'Protein',
##    'pbc' : 'mol',
##    'center' : True
##}
##
### Create and launch bb
##gmx_image(input_traj_path=output_md_trr,
##         input_top_path=output_gppmd_tpr,
##         output_traj_path=output_imaged_traj,
##          properties=prop)
##
##
##from biobb_analysis.gromacs.gmx_trjconv_str import gmx_trjconv_str
##
### Create prop dict and inputs/outputs
##output_dry_gro = pdbCode+'_md_dry.gro'
##prop = {
##    'selection':  'Protein'
##}
##
### Create and launch bb
##gmx_trjconv_str(input_structure_path=output_md_gro,
##         input_top_path=output_gppmd_tpr,
##         output_str_path=output_dry_gro,
##          properties=prop)
##
##
