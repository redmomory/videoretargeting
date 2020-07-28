function [Tc_q] = Quad_Tc(Tc_q ,quad_num_h, quad_num_w, ,h,w)
for qi = 1:quad_num_h
            for qj = 1:quad_num_w
                for i = 1:mesh_size
                    for j = 1:mesh_size
                        if((qi-1)*mesh_size + i <= h)
                            if((qj-1)*mesh_size + j <= w)
                                Tc_q(qi,qj) = Tc_q(qi,qj) + Tc((qi-1)*mesh_size+i,(qj-1)*mesh_size+j);
                            end
                        end
                    end
                end
            end
end
for qi = 1:quad_num_h
     for qj = 1:quad_num_w
          Tc_q(qi,qj) = Tc_q(qi,qj) + 40;
     end
end
for qi = 1:quad_num_h
     for qj = 1:quad_num_w
          Tc_q(qi,qj) = 1/Tc_q(qi,qj);
     end
end
        