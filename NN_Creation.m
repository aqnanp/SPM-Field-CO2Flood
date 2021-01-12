clc
clear

%% Data Preparation
%sampling
data = importdata('exp.txt');
qinj = data(:,1);
PVinj = data(:,2);
InjFluidID = data(:,3);
starttime = data(:,4);
InjFluidData=[1 0 0; 0.95 0.05 0; 0.95 0 0.05; 0.9 0.1 0; 0.9 0 0.1; ...
    0.9 0.05 0.05; 0.85 0.15 0; 0.85 0 0.15; 0.85 0.1 0.05; 0.85 0.05 0.1; ...
    0.8 0.2 0; 0.8 0 0.2; 0.8 0.05 0.15; 0.8 0.15 0.05;0.8 0.1 0.1];

%runresult extraction
time = importdata('time.txt');
FOPR = importdata('foprvSV.txt');

%empty file
Inj_Rate = [];
PV_Inj = [];
start_time = [];
CO2_comp = [];
C1_comp = [];
C2_comp = [];
FOPR_before = [];

j=1;
for i=1:length(time)
    if (i>1) && (time(i)<time(i-1))
        j=j+1;
    end
    Inj_Rate = [Inj_Rate;qinj(j)];
    PV_Inj = [PV_Inj;PVinj(j)];
    start_time = [start_time;starttime(j)];
    CO2_comp = [CO2_comp;InjFluidData(InjFluidID(j),1)];
    C1_comp = [C1_comp;InjFluidData(InjFluidID(j),2)];
    C2_comp = [C2_comp;InjFluidData(InjFluidID(j),3)];
    if (i==1) | (time(i)<time(i-1))
        FOPR_before = [FOPR_before;0];
    else
        FOPR_before = [FOPR_before;FOPR(i-1)];
    end
end

dataset = [time Inj_Rate PV_Inj start_time CO2_comp C1_comp C2_comp FOPR_before FOPR];
% tabledataset = table(time,Inj_Rate,PV_Inj,start_time,CO2_comp,C1_comp,C2_comp,FOPR_before,FOPR);

%% ANN Construction
% xx2=importdata('aa.txt');%importing your data
input=dataset(:,1:end-1)';
output=dataset(:,end)';
t=(output);

con=80;
while con~=1
    hiddenLayerSize=[8 5];
    trainFcn = 'trainlm'; 
    net = fitnet(hiddenLayerSize,trainFcn);
    net.performFcn = 'msereg';
    net.trainParam.epochs=2500;
    net.trainParam.max_fail=30;
    net.trainParam.min_grad=1e-10;
    net.layers{1}.transferFcn ='logsig';% 'radbas';
    net.layers{2}.transferFcn = 'logsig';
    %net.layers{3}.transferFcn = 'logsig';
    %net.divideFcn='divideint';
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;

    [net,tr] = train(net,input,t);
    y1 = net(input);
    y=(y1);
    e = gsubtract(t,y);
    RR=corrcoef(t,y);
    RX=RR(1,2);
    AAPRD=mae(e./t)*100;
    rmsse1=((1/length(e))*sum(((t)-y).^2)).^0.5;
    %xc=tr.best_vperf;
    if rmsse1<2.75%here it is the stopping condition 
        genFunction(net,'GeneratedANN','MatrixOnly','yes');%% Creation de la fct
        con=1;
    end
end

%% Blind Test Data Import
FOPR_blindtest = importdata('foprvSV_blind.txt');
time_blindtest = importdata('time_blind.txt');

%sampling
blinddata = importdata('blindtest.txt');
qinj_blind = blinddata(:,1);
PVinj_blind = blinddata(:,2);
InjFluidID_blind = blinddata(:,3);
starttime_blind = blinddata(:,4);

FOPR_before_blind=[];
blinddataset=[];
j=1;
for i=1:length(time_blindtest)
    if (i>1) && (time_blindtest(i)<time_blindtest(i-1))
        j=j+1;
    end
    blinddataset = [blinddataset;time_blindtest(i) qinj_blind(j) PVinj_blind(j) starttime_blind(j) ...
        InjFluidData(InjFluidID_blind(j),1) InjFluidData(InjFluidID_blind(j),2) ...
        InjFluidData(InjFluidID_blind(j),3)];
    if (i==1) | (time_blindtest(i)<time_blindtest(i-1))
        FOPR_before_blind = [FOPR_before_blind; 0];
    else
        FOPR_before_blind = [FOPR_before_blind; FOPR_blindtest(i-1)];
    end
end

blinddataset = [blinddataset FOPR_before_blind FOPR_blindtest];


%% Blind Test
start_data=255;
end_data=328;

all_blind_input_proxy=[];
for i=1:(end_data-start_data+1)
    if i==1
        blind_input_proxy = [blinddataset(i+start_data-1,1:end-2) 0];
    else
        blind_input_proxy = [blinddataset(i+start_data-1,1:end-2) all_blind_input_proxy(i-1,end)];
    end
    FOPR_blind_gen = GeneratedANN(blind_input_proxy');
    all_blind_input_proxy = [all_blind_input_proxy; blind_input_proxy FOPR_blind_gen];
end

figure;
hold;
scatter(blinddataset(start_data:end_data,1),all_blind_input_proxy(:,end),'r');
plot(blinddataset(start_data:end_data,1),FOPR_blindtest(start_data:end_data),'k');
legend('Proxy','Eclipse', 'Location', 'southwest');
ylim([0,1800]);
ylabel('FOPR (sm^3/day)');
xlabel('time (years)');