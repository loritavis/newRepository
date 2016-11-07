function varargout = wmlimits(varargin)
%WMLIMITS Set or obtain web map limits
%
%   Syntax
%   ------
%   WMLIMITS(latitudeLimits, longitudeLimits)
%   WMLIMITS(WM, latitudeLimits, longitudeLimits)
%   [latitudeLimits, longitudeLimits] = WMLIMITS()
%   [latitudeLimits, longitudeLimits] = WMLIMITS(WM)
%
%   Updated Description
%   -----------
%   WMLIMITS(latitudeLimits, longitudeLimits) requests that the current web
%   map, or a new web map if there is no current web map, be centered
%   within the latitude limits latitudeLimits and the longitude limits
%   longitudeLimits. The resulting limits often do not match the requested
%   limits, because the zoom level is quantized to discrete integer values
%   and because the longitude limits may be constrained if the map was
%   constructed with 'WrapAround', false.
%
%   WMLIMITS(WM, latitudeLimits, longitudeLimits)  centers the web map
%   specified by the web map handle WM within the specified latitude limits
%   and longitude limits.
%
%   [latitudeLimits, longitudeLimits] = WMLIMITS() returns the latitude and
%   longitude limits of the web map specified by WM.
%
%   [latitudeLimits, longitudeLimits] = WMLIMITS(WM) returns the latitude
%   and longitude limits of the web map specified by WM.
%
%   Input Arguments
%   ----------------
%
%   Name                  Description                Data Type
%   ----            ------------------------    -------------------------
%   latitudeLimits   latitude limits in degrees 1-by-2 row vector, double
%   longitudeLimits longitude limits in degrees 1-by-2 row vector, double
%   WM              handle to web map           scalar web map
%
%   Output Arguments
%   ----------------
%
%   Name                   Description            Data Type
%   ----            -------------------------    -------------
%   latitudeLimits   latitude limits in degrees  scalar double
%
%   longitudeLimits longitude limits in degrees  scalar double
%
%   Example 1
%   ---------
%   wmlimits([37, 42], [-108.9, -100.7])
%   [latitudeLimits, longitudeLimits] = wmlimits()
%
%   Example 2
%   ---------
%   h1 = webmap;
%   h2 = webmap('worldtopographic');
%   latitudeLimits = [37, 42];
%   longitudeLimits = [-108.9, -100.7];
%   wmlimits(h1, latitudeLimits, longitudeLimits)
%   wmlimits(h2, latitudeLimits, longitudeLimits)
%
%   See also WEBMAP, WMCENTER, WMCLOSE, WMLINE, WMMARKER, WMPOLYGON, WMPRINT, WMREMOVE, WMZOOM

% Copyright 2013-2015 The MathWorks, Inc.

narginchk(0, 3)
nargoutchk(0, 2)

% Parse the inputs.
[wm, latlim, lonlim] = parseInputs(varargin);

% If the web map canvas handle, wm, is unspecified ([]), then create a new
% one and set the browserIsEnabled flag to false. Otherwise, validate wm
% and set browserIsEnabled to true. wm is returned as a valid web map
% canvas handle.
[wm, browserIsEnabled] = webMapCanvasHandle(wm);

if nargout > 0    
    % Do not create a new web map for the syntax:
    % wmlimits()
    if ~browserIsEnabled 
        % Create a new web map. Create the map before getting limits since
        % the web map after creation may not match the default limits.
        web(wm);
    end
    
    if nargin > 1
        % Support undocumented syntax:
        %   [latlim, lonlim] = wmlimits(wm, latlim, lonlim)
        %   [latlim, lonlim] = wmlimits(latlim, lonlim)
        %
        % Set new latlim, lonlim values in the web map.
        setLimitProperties(wm, latlim, lonlim);
    end
    
    % Get the latitude and longitude limits from the web map.
    [latlim, lonlim] = getLimitProperties(wm);
    varargout{1} = latlim;
    if nargout == 2
        varargout{2} = lonlim;
    end
    
elseif nargin > 0
    % Set new latlim, lonlim values in the web map.
    setLimitProperties(wm, latlim, lonlim);
    
    % Do not create a new web map for the syntax:
    % wmlimits()
    if ~browserIsEnabled 
        % Create a new web map.
        web(wm);
    end
end

%--------------------------------------------------------------------------

function [wm, latlim, lonlim] = parseInputs(inputs)
% Parse inputs.

% Set default values.
wm = [];
latlim = [];
lonlim = [];

switch length(inputs)
    case 0
        % wmlimits()
        % [latlim, lonlim] = wmlimits()
    case 1
        % [latlim, lonlim] = wmlimits(wm)
        wm = inputs{1};
    case 2
        % wmlimits(latlim, lonlim)
        latlim = inputs{1};
        lonlim = inputs{2};
    case 3
        % wmlimits(wm, latlim, lonlim)
        wm = inputs{1};
        latlim = inputs{2};
        lonlim = inputs{3};        
end

%--------------------------------------------------------------------------

function setLimitProperties(wm, latlim, lonlim)
% Set the latlim and lonlim inputs in the web map.

try    
    % Validate and set LatitudeLimits and LongitudeLimits. The Canvas class
    % validates the limits.
    % Set the CenterPoint to [] to indicate that limits should be used
    % instead of center point.
    wm.CenterPoint = [];
    setLimits(wm, latlim, lonlim);
catch e
    throwAsCaller(e);
end

%--------------------------------------------------------------------------

function [latlim, lonlim] = getLimitProperties(wm)
% Get the latlim and lonlim inputs in the web map.

try
    latlim = wm.LatitudeLimits;
    lonlim = wm.LongitudeLimits;
catch e
    throwAsCaller(e)
end
