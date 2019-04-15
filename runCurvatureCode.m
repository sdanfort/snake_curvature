%runCurvatureCode

%This MATLAB script is a general example for running through a series of
%snake centerlines, which MUST be ordered from head to toe:
%   - finding areas of local max. curvature, 
%   - determining the radius of curvature at each of these points, 
%   - determining if each curve falls to the left or right of the 
%     snake's head, 
%   - plotting the results for user visualization,
%   - save the figure, 
%   - tabulate reuslts (saved as .txt and .xls), and
%   - save data as a .mat struct.

% NOTES: - You will need to update 'inpath' string for wherever your data
%           is located.
%        - Centerline data is found under {snake species name}/{video file
%           name}/{handdrawn_centerline} and is a .txt file with a sequence
%           of ordered pairs separated by commas. 
%        - close_figure should always be set to 1 if you are running 
%           through a high volume of images, unless you set a breakpoint in
%           the plot_ROC function and plan to close after each iteration \
%           yourself. Matlab will freeze up if too many images are plotted
%           at once.
%        - Smoothing, averaging, and window parameters to play around with,
%           see below.

% Author:       Shannon Danforth
% Written:      03/30/2019
% Last update:  04/14/2019

clear; close all;

%snake species name
snakeName = 'hemprichii';

%define some constants
numPts = 500;           %number of points in spline
win = 0.02;             %window for determining curvature (fraction of snake length)
save_files = 1;         %save resulting figures, tables, and data structs?
close_figure = 1;       %close figure after each iteration?

%smooth points?
smoothPoints_on = 1;
smoothPts = 30;

%minimum distance to average peaks together.
minPkDist = 30;         %points (update accordingly if you change numPts)

%radius thresh?
radiusThreshOn = 1;
radiusThresh = 7;       %percentage of snake length

%define the general path to the snakedata.
%user must update to filepath!!!
inpath = '/Users/...';

%find how many subfolders we have for that snake species.
d = dir( sprintf( '%s/%s', inpath, snakeName ) );
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];

for i = 1:length( nameFolds )
    
    imFolder = nameFolds{ i };
    
    %now find how many txt files are in the handdrawn_centerline folder 
    %(if it's zero, it'll just return an empty array and skip to the next)
    snakeFiles = dir( sprintf( '%s/%s/%s/handdrawn_centerline/*.txt',...
        inpath, snakeName, imFolder ) );
    
     for j = 1:length(snakeFiles)

        fileName = snakeFiles( j ).name;
         
        %organize the points into [x, y] vector
        curve_pts = importSnake( sprintf( '%s/%s/%s/handdrawn_centerline/%s',...
            inpath, snakeName, imFolder, fileName) );
        
        x = curve_pts(:, 1);
        y = curve_pts(:, 2);
        
        %get rid of curve points at beginning and end that are far away 
        %from all of the other points 
        %(hand-drawn centerline sometimes included an accidental 
        %far-away click at the end).
        normPts = 100;
        while normPts > 75
            
            normPts = norm( [ x(end), y(end) ] - [ x(end - 1 ),...
                y(end - 1 ) ] );
            
            if normPts > 75
                
                %get rid of the last point in (x, y)
                x = x(1:end - 1);
                y = y(1:end - 1);
                
            end
            
        end
    
        %spline x and y.
        [x, y] = spline_x_and_y( x, y, numPts ); 
        
        %smooth the snake centerline points to account for sharp corners in
        %human-centerline-picking
        %note: 'smooth' requires special matlab toolbox. Can also use 'movmean'
        if smoothPoints_on
            x = smooth( x, smoothPts );
            y = smooth( y, smoothPts );
        end
            
        %find curve midpoints.
        [ R, K, R_pks, K_pks, R_idx, L, L_full] = find_curves( x, y, win,...
            radiusThreshOn, radiusThresh );

        %find whether they are L or R of the snake's head
        LR = left_or_right( x, y, K );
        
        %now average peaks 
        [R_idx, R_pks, K_pks, R_d] = average_pks( R_idx, R_pks, K_pks, LR,...
            minPkDist, L, L_full );
         
        %plot things to get a feel if the radii are accurate
        plot_ROC( x, y, R_idx, R_pks, K, LR, inpath, snakeName, imFolder,...
            fileName, save_files, close_figure, L_full );   
        
        
        if save_files
            
            %round the numbers so they don't have so many sig figs
            R_location = round(R_d.*100)./100;
            R_normalized = round(R_pks.*100)./100;
            
            %number the curves in order from head to toe
            curveNumber = ( 1:length (R_pks ) )';
            
            %we just care about LR value at indices of peak curvature
            L_or_R = LR(R_idx);
            
            %make table for each image:
            t1 = table( curveNumber, R_location, R_normalized, L_or_R );

            %make some folders (check filename):
            if ~exist( sprintf('%s/%s/%s/curvatureTables', inpath,...
                    snakeName, imFolder ), 'dir' )

                mkdir( sprintf('%s/%s/%s/curvatureTables', inpath,...
                    snakeName, imFolder ) );

            end

            if ~exist( sprintf('%s/%s/%s/curvatureTables/txt', inpath,...
                    snakeName, imFolder ), 'dir' )

                mkdir( sprintf('%s/%s/%s/curvatureTables/txt', inpath,...
                    snakeName, imFolder ) );

            end

            if ~exist( sprintf('%s/%s/%s/curvatureTables/xls', inpath,...
                    snakeName, imFolder ), 'dir' )

                mkdir( sprintf('%s/%s/%s/curvatureTables/xls', inpath,...
                    snakeName, imFolder ) );

            end

            %write to .txt file
            writetable( t1, sprintf('%s/%s/%s/curvatureTables/txt/%s', inpath,...
                snakeName, imFolder, fileName(1:end-4) ), 'Delimiter', 'tab' );

            %write to .xls file
            writetable( t1, sprintf('%s/%s/%s/curvatureTables/xls/%s.xls', inpath,...
                snakeName, imFolder, fileName(1:end-4) ) );

            %save as struct
            data.snakeName = snakeName;
            data.imFolder = imFolder;
            data.fileName = fileName(1:end-4);
            data.x = x;
            data.y = y;
            data.snakeLength = L_full;
            data.R = R;
            data.K = K;
            data.R_idx = R_idx;
            data.R_pks = R_pks;
            data.K_pks = K_pks;
            data.L_or_R = LR;
            data.R_distance = R_d;
            data.table = t1;

            if ~exist( sprintf('%s/%s/%s/curvatureStructs', inpath,...
                    snakeName, imFolder ), 'dir' )

                mkdir( sprintf('%s/%s/%s/curvatureStructs', inpath,...
                    snakeName, imFolder ) );

            end

            save( sprintf('%s/%s/%s/curvatureStructs/%s', inpath,...
                    snakeName, imFolder, fileName(1:end-4) ), 'data' );

        end
        
    end
 
end