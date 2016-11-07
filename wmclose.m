function wmclose(varargin)

%
%   Syntax
%   ------
%   WMCLOSE
%   WMCLOSE(WM)
%   WMCLOSE ALL
%
%   Description
%   -----------
%   WMCLOSE closes the current web map.
%
%   WMCLOSE(WM) closes the web map specified by WM.
%
%   WMCLOSE ALL closes all the web maps.
%
%   Input Arguments
%   ----------------
%
%   Name      Description          Data Type
%   ----    -----------------    --------------
%   WM      handle to web map    scalar web map
%
%   Example 1
%   ---------
%   webmap
%   pause(5)
%   wmclose
%
%   Example 2
%   ---------
%   h1 = webmap;
%   h2 = webmap('ocean basemap');
%   pause(5)
%   wmclose(h1)
%   wmclose all
%
%   See also WEBMAP, WMCENTER, WMLIMITS, WMLINE, WMMARKER, WMPOLYGON, WMPRINT, WMREMOVE, WMZOOM

% Copyright 2013-2015 The MathWorks, Inc.

narginchk(0,1)

% Parse the inputs.
[wm, closeAll] = parseInputs(varargin);

% Delete the web map.
delete(wm);

if closeAll
    % wmclose('all') was requested.
    closeAllWebMapBrowsers()
end
        
%--------------------------------------------------------------------------

function [wm, closeAll] = parseInputs(inputs)
% Parse inputs. Return a valid web map canvas handle in wm.
% closeAll is true if 'all' was specified in the cell array, inputs.

if isempty(inputs)
    wm = [];
    wm = webMapCanvasHandle(wm);
    closeAll = false;
    
elseif ischar(inputs{1})
    validatestring(inputs{1}, {'all'});
    wm = [];
    closeAll = true;
    
else
    wm = inputs{1};
    wm = webMapCanvasHandle(wm);
    closeAll = false;
end

%--------------------------------------------------------------------------

function closeAllWebMapBrowsers()
%closeAllWebMapBrowser Close all web map browsers

% Obtain all the handles from the webmap appdata and delete them.
if isappdata(0, 'webmap')
    s = getappdata(0,'webmap');
    values = s.values;
    for k = length(values):-1:1
        delete(values{k})
    end
    if isappdata(0, 'webmap')
       rmappdata(0, 'webmap')
    end
end
