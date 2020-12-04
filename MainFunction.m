%% ��ȡ��·��Ϣ
clear;clc;
[Busdata,Gendata,branchdata,Gencostdata]=Data();
% ��·��Ϣ
LineI=branchdata(:,1);
LineJ=branchdata(:,2);
LineR=branchdata(:,3);
LineX=branchdata(:,4);
LineB=branchdata(:,5);
LineNum=length(LineI);
% �ڵ���Ϣ
NodeI=Busdata(:,1);
NodeNum=length(NodeI);
% �������Ϣ
GenI=Gendata(:,1);

%% ��ʼ��
IniPostiveBranchFlow=sparse([LineI;LineJ],[LineJ,LineI],[ones(LineNum,1);-ones(LineNum,1)],NodeNum,NodeNum);
IniReactiveBranchFlow=sparse([LineI;LineJ],[LineJ,LineI],[zeros(LineNum,1);zeros(LineNum,1)],NodeNum,NodeNum);
NodeIniVoltage=ones(NodeNum,1);
NodeIniTheta=zeros(NodeNum,1);
DNodeIniVoltage=zeros(NodeNum,1);


%% �״δ���
[PostiveBranchFlow,ReactiveBranchFlow,NodeVoltageS,DNodeVoltageS,NodeTheta,BatteryCh,BatteryDc,DBatteryCh,DBatteryDc,VIMultiDVI]=...
          FormulationDeclear(IniPostiveBranchFlow,IniReactiveBranchFlow,NodeIniVoltage,NodeIniTheta,DNodeIniVoltage);
        
DNodeIniVoltage=sqrt(DNodeVoltageS+NodeVoltageS+2*VIMultiDVI)-sqrt(NodeVoltageS);

%% ����ڶ��ν�
IniPostiveBranchFlow=PostiveBranchFlow;
IniReactiveBranchFlow=ReactiveBranchFlow;
NodeIniVoltage=sqrt(NodeVoltageS);
NodeIniTheta=NodeTheta;


[PostiveBranchFlow,ReactiveBranchFlow,NodeVoltageS,DNodeVoltageS,NodeTheta,BatteryCh,BatteryDc,DBatteryCh,DBatteryDc,VIMultiDVI]=...
          FormulationDeclear(IniPostiveBranchFlow,IniReactiveBranchFlow,NodeIniVoltage,NodeIniTheta,DNodeIniVoltage);



%% ����ƫ��
ACN=[branchdata(:,1) branchdata(:,2)]; %��ȡ��·�ڵ���Ϣ
for iteration=1:100
for i=1:length(ACN(:,1))
    PQ(i)=PQS(PostiveBranchFlow(ACN(i,1),ACN(i,2)),ReactiveBranchFlow(ACN(i,1),ACN(i,2)));
end
    MAXPQ=max(PQ);

for i=1:length(ACN(:,1))
    DeltaPQ(i,iteration)=abs(PQ(i)-PQS(IniPostiveBranchFlow(ACN(i,1),ACN(i,2)),IniReactiveBranchFlow(ACN(i,1),ACN(i,2))))/MAXPQ;
end   

% �ж���������
   if DeltaPQ(:,iteration)<=0.01
      fprintf('�����������������\n'); break
   else
   IniPostiveBranchFlow=PostiveBranchFlow;   %���³�ʼ������
   IniReactiveBranchFlow=ReactiveBranchFlow; %���³�ʼ������
% NodeIniVoltage=sqrt(NodeVoltageS);
% NodeIniTheta=NodeTheta;
   DNodeIniVoltage=sqrt(DNodeVoltageS+NodeVoltageS+2*VIMultiDVI)-sqrt(NodeVoltageS);


   [PostiveBranchFlow,ReactiveBranchFlow,NodeVoltageS,DNodeVoltageS,NodeTheta,BatteryCh,BatteryDc,DBatteryCh,DBatteryDc,VIMultiDVI]=...
          FormulationDeclear(IniPostiveBranchFlow,IniReactiveBranchFlow,NodeIniVoltage,NodeIniTheta,DNodeIniVoltage);
   end
end
IniPostiveBranchFlow=PostiveBranchFlow;
IniReactiveBranchFlow=ReactiveBranchFlow;
% NodeIniVoltage=sqrt(NodeVoltageS);
% NodeIniTheta=NodeTheta;



DNodeIniVoltage=sqrt(DNodeVoltageS+NodeVoltageS+2*VIMultiDVI)-sqrt(NodeVoltageS);


[PostiveBranchFlow,ReactiveBranchFlow,NodeVoltageS,DNodeVoltageS,NodeTheta,BatteryCh,BatteryDc,DBatteryCh,DBatteryDc,VIMultiDVI]=...
          FormulationDeclear(IniPostiveBranchFlow,IniReactiveBranchFlow,NodeIniVoltage,NodeIniTheta,DNodeIniVoltage);
