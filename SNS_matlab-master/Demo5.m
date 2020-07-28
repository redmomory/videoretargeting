clear all; clc
obj = VideoReader('ratatouille1.mov');
v = VideoWriter('ratat_k_1.avi');
v.FrameRate = 15;
open(v)
% parameters
Ratio = 0.5;
mesh_size = 10; % using mesh_size x mesh_size quad
h = obj.height;
w = obj.width;
quad_num_h = floor(h/mesh_size);
quad_num_w = floor(w/mesh_size);
count = zeros(obj.NumFrames,1);
Flow_energy = flow_energy(obj);
obj = VideoReader('ratatouille1.mov');
for num = 1:obj.NumFrames
    im = readFrame(obj);
    if(num ~= 1) %이전 Vertex_update -> pre_Vertex로 저장
        pre_im = zeros(h,w,'uint8');
        pre_im(:,:) = dark_im;
        pre_size = size(Vertex_updated);
        pre_Vertex = zeros(pre_size(1),pre_size(2),2,'double');
        pre_Vertex(:,:,:) = Vertex_updated;
    end
    dark_im = rgb2gray(im);
    %% Compute Quad Energy
    if(num ~= 1)
        Quad_Tc = Temp_Quad(dark_im,pre_im,quad_num_h,quad_num_w,mesh_size,h,w);
    end
    %% Image Warping
    Vertex_set_org = ImgRegualrMeshGrid(im, mesh_size); %Origianl Vertex 생성
    importance_map =  SNS_importanceMap(im, true); % generate the importance map
    importance_quad = SNS_importanceMap_quad(importance_map, Vertex_set_org); %Quad별 importance map생성
    importance_quad = importance_quad/sum(importance_quad(:)); % the importance weight for the quad
    Vertex_warped_initial = Vertex_set_org;
    Vertex_warped_initial(:,:,2) = Vertex_warped_initial(:,:,2)*Ratio;
    [Vertex_updated] = ...
       SNS_optimization(Vertex_set_org ,Vertex_warped_initial, importance_quad);
   %% Adaptive Motion Level
    if(num ~= 1)
       if(Flow_energy(num,2) == 1)
           [Vertex_updated] = Opt_Tc(pre_Vertex ,Vertex_updated, Quad_Tc);
       elseif(Flow_energy(num,2) == 2)
           Vertex_updated = 0.5*pre_Vertex + 0.5*Opt_Tc(pre_Vertex ,Vertex_updated, Quad_Tc);
       elseif(Flow_energy(num,2) == 3)
           Vertex_updated = pre_Vertex;
       end
    end
    %%  warp the new image
    im_warped = MeshBasedImageWarp(im, [1 Ratio], Vertex_set_org, Vertex_updated);
    [h1, w1, ~] = size(im_warped);
    writeVideo(v,im_warped);
end
close(v);



