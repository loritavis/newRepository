function layers = wmsfind(varargin)
%WMSFIND Search local database for Web map servers and layers
%
%   WMSFIND searches an installed database that contains information about
%   Web Map Service (WMS) servers.  A WMS server produces maps of spatially
%   referenced raster data, such as temperature or elevation, known as a
%   layer.  The information found in the database is static and is not
%   automatically updated; it was validated at the time of the software
%   release.  
%
%   The WMS database can be searched for a server title, server URL, layer
%   title, or layer name.  A server title includes descriptive information
%   about the server.  A layer title includes descriptive information about
%   a layer and facilitates understanding the meaning of the raster values
%   of the layer.  The layer name is an abbreviated form and is the keyword
%   the server uses to retrieve the layer. The server URL and layer
%   information facilitates the reading of raster layers by the function
%   WMSREAD.  For additional information about a specific server, use the
%   function WMSINFO with the specific server URL.
%
%   The WMS database contains the following fields:
%
%   Field Name     Data Type            Field Content
%   ----------     ---------            -------------
%   ServerTitle    character vector     Title of server
%
%   ServerURL      character vector     URL of server
%
%   LayerTitle     character vector     Title of layer
%
%   LayerName      character vector     Name of layer
%
%   Latlim         two-element vector   Southern and northern latitude 
%                                       limits of layer
% 
%   Lonlim         two-element vector   Western and eastern longitude 
%                                       limits of layer 
%
%   LAYERS = WMSFIND(QUERYSTR) searches the WMS database and finds partial
%   matches for entries in either the LayerTitle or the LayerName fields of
%   the WMS database. QUERYSTR is a string or character vector and may
%   contain the wildcard character '*'. LAYERS is a WMSLayer array
%   containing one element for each layer whose name or title partially
%   matches QUERYSTR.
%
%   A WMSLayer array contains properties with the same names as the field
%   names of the WMS database and contains three additional properties,
%   'Abstract', 'CoordRefSysCodes', and 'Details'. Information for these
%   additional properties is not stored in the WMS database. You can
%   populate these additional properties by using the WMSUPDATE function.
%   This function downloads the layer information from the server and
%   synchronizes the layer with the updated information. These unpopulated
%   properties are not automatically displayed when using the disp method
%   of WMSLayer, but may be displayed by setting the disp 'Properties'
%   parameter to 'all'.
%
%   LAYERS = WMSFIND(__, Name, Value) modifies the search of the WMS
%   database based on the values of the parameters. Parameter names can be
%   abbreviated, and case does not matter.
%
%   Modify the search by specifying any of the following parameters:
%
%   'SearchFields'        Specifies which field to search. Valid options 
%                         are 'layer', layertitle', 'layername', 'server',
%                         'serverurl', 'servertitle', or 'any'. Default
%                         value is 'layer'. Multiple options may be
%                         included in a string array or cell array of
%                         character vectors.
%
%                         The function searches the entries in the
%                         'SearchFields' of the WMS database for a partial
%                         match of the entry with QUERYSTR. If 'layer' is
%                         supplied then both the 'layertitle' and
%                         'layername' fields are searched. If 'server' is
%                         supplied, then both the 'serverurl' and
%                         'servertitle' fields are searched. The layer
%                         information is returned if any supplied
%                         'SearchFields' match.
%
%   'MatchType'           Specifies the type of match algorithm to use.  
%                         Valid options are 'partial' or 'exact'. Default
%                         value is 'partial'.
%
%                         If 'MatchType' is 'partial', then a match is
%                         found for any partial match.  If 'MatchType' is
%                         'exact', then a match is found if the query
%                         matches the item exactly.  If 'MatchType' is
%                         'exact' and QUERYSTR is '*', a match is found if
%                         the search field matches the character '*'.
%
%   'IgnoreCase'          Specifies whether to ignore case when performing 
%                         comparisons. Default value is true.
%
%   'Latlim'              Specifies latitudinal limits of the search in the
%                         form [southern_limit northern_limit] or a scalar
%                         value representing the latitude of a single
%                         point. All angles are in units of degrees.
%
%                         If provided and not empty, a given layer is
%                         included in the results only if its limits fully
%                         contain the specified 'Latlim' limits. Partial
%                         overlap does not result in a match.
%
%   'Lonlim'              Specifies longitudinal limits of the search in 
%                         the form [western_limit eastern_limit] or a
%                         scalar value representing the longitude of a
%                         single point. All angles are in units of degrees.
%
%                         If provided and not empty, a given layer is
%                         included in the results only if its limits
%                         contain the specified 'Lonlim' limits. Partial
%                         overlap does not result in a match.
%
%   'Version'             Specifies which version of the WMS database to 
%                         read. Valid options are 'custom', 'installed', or
%                         'online'. Use 'custom' to read from a
%                         wmsdatabase.mat file on the MATLAB path. Use
%                         'installed' to read from the installed database.
%                         Use 'online' to read from the most current
%                         version of the database stored online. The
%                         default value is 'installed'.
%
%   Example 1
%   ---------
%   % Find layers that may contain temperature data and return a WMSLayer 
%   % array.
%   layers = wmsfind('temperature');
%
%   Example 2
%   ---------
%   % Find layers that may contain global temperature data and return
%   % a WMSLayer array.
%   layers = wmsfind('global*temperature');
%
%   Example 3
%   ---------
%   % Find all layers that contain an exact match for 'Rivers' in the
%   % LayerTitle field and return a WMSLayer array.
%   layers = wmsfind('Rivers','MatchType','exact', ...
%      'IgnoreCase',false,'SearchFields','layertitle');
%
%   Example 4
%   ---------
%   % Find all layers that contain a partial match for 'elevation' in the 
%   % LayerName field and return a WMSLayer array.
%   layers = wmsfind('elevation','SearchField','layername');
%
%   Example 5
%   ---------
%   % Find all unique servers that contain 'BlueMarbleNG' as a layer name.
%   layers = wmsfind('BlueMarbleNG','SearchField','layername', ...
%      'MatchType','exact');
%   urls = servers(layers)
%
%   Example 6
%   ---------
%   % Find layers that may contain elevation data for Colorado and return 
%   % a WMSLayer array.
%   latlim = [35 43];
%   lonlim = [-111 -101];
%   layers = wmsfind('elevation','Latlim',latlim,'Lonlim',lonlim);
%
%   Example 7
%   ---------
%   % Find all layers that contain temperature data for a point in Perth,
%   % Australia and return a WMSLayer array.
%   lat = -31.9452;
%   lon = 115.8323;
%   layers = wmsfind('temperature','Latlim',lat,'Lonlim',lon);
%
%   Example 8
%   ---------
%   % Find all the layers provided by servers located at the 
%   % Jet Propulsion Laboratory (JPL). Display to the command window 
%   % each server URL, layer title and layer name.
%   layers = wmsfind('jpl.nasa.gov','SearchField','serverurl');
%   disp(layers,'Properties',{'serverURL','layerTitle','layerName'});
%
%   Example 9
%   ---------
%   % Find all the unique URLs of all government servers.
%   layers = wmsfind('*.gov*','SearchField','serverurl');
%   urls = servers(layers);
%
%   Example 10
%   ----------
%   % Perform multiple searches.
%   % Find all the layers that contain temperature in the layer name or
%   % title fields.
%   fields = [string('layertitle') string('layername')];
%   temperature = wmsfind('temperature','SearchField',fields);
% 
%   % Find sea surface temperature layers.
%   sst = refine(temperature,'sea surface');
%
%   % Find and display to the command window a list of global sea surface 
%   % temperature layers.
%   global_sst = refine(sst,'global')
%
%   Example 11
%   ----------
%   % Perform multiple listings and searches of the entire WMS database.
%   % Please note that finding all the layers from the WMS database may 
%   % take several seconds to execute and require a substantial amount 
%   % of memory.
%
%   % Find all layers in the WMS database. 
%   layers = wmsfind('*');
%
%   % Sort and display to the command window the unique layer titles in  
%   % the WMS database.
%   layerTitles = sort(unique({layers.LayerTitle}))'
%
%   % Refine layers to include only layers with global coverage.
%   global_layers = refineLimits(layers, ...
%      'Latlim',[-90 90],'Lonlim',[-180 180]);
%
%   % Refine global_layers to contain only topography layers that have 
%   % global extent.
%   topography = refine(global_layers,'topography');
%
%   % Refine layers to contain only layers that have the terms oil and gas
%   % in the LayerTitle property.
%   oil_gas = refine(layers,'oil*gas','SearchField','layertitle');
%
%   Example 12
%   ----------
%   % Search the most recent online version of the WMS database for 
%   % layers that may contain elevation.
%   elevation = wmsfind('elevation','Version','online')
%
%   See also WMSINFO, WMSLayer, WMSREAD, WMSUPDATE.

