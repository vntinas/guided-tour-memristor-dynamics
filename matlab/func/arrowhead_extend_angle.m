function [h] = arrowhead_extend_angle(h, extend_factor, angle_reduction_coef)

angle_reduction_coef = angle_reduction_coef*pi/180;

drawnow

% Arrowhead Vertices
x1s = h.NodeChildren(3).VertexData(1,1:3:end);
x2s = h.NodeChildren(3).VertexData(1,2:3:end);
x3s = h.NodeChildren(3).VertexData(1,3:3:end);
y1s = h.NodeChildren(3).VertexData(2,1:3:end);
y2s = h.NodeChildren(3).VertexData(2,2:3:end);
y3s = h.NodeChildren(3).VertexData(2,3:3:end);

% Calculate the difference vectors
d1_x = x1s - x2s; 
d1_y = y1s - y2s;
d2_x = x3s - x2s;
d2_y = y3s - y2s;

% Calculate the current angles
angle1 = atan2(d1_y, d1_x);
angle2 = atan2(d2_y, d2_x);

% Calculate the lengths of the arrowhead lines
length1 = sqrt(d1_x.^2 + d1_y.^2);
length2 = sqrt(d2_x.^2 + d2_y.^2);

% Extend the lengths by the extend_factor
new_length1 = length1 * extend_factor;
new_length2 = length2 * extend_factor;

% Adjust the angles based on the angle_reduction_coef
new_angle1 = angle1 - angle_reduction_coef;
new_angle2 = angle2 + angle_reduction_coef;

% Calculate the new difference vectors with the extended length
new_d1_x = new_length1 .* cos(new_angle1);
new_d1_y = new_length1 .* sin(new_angle1);
new_d2_x = new_length2 .* cos(new_angle2);
new_d2_y = new_length2 .* sin(new_angle2);

% Calculate the new points by extending the vectors
new_point1_x = x2s + new_d1_x;
new_point1_y = y2s + new_d1_y;
new_point3_x = x2s + new_d2_x;
new_point3_y = y2s + new_d2_y;

% Assign the new points
h.NodeChildren(3).VertexData(1,1:3:end) = new_point1_x;
h.NodeChildren(3).VertexData(2,1:3:end) = new_point1_y;
h.NodeChildren(3).VertexData(1,3:3:end) = new_point3_x;
h.NodeChildren(3).VertexData(2,3:3:end) = new_point3_y;

end
