function Form_RHS_tmp( obj,ct )
% Assemble time dependent RHS and update J and K, run for every time loop
% ct is the time point for E and H
% so the time point for integral is: ct - 0.5*dt
% since RHS_tmp have not been clean, just rewrite it. do not add old value!
% Also write vec_g3 = \int g3 \phi
% and vec_g4 = \int g4*1
obj.RHS_tmp = zeros(obj.num_unk,1);
cst1 = -obj.dt.^2/(2 + obj.dt*obj.ge);
cst2 = -obj.dt.^2/(2 + obj.dt*obj.gm);
% raw_vec1 and raw_vec2 include all integral especially for BOUNDARY edges.
% should return the interior elements finally
raw_vec1 = zeros(obj.nedg,1);
raw_vec_g3 = zeros(obj.nedg,1);
raw_vec2 = zeros(obj.nele,1);
raw_vec_g4 = zeros(obj.nele,1);
for i = 1:obj.nele   % loop for all elements
%             (x1,y1)
%               / \
%              /   \
%             /     \
%        (x2,y2)---(x3,y3)    
%
x1 = obj.no2xy(1,obj.el2no(1,i));  y1 = obj.no2xy(2,obj.el2no(1,i));
x2 = obj.no2xy(1,obj.el2no(2,i));  y2 = obj.no2xy(2,obj.el2no(2,i));
x3 = obj.no2xy(1,obj.el2no(3,i));  y3 = obj.no2xy(2,obj.el2no(3,i));
p = [x1 , x2 , x3; y1 , y2 , y3];
   for j = 1:obj.side_ele
        ed1 = obj.el2ed(j,i);
        % for E
        % (f,\phi)
        fcn_tmp11 = @(x,y)obj.g3_1(x,y,ct-0.5*obj.dt).*Basis_fcn1(x,y,i,j,1,obj)+obj.g3_2(x,y,ct-0.5*obj.dt).*Basis_fcn1(x,y,i,j,2,obj);                    
        fcn_tmp12 = @(x,y)obj.g1_1(x,y,ct-0.5*obj.dt).*Basis_fcn1(x,y,i,j,1,obj)+obj.g1_2(x,y,ct-0.5*obj.dt).*Basis_fcn1(x,y,i,j,2,obj);
        int_val11 = Quad_Ele_Tri(@(x,y)fcn_tmp11(x,y),p)*obj.edori(i,j); % be careful for the direction of edges
        int_val12 = Quad_Ele_Tri(@(x,y)fcn_tmp12(x,y),p)*obj.edori(i,j);
        raw_vec1(ed1) = raw_vec1(ed1) + cst1*int_val11 + obj.dt*int_val12;
        raw_vec_g3(ed1) = raw_vec_g3(ed1) + int_val11;
    end
	% for H
    fcn_tmp21 = @(x,y)obj.g4(x,y,ct-0.5*obj.dt);
    fcn_tmp22 = @(x,y)obj.g2(x,y,ct-0.5*obj.dt);
    int_val21 = Quad_Ele_Tri(@(x,y)fcn_tmp21(x,y),p);
    int_val22 = Quad_Ele_Tri(@(x,y)fcn_tmp22(x,y),p);
    raw_vec2(i) = cst2*int_val21 + obj.dt*int_val22;
    raw_vec_g4(i) = int_val21;
end
obj.RHS_tmp = [raw_vec1(obj.eint);raw_vec2];
obj.vec_g3 = raw_vec_g3(obj.eint);
obj.vec_g4 = raw_vec_g4;

end

