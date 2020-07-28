function [count] = Motion_level(Vx_t ,Vy_t)
size_im = size(Vx_t);
size_y = size_im(1);
size_x = size_im(2);
count_x = zeros(size_x,1);
count_y = zeros(size_x,1);
count = 0;
for x = 1 : size_x
    for y = 1 : size_y
        temp_x  = Vx_t(y,x);
        temp_y  = Vy_t(y,x);
        count_x(x,1) = count_x(x,1) + temp_x;
        count_y(x,1) = count_y(x,1) + temp_y;
    end
    count_x(x,1) = count_x(x,1) / size_y;
    count_y(x,1) = count_y(x,1) / size_y;
end
clearvars size_im;
for x = 1 : size_x
    count = count + sqrt(count_x(x,1).^2 + count_y(x,1).^2);
end
count = count / size_x;
end