% Copyright 2008-2016 The MathWorks, Inc.

% Verify the number of inputs.
narginchk(1, inf);

% Parse the inputs from the command line into an inputs structure.
inputs = parseInputs(varargin{:});

% Perform the query.
layers = wmsquery(inputs);

%--------------------------------------------------------------------------

function inputs = parseInputs(varargin)
% Parse the parameters from the command line into an INPUTS structure.
% The fields of the INPUTS structure match the interface and contains the
% following fieldnames:
%
%    Field Name       Datatype
%    -------------    --------
%    SearchFields     cell array of character vectors
%    MatchType        character vector with value 'partial' or 'exact'
%    Latlim           double array
%    Lonlim           double array
%    QueryStr         character vector
%    Version          character vector

% Verify the QueryStr input.
query = varargin{1};
varargin(1) = [];
classes = {'char', 'string'};
validateattributes(query, classes, {'row', 'vector'}, mfilename, 'QUERYSTR');
if isstring(query) && ~isscalar(query)
    validateattributes(query, classes, {'scalar'}, ...
        mfilename, 'QUERYSTR');
end
query = char(query);

% Parse and validate the parameter-value pair inputs.
% parameterNames contains the valid parameter names.
% defaultValues contains the default values for each parameter name.
parameterNames = ...
    {'SearchFields', 'MatchType', 'Latlim', 'Lonlim', 'IgnoreCase', 'Version'};
