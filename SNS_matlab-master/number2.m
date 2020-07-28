X = [1 2 1;1 4 2;1 6 3]
Y= [2;3;7]
X_T= transpose(X)
Z = (X_T*X + [1 0 0;0 1 0;0 0 1])
W = Z\(X_T*Y)

forecast = [1 5 5]*W
Y1 = [1 2 1]*W
Y2 = [1 4 2]*W
Y3 = [1 6 3]*W
norm = Y - [Y1;Y2;Y3]
SSE = transpose(norm)*norm

