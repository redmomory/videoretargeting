clc
clear all

x1=randn(50,2)*10;
y1=x1(:,1)*2+x1(:,2)*3+4+rand(50,1);
x2=randn(50,2)*10;
y2=x2(:,1)*5+x2(:,2)*6+7+rand(50,1);

X=[x1 ; x2];
Y=[y1 ; y2];
C=[ones(50,1); zeros(50,1)];
C=logical(C);

%% Matlab Help Example
X1 = [X ones(size(X,1),1)];
b1 = regress(Y,X1)
result=X1 * b1;
RMSE1=sqrt(mean((result-Y).^2))


%% Bias Change
X2 = [X double(C) ones(size(X,1),1)];
b2 = regress(Y,X2)
result=X2 * b2;
RMSE2=sqrt(mean((result-Y).^2))


%% 1
X3 = [X ones(size(X,1),1)];
b3 = regress(Y(C),X3(C,:))
result1=X3(C,:) * b3;


%% 0
b4 = regress(Y(~C),X3(~C,:))
result2=X3(~C,:) * b4;
RMSE34=sqrt(mean(([result1;result2]-[Y(C);Y(~C)]).^2))


%% Matlab Help Example
X4 = [X X(:,1).*double(C) X(:,2).*double(C) double(C) ones(size(X,1),1)];
b5 = regress(Y,X4)
result=X4 * b5;
RMSE5=sqrt(mean((result-Y).^2))




