function wmremove(varargin)
%WMREMOVE Remove overlay on web map
%
%   Syntax
%   ------
%   WMREMOVE
%   WMREMOVE(H)
%
%  Update  Description
%   -----------
%   WMREMOVE removes the vector overlay most recently inserted into the
%   current web map.
%
%   WMREMOVE(H) removes the overlay or overlays specified by the web map
%   marker handle, web map line handle, or web map polygon handle H.
%
%   Input Arguments
%   ---------------
%
%   Name       Description                  Data Type
%   ----    -----------------           ---------------------
%   H       handle to vector overlay    web map marker handle vector 
%                                       or web map line handle vector.
%
%   Example 1
%   ----------
%   webmap
%   wmmarker(42, -73);
%   wmremove
%   h = wmmarker(42, -72.5);
%   wmremove(h)
%   h1 = wmmarker(42, -80);
%   h2 = wmmarker(42, -78);
%   wmremove([h1 h2])
%
%   Example 2
%   ---------
%   load coastlines
%   webmap
%   h = wmline(coastlat, coastlon);
%   wmremove(h)
%
%   Example 3
%   ---------
%   load coastlines
%   webmap
%   h = wmpolygon(coastlat, coastlon);
%   wmremove(h)
%
%   See also WEBMAP, WMCLOSE, WMLINE, WMMARKER, WMPOLYGON

% Copyright 2013-2015 The MathWorks, Inc.

narginchk(0,1)

% Parse the inputs.
[wm, h] = parseInputs(varargin);

% If the web map canvas handle, wm, is unspecified ([]), then create a
% new one and set the browserIsEnabled flag to false. Otherwise,
% validate wm and set browserIsEnabled to true. wm is returned as a
% valid web map canvas handle.
[wm, browserIsEnabled] = webMapCanvasHandle(wm);

% Remove the overlay from the web map if the browser is enabled.
if browserIsEnabled
    try
        if isempty(h)
            % Remove last overlay.
            removeOverlay(wm);
        else
            % Remove all overlays in h.
            for k = 1:length(h)
                wm = h(k).Canvas;
                removeOverlay(wm, h(k));
            end
        end
    catch e
        throwAsCaller(e);
    end
end

%--------------------------------------------------------------------------

function [wm, h] = parseInputs(inputs)
% Parse inputs and return WM and H.

n = length(inputs);
if n == 1
    % wmremove(h)
    h = inputs{1};
    classes = {'map.webmap.MarkerOverlay', 'map.webmap.LineOverlay', 'map.webmap.PolygonOverlay'};
    validateattributes(h, classes, {'nonempty'}, mfilename, 'H');
    wm = [];   
else
    % wmremove
    h = [];
    wm = [];
end   
