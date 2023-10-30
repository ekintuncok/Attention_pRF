function [proportion_deviated] = attpRF_calculate_eye_deviation(data)

distance_from_center = sqrt((data(:, 1)).^2 + (data(:, 2)).^2);
proportion_deviated = sum(distance_from_center > 2)/length(distance_from_center);

end