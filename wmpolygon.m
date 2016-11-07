function varargout = wmpolygon(varargin)
%WMPOLYGON Display geographic polygon in a web map
%
%   Syntax
%   ------
%   WMPOLYGON(LAT, LON)
%   WMPOLYGON(P)
%   WMPOLYGON(WM, __)
%   WMPOLYGON(__, Name, Value)
%   H = WMPOLYGON(__)
%
%   Description
%   -----------
%   WMPOLYGON(LAT, LON)  displays a polygon overlay consisting of the
%   vertices in LAT and LON. The overlay appears on the current web map, or
%   on a new web map if there is no current web map. The map is centered
%   and scaled such that all the vector overlays displayed in the web map
%   are visible.
%
%   WMPOLYGON(P) displays a polygon overlay based on the content of the
%   polygon geoshape vector P. The overlay contains one polygon feature for
%   each element of P.
%
%   WMPOLYGON(WM, __) displays the overlay in the web map specified by the
%   web map handle, WM.
%
%   WMPOLYGON(__, Name, Value) specifies name-value pairs that set
%   additional display properties. When the input is a polygon geoshape and
%   a single color (any colorspec), width, or alpha value is specified, the
%   same value applies to all the features. To control the display of M
%   features individually, where M = length(P), a vector of length P (or an
%   M-by-3 array of RBG values) is needed.
%
%   H = WMPOLYGON(__) returns a handle to the overlay. 
%
%   Input Arguments
%   ---------------
%
%   Name      Description                  Data Type
%   ----   --------------------    ----------------------------------------
%   LAT    latitude of vertices    single or double matrix in range [-90 90]
%   LON    longitude of vertices   single or double matrix
%   P      geographic features     polygon geoshape vector  
%   WM     handle to web map       scalar web map handle  
%
%   Name Value Pair Arguments
%   -------------------------
%
%   AutoFit
%          A scalar logical or numeric 0 or 1 that specifies whether the
%          spatial extent of the map is adjusted to ensure that all the
%          vector overlays on the map are visible. If false, the spatial
%          extent is not adjusted when the vector layer is added to the
%          map. The default value is true.
%
%   OverlayName
%          A string that specifies the name of the overlay layer.  The name
%          is inserted in the Layer Manager under the "Overlays" item. The
%          Layer Manager is the tool that appears on the right side of the
%          web map frame. The default value is 'Polygon Overlay N' where N
%          is the number for this overlay.
%
%   FeatureName
%          A string or cellstr that specifies the name of the feature. The
%          name appears in the feature's balloon when the feature is
%          clicked in the web map.  If the value is a string, it applies to
%          all features. If the value is a cellstr it is either scalar or
%          the same length as P. The default value is 
%          'OverlayName : Polygon K', where OverlayName is the name of the
%          overlay and K is the number for a particular polygon.
%
%   Description
%          A string, cellstr, or scalar structure that specifies a
%          description of the feature. The description content is displayed
%          in the feature's balloon which appears when the feature is
%          clicked in the web map. Description elements can be either plain
%          text or marked up with HTML. When an attribute specification
%          structure is provided, the display in the balloon for the
%          attribute fields of P are modified according to the
%          specification. If the value is a cell array it is either scalar
%          or the same length as P, and specifies the description for each
%          polygon. If the value is a structure, the attribute
%          specification is applied to the attributes of each feature of P.
%          The default value is the empty string.
%         
%   FaceColor 
%          A MATLAB Color Specification (ColorSpec) (string, cellstr, or
%          numeric array with values between 0 and 1) that specifies the
%          color of polygon faces. If the value is a cell array, it is
%          scalar or the same length as P. If the value is a numeric array,
%          it is size M-by-3 where M is the length of P. The value 'none'
%          indicates that polygons are not filled. The default value is
%          'black'.
%
%   FaceAlpha
%          A numeric scalar or vector with values between 0 and 1 that
%          specifies the transparency of the polygon faces. If the value is
%          scalar it applies to all polygon faces. If the value is a
%          vector, it is the same length as P. The default value is 1
%          (fully opaque).
%
%   EdgeColor
%          A MATLAB Color Specification (ColorSpec) (string, cellstr, or
%          numeric array with values between 0 and 1) that specifies the
%          color of the polygon edges. If the value is a cell array, it is
%          scalar or the same length as P. If the value is a numeric array,
%          it is size M-by-3 where M is the length of P. The value 'none'
%          indicates that polygons have no outline. The default value is
%          'none'.
%
%   EdgeAlpha
%          A numeric scalar or vector with values between 0 and 1 that
%          specifies the transparency of the polygon edges. If the value is
%          scalar it applies to all polygon edges. If the value is a
%          vector, it is the same length as P. The default value is 1
%          (fully opaque).
%
%   LineWidth
%          A positive numeric scalar or vector that specifies the width of
%          polygon edges in pixels. If the value is scalar it applies to
%          all polygon edges. If the value is a vector, it is the same
%          length as P. The default value is 1.
%
%   Output Arguments
%   ----------------
%
%   Name          Description                   Data Type
%   ----     -------------------------   -----------------------------
%   H        handle to polygon overlay   scalar polygon overlay handle 
%
%   Example 1
%   ----------
%   % Display coastlines as a polygon.
%   load coastlines
%   wmpolygon(coastlat,coastlon,'OverlayName','Polygon coastlines')
%
%   Example 2
%   ---------
%   % Display a polygon with an inner ring around the Eiffel Tower.
%   lat0 = 48.858288;
%   lon0 = 2.294548;
%   outerRadius = .01;
%   innerRadius = .005;
%   [lat1,lon1] = scircle1(lat0,lon0,outerRadius);
%   [lat2,lon2] = scircle1(lat0,lon0,innerRadius);
%   lat2 = flipud(lat2);
%   lon2 = flipud(lon2);
%   lat = [lat1; NaN; lat2];
%   lon = [lon1; NaN; lon2];
%   webmap('worldimagery')
%   wmpolygon(lat,lon,'EdgeColor','g','FaceColor','c','FaceAlpha',.5)
%
%   Example 3
%   ---------
%   % Display the USA state boundaries using a political color map.
%   p = shaperead('usastatelo.shp','UseGeoCoords',true);
%   p = geoshape(p);
%   colors = polcmap(length(p));
%   webmap('worldphysicalmap')
%   wmpolygon(p,'FaceColor',colors,'FaceAlpha',.5,'EdgeColor','k', ...
%     'EdgeAlpha',.5,'OverlayName','USA Boundary','FeatureName',p.Name)
%
%   See also WEBMAP, WMCENTER, WMCLOSE, WMLIMITS, WMLINE, WMMARKER, WMPRINT, WMREMOVE, WMZOOM

% Copyright 2015 The MathWorks, Inc.

nargoutchk(0,1)
if nargin == 0
    % Permit, but do not create a new web map for the syntax:
    % wmpolygon
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

% Create a polygon overlay handle.
try
    hpoly = addPolygonOverlay(wm, varargin{:});
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
    % Return the polygon overlay handle.
    varargout{1} = hpoly;
end
