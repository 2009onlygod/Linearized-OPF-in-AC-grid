function [Constraints,Obj1,Obj2,Obj3,PostiveBranchFlow,ReactiveBranchFlow]...
         =ObjandConstraint(PostiveBranchFlow,ReactiveBranchFlow,NodeVoltageS,NodeTheta,...
                         UnitP,GenOutP,OperationIF1,UnitQ,GenOutQ,...
                         InstallLocation,InstallCapacity,InstallPowerrating,...
                         BatteryDc,BatteryCh,BatteryIF,...
                         AGV1,AGV2,NodeIniVoltage,NodeIniTheta)
                                           
[Busdata,Gendata,branchdata,Gencostdata]=Data(); %��ȡ��������


% ��·��Ϣ
LineI=branchdata(:,1);
LineJ=branchdata(:,2);
LineR=branchdata(:,3);
LineX=branchdata(:,4);
LineB=branchdata(:,5);
LineNum=length(LineI);

% �ڵ���Ϣ
NodeI=Busdata(:,1);
NodePl=Busdata(:,3)/100;
NodeQl=Busdata(:,4)/100;
NodeNum=length(NodeI);
% �������Ϣ
GenI=Gendata(:,1);
GenNum=length(GenI);
GenPmin=Gendata(:,10)/100;
GenPmax=Gendata(:,9)/100;
GenQmin=Gendata(:,5)/100;
GenQmax=Gendata(:,4)/100;
GenC=Gencostdata(:,7);
GenB=Gencostdata(:,6);
GenA=Gencostdata(:,5);



%% OPF������������
% ֧·�й���������������sparseϡ�������ʽ������coding
% PositiveBFvarible=sdpvar(LineNum,1);
% PostiveBranchFlow=sparse([LineI;LineJ],[LineJ,LineI],[PositiveBFvarible;-PositiveBFvarible],NodeNum,NodeNum);
% IniPostiveBranchFlow=sparse([LineI;LineJ],[LineJ,LineI],[ones(LineNum,1);-ones(LineNum,1)],NodeNum,NodeNum);
% ֧·�޹���������������sparseϡ�������ʽ������coding
% ReactiveBFvarible=sdpvar(LineNum,1);
% ReactiveBranchFlow=sparse([LineI;LineJ],[LineJ,LineI],[ReactiveBFvarible;-ReactiveBFvarible],NodeNum,NodeNum);
% IniReactiveBranchFlow=sparse([LineI;LineJ],[LineJ,LineI],[zeros(LineNum,1);zeros(LineNum,1)],NodeNum,NodeNum);
% �ڵ��ѹƽ����������
% NodeVoltageS=sdpvar(NodeNum,1);
% NodeIniVoltage=ones(NodeNum,1);
% �ڵ���Ǳ�������
% NodeTheta=sdpvar(NodeNum,1);
% NodeIniTheta=zeros(NodeNum,1); %��������и���
% ����������й���������
% UnitP=sdpvar(GenNum,1);
% OperationIF=binvar(GenNum,1);
% GenOutP=sparse(GenI,ones(1,length(GenI)),UnitP,NodeNum);
% ����������޹���������
% UnitQ=sdpvar(GenNum,1);
% GenOutQ=sparse(GenI,ones(1,length(GenI)),UnitQ,NodeNum);
%% ���ڴ�ͳOPF�����ϣ��Դ���ѡַ���ݱ�����������
% InstallLocation=binvar(NodeNum,1);
% InstallCapacity=sdpvar(NodeNum,1);
% InstallPowerrating=sdpvar(NodeNum,1);
% BatteryDc=sdpvar(NodeNum,1); %��طŵ����
% BatteryCh=sdpvar(NodeNum,1); %��س�����
% BatterySoc=sdpvar(NodeNum,1); %��س��״̬
% BatteryIF=binvar(NodeNum,1); %������صĳ��״̬Լ��
MaxCapacity=0; % ����½��������
MaxPowerrating=0; %����½���ض�й�����
%% �γɽڵ㵼�ɾ���Ymatrix

