function drawFixation(windowPtr, p, half_l, color, width)

% wrote by HM 12/10/2013 
if ~exist('width', 'var') || isempty(width)
    width = 2;
end
Screen('DrawLine',windowPtr,color,x-half_l, y, x+half_l, y, width);
Screen('DrawLine',windowPtr,color,x, y-half_l, x, y+half_l, width); 
