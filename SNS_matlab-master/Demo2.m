clear all; clc
obj = VideoReader('itzy.mp4');
opticFlow = opticalFlowFarneback;
count = zeros(500,1);
for num = 1:500
    ori = readFrame(obj);
    im = imresize(ori, 1/2);
    dark_im = rgb2gray(im);
    flow = estimateFlow(opticFlow,dark_im);
    Vx_t(:,:) = flow.Vx;
    Vy_t(:,:) = flow.Vy;
    count(num,1) = Motion_level(Vx_t,Vy_t);
    disp(num)
end
plot(count);