% �γɽڵ㵼�ɾ���Ymatrix�ĶԽ���
LineY=1./(LineR+1i*LineX); % ����ÿ����·�ĵ���       
Y1=sparse([LineI;LineJ],[LineJ;LineI],[-LineY;-LineY],NodeNum,NodeNum);    
% �γɽڵ㵼�ɾ���Ymatrix�ķǶԽ���
Y2=sparse([LineI;LineJ],[LineI;LineJ],[LineY+1i*LineB;LineY+1i*LineB],NodeNum,NodeNum);
AdmittanceMatrix=Y1+Y2;
% �γ�ÿ����·�ĵ絼g�͵���b
Conductanceij=sparse([LineI;LineJ],[LineJ;LineI],[real(LineY);real(LineY)],NodeNum,NodeNum);   %�絼g
Susceptanceij=sparse([LineI;LineJ],[LineJ;LineI],[imag(LineY);imag(LineY)],NodeNum,NodeNum);   %����b
% �γ���ǲ�ϵ������
DeffTheta=sparse([LineI;LineJ],[LineJ;LineI],[NodeTheta(LineI)-NodeTheta(LineJ);NodeTheta(LineJ)-NodeTheta(LineI)],NodeNum,NodeNum);
DeffIniTheta=sparse([LineI;LineJ],[LineJ;LineI],[NodeIniTheta(LineI)-NodeIniTheta(LineJ);NodeIniTheta(LineJ)-NodeIniTheta(LineI)],NodeNum,NodeNum);
% �γɳ�ʼ�ڵ��ѹϵ�����󼰵�����ѹϵ������
MultiVoltageij=sparse([LineI;LineJ],[LineJ;LineI],[NodeIniVoltage(LineI).*NodeIniVoltage(LineJ);NodeIniVoltage(LineJ).*NodeIniVoltage(LineI)],NodeNum,NodeNum);
VoltageijS=sparse([LineI;LineJ],[LineJ;LineI],...
           [2*(NodeIniVoltage(LineI)-NodeIniVoltage(LineJ))./(NodeIniVoltage(LineI)+NodeIniVoltage(LineJ)).*(NodeVoltageS(LineI)-NodeVoltageS(LineJ))-(NodeIniVoltage(LineI)-NodeIniVoltage(LineJ)).^2;...
            2*(NodeIniVoltage(LineJ)-NodeIniVoltage(LineI))./(NodeIniVoltage(LineI)+NodeIniVoltage(LineJ)).*(NodeVoltageS(LineJ)-NodeVoltageS(LineI))-(NodeIniVoltage(LineJ)-NodeIniVoltage(LineI)).^2],NodeNum,NodeNum);
% �γ�ÿ����·���й���Ч�絼�͵�Ч����
EPConductanceij=Conductanceij.*cos(DeffIniTheta)+Susceptanceij.*sin(DeffIniTheta);
EPSusceptanceij=-Conductanceij.*MultiVoltageij.*sin(DeffIniTheta)+Susceptanceij.*MultiVoltageij.*cos(DeffIniTheta);
% �γ�ÿ����·���޹���Ч�絼�͵�Ч����
EQConductanceij=Conductanceij.*MultiVoltageij.*cos(DeffIniTheta)+Susceptanceij.*MultiVoltageij.*sin(DeffIniTheta);
EQSusceptanceij=-Conductanceij.*sin(DeffIniTheta)+Susceptanceij.*cos(DeffIniTheta);

