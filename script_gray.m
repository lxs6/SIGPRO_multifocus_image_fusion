%   Fusion code of grayscale source images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Xiaosong Li,Fuqiang Zhou, Haishu Tan et al. Multi-focus Image Fusion Based on Nonsubsampled 
%    Contourlet Transform and Residual Information Removal [J],Signal processin,Signal processing,184 (2021) 108062.
%    Beihang university,

clc; clear all; close all;
addpath source_images
addpath function_toolbox;

f1=imread('gray02_1.tif');  f2=imread('gray02_2.tif');     % input source images
f1=im2double(f1);  f2=im2double(f2);
figure,imshow(f1);   figure,imshow(f2);
if size(f1,3)==3
    f1=rgb2gray(f1);   
end
if size(f2,3)==3
    f2=rgb2gray(f2); 
end
[row,column]=size(f1);     

tic
%% 
temp_fused=NSCT_fusion(f1,f2);
dif1=temp_fused-f1; dif2=temp_fused-f2;
%% 
v1=1;  K=25; 
for k=1:K
    G{k}=fspecial('gaussian',k,20);
    blur1{k}=imfilter(f1,G{k},'same');
    blur2{k}=imfilter(f2,G{k},'same');
    D1{k}=f1-blur1{k}; 
    D2{k}=f2-blur2{k};
    D3{k}=str_tensor_map(D1{k},v1);  
    D4{k}=str_tensor_map(D2{k},v1);
end
th=10^(-5); 
for k=1:K
     initial_map1{k}=(D3{k}-D4{k}>th);
     initial_map2{k}=(D3{k}-D4{k}<=th);
end
%%
map1=zeros(row,column);  sum_map1=zeros(row,column); sum_map2=zeros(row,column);
for k=1:K         
    sum_map1=sum_map1+initial_map1{k};  sum_map2=sum_map2+initial_map2{k};
end
T=0.6*K;  
map1=(sum_map1-sum_map2>T*ones(row,column)); 
map2=(sum_map2-sum_map1>T*ones(row,column));  
Gauss=fspecial('gaussian',3,5);
blurA1=imfilter(f1,Gauss,'same');         blurB1=imfilter(f2,Gauss,'same');
DD1=f1-blurB1;                            DD2=f2-blurA1;
SA=str_tensor_map(DD1,1);                 SB=str_tensor_map(DD2,1);
mapp1=(SA>SB);                            mapp2=1-mapp1;
for i=1:row
    for  j=1:column
        if  map1(i,j)==1;
            new_map1(i,j)=1;   
        elseif map2(i,j)==1;
            new_map1(i,j)=0;
        elseif  map1(i,j)==map2(i,j)  &&  sum_map1(i,j)>sum_map2(i,j);
            new_map1(i,j)=mapp1(i,j);
        else map1(i,j)==map2(i,j) && sum_map1(i,j)<sum_map2(i,j);
            new_map1(i,j)=mapp2(i,j);
        end
    end
end        
%%
ratio=0.015;   
area=ceil(ratio*row*column);
tempMap1=bwareaopen(new_map1,area);
tempMap2=1-tempMap1;
tempMap3=bwareaopen(tempMap2,area);
midmap1=1-tempMap3;
midmap2=imcomplement(midmap1); 
%%
window_size=17; 
finalmap1 = majority_consist_new(midmap1,window_size);
finalmap2 = majority_consist_new(midmap2,window_size);
%% 
th=3;   no_borderA=border_o(finalmap1,th);      no_borderB=border_o(finalmap2,th);
mid_dif1 = dif1.*no_borderA;           mid_dif2 = dif2.*no_borderB;
%%
final_fused=temp_fused-mid_dif1-mid_dif2;
toc
%% 
figure,imshow(final_fused);
