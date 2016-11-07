function wmprint(wm)
%WMPRINT Print web map
%
%   Syntax
%   ------
%   WMPRINT
%   WMPRINT(WM)
%
%  Update  Description
%   -----------
%   WMPRINT prints the contents of the current web map to a printer.
%
%   WMPRINT(WM) prints the contents of the web map specified by WM.
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
%   webmap('openstreetmap')
%   wmcenter(51.487, 0, 15)
%   wmprint
%
%   See also WEBMAP, WMCENTER, WMCLOSE, WMLIMITS, WMLINE, WMMARKER, WMPOLYGON, WMREMOVE, WMZOOM

% Copyright 2013-2016 The MathWorks, Inc.

% Obtain wm.
if ~exist('wm', 'var')
    [wm, browserIsEnabled] = webMapCanvasHandle();
else
    [wm, browserIsEnabled] = webMapCanvasHandle(wm);
end

if browserIsEnabled
    % Print the webmap.
    print(wm);
end