%% *********����Լ��*********
Constraints=[];
%% *********��������״̬*********
%% ���ܵ�س�ŵ�Լ��������ѡַ��
M=100;
Constraints=[Constraints, 0<=InstallPowerrating(NodeI)<=InstallLocation(NodeI)*MaxPowerrating];  %�Ƿ����õ�أ������õ�صĶ�й�����Լ��
Constraints=[Constraints, 0<=InstallCapacity(NodeI)<=InstallLocation(NodeI)*MaxCapacity];        %�Ƿ����õ�أ������õ�ص���������Լ��
Constraints=[Constraints, 0<=BatteryDc(NodeI)<=InstallPowerrating(NodeI)];                       %��س���й�Լ��
Constraints=[Constraints, 0<=BatteryCh(NodeI)<=InstallPowerrating(NodeI)];                       %��طŵ��й�Լ��
Constraints=[Constraints, 0<=BatteryDc(NodeI)<=M*BatteryIF(NodeI)];        %��ŵ�Լ��          
Constraints=[Constraints, 0<=BatteryCh(NodeI)<=M*(1-BatteryIF(NodeI))];    %��ŵ�Լ��
Kcharge=0.9;
Kdischarge=1.1;
Constraints=[Constraints,  Kcharge*BatteryCh(NodeI)-Kdischarge*BatteryDc(NodeI)<=InstallCapacity(NodeI)];
Constraints=[Constraints,  Kcharge*BatteryCh(NodeI)-Kdischarge*BatteryDc(NodeI)>=0];
%% ���콻����·��Input node �� Output node����������

GetACBranchI=branchdata(:,1);
GetACBranchJ=branchdata(:,2);
EAV=ones(length(GetACBranchI),1); %��չ�������󣬷���������������д
% ���콻����·�й��޹�����

PostiveBranchFlow(GetACBranchI,GetACBranchJ) =Conductanceij(GetACBranchI,GetACBranchJ).*NodeVoltageS(GetACBranchI,EAV)-...
                                              EPConductanceij(GetACBranchI,GetACBranchJ).*(NodeVoltageS(GetACBranchI,EAV)+NodeVoltageS(GetACBranchJ,EAV))/2-...
                                              EPSusceptanceij(GetACBranchI,GetACBranchJ).*(DeffTheta(GetACBranchI,GetACBranchJ)-DeffIniTheta(GetACBranchI,GetACBranchJ))+...
                                              EPConductanceij(GetACBranchI,GetACBranchJ).*VoltageijS(GetACBranchI,GetACBranchJ)/2;
PostiveBranchFlow(GetACBranchJ,GetACBranchI) =Conductanceij(GetACBranchJ,GetACBranchI).*NodeVoltageS(GetACBranchJ,EAV)-...
                                              EPConductanceij(GetACBranchJ,GetACBranchI).*(NodeVoltageS(GetACBranchI,EAV)+NodeVoltageS(GetACBranchJ,EAV))/2-...
                                              EPSusceptanceij(GetACBranchJ,GetACBranchI).*(DeffTheta(GetACBranchJ,GetACBranchI)-DeffIniTheta(GetACBranchJ,GetACBranchI))+...
                                              EPConductanceij(GetACBranchJ,GetACBranchI).*VoltageijS(GetACBranchJ,GetACBranchI)/2;

ReactiveBranchFlow(GetACBranchI,GetACBranchJ)=-Susceptanceij(GetACBranchI,GetACBranchJ).*NodeVoltageS(GetACBranchI,EAV)+...
                                              EQSusceptanceij(GetACBranchI,GetACBranchJ).*(NodeVoltageS(GetACBranchI,EAV)+NodeVoltageS(GetACBranchJ,EAV))/2-...
                                              EQConductanceij(GetACBranchI,GetACBranchJ).*(DeffTheta(GetACBranchI,GetACBranchJ)-DeffIniTheta(GetACBranchI,GetACBranchJ))-...
                                              EQSusceptanceij(GetACBranchI,GetACBranchJ).*VoltageijS(GetACBranchI,GetACBranchJ)/2;
