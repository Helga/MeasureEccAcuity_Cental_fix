function ind = find_clicked_letter(grid_xy, numCol, numRow, x,y)

% finds which letter was clicked on.
%grid_xy has the coordinates of the top-left and the bottom-right of the
%grid. x, y are where the subject clicked on

% History: July 31, 2014 created by HM

Xs = linspace(grid_xy(1), grid_xy(3), numCol + 1);%x coordinates of the grid
Ys = linspace(grid_xy(2), grid_xy(4), numRow + 1);%y coordinates of the grid

%fidn on which cell the subject clicked on
ind_x = find(Xs > x, 1) - 1;
ind_y = find(Ys > y, 1) -1 ;

ind = (ind_y-1) * numCol + ind_x;%convert x,y indices to a one dimensional index
