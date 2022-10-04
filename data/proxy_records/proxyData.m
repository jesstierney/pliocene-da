classdef proxyData
%% proxyData  Organizes proxy datasets and implements time averaging over Pliocene time slices
% ----------
%   The proxyData class provides several methods that help organize and
%   format the proxy data sets in preparation for data assimilation. The
%   key method here is "proxyData.organize". This method scans through the
%   various CSV files, collecting proxy values and metadata. The method
%   then averages proxy values within the time slices for the assimilation.
%   Finally, it exports proxy metadata and time-averaged values to a
%   MAT-file for use with the DASH toolbox.
%
%   To use this class, call 

    % Experimental parameters for time averaging proxy values
    properties(Constant)
        times = [0, 3.25, 4.75];        
        timeUnits = "Ma";
        timeBounds = [0 0;3 3.5;4.5 5.5];
        nRound = 1;  
    end


    % Data properties scanned from individual data files
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

    methods
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
    end

end