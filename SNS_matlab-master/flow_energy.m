function [Flow_energy] = flow_energy(obj)
opticFlow = opticalFlowFarneback;
Flow_energy = zeros(obj.NumFrames,1);

for num = 1:obj.NumFrames
    im = readFrame(obj);
    dark_im = rgb2gray(im);
    flow = estimateFlow(opticFlow,dark_im); 
    Vx_t(:,:) = flow.Vx;
    Vy_t(:,:) = flow.Vy;
    Flow_energy(num,1) = Motion_level(Vx_t,Vy_t);
end
clearvars im dark_im;
Flow_energy(1,1) = 0;
idx = kmeans(Flow_energy,3)

class_1 = 0;
count_1 = 0;
class_2 = 0;
count_2 = 0;
class_3 = 0;
count_3 = 0;
for i = 1:size(idx,1)
    if(idx(i,1) == 1)
        class_1 = class_1 + Flow_energy(i,1);
        count_1 = count_1 + 1;
    elseif(idx(i,1) == 2)
        class_2 = class_2 + Flow_energy(i,1);
        count_2 = count_2 + 1;
    else
        class_3 = class_3 + Flow_energy(i,1);
        count_3 = count_3 + 1;
    end
end
class_1 = class_1 / count_1;
class_2 = class_2 / count_2;
class_3 = class_3 / count_3;

matrix = [class_1 1;class_2 2;class_3 3];
matrix  = sortrows(matrix,1)

for i = 1:size(idx,1)
    if(idx(i,1) == matrix(1,2))
        idx(i,1) = 4;
    elseif(idx(i,1) == matrix(2,2))
        idx(i,1) = 5;
    else
        idx(i,1) = 6;
    end
end
idx = idx - 3;

Flow_energy = [Flow_energy, idx];
end
