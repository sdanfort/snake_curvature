# snake_curvature

This repository provides a set of functions to:
- find areas of local maximum curvature along a snake centerline using an 
  altered version of functions written by Are Mjaavatten 
  (https://www.mathworks.com/matlabcentral/fileexchange/69452-curvature-of-a-2d-or-3d-curve/)
- determine the radius of curvature at each of these points, 
- determine if each curve falls to the left or right of the snake's head, 
- plot the results for user visualization.

A full example can be run, with the option to save the figure, tabulate results 
(saved as .txt and .xls), and save data as a .mat struct in runCurvatureCode.m

Note that snake centerline .txt files are not provided, and you must update your file paths in runCurvatureCode.m

Code written by Shannon Danforth

Moore, T.Y., Danforth, S.M., Larson, J.G., and Davis Rabosky, A.R. A quantitative analysis of Micrurus coral snakes reveals unexpected variation in stereotyped anti-predator displays within a mimicry system, Integrative Organismal Biology, March 2020.
