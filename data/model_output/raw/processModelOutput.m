function[] = processModelOutput
%% processModelOutput  Build pre-processed climate model NetCDF files from raw output files
% ----------
%   processModelOutput
%   Processes raw climate model outputs in preparation for assimilation.
%   Creates a NetCDF file with pre-processed variables for each climate 
%   model run. Writes the NetCDF files to the current directory. The naming
%   convention for the NetCDFs is <model name>_<experiment ID>.nc
% 
%   Each NetCDF contains data and metadata for precipitation (pr), 
%   near surface air temperature (tas), sea surface temperature (tos), sea
%   surface salinity (sos), and sea ice area percentage (siconc).
%
%   To build the files, raw climate model output is first used to compute
%   monthly climatologies for each climate variable. Each climatology is
%   constructed from 100 years of output. The monthly climatologies are then
%   regridded to a 1x1 resolution.
% ----------
%   Outputs:
%       Creates a number of NetCDF files in the current directory.

% Call the pre-processing script for every model run
CCSM4_NCAR_e280;
CCSM4_NCAR_eoi400;

CCSM4_UoT_e280;
CCSM4_UoT_eoi400;

CESM1_2_e280;
CESM1_2_eoi400;

CESM1_2_2_plio;
CESM1_2_2_pliob17;
CESM1_2_2_preind;

CESM1_2_2_cheyco2;
CESM1_2_2_cheyctrl;
tags = ["p05","p10","p15","p20","n05","n10","n15","n20"];
for t = 1:numel(tags)
    CESM1_2_2_laystrat(tags(t));
end

CESM2_e280;
CESM2_eoi400;
CESM2_pi400;
CESM2_eo400new;

COSMOS_e280;
COSMOS_eoi400;

EC_Earth3_3_e280;
EC_Earth3_3_eoi400;

GISS_ModelE2_e280;
GISS_ModelE2_eoi400;

HadCM3_e280;
HadCM3_eoi400;

HadGM3_e280;
HadGM3_eoi400;

IPSL_CM5A_e280;
IPSL_CM5A_eoi400;

IPSL_CM5A2_e280;
IPSL_CM5A2_eoi400;

IPSL_CM6A_e280;
IPSL_CM6A_eoi400;

MIROC4m_e280;
MIROC4m_eoi400;

NorESM1_F_e280;
NorESM1_F_eoi400;

NorESM_L_e280;
NorESM_L_eoi400;

end