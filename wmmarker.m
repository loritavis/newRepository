function varargout = wmmarker(varargin)
%WMMARKER Display geographic marker on web map
%
%   Syntax
%   ------
%   WMMARKER(LAT, LON)
%   WMMARKER(P)
%   WMMARKER(WM, __)
%   WMMARKER(__, Name, Value)
%   H = WMMARKER(__)
%
%   Description
%   ------------
%   WMMARKER(LAT, LON) displays a marker overlay consisting of the points
%   in LAT and LON. The overlay appears on the current web map, or on a new
%   web map if there is no current web map. The map is centered such that
%   all the vector overlays displayed in the web map are visible.
%
%   WMMARKER(P) displays a marker overlay based on the content of the
%   geopoint vector P. The overlay contains one point feature for each
%   element of P.
%
%   WMMARKER(WM, __) displays the overlay in the web map specified by the
%   web map handle, WM.
%
%   WMMARKER(__, Name, Value) specifies name-value pairs that set
%   additional web map marker properties. Parameter names can be
%   abbreviated and are case-insensitive.
%
%   H = WMMARKER(__) returns a handle to the overlay.
%
%   Input Arguments
%   ---------------
%
%   Name     Description                 Data Type
%   ----  --------------------     -----------------------
%   LAT   latitude of vertices     single or double matrix
%   LON   longitude of vertices    single or double matrix                                         
%   P     geographic features      geopoint vector
%   WM    handle to web map        scalar web map handle  
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
%                               web map frame. The default name is 'Marker
%                               Overlay N' where N is the number for this
%                               overlay.
%
%   FeatureName String or       Name for the feature. The name appears in
%               cellstr         the feature's balloon when the feature is
%                               clicked in the web map. The default value
%                               is "OverlayName : Point K", where
%                               OverlayName is the name of the overlay and
%                               K is the number for a particular point. If
%                               the value is a string, it applies to all
%                               features. If the value is a cellstr it is
%                               either scalar or the same length as p or
%                               lat and lon.
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
%                               p, or lat and lon, and specifies the
%                               description for each marker. If the value
%                               is a structure, the attribute specification
%                               is applied to the attributes of each
%                               feature of P and ignored with LAT and LON
%                               input.
%
%  Icon         String or       File name of a custom icon for the marker.
%               cellstr         If the icon filename is not in the current
%                               folder, or in a folder on the MATLAB path,
%                               specify a full or relative pathname. The
%                               string may be an Internet URL. The URL must
%                               include the protocol type. If the icon
%                               filename is not specified, the default icon
%                               is displayed. For best results when you
%                               want to view a non-default icon, specify a
%                               PNG file containing image data with an
%                               alpha mask. If the value is a string, the
%                               value is applied to all markers. If the
%                               value is a cell array, it is the same
%                               length as P or LAT and LON, and specifies
%                               the icon for each marker.
%  
%  IconScale  Positive numeric  Scaling factor for icon. The default value
%             scalar or vector  is 1. If the value is a scalar, the value
%                               is applied to all icons. If the value is a
%                               vector, it must specify a value for each
%                               icon, and it must be the same length as LAT
%                               and LON, or P.
%
%  Color  MATLAB Color          Color of icon. The color is applied to the
%         Specification,        icon when a custom icon file has not been 
%         cellstr, or           specified, otherwise it is
%         M-by-3 numeric array  ignored. The default value is 'red'.  
%                               If the value is a cell array, it must be
%                               the same length as LAT and LON, or P. If
%                               the value is a numeric array, it must be
%                               1-by-3 or M-by-3 where M is the length of
%                               lat and lon, or p.
%
%  Alpha  Numeric scalar        Transparency of marker. If you specify a
%         or vector             vector it must include a value for each
%                               marker, that is, it must be the same length
%                               as P. The value ranges from 0 to 1. If
%                               unspecified, the value is 1 (fully opaque).
%
%   Output Arguments
%   ----------------
%
%   Name          Description                     Data Type
%   ----     ------------------------      ----------------------------
%   H        handle to marker overlay      scalar marker overlay handle 
%
%   Example 1
%   ---------
%   % Display a location in London, England as a marker on a web map.
%   lat = 51.5187666404504;
%   lon = -0.130003487285315;
%   wmmarker(lat,lon);
%
%   Example 2
%   ---------
%   % Display points from a GPX file as markers on a web map.
%   p = gpxread('boston_placenames');
%   wmmarker(p,'FeatureName',p.Name,'OverlayName','Boston Placenames')
%
%   Example 3
%   ----------
%   % Display an icon as a marker containing a description in HTML.
%   lat =  42.299827;
%   lon = -71.350273;
%   description = sprintf('%s<br>%s</br><br>%s</br>', ...
%     '3 Apple Hill Drive', 'Natick, MA. 01760', ...
%     'https://www.mathworks.com');
%   name = 'The MathWorks, Inc.';
%   iconDir = fullfile(matlabroot,'toolbox','matlab','icons');
%   iconFilename = fullfile(iconDir,'matlabicon.gif');
%   wmmarker(lat,lon,'Description',description,'Icon',iconFilename,...
%     'FeatureName',name,'OverlayName',name);
%
%   Example 4
%   ---------
%   % Display points from a shapefile representing tsunami (tidal wave)
%   % events using an attribute specification.
%   S = shaperead('tsunamis','UseGeoCoords',true);
%   p = geopoint(S);
%
%   % Construct an attribute specification.
%   attribspec = makeattribspec(p);
%
%   % Modify the attribute spec to:
%   % (a) Display Max_Height, Cause, Year, Location, and Country attributes 
%   % (b) Rename the 'Max_Height' field to 'Maximum Height' 
%   % (c) Highlight each attribute label with a bold font 
%   % (d) Set to zero the number of decimal places used to display Year
%   % (e) We have independent knowledge that the height units are meters, 
%   %     so we will add that to the Height format specifier
%
%   desiredAttributes = ...
%      {'Max_Height', 'Cause', 'Year', 'Location', 'Country'};
%   allAttributes = fieldnames(attribspec);
%   attributes = setdiff(allAttributes, desiredAttributes);
%   attribspec = rmfield(attribspec, attributes);
%   attribspec.Max_Height.AttributeLabel = '<b>Maximum Height</b>';
%   attribspec.Max_Height.Format = '%.1f Meters';
%   attribspec.Cause.AttributeLabel = '<b>Cause</b>';
%   attribspec.Year.AttributeLabel = '<b>Year</b>';
%   attribspec.Year.Format = '%.0f';
%   attribspec.Location.AttributeLabel = '<b>Location</b>';
%   attribspec.Country.AttributeLabel = '<b>Country</b>';
% 
%   % Display the locations on a web map as markers.
%   webmap('oceanbasemap','WrapAround',false);
%   wmmarker(p,'Description',attribspec,'OverlayName','Tsunami Events')
%   wmzoom(2)
%
%   See also WEBMAP, WMCENTER, WMCLOSE, WMLIMITS, WMLINE, WMPOLYGON, WMPRINT, WMREMOVE, WMZOOM

% Copyright 2013-2016 The MathWorks, Inc.

nargoutchk(0,1)
if nargin == 0 
    % Permit, but do not create a new web map for the syntax:
    % wmmarker()
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

% Create a marker overlay handle.
try
    hmarker = addMarkerOverlay(wm, varargin{:});
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
    % Return the marker overlay handle.
    varargout{1} = hmarker;
end
