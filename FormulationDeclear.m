function [PostiveBranchFlow,ReactiveBranchFlow,NodeVoltageS,DNodeVoltageS,NodeTheta,BatteryCh,BatteryDc,DBatteryCh,DBatteryDc,VIMultiDVI]=...
          FormulationDeclear(IniPostiveBranchFlow,IniReactiveBranchFlow,NodeIniVoltage,NodeIniTheta,DNodeIniVoltage)

      
DNodeIniVoltage=0; %��չ���ݽӿڣ��ݲ���
DNodeVoltageS=0;   %��չ���ݽӿڣ��ݲ���
DBatteryCh=0;      %��չ���ݽӿڣ��ݲ���
DBatteryDc=0;      %��չ���ݽӿڣ��ݲ���
VIMultiDVI=0;      %��չ���ݽӿڣ��ݲ���

[Busdata,Gendata,branchdata,Gencostdata]=Data(); %��ȡ��������
LineI=branchdata(:,1);
LineJ=branchdata(:,2);
LineNum=length(LineI);
% �ڵ���Ϣ
NodeI=Busdata(:,1);
NodeNum=length(NodeI);
% �������Ϣ
GenI=Gendata(:,1);
GenNum=length(GenI);


%% OPF������������
% ֧·�й���������������sparseϡ�������ʽ������coding
PositiveBFvarible=sdpvar(LineNum,1);
PostiveBranchFlow=sparse([LineI;LineJ],[LineJ,LineI],[PositiveBFvarible;-PositiveBFvarible],NodeNum,NodeNum);

% ֧·�޹���������������sparseϡ�������ʽ������coding
ReactiveBFvarible=sdpvar(LineNum,1);
ReactiveBranchFlow=sparse([LineI;LineJ],[LineJ,LineI],[ReactiveBFvarible;-ReactiveBFvarible],NodeNum,NodeNum);

% �ڵ��ѹƽ����������
NodeVoltageS=sdpvar(NodeNum,1);

% �ڵ���Ǳ�������
NodeTheta=sdpvar(NodeNum,1);

% ����������й���������
UnitP=sdpvar(GenNum,1);
OperationIF1=binvar(GenNum,1);
OperationIF2=binvar(GenNum,1);
GenOutP=sparse(GenI,ones(1,length(GenI)),UnitP,NodeNum);

% ����������޹���������
UnitQ=sdpvar(GenNum,1);
GenOutQ=sparse(GenI,ones(1,length(GenI)),UnitQ,NodeNum);

%% ���ڴ�ͳOPF�����ϣ��Դ���ѡַ���ݱ�����������
InstallLocation=binvar(NodeNum,1);
InstallCapacity=sdpvar(NodeNum,1);
InstallPowerrating=sdpvar(NodeNum,1);

BatteryDc=sdpvar(NodeNum,1); %��طŵ����
BatteryCh=sdpvar(NodeNum,1); %��س�����
BatteryIF=binvar(NodeNum,1); %������صĳ��״̬Լ��

%% �������Լ����
AGV1=sdpvar(GenNum,1); % anxillary generator varible +
AGV2=sdpvar(GenNum,1); % anxillary generator varible -

% %% *********��������״̬*********
% DPositiveBFvarible=sdpvar(LineNum,1);
% DPostiveBranchFlow=sparse([LineI;LineJ],[LineJ,LineI],[DPositiveBFvarible;-DPositiveBFvarible],NodeNum,NodeNum);
% DReactiveBFvarible=sdpvar(LineNum,1);
% DReactiveBranchFlow=sparse([LineI;LineJ],[LineJ,LineI],[DReactiveBFvarible;-DReactiveBFvarible],NodeNum,NodeNum);

% % ϵͳƵ�ʱ仯
% DeltaF=sdpvar(1,1);

% % ����״̬�ڵ��ѹƽ���������� ����ĸD��ʾdelta����ʾ�仯��
% DNodeVoltageS=sdpvar(NodeNum,1);

% % ����״̬�ڵ���Ǳ�������
% DNodeTheta=sdpvar(NodeNum,1);

% % �й�˦����
% CurtailP=sdpvar(NodeNum,1);

% % �޹�˦����
% CurtailQ=sdpvar(NodeNum,1);

% % ��������������й������仯��
% DUnitP=sdpvar(GenNum,1);
% DGenOutP=sparse(GenI,ones(1,length(GenI)),DUnitP,NodeNum);

% % ��س�ŵ�仯������
% DBatteryDc=sdpvar(NodeNum,1); %��طŵ����
% DBatteryCh=sdpvar(NodeNum,1); %��س�����

% DNodePl=sdpvar(NodeNum,1);
% DNodeQl=sdpvar(NodeNum,1);

% %��ѹ�仯��
% VIMultiDVI=zeros(NodeNum,1);
%% ���ù��캯��
% IniPostiveBranchFlow=sparse([LineI;LineJ],[LineJ,LineI],[ones(LineNum,1);-ones(LineNum,1)],NodeNum,NodeNum);
% IniReactiveBranchFlow=sparse([LineI;LineJ],[LineJ,LineI],[zeros(LineNum,1);zeros(LineNum,1)],NodeNum,NodeNum);
% NodeIniVoltage=ones(NodeNum,1);
% NodeIniTheta=zeros(NodeNum,1);
[Constraints,Obj1,Obj2,Obj3,PostiveBranchFlow,ReactiveBranchFlow]...
         =ObjandConstraint(PostiveBranchFlow,ReactiveBranchFlow,NodeVoltageS,NodeTheta,...
                         UnitP,GenOutP,OperationIF1,UnitQ,GenOutQ,...
                         InstallLocation,InstallCapacity,InstallPowerrating,...
                         BatteryDc,BatteryCh,BatteryIF,...
                         AGV1,AGV2,NodeIniVoltage,NodeIniTheta);



OBJ=Obj1+Obj2+Obj3;
optimize(Constraints,OBJ);

NodeTheta=double(NodeTheta);
NodeVoltageS=double(NodeVoltageS);
PostiveBranchFlow=double(PostiveBranchFlow); ReactiveBranchFlow=double(ReactiveBranchFlow);


BatteryDc=double(BatteryDc);
BatteryCh=double(BatteryCh);


AGV1=double(AGV1); AGV2=double(AGV2);
NodeTheta=double(NodeTheta);
GenOutP=double(GenOutP); GenOutQ=double(GenOutQ);
NodeVoltageS=double(NodeVoltageS); UnitP=double(UnitP); UnitQ=double(UnitQ); OperationIF1=double(OperationIF1); OperationIF2=double(OperationIF2);
PostiveBranchFlow=double(PostiveBranchFlow); ReactiveBranchFlow=double(ReactiveBranchFlow);
BatteryCh=double(BatteryCh); BatteryDc=double(BatteryDc); InstallPowerrating=double(InstallPowerrating); InstallCapacity=double(InstallCapacity);
InstallLocation=double(InstallLocation);BatteryIF=double(BatteryIF);

Obj1=double(Obj1); Obj2=double(Obj2); Obj3=double(Obj3);

end