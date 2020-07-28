
clear all; clc
obj = VideoReader('itzy.mp4');
v = VideoWriter('i_scale_0.5_temporal_o2_type_warping.avi');
open(v)
opticFlow = opticalFlowFarneback;
figure;

mesh_size = 20; % using mesh_size x mesh_size quad
h = obj.height / 2;
w = obj.width / 2;
quad_num_h = floor(h/mesh_size);
quad_num_w = floor(w/mesh_size);

for num = 1:500
    ori = readFrame(obj);
    im = imresize(ori, 1/2);
    dark_im = rgb2gray(im);
    flow = estimateFlow(opticFlow,dark_im);
    plot(flow);
    Vx_t(:,:) = flow.Vx;
    Vy_t(:,:) = flow.Vy;
    Quad_op = zeros(quad_num_h,quad_num_w,2,'single');
    for i = 1 : quad_num_h
        for j = 1: quad_num_w
            for x = 1:mesh_size
                for y = 1:mesh_size
                    if((i-1)*20 + i <= h)
                            if((j-1)*20 + j <= w)
                                Quad_op(i,j,1) = Quad_op(i,j,1) + Vx_t((i-1)*mesh_size+y,(j-1)*mesh_size+x);
                                Quad_op(i,j,2) = Quad_op(i,j,2) + Vy_t((i-1)*mesh_size+y,(j-1)*mesh_size+x);
                            end
                    end
                end
            end
        end
    end
    pause(0.01);
end
