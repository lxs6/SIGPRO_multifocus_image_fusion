%   Authors: Li Xiaosong, Zhou Fuqiang, et al.   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Xiaosong Li,Fuqiang Zhou, Haishu Tan et al. Multi-focus Image Fusion Based on Nonsubsampled 
%    Contourlet Transform and Residual Information Removal [J,Signal processing,184 (2021) 108062.
% Beihang university,
% Last update:01-27-2021
clc; clear all; close all;
f1=imread('gray02_1.tif');  f2=imread('gray02_2.tif');     % input source images
f1=im2double(source_f1);    f2=im2double(source_f2);
figure,imshow(f1);   figure,imshow(f2);
[row,column,z]=size(f1);
tic
%%
temp_fused = zeros(size(f1));
 for i=1:3
        temp_fused(:,:,i) =  NSCT_fusion(f1(:,:,i),f2(:,:,i));    %for color images
 end  
gray_dif1=rgb2gray(temp_fused)-rgb2gray(f1);
gray_dif2=rgb2gray(temp_fused)-rgb2gray(f2);
%% 
f1=rgb2gray(f1);   f2=rgb2gray(f2);
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
th=10^(-5 );  
for k=1:K
     initial_map1{k}=(D3{k}-D4{k}>th);
     initial_map2{k}=(D3{k}-D4{k}<=th);
end
sum_map1=zeros(row,column); sum_map2=zeros(row,column);
for k=1:K         
    sum_map1=sum_map1+initial_map1{k};
    sum_map2=sum_map2+initial_map2{k};
end
T=0.6*K;  
map1=zeros(row,column); 
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
window_size=17;  th2=5;  
finalmap1 = majority_consist_new(midmap1,window_size);
finalmap2 = majority_consist_new(midmap2,window_size);
border_omit_mapA=border_omit(finalmap1,th2);      border_omit_mapB=border_omit(finalmap2,th2);
%%
f11=im2double(source_f1);  f22=im2double(source_f2);
dif1=temp_fused-f11;       dif2=temp_fused-f22;     
final_fused = zeros(size(f11));
    for i=1:3
        mis_infor1(:,:,i) = dif1(:,:,i).*border_omit_mapA;  
        mis_infor2(:,:,i) = dif2(:,:,i).*border_omit_mapB;
        final_fused(:,:,i)=temp_fused(:,:,i)-mis_infor1(:,:,i)-mis_infor2(:,:,i);
    end 
 toc
    figure,imshow(final_fused);
