function varargout = wmcenter(varargin)
%WMCENTER Set or obtain web map center point
%
%   Syntax
%   ------
%   WMCENTER(centerLatitude, centerLongitude)
%   WMCENTER(WM, centerLatitude, centerLongitude)
%   WMCENTER(__, zoomLevel)
%   [centerLatitude, centerLongitude] = WMCENTER()
%   [centerLatitude, centerLongitude] = WMCENTER(WM)
%
%   Description
%   -----------
%   WMCENTER(centerLatitude, centerLongitude) centers either the current
%   web map, or a new web map if there is no current web map, at the
%   specified latitude and longitude.
%
%   WMCENTER(WM, centerLatitude, centerLongitude)  centers the web map
%   specified by the web map handle WM.
%
%   WMCENTER(__, zoomLevel) centers and zooms the web map to the specified
%   zoom level.
%
%   [centerLatitude, centerLongitude] = WMCENTER() returns the center
%   latitude and longitude point of the current web map.
%
%   [centerLatitude, centerLongitude] = WMCENTER(WM) returns the center
%   latitude and longitude of the web map specified by WM.
%
%   Input Arguments
%   ----------------
%
%   Name                  Description                Data Type
%   ----            ------------------------  -------------------------
%   centerLatitude  latitude of center point  scalar single or double in
%                                             the range [-90 90]
%   centerLongitude longitude of center point scalar single or double
%                                             automatically wrapped to the
%                                             range [-180 180]
%   zoomLevel       zoom level of web map     scalar numeric integer-valued
%                                             in the range [0 18]
%   WM              handle to web map         scalar web map
%
%   Output Arguments
%   ----------------
%
%   Name                   Description                Data Type
%   ----            -------------------------  -------------------------
%   centerLatitude   latitude of center point  scalar double in the range 
%                                              [-90 90]
%   centerLongitude longitude of center point  scalar double in the range 
%                                              [-180 180]
%
%   Example 1
%   ---------
%   [centerLatitude, centerLongitude] = wmcenter()
%   wmcenter(51.52, 0)
%
%   Example 2
%   ---------
%   h1 = webmap;
%   h2 = webmap('usgsimagery');
%   centerLatitude = 36.1;
%   centerLongitude = -113.2;
%   zoomLevel = 10;
%   wmcenter(h1, centerLatitude, centerLongitude, zoomLevel)
%   wmcenter(h2, centerLatitude, centerLongitude, zoomLevel)
%
%   See also WEBMAP, WMCLOSE, WMLIMITS, WMLINE, WMMARKER, WMPOLYGON, WMPRINT, WMREMOVE, WMZOOM

% Copyright 2013-2016 The MathWorks, Inc.

narginchk(0, 4)
nargoutchk(0, 2)

% Parse the inputs.
[wm, lat, lon, zoom] = parseInputs(varargin);

% If the web map canvas handle, wm, is unspecified ([]), then create a new
% one and set the browserIsEnabled flag to false. Otherwise, validate wm
% and set browserIsEnabled to true. wm is returned as a valid web map
% canvas handle.
[wm, browserIsEnabled] = webMapCanvasHandle(wm);

if nargout > 0
    % [lat, lon] = wmcenter(...)
    if nargin > 1
        % Support undocumented syntax:
        %   [lat, lon] = wmcenter(wm, lat, lon, ...)
        %   [lat, lon] = wmcenter(lat, lon, ...)
                
        % Set the zoom level in the web map if zoom is not empty.
        setZoomLevelProperty(wm, zoom, browserIsEnabled);
        
        % Set the center point lat and lon values in the web map.
        setCenterPointProperty(wm, lat, lon);
    end

    % Get the center point lat and lon values from the web map.
    [lat, lon] = getCenterPointProperty(wm);
    
    % Return the values if requested.
    varargout{1} = lat;
    if nargout == 2
        varargout{2} = lon;
    end
    
elseif nargin > 0
    % nargout is 0
    % wmcenter(lat, lon)
    % wmcenter(wm, lat, lon)
    % wmcenter(wm, lat, lon, zoom)
    narginchk(2, 4)
        
    % Set new zoom level in the web map if zoom is not empty.
    setZoomLevelProperty(wm, zoom, browserIsEnabled);
    
    % Set new center lat and lon values in the web map.
    setCenterPointProperty(wm, lat, lon);
end

% Do not create a new web map for the syntax:
% wmcenter()
if ~browserIsEnabled && ~(nargout == 0 && nargin == 0)
    % Create a new web map.
    web(wm);
end

%--------------------------------------------------------------------------

function [wm, lat, lon, zoom] = parseInputs(inputs)
% Parse inputs.

% Set default values.
lat = [];
lon = [];
zoom = [];
wm = [];

switch length(inputs)
    case 0
        % wmcenter()
        % [lat, lon] = wmcenter()
    case 1
        % [lat, lon] = wmcenter(wm)
        wm = inputs{1};
    case 2
        % wmcenter(lat, lon)
        lat = inputs{1};
        lon = inputs{2};
    case 3
        if isa(inputs{1}, 'map.webmap.Canvas')
            % wmcenter(wm, lat, lon)
            wm = inputs{1};
            lat = inputs{2};
            lon = inputs{3};
        else
            % wmcenter(lat, lon, zoom)
            lat = inputs{1};
            lon = inputs{2};
            zoom = inputs{3};
        end
    case 4
        % wmcenter(wm, lat, lon, zoom)
        wm = inputs{1};
        lat = inputs{2};
        lon = inputs{3};
        zoom = inputs{4};
end

%--------------------------------------------------------------------------

function setCenterPointProperty(wm, lat, lon)
% Set the CenterPoint property in the web map.

try
    % Setting the CenterPoint property validates the inputs. However, it
    % expects two elements. If either lat or lon is not scalar, then the
    % error message includes the input name "CenterPoint" rather than
    % CenterLatitude or CenterLongitude. Handle this special case here.
    if ~isscalar(lat) || ~isscalar(lon)
        validateattributes(lat, {'double'}, {'scalar'},  mfilename, ...
            'CenterLatitude');
        validateattributes(lon, {'double'}, {'scalar'}, mfilename, ...
            'CenterLongitude');
    end
    
    % Validate and set CenterLatitude and CenterLongitude.
    wm.CenterPoint = [lat, lon];
catch e
    throwAsCaller(e);
end

%--------------------------------------------------------------------------

function setZoomLevelProperty(wm, zoom, browserIsEnabled)
% Set the ZoomLevel property in the web map, if zoom is not empty.

try
    if isempty(zoom) && ~browserIsEnabled
        % zoom value has not been set and browser is not enabled. Set zoom
        % level to minimum value (3).
        zoom = 3;
        wm.ZoomLevel = zoom;
        
    elseif ~isempty(zoom)
        % ZoomLevel validation is performed by the set operation in
        % WebMapScript.
        wm.ZoomLevel = zoom;
    end
catch e
    throwAsCaller(e);
end

%--------------------------------------------------------------------------

function [lat,lon] = getCenterPointProperty(wm)
% Get lat and lon center point from the web map.

try
    pt = wm.CenterPoint;
    lat = pt(1);
    lon = pt(2);
catch e
    throwAsCaller(e)
end