defaultValues = ...
    {{'LayerName', 'LayerTitle'}, 'partial', [], [], true, 'installed'};

% Setup a cell array of validation functions.
wmsFcns = assignWmsValidationFcns(mfilename);
validateFcns = { ...
    wmsFcns.validateSearchFields, ...
    wmsFcns.validateMatchType, ...
    wmsFcns.validateLatlim, ...
    wmsFcns.validateLonlim, ...
    wmsFcns.validateIgnoreCase, ...
    @(x)validateVersion(x)};

% Parse the parameters from the command line and validate using the
% functions in validateFcns.
[inputs, userSupplied, unmatched] = ...
    internal.map.parsepv(parameterNames, validateFcns, varargin{:});

% Verify the first parameter is a string.
if ~isempty(varargin) && ~ischar(varargin{1})
     unmatched{1} = 'PARAM1';
end

% Check if varargin contained unmatched parameters.   
if ~isempty(unmatched)
    p = sprintf('''%s'', ', parameterNames{1:end});
    error(message('map:validate:invalidParameterName', ...
        unmatched{1}, p(1:end-2)));
end

% Set default values for any parameter that is not specified.
inputs = setDefaultValues(inputs, defaultValues, userSupplied);

% Assign the QueryStr field.
inputs.QueryStr = query;

%--------------------------------------------------------------------------

function inputs = setDefaultValues(inputs, defaultValues, userSupplied)
% Set default values to any parameter that is not supplied.

inputFieldNames = fieldnames(inputs);
for k=1:numel(inputFieldNames)
    name = inputFieldNames{k};
    if ~userSupplied.(name)
        inputs.(name) = defaultValues{k};
    end
end
      
%--------------------------------------------------------------------------

function layers = wmsquery(inputs)
% Perform the query on the WMS database and return a WMSLayer array in
% LAYERS.

% Search the WMS database for the query string according in the specified
% SearchFields.
wmsdb = wmssearch(inputs.QueryStr, inputs.SearchFields,  ...
    inputs.MatchType, inputs.IgnoreCase, inputs.Version);

layer = WMSLayer();
if ~isempty(wmsdb.ServerURL)
    % Construct a WMSLayer array from the WMSDB structure.
    layers = layer.setPropertiesFromWMSDB( ...
        wmsdb.ServerTitle, wmsdb.ServerURL,  ...
        wmsdb.LayerTitle,  wmsdb.LayerName,  ...
        wmsdb.Latlim, wmsdb.Lonlim);
    
    % Check if Latlim or Lonlim has been specified. If so, then check that
    % the quad limits are contained in the layer limits.
    if ~isempty(inputs.Latlim) || ~isempty(inputs.Lonlim)
        % Remove all layers that do not fully contain the user-specified
        % quadrangle.
        layers(~layerContainsQuad(layers, inputs.Latlim, inputs.Lonlim)) = [];
    end
else
    % The search returned empty results.
    layers = layer(false);
end

%--------------------------------------------------------------------------

function c = validateVersion(c)
% Validate c as a valid 'Version' input. A 'Version'
% input must be either 'installed', 'custom', or 'online'.

% Validate 'Version' as a non-empty character vector.
if isstring(c)
    c = char(c);
end
classes = {'char', 'string'};
paramName = 'Version';
validateattributes(c, classes, {'row', 'vector'}, mfilename, paramName);

% The 'Version' input must be either 'installed', 'custom', or 'online'.
validVersionStrs = {'installed', 'custom', 'online'};
singleQuote = '''';
varName = [singleQuote paramName singleQuote];
c = validatestring(c, validVersionStrs, mfilename, varName);
