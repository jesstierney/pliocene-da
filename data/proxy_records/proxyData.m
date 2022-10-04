classdef proxyData
%% proxyData  Organizes proxy datasets and implements time averaging over Pliocene time slices
% ----------
%   The proxyData class provides several methods that help organize and
%   format the proxy data sets in preparation for data assimilation.
%
%   **KEY METHOD**
%   The key method is "proxyData.organize". Running this command will
%   format the raw proxy records in preparation for assimilation. The
%   method scans through the proxy record CSV files, collecting proxy
%   values and metadata. The method then averages proxy values within the
%   assimilation time slices. Finally, the method exports proxy metadata
%   and time-averaged values to a NetCDF file for use with the DASH
%   toolbox. See its help section for additional details.
%
%   **EXPERIMENTAL PARAMETERS**
%   This class includes parameters that set the time-slices used for the
%   assimilation. (These parameters are used to implement the
%   time-averaging for the proxy data). You can edit these parameters to
%   change the time-slices for the assimilation. To edit these parameters,
%   navigate to the "Experimental Parameters" property block (immediately
%   after this comment) and follow the prompts.

    %% Experimental parameters
    %
    % These properties set the time-slices used for the assimilation. You
    % can edit them to change the time slices for the assimilation. See the
    % description of each property for instructions on editing.
    %
    % If you edit these parameters, you should run the
    % "proxyData.validateParameters" command in the console to ensure that
    % your edits are valid.
    properties(Constant)

        % This indicates the number of time steps in the assimilation. It
        % should be a scalar positive integer.
        nTime = 3;

        % This indicates the time metadata to use for each of the
        % assimilation time steps. It will be saved as metadata in the
        % NetCDF file containing the formatted proxy data. It should be a
        % numeric vector with one element per assimilation time step.
        % It cannot include repeated, NaN, or complex-valued elements.
        times = [0; 3.25; 4.75];

        % This indicates the units of the time data. It will be saved as
        % metadata in the NetCDF file containing the formatted proxy data.
        % It should be a string scalar.
        timeUnits = "Ma";

        % This indicates the spans of ages to use when time-averaging the
        % proxies for the assimilation time slices. Proxy values within
        % each span are averaged into the final value for the associated
        % assimilation time slice.
        %
        % This should be a numeric matrix. It should have one row per
        % assimilation time slice, and two columns. Each row is the time
        % span for the associated time slice (listed in the "times"
        % property above). The first column is the lower bound (inclusive)
        % for the time slice, and the second column is the upper bound
        % (inclusive). The time span should contain the metadata value used
        % for the time slice (listed in the "times" property).
        timeBounds = [0    0
                      3    3.5
                      4.5  5.5];

        % Indicates the amount of rounding to apply to the ages in the raw
        % proxy data files. The property lists the number of digits after
        % the decimal place to use when rounding. This should be a scalar
        % integer. Alternatively, you can set this value to NaN to disable
        % rounding.
        nRound = 1;
    end


    %% Scanned data properties
    % This properties are the values scanned from the raw data files. You
    % probably shouldn't edit them...
    properties (SetAccess = private)
        name;
        lat;
        lon;
        pLat325;
        pLon325;
        pLat475;
        pLon475;
        type;
        species;
        cleaning;
        ages;
        values;
        flags;
    end


    methods (Static)
        function[] = organize(folders, saveFile)
            nFolders = numel(folders);
            data = cell(nFolders, 1);

            for f = 1:nFolders
                folder = folders(f);
                files = proxyData.csvFiles(folder);
                files = fullfile(folder, files);
                data{f} = proxyData(files, folder)';
            end
            data = [data{:}]';

            data = data.screenFlags;
            data = data.averageValues;
            data.export(saveFile);
        end










        function[obj] = proxyData(filenames, defaultType)
            if ~exist('defaultType', 'var')
                defaultType = string(NaN);
            end

            nFile = numel(filenames);
            obj = repmat(obj, [nFile, 1]);

            for f = 1:nFile
                file = filenames(f);
    
                % Import data file as a table
                T = readtable(file, 'TextType', 'string', 'NumHeaderLines', 1, ...
                      'VariableNamesLine', 1);
        
                % Record values
                obj(f).name = string(T.SiteName(2));
                obj(f).lat = T.Lat(2);
                obj(f).lon = T.Lon(2);
                obj(f).pLat325 = T.pLat325(2);
                obj(f).pLon325 = T.pLon325(2);
                obj(f).pLat475 = T.pLat475(2);
                obj(f).pLon475 = T.pLon475(2);
                obj(f).type = string(T.ProxyType(2));
                obj(f).cleaning = string(T.CleaningMethod(2));
                obj(f).species = string(T.Species(2));
        
                % Values and ages
                obj(f).values = T.ProxyValue;
                obj(f).ages = T.Age;
        
                % Optional quality flag
                if ismember("QualityFlag", T.Properties.VariableNames)
                    obj(f).flags = T.QualityFlag;
                end

                % Fill missing proxy type
                if ismissing(obj(f).type)
                    obj(f).type = defaultType;
                end
            end
        end
        function[obj] = screenFlags(obj)
            for k = 1:numel(obj)
                if ~isempty(obj(k).flags)
                    remove = obj(k).flags == 1;
                    obj(k).ages(remove) = [];
                    obj(k).values(remove) = [];
                end
            end
        end
        function[obj] = averageValues(obj)
            for k = 1:numel(obj)
                obj(k).ages = round(obj(k).ages, proxyData.nRound);
    
                % Preallocate mean values for the timeslices
                nTime = size(proxyData.timeBounds, 1);
                meanValues = NaN(nTime, 1);
                
                % Get the upper and lower bound of each time slice
                for t = 1:nTime
                    lower = proxyData.timeBounds(t,1);
                    upper = proxyData.timeBounds(t,2);
                
                    % Record the mean of values within the time slice
                    use = obj(k).ages>=lower & obj(k).ages<=upper;
                    meanValues(t) = mean(obj(k).values(use));
                end

                % Upate values and ages
                obj(k).ages = obj(k).times;
                obj(k).values = meanValues;
            end
        end
        function[] = export(obj, file)

            % Collect values
            names = obj.collect('name');
            lats = obj.collect('lat');
            lons = obj.collect('lon');
            pLat325 = obj.collect('pLat325'); %#ok<PROPLC> 
            pLon325 = obj.collect('pLon325'); %#ok<PROPLC> 
            pLat475 = obj.collect('pLat475'); %#ok<PROPLC> 
            pLon475 = obj.collect('pLon475'); %#ok<PROPLC> 
            types = obj.collect('type');
            species = obj.collect('species'); %#ok<PROPLC> 
            cleaning = obj.collect('cleaning'); %#ok<PROPLC> 
            data = obj.collect('values');
            times = proxyData.times; %#ok<PROPLC> 

            % Save to file
            save(file, '-v7.3', 'names', 'lats', 'lons', 'pLat325', ...
                'pLon325', 'pLat475', 'pLon475', 'types', 'species', 'cleaning',...
                'data', 'times');

        end
        function[values] = collect(obj, field)
            values = [obj.(field)]';
        end
    end

    methods (Static)
        function[files] = csvFiles(folder)
            files = dir(folder);
            files = string({files.name});
            files = files(endsWith(files, '.csv'));
        end

    end

end