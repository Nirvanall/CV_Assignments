function draw_box(x, varargin)
%DRAW_BOX Draws a bounding box given a state estimate
%
%   draw_box(x, varargin)
%

    r = x(1);
    c = x(2);
    w = x(6)*x(5);
    h = x(6);

    x1 = r;
    x2 = r + w;
    y1 = c;
    y2 = c + h;

    if nargin == 1
        line([x1 x1 x2 x2 x1], [y1 y2 y2 y1 y1]);
    else
        line([x1 x1 x2 x2 x1], [y1 y2 y2 y1 y1], 'Color', varargin{1}, 'LineWidth', 1.5);
    end
