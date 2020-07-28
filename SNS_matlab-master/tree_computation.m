clear;
clc
Demand = [13 22 24 28]
Hour = [1 2 3 4]
mean = 0;
for i = 1:4
    mean = mean+ Demand(i);
end
sum = 0;
for i = 1:4
    sum = (Demand(i) - mean)* (Demand(i) - mean);
end
    
% Dew = [2 4 5 6]
% left_sum = [0 0 0 0;0 0 0 0];
% right_sum = [0 0 0 0;0 0 0 0];
% for k = 1:2
%     %case1 = Hour
%     %case2 = Dew
%     for i = 1:4
%         if(k == 1)
%             leaf = Hour(i);
%         else
%             leaf = Dew(i);
%         end
%         left_num = 0;
%         right_num = 0;
%         for j = 1 : 4
%             if (leaf < Hour(j))
%                 right_sum(k,i) = right_sum(k,i) + Demand(j);
%                 right_num = right_num + 1;
%             else
%                 left_sum(k,i) = left_sum(k,i) + Demand(j);
%                 left_num = left_num + 1;
%             end
%         end
%         right_sum(k,i) = right_sum(k,i)/ right_num;
%         left_sum(k,i) = left_sum(k,i)/ left_num;
%     end
% end
% 
% mae = [0 0 0 0;0 0 0 0];
% 
% for k = 1:2
%     %case1 = Hour
%     %case2 = Dew
%     for i = 1:4
%         if(k == 1)
%             leaf = Hour(i);
%         else
%             leaf = Dew(i);
%         end
%         for j = 1 : 4
%             if (leaf < Hour(j))
%                 mae(k,i) = mae(k,i) + abs(Demand(j) - right_sum(k,i));
%             else
%                 mae(k,i) = left_sum(k,i) + abs(Demand(j) - left_sum(k,i));
%             end
%         end
%         mae(k,i) = mae(k,i)/4;
%     end
% end

        