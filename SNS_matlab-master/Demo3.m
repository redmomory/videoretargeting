clear all; clc
obj = VideoReader('ratatouille1.mov');
opticFlow = opticalFlowFarneback;
% parameters
Ratio = 0.5;
mesh_size = 10; % using mesh_size x mesh_size quad
h = obj.height;
w = obj.width;
quad_num_h = floor(h/mesh_size);
quad_num_w = floor(w/mesh_size);
count = zeros(obj.NumFrames,1);
for num = 1:obj.NumFrames
    im = readFrame(obj);
    if(num ~= 1) %이전 Vertex_update -> pre_Vertex로 저장
        pre_im = zeros(h,w,'uint8');
        pre_im(:,:) = dark_im;
        pre_size = size(Vertex_updated);
        pre_Vertex = zeros(pre_size(1),pre_size(2),2,'double');
        pre_Vertex(:,:,:) = Vertex_updated;
    end
    %im = imresize(ori, 1/2); %Image Resizing
    dark_im = rgb2gray(im);
    %% Pixel별 Flow 저장
    flow = estimateFlow(opticFlow,dark_im); 
    Vx_t(:,:) = flow.Vx;
    Vy_t(:,:) = flow.Vy;
    level = Motion_level(Vx_t,Vy_t);
    %% Compute Quad Energy
    if(num ~= 1)
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
    count(num,1)= Motion_level(Vx_t ,Vy_t);
    %% Image Warping
    Vertex_set_org = ImgRegualrMeshGrid(im, mesh_size); %Origianl Vertex 생성
    importance_map =  SNS_importanceMap(im, true); % generate the importance map
    importance_quad = SNS_importanceMap_quad(importance_map, Vertex_set_org); %Quad별 importance map생성
    importance_quad = importance_quad/sum(importance_quad(:)); % the importance weight for the quad
    Vertex_warped_initial = Vertex_set_org;
    Vertex_warped_initial(:,:,2) = Vertex_warped_initial(:,:,2)*Ratio;
    [Vertex_updated] = ...
       SNS_optimization(Vertex_set_org ,Vertex_warped_initial, importance_quad);
    if(num ~= 1)
       if(count(num,1) < 1.5)
           [Vertex_updated] = ...       
           Opt_Tc(pre_Vertex ,Vertex_updated, Quad_Tc); %NOT EM
       else
           Vertex_updated = pre_Vertex;
       end
    end
    %%  warp the new image
    im_warped = MeshBasedImageWarp(im, [1 Ratio], Vertex_set_org, Vertex_updated);
    [h1, w1, ~] = size(im_warped);
    writeVideo(v,im_warped);
end
plot(count);
close(v);



