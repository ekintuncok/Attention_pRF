function th = fix_deg(x)
% helper:
th = x - floor(x/360 + 0.5) * 360;
end