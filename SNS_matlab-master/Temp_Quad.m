function [Quad_Tc] = Temp_Quad(dark_im,pre_im,quad_num_h,quad_num_w,mesh_size,h,w)
Tc = zeros(h,w);
for i = 1:h
    for j = 1:w
        Tc(i,j) = abs(dark_im(i,j) - pre_im(i,j));
    end
end
Quad_Tc = zeros(quad_num_h, quad_num_w);
for qi = 1:quad_num_h
    for qj = 1:quad_num_w
        for i = 1:mesh_size
            for j = 1:mesh_size
                if((qi-1)*mesh_size + i <= h)
                    if((qj-1)*mesh_size + j <= w)
                        Quad_Tc(qi,qj) = Quad_Tc(qi,qj) + Tc((qi-1)*mesh_size+i,(qj-1)*mesh_size+j);
                    end
                end
            end
        end
    end
end
for qi = 1:quad_num_h
    for qj = 1:quad_num_w
        Quad_Tc(qi,qj) = Quad_Tc(qi,qj) + 40;
    end
end
for qi = 1:quad_num_h
    for qj = 1:quad_num_w
        Quad_Tc(qi,qj) = 1/Quad_Tc(qi,qj);
    end
end
end