ReactiveBranchFlow(GetACBranchJ,GetACBranchI)=-Susceptanceij(GetACBranchJ,GetACBranchI).*NodeVoltageS(GetACBranchJ,EAV)+...
                                              EQSusceptanceij(GetACBranchJ,GetACBranchI).*(NodeVoltageS(GetACBranchI,EAV)+NodeVoltageS(GetACBranchJ,EAV))/2-...
                                              EQConductanceij(GetACBranchJ,GetACBranchI).*(DeffTheta(GetACBranchJ,GetACBranchI)-DeffIniTheta(GetACBranchJ,GetACBranchI))-...
                                              EQSusceptanceij(GetACBranchJ,GetACBranchI).*VoltageijS(GetACBranchJ,GetACBranchI)/2;




%% ����ڵ�ƽ�ⷽ��-�����ڵ�

GetACNodeI=Busdata(:,1);
for i=1:length(GetACNodeI)
    SumGij(GetACNodeI(i))=sum(real(AdmittanceMatrix((GetACNodeI(i)),:)));
    SumBij(GetACNodeI(i))=sum(imag(AdmittanceMatrix((GetACNodeI(i)),:)));
end
for i=1:length(GetACNodeI)
    if GetACNodeI(i)==1  %ƽ��ڵ����Լ��
      Constraints=[Constraints,sum(UnitP)+sum(BatteryDc)-sum(BatteryCh)-SumGij(GetACNodeI)*NodeVoltageS(GetACNodeI)-sum(sum(PostiveBranchFlow))==sum(NodePl)];
      Constraints=[Constraints,sum(UnitQ)+SumBij(GetACNodeI)*NodeVoltageS(GetACNodeI)-sum(sum(ReactiveBranchFlow))==sum(NodeQl)];
%                 +ReactiveBranchFlow(ACDCconnectiondata(1,1),ACDCconnectiondata(1,2))+ReactiveBranchFlow(ACDCconnectiondata(2,1),ACDCconnectiondata(2,2))
%                 %********************************************************�����������ɣ���Ҫ����********************************************************%
      Constraints=[Constraints,  NodeVoltageS(GetACNodeI(i))<=1.05^2 , 0.95^2<=NodeVoltageS(GetACNodeI(i))];  
    else
    Corrlbranchij=SearchNodeConnection(LineI,LineJ,GetACNodeI(i)); %��ȡÿ���ڵ��Ӧ��֧·��Ϣ
    InjectionACNodeP(GetACNodeI(i))=GenOutP(GetACNodeI(i))-NodePl(GetACNodeI(i))+BatteryDc(GetACNodeI(i))-BatteryCh(GetACNodeI(i));
    InjectionACNodeQ(GetACNodeI(i))=GenOutQ(GetACNodeI(i))-NodeQl(GetACNodeI(i));   
    SumCorrlBranchACP(GetACNodeI(i))=sum(PostiveBranchFlow(GetACNodeI(i),Corrlbranchij(:,2))); 
    SumCorrlBranchACQ(GetACNodeI(i))=sum(ReactiveBranchFlow(GetACNodeI(i),Corrlbranchij(:,2))); 
    % �ڵ��й�ƽ��
    Constraints=[Constraints,...
        InjectionACNodeP(GetACNodeI(i))==SumCorrlBranchACP(GetACNodeI(i))+NodeVoltageS(GetACNodeI(i))*SumGij(GetACNodeI(i))
    ];

    % �ڵ��޹�ƽ��
    Constraints=[Constraints,...
        InjectionACNodeQ(GetACNodeI(i))==SumCorrlBranchACQ(GetACNodeI(i))-NodeVoltageS(GetACNodeI(i))*SumBij(GetACNodeI(i))
    ];

    % �ڵ��ѹԼ��
    Constraints=[Constraints,  NodeVoltageS(GetACNodeI(i))<=1.05^2 , 0.95^2<=NodeVoltageS(GetACNodeI(i))];  
    end
end



