function [BB,L,R,RBP,T]=PAI_BB(TR,RBP)
% Inertia-based bounding box of a CLOSED surface mesh.
%
% INPUT:
%   - TR    : closed triangular surface mesh. Any format recognisable by the
%		      the 'GetMeshData' function. 
%   - RBP   : structured generated by the 'RigidBodyParams' function (optional)
%
% OUTOUT:
%   - BB    : BB patch object 
%   - L     : 1-by-3 vector of BB edge lengths
%   - R     : 3-by-3 matrix of principal BB directions (along columns), so
%             that R(:,i) corresponds to L(i)
%
% AUTHOR: Anton Semechko (a.semechko@gmail.com)
%


[Tri,X,fmt]=GetMeshData(TR);
if fmt>1, TR=triangulation(Tri,X); end

if nargin<2 || isempty(RBP)
    RBP=RigidBodyParams(TR);
end

R=RBP.PAI;
R=fliplr(R);
R(:,3)=cross(R(:,1),R(:,2));

C=RBP.centroid;

T1=eye(4); T1(1:3,4)=-C;
T2=eye(4); T2(1:3,1:3)=R';
T=T2*T1;

X=ApplySimTform(X,T);
L=max(X)-min(X);

BB=unit_cube_mesh;
V=bsxfun(@times,L,BB.vertices);
V=bsxfun(@plus,V,min(X));
V=ApplySimTform(V,T,false);

BB.vertices=V;
