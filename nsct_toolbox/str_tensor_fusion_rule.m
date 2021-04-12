function  B=str_tensor_fusion_rule(S1,S2,n);
map=(str_tensor_map(S1,1)>=str_tensor_map(S2,1));
map=majority_consist_new(map,n);
B=S1.*map+~map.*S2;