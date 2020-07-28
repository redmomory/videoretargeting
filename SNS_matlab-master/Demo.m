% ==== (SNS matlab code)======
% The Code (Version 1) is created by ZHANG Yabin,
% Nanyang Technological University, 2015-12-30
% which is based on the method described in the following paper 
% [1] Wang, Yu-Shuen, et al. "Optimized scale-and-stretch for image resizing." 
% ACM Transactions on Graphics (TOG) 27.5 (2008): 118. 
% The binary code is provided on the project page:
% http://graphics.csie.ncku.edu.tw/Image_Resizing/
% The Matlab codes are for non-comercial use only.
% Note that the importance maps are slightly different from the original
% ones, and the retargeted images are influenced.

clear all; clc
obj = VideoReader('videoplayback.mp4');
v = VideoWriter('v_scale_0.5_temporal_o_type_warping_10_Grid.avi');
open(v)
opticFlow = opticalFlowFarneback;
% parameters
Ratio = 0.5;
mesh_size = 10; % using mesh_size x mesh_size quad
h = obj.height/2;
w = obj.width/2;
quad_num_h = floor(h/mesh_size);
quad_num_w = floor(w/mesh_size);
count = zeros(500);
for num = 1:500
    ori = readFrame(obj);
    %pre_Vertex_updated;
    if(num ~= 1)
        Vx_before(:,:) = Vx_t;
        Vy_before(:,:) = Vy_t;
        pre_im = zeros(h,w,'uint8');
        pre_im(:,:) = dark_im;
        pre_Vertex = zeros(19,32,2,'double');
        pre_Vertex(:,:,:) = Vertex_updated;
    end
    
    
    %Quad_op = zeros(quad_num_h,quad_num_w,2,'single');
    %Quad_diff = zeros(quad_num_h,quad_num_w);
    if(num ~= 1)
     %  for i = 1 : quad_num_h
     %     for j = 1: quad_num_w
     %       count = 0;
     %       for x = 1:mesh_size
     %           for y = 1:mesh_size
     %               if((i-1)*20 + y <= h)
     %                       if((j-1)*20 + x <= w)
     %                           Quad_op(i,j,1) = Quad_op(i,j,1) + Vx_before((i-1)*mesh_size+y,(j-1)*mesh_size+x);
     %                           Quad_op(i,j,2) = Quad_op(i,j,2) + Vy_before((i-1)*mesh_size+y,(j-1)*mesh_size+x);
     %                           count = count + 1;
     %                       end
     %               end
     %           end
     %       end
     %       Quad_op(i,j,1) = Quad_op(i,j,1) / count;
     %       Quad_op(i,j,2) = Quad_op(i,j,2) / count;
     %     end
     %   end
     %   for i = 1 : quad_num_h
     %     for j = 1: quad_num_w
     %       count = 0;
     %       for x = 1:mesh_size
     %           for y = 1:mesh_size
     %               t_y = cast((i-1)*20 + y + Quad_op(i,j,2),'int8');
     %               t_x = cast((i-1)*20 + x + Quad_op(i,j,1),'int8');
     %               if(t_y <= h && t_y >= 1)
     %                       if(t_x <= w && t_x >= 1)
     %                           if((i-1)*20 + y <= h)
     %                                    if((j-1)*20 + x <= w)
     %                                         Quad_diff(i,j) = Quad_diff(i,j) + abs(pre_im((i-1)*20 + y,(j-1)*20 + x) - dark_im(t_y,t_x));
     %                                         count = count + 1;
     %                                    end
     %                           end
     %                       end
     %               end
     %           end
     %       end
     %       Quad_diff(i,j) = Quad_diff(i,j)/count + 0.1;
     %     end
     %   end
     %   for i = 1 : quad_num_h
     %     for j = 1: quad_num_w
     %         Quad_diff(i,j) = 1/Quad_diff(i,j);
     %         if((abs(Quad_op(i,j,1)) + abs(Quad_op(i,j,2))) < 1)
     %           Quad_diff(i,j) = 0;
     %         end
     %     end
     %   end
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
    %im =  imread('tajmahal.png');
    %im_SNS = imread('tajmahal_0.50_sns.png');
    
    % im =  imread('Brasserie_L_Aficion.png');
    % im_SNS = imread('Brasserie_L_Aficion_0.50_sns.png');

    % the regular mesh on original image
    Vertex_set_org = ImgRegualrMeshGrid(im, mesh_size);

    % the importance map generation
    importance_map =  SNS_importanceMap(im, true); % generate the importance map
    importance_quad = SNS_importanceMap_quad(importance_map, Vertex_set_org);
    importance_quad = importance_quad/sum(importance_quad(:)); % the importance weight for the quad

    % the naive initialization of the mesh
    % retargeting on the width
    Vertex_warped_initial = Vertex_set_org;
    Vertex_warped_initial(:,:,2) = Vertex_warped_initial(:,:,2)*Ratio;

    % the mesh grid optimization
    [Vertex_updated] = ...
        SNS_optimization(Vertex_set_org ,Vertex_warped_initial, importance_quad); %EM 방식
    %if(num ~= 1)
    %    Vertex_updated = 0.3*Vertex_updated + 0.7*pre_Vertex;
    %end
   if(num ~= 1)
       [Vertex_updated] = ...
           
       Opt_Tc(pre_Vertex ,Vertex_updated, Quad_Tc); %NOT EM
   end
    % warp the new image
    im_warped = MeshBasedImageWarp(ori, [1 Ratio], 2*Vertex_set_org, 2*Vertex_updated);
    [h1, w1, ~] = size(im_warped);
    ]if(h1 == 360)
        if(w1 == 319)
            writeVideo(v,im_warped);
        end
    end
    %writeVideo(v,im_warped);
    %figure; 
    %subplot(1,2,1);
    %imshow(im_warped);
    %title(['My warped'], 'FontSize' , 15); 
    %subplot(1,2,2);
    %imshow(im_SNS);
    %title(['Original SNS warped'], 'FontSize' , 15); 

    % show the mesh grid on the original image and retargeted image
    % MeshGridImgPlot(im, Vertex_set_org, [0.5 0.0 0.5]);
    % title(['Regular mesh grid on original image'], 'FontSize' , 15);
    % MeshGridImgPlot(im_warped, Vertex_updated, [0.5 0.0 0.5]);
    % title(['Warped image '], 'FontSize' , 15); 
end
close(v);



