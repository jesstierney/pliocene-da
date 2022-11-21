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

% PlioMIP2 E280 runs
CCSM4_NCAR_e280;
CCSM4_UoT_e280;
CESM1_2_e280;
CESM2_e280;
COSMOS_e280;
EC_Earth3_3_e280;
GISS_ModelE2_e280;
HadCM3_e280;
HadGM3_e280;
IPSL_CM5A_e280;
IPSL_CM5A2_e280;
IPSL_CM6A_e280;
MIROC4m_e280;
NorESM1_F_e280;
NorESM_L_e280;

% PlioMIP2 EOI400 runs
CCSM4_NCAR_eoi400;
CCSM4_UoT_eoi400;
CESM1_2_eoi400;
CESM2_eoi400;
COSMOS_eoi400;
EC_Earth3_3_eoi400;
GISS_ModelE2_eoi400;
HadCM3_eoi400;
HadGM3_eoi400;
IPSL_CM5A_eoi400;
IPSL_CM5A2_eoi400;
IPSL_CM6A_eoi400;
MIROC4m_eoi400;
NorESM1_F_eoi400;
NorESM_L_eoi400;

% Extra CESM2 Pliocene-like runs
CESM2_pi400;
CESM2_eo400new;

% Ford et al. (2022)
CESM1_2_2_plio;
CESM1_2_2_pliob17;
CESM1_2_2_preind;

% Erfani and Burls (2019)
CESM1_2_2_cheyctrl;
CESM1_2_2_cheyco2;

runs = parameters.plioceneRuns.Erfani2019;
runs = runs(:,2);
runs = runs(~strcmp(runs, "cheyco2"));
for r = 1:numel(runs)
    CESM1_2_2_EB19(runs(r));
end

% Burls and Fedorov (2014)
runs = parameters.plioceneRuns.Burls2014;
runs = replace(runs(:,2), '-', '_');
for r = 1:numel(runs)
    CESM1_0_4_BF14(runs(r));
end

end