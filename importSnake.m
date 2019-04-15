function curve_pts = importSnake(filename)
%
% This MATLAB function takes a list of n pairs from a .txt file and outputs
% an nx2 array of (x,y) snake centerline points.
%
% Input:  - filename: a string describing the filename of .txt file with n
%           ordered pairs separated by commas
%
% Output: - curve_pts: an nx2 array of snanke centerline points.
%
% Author:       Shannon Danforth
% Written:      03/25/2019
% Last update:  -----
    
    fileID=fopen(filename);
    a = textscan(fileID,'%s',Inf,'Delimiter',{',',' '},'MultipleDelimsAsOne',true);
    for col=1:length(a{:})
        rawData(col) = double(string(a{:}{col}));
    end
    curve_pts(:, 1) = rawData(1:2:end);
    curve_pts(:, 2) = rawData(2:2:end);
    fclose(fileID);
    
end
