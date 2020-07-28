clear all; clc
obj = VideoReader('roatatouille_warping_15.avi');
v = VideoWriter('mousew_15.avi');
v.FrameRate = 15;
open(v)
while hasFrame(obj)
    im = readFrame(obj);
    writeVideo(v,im);
end
close(v);



