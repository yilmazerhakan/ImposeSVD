% Implementation of the EigenRec algorithm for top-N recommendations. The algorithm is presented in the paper:

% A. N. Nikolakopoulos, V. Kalantzis, E. Gallopoulos and J. D. Garofalakis, "EigenRec: Generalizing PureSVD for % Effective and Efficient Top-N Recommendations," Knowl. Inf. Syst., 2018. doi: 10.1007/s10115-018-1197-7 .

% https://github.com/nikolakopoulos/EigenRec

function [ Y ] = eigenrec_afunc(x,W)
%AFUNC This Function Computes the MatrixVector product with the Inter-Item
%Proximity matrix that can be expressed in terms of sparse and/or low-rank
%components. Here as an example we give the simple Cosine Inter-Proximity
%Matrix. vector x is fed by the eigs function. (see EIGENREC.m)   
%disp(sum(x));
Y = (W'*(W*x));  % General Cosine Inter-Item Proximity Matrix. 
                 % For Simple PureSVD choose (W==R)
end