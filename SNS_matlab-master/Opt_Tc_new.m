function [ Vertex_updated] = Opt_motion(Vertex_set_org ,Vertex_warped, Quad_diff)

%필요한 parameter (1. Quad별 속도) , (2. 과거 vertex)
%, (3. waped vertex), (4.Quad_diff 이용))
% Optical Flow를 이용한다.

[h_V, w_V, ~] = size(Vertex_set_org);

% compute the sysmetric matrix
% sf update....
h_Boundary = Vertex_warped(h_V, w_V, 1);
w_Boundary = Vertex_warped(h_V, w_V, 2);
Vertex_new = zeros(h_V, w_V, 2);
Diff_max = 0;

for Q_h =  1:h_V-1
    for Q_w = 1:w_V-1
        if(Diff_max <= Quad_diff(Q_h,Q_w))
            Diff_max = Quad_diff(Q_h,Q_w);
        end
    end
end

for Layer_Vertex = [2 1] % for H and W layer
        A_matrix = zeros(h_V*w_V, h_V*w_V);
        B_vector = zeros(h_V*w_V, 1);
        for Q_h =  1:h_V
            for Q_w = 1:w_V
                Vector_loc = Q_h + (Q_w-1)*h_V;        
                % ##################################
                % ##### add the quad deformation part coefficients
                % 1 === the top-left quad
                if( (Q_h - 1) > 0 && (Q_w - 1) > 0)
                    tc_quad = Tc_quad(Q_h - 1, Q_w - 1);
                    A_matrix(Vector_loc, Vector_loc) = ...
                        A_matrix(Vector_loc, Vector_loc) + 2;
                    % T
                    A_matrix(Vector_loc, Vector_loc-1) = ...
                        A_matrix(Vector_loc, Vector_loc-1) - 1;
                    % L
                    A_matrix(Vector_loc, Vector_loc-h_V) = ...
                        A_matrix(Vector_loc, Vector_loc-h_V) - 1;
                    % B_vector
                    B_vector(Vector_loc) = ...
                        B_vector(Vector_loc) + (tc_quad/Tc_max)*(2*Vertex_set_org(Q_h,Q_w,Layer_Vertex) ...
                        - Vertex_set_org(Q_h-1,Q_w,Layer_Vertex) - Vertex_set_org(Q_h,Q_w-1,Layer_Vertex))...
                    + (1 - tc_quad/Tc_max)*(2*Vertex_warped(Q_h,Q_w,Layer_Vertex) ...
                        - Vertex_warped(Q_h-1,Q_w,Layer_Vertex) - Vertex_warped(Q_h,Q_w-1,Layer_Vertex));
                end

                % 2 === the top-right quad
                if( (Q_h - 1) > 0 && (Q_w + 1) <= w_V)
                    tc_quad = Tc_quad(Q_h - 1, Q_w);
                    A_matrix(Vector_loc, Vector_loc) = ...
                        A_matrix(Vector_loc, Vector_loc) + 2;
                    % T
                    A_matrix(Vector_loc, Vector_loc-1) = ...
                        A_matrix(Vector_loc, Vector_loc-1) - 1;
                    % R
                    A_matrix(Vector_loc, Vector_loc+h_V) = ...
                        A_matrix(Vector_loc, Vector_loc+h_V) - 1;
                    % B_vector
                    B_vector(Vector_loc) = ...
                        B_vector(Vector_loc) + (tc_quad/Tc_max)*(2*Vertex_set_org(Q_h,Q_w,Layer_Vertex) ...
                        - Vertex_set_org(Q_h-1,Q_w,Layer_Vertex) - Vertex_set_org(Q_h,Q_w+1,Layer_Vertex))...
                    + (1 - tc_quad/Tc_max)*(2*Vertex_warped(Q_h,Q_w,Layer_Vertex) ...
                        - Vertex_warped(Q_h-1,Q_w,Layer_Vertex) - Vertex_warped(Q_h,Q_w+1,Layer_Vertex));

                end

                % 3 === the bottom-left quad
                if( (Q_h + 1) <= h_V && (Q_w - 1) > 0)
                    tc_quad = Tc_quad(Q_h, Q_w - 1);
                    A_matrix(Vector_loc, Vector_loc) = ...
                        A_matrix(Vector_loc, Vector_loc) + 2;
                    % D
                    A_matrix(Vector_loc, Vector_loc+1) = ...
                        A_matrix(Vector_loc, Vector_loc+1) - 1;
                    % L
                    A_matrix(Vector_loc, Vector_loc-h_V) = ...
                        A_matrix(Vector_loc, Vector_loc-h_V) - 1;
                    % B_vector
                    B_vector(Vector_loc) = ...
                        B_vector(Vector_loc) + (tc_quad/Tc_max)*(2*Vertex_set_org(Q_h,Q_w,Layer_Vertex) ...
                        - Vertex_set_org(Q_h+1,Q_w,Layer_Vertex) - Vertex_set_org(Q_h,Q_w-1,Layer_Vertex))...
                    + (1 - tc_quad/Tc_max)*(2*Vertex_warped(Q_h,Q_w,Layer_Vertex) ...
                        - Vertex_warped(Q_h+1,Q_w,Layer_Vertex) - Vertex_warped(Q_h,Q_w-1,Layer_Vertex));;   
                end

                % 4 === the bottom-right quad
                if( (Q_h + 1) <= h_V && (Q_w + 1) <= w_V)
                    tc_quad = Tc_quad(Q_h, Q_w);
                    A_matrix(Vector_loc, Vector_loc) = ...
                        A_matrix(Vector_loc, Vector_loc) + 2;
                    % D
                    A_matrix(Vector_loc, Vector_loc+1) = ...
                        A_matrix(Vector_loc, Vector_loc+1) - 1;
                    % R
                    A_matrix(Vector_loc, Vector_loc+h_V) = ...
                        A_matrix(Vector_loc, Vector_loc+h_V) - 1;
                    % B_vector
                    B_vector(Vector_loc) = ...
                        B_vector(Vector_loc) + (tc_quad/Tc_max)*(2*Vertex_set_org(Q_h,Q_w,Layer_Vertex) ...
                        - Vertex_set_org(Q_h+1,Q_w,Layer_Vertex) - Vertex_set_org(Q_h,Q_w+1,Layer_Vertex))...
                    + (1 - tc_quad/Tc_max)*(2*Vertex_warped(Q_h,Q_w,Layer_Vertex) ...
                        - Vertex_warped(Q_h+1,Q_w,Layer_Vertex) - Vertex_warped(Q_h,Q_w+1,Layer_Vertex));
                end
            end
        end
        N = 1;
        %These constraints are simply substituted into the linear system during the optimization
        START_POINT = 0;
        if(Layer_Vertex == 1)
            for Q_h =  1
                for Q_w = 1:w_V
                    Vector_loc = Q_h + (Q_w-1)*h_V;
                    A_matrix(Vector_loc, :) = 0;
                    A_matrix(Vector_loc, Vector_loc) = 1*N;
                    B_vector(Vector_loc) = START_POINT*N;
                end
            end
            for Q_h =  h_V
                for Q_w = 1:w_V
                    Vector_loc = Q_h + (Q_w-1)*h_V;
                    A_matrix(Vector_loc, :) = 0;
                    A_matrix(Vector_loc, Vector_loc) = 1;
                    B_vector(Vector_loc) = h_Boundary;
                end
            end
        else
            for Q_h =  1:h_V
                for Q_w = 1
                    Vector_loc = Q_h + (Q_w-1)*h_V;
                    A_matrix(Vector_loc, :) = 0;
                    A_matrix(Vector_loc, Vector_loc) = 1*N;
                    B_vector(Vector_loc) = START_POINT*N;
                end
            end
            for Q_h = 1:h_V
                for Q_w = w_V
                    Vector_loc = Q_h + (Q_w-1)*h_V;
                    A_matrix(Vector_loc, :) = 0;
                    A_matrix(Vector_loc, Vector_loc) = 1;
                    B_vector(Vector_loc) = w_Boundary;
                end
            end
        end
        [L, U] = lu(A_matrix);
        Vect_vertex_warped_factorization = U\(L\B_vector);
        foo = reshape(Vect_vertex_warped_factorization, [h_V w_V]);
        Vertex_new(:, :, Layer_Vertex) = foo;
end
   Vertex_updated = Vertex_new;  % Vertex_new; %0.5*Vertex_updated + 0.5*Vertex_new;
end

