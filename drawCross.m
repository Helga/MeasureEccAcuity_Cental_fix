function drawCross(windowPtr, p, half_l, color, width)

% wrote by HM 12/10/2013 
%draws a X at the center of rec on the screen , size is in pixels
if ~exist('width', 'var') || isempty(width)
    width = 2;
end
    
x = p(1);
y = p(2);
Screen('DrawLine',windowPtr,color,x - half_l,y- half_l,x+ half_l,y+ half_l,width);
Screen('DrawLine',windowPtr,color,x - half_l,y+half_l,x+ half_l,y-half_l,width); 
