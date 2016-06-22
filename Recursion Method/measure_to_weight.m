function weight=measure_to_weight(Node_Number,measure,probability,Location,MDistance,Cita,Size_Grid,scale,get_weight)
estimated_location = GM_Probility_Cutting(Node_Number,measure,probability,Location,MDistance,Cita,Size_Grid,scale);
estimated_data=get_sequence(Node_Number,Location,Cita,estimated_location);
faulty_node=zeros(1,Node_Number);
for i=1:Node_Number
    %当测量值不等于有定位结果分析的'真实值'时，实验中认为说明该节点出错
    if measure(i)~=estimated_data(i)
        faulty_node(i)=1;
    end
end
%计算每个估计出来的错误节点和声源的位置
%因为越远越不容易出错，所以权值和距离成正相关
%distance_multi=calculate_dis(Microphone_Center_Location_with_error(i,:),Microphone_Cita_with_error(i,:),estimated_location);
%提升的方法使用距离进行加权
weight=calculate_weight(get_weight,Location,Cita,estimated_location,faulty_node);