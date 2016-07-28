% main function
clc;
%clear all  %���
close all; %�ر�֮ǰ����
RUNS = 100; %%�������
Node_Error_NUM_Percent=0.20; %�ڵ�������Ϣ�����İٷֱ�
for_begin=4;
for_gap=1;
for_end=10;

Size_Grid=10;  %�����С����λ��m
Room_Length=Size_Grid; %���䳤��
Room_Width=Size_Grid;  %�������
scale=5;    %       �ɱ������GM�㷨�Ŀռ���ɢ������
Microphone_Distance=0.2; %�ֻ�������mic֮�����
measure_alpha=0.75;     %%%�и����
percent             = 0.95;      %���㶨λ���ʱ��ֻȡǰ90%���������10%
KNN=4;  %% Basic Hamming parameter ��Hamming������С��KNN����ȡƽ��
location_error_range_abs = 0.03;         %�ڵ�λ����Χ,��λm
angle_error_range_abs = 5;            %�ڵ�Ƕ���Χ,��λ�Ƕ�
TODA_error_range_abs=10;
real_statics_run=floor(RUNS*percent);
Node_Number=100;

circulation=3;
x_label=for_begin:for_gap:for_end;
Detection_Ratio=3;
FPR_Basic=zeros(RUNS,(for_end-for_begin)/for_gap+1);
FNR_Basic=zeros(RUNS,(for_end-for_begin)/for_gap+1);
FPR_OnlyOne=zeros(RUNS,(for_end-for_begin)/for_gap+1);
FNR_OnlyOne=zeros(RUNS,(for_end-for_begin)/for_gap+1);
FPR_HistGet=zeros(RUNS,(for_end-for_begin)/for_gap+1);
FNR_HistGet=zeros(RUNS,(for_end-for_begin)/for_gap+1);
for runs=1:RUNS
    disp(['Run Times:' num2str(runs)]);
    FPR_Basic_tmp=zeros((for_end-for_begin)/for_gap+1,1);
    FNR_Basic_tmp=zeros((for_end-for_begin)/for_gap+1,1);
    FPR_OnlyOne_tmp=zeros((for_end-for_begin)/for_gap+1,1);
    FNR_OnlyOne_tmp=zeros((for_end-for_begin)/for_gap+1,1);
    FPR_HistGet_tmp=zeros((for_end-for_begin)/for_gap+1,1);
    FNR_HistGet_tmp=zeros((for_end-for_begin)/for_gap+1,1);
    for changething=for_begin:for_gap:for_end
        circulation=changething;
        Random_Node_Sequence=randperm(Node_Number);
        Microphone_Cita=fix(-90+180*(rand(Node_Number,1))); %%���� [-90  90]
        Microphone_Center_Location=fix(Size_Grid*abs((rand(Node_Number,2)))); % ���� λ��
        
        node_basic_weight=zeros(1,Node_Number);%��������Ȩֵ
        real_data=zeros(Node_Number,circulation);
        measure_data=zeros(Node_Number,circulation);
        real_speaker_location=zeros(circulation,2);
        Node_Error_NUM=floor(Node_Error_NUM_Percent*Node_Number);%��������ڵ����
        Error_Node=sort(Random_Node_Sequence(1:Node_Error_NUM));%��������ڵ�
        %         if mod(circulation,5)==0
        %             sequence=circulation
        %         end
        %��ó����еĲ�������----------------------
        for sequence=1:circulation
            real_speaker_location(sequence,:)=(Size_Grid*abs((rand(1,2))));
            real_data(:,sequence)=get_sequence(Node_Number,Microphone_Center_Location,Microphone_Cita,real_speaker_location(sequence,:),TODA_error_range_abs);
            %�и����
            probability=ones(Node_Number,1);
            for i=1:Node_Number
                probability(i)=measure_alpha;
            end
            %����ڵ��λ����ָ�����, ׼����������
            Measure_Cita=Microphone_Cita+angle_error_range_abs*2*(-0.5+rand( size(Microphone_Cita)));
            Measure_Location=Microphone_Center_Location+location_error_range_abs*2*(-0.5+rand(size(Microphone_Center_Location)));
            %���ɴ���ڵ�
            err_node=Error_Node;
            %�����д���Ĳ�������
            measure_data(:,sequence)=real_data(:,sequence);
            for i=1:Node_Error_NUM
                if err_node(1,i)~=0
                    if measure_data(err_node(1,i),sequence)==0
                        measure_data(err_node(1,i),sequence)=1;
                    else
                        measure_data(err_node(1,i),sequence)=0;
                    end
                end
            end
        end
        %��ó����еĲ�������------------------------end
        %��������
        weight = Get_Weight(measure_data,probability,Measure_Location,Microphone_Distance,Measure_Cita,Size_Grid,scale);
        Basic_ErrorNode = Basic_Method(Node_Error_NUM_Percent,weight);
        
        %ֻ����һ�δ��󷽷�
        OnlyOne_ErrorNode = OnlyOne_Method(weight);
        %ʹ��ֱ��ͼ����
        HistGet_ErrorNode = HistGet_Method(circulation,weight);
        
        [FPR_Basic_tmp((changething-for_begin)/for_gap+1),FNR_Basic_tmp((changething-for_begin)/for_gap+1)]=False_Rate(Error_Node,Basic_ErrorNode);
        [FPR_OnlyOne_tmp((changething-for_begin)/for_gap+1),FNR_OnlyOne_tmp((changething-for_begin)/for_gap+1)]=False_Rate(Error_Node,OnlyOne_ErrorNode);
        [FPR_HistGet_tmp((changething-for_begin)/for_gap+1),FNR_HistGet_tmp((changething-for_begin)/for_gap+1)]=False_Rate(Error_Node,HistGet_ErrorNode);
        
        
    end
    
    %     pause;
    FPR_Basic(runs,:)=FPR_Basic_tmp;
    FNR_Basic(runs,:)=FNR_Basic_tmp;
    FPR_OnlyOne(runs,:)=FPR_OnlyOne_tmp;
    FNR_OnlyOne(runs,:)=FNR_OnlyOne_tmp;
    FPR_HistGet(runs,:)=FPR_HistGet_tmp;
    FNR_HistGet(runs,:)=FNR_HistGet_tmp;
end

FPR_Basic_mean = mean(FPR_Basic(1:RUNS,:));
FNR_Basic_mean = mean(FNR_Basic(1:RUNS,:));
FPR_OnlyOne_mean = mean(FPR_OnlyOne(1:RUNS,:));
FNR_OnlyOne_mean = mean(FNR_OnlyOne(1:RUNS,:));
FPR_HistGet_mean = mean(FPR_HistGet(1:RUNS,:));
FNR_HistGet_mean = mean(FNR_HistGet(1:RUNS,:));
%print figure
save print_data.mat x_label FPR_Basic_mean FNR_Basic_mean   FPR_OnlyOne_mean FNR_OnlyOne_mean FPR_HistGet_mean FNR_HistGet_mean

%clear all;
print_diagram();