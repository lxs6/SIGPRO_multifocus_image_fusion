function temp_fused=NSCT_fusion(f1,f2)
y1=nsctdec(f1,[1,1,1,1],'vk','pyrexc');  
y2=nsctdec(f2,[1,1,1,1],'vk','pyrexc');
y{1,1}=(y1{1,1}+y2{1,1})/2;
for m=2:length(y1)
   for n=1:length(y1{m})  
       y{m}{n}=str_tensor_fusion_rule(y1{m}{n},y2{m}{n},5);  
   end 
end
temp_fused=nsscrec(y,'vk','pyrexc');