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
%   after this comment) and follow the prompts. You should run the
%   "proxyData.validateParameters" method after editing to ensure that
%   your new values are valid.
%
%   **ADDING NEW RECORDS**
%   You can add more records to the assimilation. Each new record should be
%   organized in a CSV file, and should follow the existing formatting
%   style. (See raw/Contents.md for information on the formatting style).
%   The CSV file should be placed in a subfolder of the "raw" folder. If
%   using one of the currently used proxy types, add the CSV folder to the
%   appropriate subfolder. If using a new proxy type, create a new
%   subfolder for the proxy data file. The name of the new folder
%   should be an identifying string for the proxy type.

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
    % probably shouldn't edit these...
    properties (SetAccess = private)
        name;
        lat;
        lon;
        pLat325;
        pLon325;
        pLat475;
        pLon475;
        depth;
        type;
        species;
        cleaning;
        ages;
        values;
        flags;
    end


    methods (Static)
        function[] = validateParameters
            %% proxyData.validateParameters  Checks that experimental parameters are valid
            % ----------
            %   proxyData.validateParameters
            %   Checks that the experimental parameters are valid. If
            %   the parameters are valid, exits silently. Otherwise, throws
            %   an error reporting the problem.
            % ----------
            
            % nTime must be a scalar positive integer
            nTime = proxyData.nTime;
            assertNumeric(nTime, 'nTime');
            assertScalar(nTime, 'nTime');
            assertDefined(nTime, 'nTime');
            assertInteger(nTime, 'nTime');
            assert(nTime>0, 'nTime must be positive');

            % times must be a numeric vector with nTime elements
            times = proxyData.times;
            assertNumeric(times, 'times');
            assert(isvector(times), 'times must be a vector');
            assert(numel(times)==nTime, 'times must have %.f elements (one per assimilation time slice)', nTime);
            assertDefined(times, 'times');

            % timeUnits should be a scalar string
            timeUnits = proxyData.timeUnits;
            assert(isstring(timeUnits), 'timeUnits must be a string (using double quotes "")');
            assertScalar(timeUnits, 'timeUnits');

            % timeBounds should be a numeric matrix with one row per time
            % slice and two columns. Each row should span the associated
            % time slice. The second column should be >= the first
            timeBounds = proxyData.timeBounds;
            assertNumeric(timeBounds, 'timeBounds');
            assert(ismatrix(timeBounds), 'timeBounds must be a matrix');
            [nRows, nCols] = size(timeBounds);
            assert(nRows==nTime, 'timeBounds must have %.f rows (one per assimilation time step)', nRows);
            assert(nCols==2, 'timeBounds must have 2 columns');
            assertDefined(timeBounds, 'timeBounds');

            % Check each row spans the associated time slice
            for t = 1:nTime
                lower = timeBounds(t,1);
                upper = timeBounds(t,2);
                assert(upper>=lower, 'The upper bound for time slice %.f (%f) is less than the lower bound (%f)', t, upper, lower);
                metadata = times(t);
                assert(lower<=metadata, 'The lower bound for time slice %.f (%f) is greater than the metadata for the time slice (%f)', t, lower, metadata);
                assert(upper>=metadata, 'The upper bound for time slice %.f (%f) is less than the metadata for the time slice (%f)', t, upper, metadata);
            end

            % nRound must be a scalar positive integer or NaN
            nRound = proxyData.nRound;
            assertNumeric(nRound, 'nRound');
            assertScalar(nRound, 'nRound');
            if ~isnan(nRound)
                assertDefined(nRound, 'nRound');
                assertInteger(nRound, 'nRound');
            end

            %% Utility functions
            % A collection of short assertions. If an assertion fails, it throws
            % an error that includes the name of the invalid parameter.
            function[] = assertNumeric(input, name)
                if ~isnumeric(input)
                    ME = MException('', '%s must be numeric', name);
                    throwAsCaller(ME);
                end
            end
            function[] = assertScalar(input, name)
                if ~isscalar(input)
                    ME = MException('', '%s must be scalar', name);
                    throwAsCaller(ME);
                end
            end
            function[] = assertDefined(input, name)
            if any(isnan(input(:)))
                ME = MException('', '%s cannot contain NaN values', name);
                throwAsCaller(ME);
            elseif any(isinf(input(:)))
                ME = MException('', '%s cannot contain infinite values', name);
                throwAsCaller(ME);
            end
            end
            function[] = assertInteger(input, name)
                if mod(input, 1) ~= 0
                    ME = MException('', '%s must be an integer', name);
                    throwAsCaller(ME);
                end
            end
        end
        function[] = organize
            %% proxyData.organize  Organizes raw proxy data in preparation for assimilation
            % ----------
            %   proxyData.organize
            %   Formats the raw proxy records in preparation for assimilation. Scans
            %   through the proxy record CSV files, collecting proxy values and metadata. 
            %   Averages proxy values within the assimilation time slices. Finally, 
            %   the method exports proxy metadata and time-averaged values to a NetCDF file
            %   named "formatted_proxies.nc". The NetCDF file will be saved to the current folder.
            %
            %   To locate proxy record CSV files, the method will first search
            %   for a folder named "raw" in the same folder as the
            %   "proxyData.m" class file. The method will then look for subfolders
            %   within the "raw" folder. Any file in these subfolders that ends
            %   with a ".csv" extension is assumed to be a proxy data file.
            % ----------
            %   Saves:
            %       Creates a NetCDF file named "formatted_proxies.nc" in
            %       the current folder.

            % Check for the "raw" folder
            path = strsplit(mfilename('fullpath'), filesep);
            home = strjoin(path(1:end-1), filesep);
            raw = strjoin({home, 'raw'}, filesep);
            if ~isfolder(raw)
                error(['Cannot locate the "raw" folder. The "raw" folder must be ',...
                    'located in the folder:\n\t%s'], home);
            end

            % Get the subfolders in the "raw" folder
            contents = dir(raw);
            contents(1:2) = [];
            isdir = [contents.isdir];
            contents = string({contents.name});
            folders = contents(isdir);

            % Preallocate the data object arrays for each folder
            nFolders = numel(folders);
            data = cell(nFolders, 1);

            % Cycle through folders.
            for f = 1:nFolders
                folder = folders(f);
                path = strjoin([raw, folder], filesep);

                % Get the CSV files in the folder
                files = dir(path);
                files(1:2) = [];
                files = string({files.name});
                isCSV = endsWith(files, '.csv');
                files = files(isCSV);

                % Scan the CSV files into data objects. Use the file name
                % as the default proxy type when type metadata is missing
                files = strcat(path, filesep, files);
                data{f} = proxyData(files, folder);
            end
            data = [data{:}];

            % Remove flagged values. Implement time averaging. Export to NetCDF
            data = data.screenFlags;
            data = data.averageValues;
            data.export;
        end
    end


    methods
        function[obj] = proxyData(filenames, defaultType)
            %% proxyData  Creates data objects for proxy records by scanning raw proxy data files
            % ----------
            %   obj = proxyData(filenames)
            %   Creates proxyData objects for the input data files. Scans
            %   each file and extracts proxy metadata and raw data values.
            %
            %   obj = proxyData(filenames, defaultType)
            %   Applies a default proxy type if the proxy type metadata is
            %   missing.
            % ----------
            %   Inputs:
            %       filenames (string array): A list of raw proxy data
            %           files. The data files should be CSV files.
            %       defaultType (string scalar): A default proxy type to
            %           use when proxy type metadata is missing. If
            %           unspecified, uses <missing> for missing type.
            %
            %   Outputs:
            %       obj (proxyData array): The proxyData objects for the
            %           input files. Will have the same size as "filenames"
            
            % Defaults and error checks
            if ~exist('defaultType', 'var') || isempty(defaultType)
                defaultType = string(NaN);
            else
                assert(isstring(defaultType), 'defaultType must be a string');
                assert(isscalar(defaultType), 'defaultType must be scalar');
            end
            assert(isstring(filenames), 'filenames must be a string array');

            % Create an object array over the files
            obj = repmat(obj, size(filenames));

            % Scan each file into a table
            try
                for f = 1:numel(filenames)
                    file = filenames(f);
                    T = readtable(file, 'TextType', 'string', 'NumHeaderLines', 1, ...
                          'VariableNamesLine', 1);

                    % Record metadata
                    obj(f).name = string(T.SiteName(2));
                    obj(f).lat = T.Lat(2);
                    obj(f).lon = T.Lon(2);
                    obj(f).pLat325 = T.pLat325(2);
                    obj(f).pLon325 = T.pLon325(2);
                    obj(f).pLat475 = T.pLat475(2);
                    obj(f).pLon475 = T.pLon475(2);
                    obj(f).depth = T.WaterDepth(2);
                    obj(f).type = string(T.ProxyType(2));
                    obj(f).cleaning = string(T.CleaningMethod(2));
                    obj(f).species = string(T.Species(2));

                    % Values, ages, and optional quality flag
                    obj(f).values = T.ProxyValue;
                    obj(f).ages = T.Age;
                    if ismember("QualityFlag", T.Properties.VariableNames)
                        obj(f).flags = T.QualityFlag;
                    end

                    % Fill missing type metadata
                    if ismissing(obj(f).type)
                        obj(f).type = defaultType;
                    end
                end

            % Informative error if a file cannot be scanned
            catch cause
                [~, file] = fileparts(file);
                ME = MException('', 'Could not import file: %s.csv\n', file);
                ME = addCause(ME, cause);
                throw(ME);
            end
        end
        function[obj] = screenFlags(obj)
            %% proxyData.screenFlags  Remove flagged values from proxy data
            % ----------
            %   obj = obj.screenFlags
            %   Checks each object in a proxyData array for flags. Removes
            %   all data values and ages for which the associated flag is
            %   equal to 1.
            % ----------
            %   Outputs:
            %       obj (proxyData array): The updated proxyData array

            for k = 1:numel(obj)
                if ~isempty(obj(k).flags)
                    remove = obj(k).flags == 1;
                    obj(k).ages(remove) = [];
                    obj(k).values(remove) = [];
                    obj(k).flags = [];
                end
            end
        end
        function[obj] = averageValues(obj)
            %% proxyData.averageValues  Implement time-averaging for a proxyData array
            % ----------
            %   obj = obj.averageValues
            %   Implements time-averaging on the data values in a proxyData
            %   array. Raw data values are averaged for assimilation time
            %   slices using the time bounds and rounding parameters set by
            %   the "Experimental Parameters" properties.
            % ----------
            %   Outputs:
            %       obj (proxyData array): The updated proxyData array

            % Round the ages for each object
            for k = 1:numel(obj)
                if ~isnan(proxyData.nRound)
                    obj(k).ages = round(obj(k).ages, proxyData.nRound);
                end

                % Preallocate values for the time slices
                meanValues = NaN(proxyData.nTime, 1);
                
                % Get the upper and lower bound of each time slice
                for t = 1:proxyData.nTime
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
        function[values] = collect(obj, field)
            values = [obj.(field)]';
        end
        function[] = export(obj)
            %% proxyData.export  Exports an vector of proxyData objects to a NetCDF file
            % ----------
            %   obj.export
            %   Takes a vector of proxyData objects and collects data
            %   values and proxy metadata. Exports these values to a NetCDF
            %   file. Time-averaged proxy values are stored in the "data"
            %   variable. The NetCDF file is named "formatted_proxies.nc"
            %   and is created in the current folder.
            % ----------
            %   Saves:
            %       Creates a NetCDF file named "formatted_proxies.nc" in
            %       the current folder

            % Only export proxyData vectors (exported data grid is poorly defined for
            % proxyData arrays). Ensure array is a column vector
            assert(isvector(obj), 'You can only export proxyData vectors');
            obj = obj(:);
            
            % Collect proxy metadata
            fields = ["name","lat","lon","pLat325","pLon325","pLat475","pLon475",...
                "depth","type","species","cleaning"];
            s = struct;
            for f = 1:numel(fields)
                field = fields(f);
                s.(field) = obj.collect(field);
            end
            s.cleaning = double(s.cleaning);
            
            % Also get proxy data values
            data = obj.collect('values');

            % Get sizes
            nTime = proxyData.nTime;
            nSite = numel(obj);
            
            % Create the NetCDF data variable, as well as dimension variables
            file = 'proxies.nc';
            nccreate(file, 'data', 'Format', 'netcdf4', 'Dimensions', {'site', nSite, 'time', nTime});
            nccreate(file, 'time', 'Dimensions', {'time', nTime});
            nccreate(file, 'site', 'Dimensions', {'site', nSite}, 'Datatype', 'string');

            % Then write the variables
            % (This order is important as writing the data variable before
            % creating the dimension variable can cause errors in NetCDF4).
            ncwrite(file, 'data', data);
            ncwrite(file, 'time', proxyData.times);
            ncwriteatt(file, 'time', 'Units', proxyData.timeUnits);
            ncwrite(file, 'site', s.name);
            ncwriteatt(file, 'site', 'Description', 'Proxy site IDs');
            
            % Create proxy metadata numeric variables
            numericFields = ["lat","lon","pLat325","pLon325","pLat475","pLon475","depth","cleaning"];
            for f = 1:numel(numericFields)
                field = numericFields(f);
                nccreate(file, field, 'Dimensions', {'site', nSite});
                ncwrite(file, field, s.(field));
            end
            
            % Create proxy metadata string variables
            stringFields = ["type","species"];
            for f = 1:numel(stringFields)
                field = stringFields(f);
                nccreate(file, field, 'Dimensions', {'site', nSite}, 'Datatype', 'string');
                
                % Replace <missing> with "" and write metadata
                value = s.(field);
                value(ismissing(value)) = "";
                ncwrite(file, field, value);
            end

            % Time bounds
            nccreate(file, 'timeBounds', 'Dimensions', {'time', nTime, 'bounds', 2});
            ncwrite(file, 'timeBounds', proxyData.timeBounds);
            ncwriteatt(file, 'timeBounds', 'Note', 'First column is lower bound. Second column is upper.');
        end
    end

end
