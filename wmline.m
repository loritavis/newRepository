function varargout = wmline(varargin)
%WMLINE Display geographic line in a web map
%
%   Syntax
%   ------
%   WMLINE(LAT, LON)
%   WMLINE(P)
%   WMLINE(WM, __)
%   WMLINE(__, Name, Value)
%   H = WMLINE(__)
%
%   Update Description
%   -----------
%   WMLINE(LAT, LON)  displays a line overlay consisting of the vertices in
%   LAT and LON. The overlay appears on the current web map, or on a new
%   web map if there is no current web map. The map is centered such that
%   all the vector overlays displayed in the web map are visible.
%
%   WMLINE(P) displays a line overlay based on the content of a geopoint or
%   a geoshape vector P. If P is a geopoint vector, then the overlay
%   contains a single line connecting its vertices. If P is a geoshape
%   vector, then the overlay contains one line feature for each element of
%   P.
%
%   WMLINE(WM, __) displays the overlay in the web map specified by the web
%   map handle, WM.
%
%   WMLINE(__, Name, Value) specifies name-value pairs that set additional
%   display properties.
%
%   H = WMLINE(__) returns a handle to the overlay. 
%
%   Input Arguments
%   ---------------
%
%   Name      Description                  Data Type
%   ----   --------------------    ----------------------------------
%   LAT    latitude of vertices    single or double matrix 
%   LON    longitude of vertices   single or double matrix
%   P      geographic features     geopoint vector or geoshape vector  
%   WM     handle to web map       scalar web map handle  
%
%   Name Value Pair Arguments
%   -------------------------
% 
%   Name        Data Type                    Description                                
%   ----        ---------       -------------------------------------------                                 
%   AutoFit     Scalar logical  If true or 1, the spatial extent of the map  
%               or numeric      is adjusted to ensure that all the vector  
%                               overlays on the map are visible. If false, 
%                               the spatial extent is not adjusted when  
%                               the vector layer is added to the map. The
%                               default value is true.
%
%   OverlayName String          Name for the overlay layer. The name is     
%                               inserted in the Layer Manager under the
%                               "Overlays" item. The Layer Manager is the
%                               tool that appears on the right side of the
%                               web map frame. The default name is 'Line
%                               Overlay N' where N is the number for this
%                               overlay.
%
%   FeatureName String or       Name for the feature. The name appears in
%               cellstr         the feature's balloon when the feature is
%                               clicked in the web map. The default value
%                               is "OverlayName : Line K", where
%                               OverlayName is the name of the overlay and
%                               K is the number for a particular line. If
%                               the value is a string, it applies to all
%                               features. If the value is a cellstr it is
%                               either scalar or the same length as p.
%
%  Description  String,         Description of feature. The description
%               cellstr, or     content is displayed in the feature's
%          scalar structure     balloon which appears when the feature is
%                               clicked in the web map. Description
%                               elements can be either plain text or marked
%                               up with HTML. When an attribute
%                               specification structure is provided, the
%                               display in the balloon for the attribute
%                               fields of P are modified according to the
%                               specification. The default value is the
%                               empty string. If the value is a cell array
%                               it is either scalar or the same length as
%                               p, and specifies the description for each
%                               line. If the value is a structure, the
%                               attribute specification is applied to the
%                               attributes of each feature of P.
%
%  Color  MATLAB Color          Color of line. The default value is 'black'.
%         Specification,        If the value is a cell array, it must be
%         cellstr, or           the same length as P or scalar. If the
%         M-by-3 numeric array  value is a numeric array, it must be  
%                               1-by-3 or M-by-3 where M is the length of
%                               p.
%
%  Alpha  Numeric scalar        Transparency of line. If you specify a
%         or vector             vector it must include a value for each
%                               line, that is, it must be the same length
%                               as P. The value ranges from 0 to 1. If
%                               unspecified, the value is 1 (fully opaque).
%
%  LineWidth Positive numeric   Width of the line in pixels. The default 
%            scalar or vector   value is 1. If you specify a vector, it
%                               must include a value for each line, that
%                               is, it must be the same length as P.
%
%   Output Arguments
%   ----------------
%
%   Name          Description                   Data Type
%   ----     -----------------------     --------------------------
%   H        handle to line overlay      scalar line overlay handle 
%
%   Example 1
%   ----------
%   % Display coast lines on a web map as a black line.
%   load coastlines
%   wmline(coastlat,coastlon)
%
%   Example 2
%   ---------
%   % Display tracks from a GPX file on a web map. 
%   % Set the color of the first track to black and the second to red.
%   % Set the transparency of the first track to .5 and the second to 1.
%   % Set the width of both tracks to 2.
%   % Set the feature name of the first track to 'Track Log 1' 
%   % and the feature name of the second track to 'Track Log 2'.
%   % Set the description to the value in p.Metadata.Name.
%   p = gpxread('sample_tracks','Index',1:2);
%   colors = {'k','r'};
%   alpha = [.5 1];
%   name = {'Track Log 1', 'Track Log 2'};
%   description = p.Metadata.Name;
%   webmap
%   wmline(p,'Color',colors,'Alpha',alpha,'LineWidth',2,'FeatureName',name, ...
%     'Description',description,'OverlayName','GPS Track Logs')
%
%   See also WEBMAP, WMCENTER, WMCLOSE, WMLIMITS, WMMARKER, WMPOLYGON, WMPRINT, WMREMOVE, WMZOOM

% Copyright 2013-2015 The MathWorks, Inc.

nargoutchk(0,1)
if nargin == 0
    % Permit, but do not create a new web map for the syntax:
    % wmline()
    if nargout > 0
        varargout = {[]};
    end
    return
end

% Obtain the web map handle, wm.
if isa(varargin{1}, 'map.webmap.Canvas')
    wm = varargin{1};
    varargin(1) = [];
else
    wm = [];
end

% If the web map canvas handle, wm, is unspecified ([]), then create a
% new one and set the browserIsEnabled flag to false. Otherwise,
% validate wm and set browserIsEnabled to true. wm is returned as a
% valid web map canvas handle.
[wm, browserIsEnabled] = webMapCanvasHandle(wm);

% Create a line overlay handle.
try
    hline = addLineOverlay(wm, varargin{:});
catch e
   throwAsCaller(e);
end

if ~browserIsEnabled
    % Save limits.
    latlim = wm.LatitudeLimits;
    lonlim = wm.LongitudeLimits;
    
    % Create a new web map.
    web(wm);
    
    if any(lonlim > 180)
        % Ensure limits are set for this special case.
        wmlimits(latlim, lonlim)
    end
end

if nargout > 0
    % Return the line overlay handle.
    varargout{1} = hline;
end