%% �������Լ����
% AGV1=sdpvar(GenNum,1); % anxillary generator varible +
% AGV2=sdpvar(GenNum,1); % anxillary generator varible -
Constraints=[Constraints, GenPmin.*OperationIF1<=UnitP<=GenPmax.*OperationIF1, GenQmin.*OperationIF1<=UnitQ<=GenQmax.*OperationIF1];
Constraints=[Constraints, UnitQ./(GenQmax-GenQmin)+AGV1-AGV2==0,  AGV1>=0, AGV2>=0];
% Constraints=[Constraints, -1<=PostiveBranchFlow(GetACBranchI,GetACBranchJ)<=1];
% Constraints=[Constraints, -0.5<=ReactiveBranchFlow(GetACBranchI,GetACBranchJ)<=0.5];
%% ������·����������Լ����
Npart=20; %���ϡ��°�Բ��Ϊ20���߶�
alpha=pi/6;
beta=(pi-2*alpha)/Npart;
M=Npart;  %�ϰ�Բ����
N=Npart;  %�°�Բ����
Smax=2;
%**********�ϰ�Բ**********%
KAU=zeros(Npart,1);KBU=zeros(Npart,1);XPAU=zeros(Npart,1);
YPAU=zeros(Npart,1);XPBU=zeros(Npart,1);YPBU=zeros(Npart,1);
%**********�°�Բ**********%
KAD=zeros(Npart,1); KBD=zeros(Npart,1);XPAD=zeros(Npart,1);
YPAD=zeros(Npart,1);XPBD=zeros(Npart,1);YPBD=zeros(Npart,1);

%**********�ϰ�Բ**********%  
for i=1:M
    KAU(i)=tan(alpha+(i-1)*beta);
    KBU(i)=tan(alpha+i*beta);
    XPAU(i)=1/( sqrt( 1+( 1/(KAU(i))^2 ) )*KAU(i) ) * Smax;
    YPAU(i)=1/( sqrt( 1+( 1/(KAU(i))^2 ) ) ) * Smax;
    XPBU(i)=1/( sqrt( 1+( 1/(KBU(i))^2 ) )*KBU(i) ) * Smax;
    YPBU(i)=1/( sqrt( 1+( 1/(KBU(i))^2 ) ) ) * Smax;
    Constraints=[Constraints, ( ( YPBU(i)-YPAU(i) )/( XPBU(i)-XPAU(i) )*( ReactiveBranchFlow(GetACBranchI,GetACBranchJ) - XPAU(i) )+YPAU(i)-PostiveBranchFlow(GetACBranchI,GetACBranchJ) )>=0,... %����֧·
    ];  
end

%**********�°�Բ**********%

for i=1:N
    KAD(i)=tan(-alpha-(i-1)*beta);
    KBD(i)=tan(-alpha-i*beta);
    XPAD(i)=-1/( sqrt( 1+( 1/(KAD(i))^2 ) )*KAD(i) ) * Smax;
    YPAD(i)=-1/( sqrt( 1+( 1/(KAD(i))^2 ) ) ) * Smax;
    XPBD(i)=-1/( sqrt( 1+( 1/(KBD(i))^2 ) )*KBD(i) ) * Smax;
    YPBD(i)=-1/( sqrt( 1+( 1/(KBD(i))^2 ) ) ) * Smax;
    Constraints=[Constraints, ( ( YPBD(i)-YPAD(i) )/( XPBD(i)-XPAD(i) )*( ReactiveBranchFlow(GetACBranchI,GetACBranchJ) - XPAD(i) )+YPAD(i)-PostiveBranchFlow(GetACBranchI,GetACBranchJ) )<=0,...%����֧·
    ]; %����֧·
end

%% Ŀ��ɱ�����
CPV=18.95;   %�й��ɱ� ��$/kW
CEV=9.01;    %�����ɱ� ��$/kWh
OMC=0.132;   %���гɱ� ��$/kW
InstallCost=sum(CPV*InstallPowerrating)+sum(CEV*InstallCapacity);
OPM=sum(OMC*(BatteryDc)+OMC*(BatteryCh));
Obj1=InstallCost;
Obj2=GenA'*UnitP+sum(AGV1+AGV2)+OPM;
Obj3=0;
end