clear
clc
%take DoE result
data=importdata('blindtest.txt');

%assigning data to respective variables
qinj = data(:,1);
PVinj = data(:,2);
InjFluidID = data(:,3);
starttime = data(:,4);

%storage preparation
z=1;time=[];fopr=[];fpr=[];
%fgpr=[];fwpr=[];fwct=[];
%fgir=[];fwir=[];fgor=[];fwit=[];fgit=[];

%months, initial year, injection fluid details
months={'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
year=2020;
InjFluidData={'0 1', '0 0.95 0.05', '0 0.95 0 0.05', '0 0.9 0.1', '0  0.9 0 0.1', '0 0.9 0.05 0.05', '0 0.85 0.15', '0 0.85 0 0.15', '0 0.85 0.1 0.05', '0 0.85 0.05 0.1', '0 0.8 0.2', '0 0.8 0 0.2', '0 0.8 0.05 0.15', '0 0.8 0.15 0.05', '0 0.8 0.1 0.1'};

%empty file for schedule and run result
dlmwrite('results_blind.RSM',' ','delimiter','');

for i=1:length(qinj)
    injrate=qinj(i,1)*1000000/4;
    InjFluid=InjFluidData(InjFluidID(i,1));
    
    %empty previous schedule data
    delete('SCHEDULE.INC');
    dlmwrite('SCHEDULE.INC',' ','delimiter','');
    
    %depletion
    for monthcount=2:starttime(i,1)*12 %start from 2 because start time is JAN (so first depletion will be FEB)
        %taking month value
        realmonth = rem(monthcount,12);
        realyear = year+floor(monthcount/12);        
        if realmonth==0
            realmonth = 12;
            realyear = realyear-1;
        end
        realmonth = months(1,realmonth);
        
        %generate dates
        y={'DATES'};
        dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
        y=append('1 ', realmonth, ' ', num2str(realyear), ' /');
        dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
        y={'/'};
        dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    end
    
    monthcount=monthcount+1;
    %turning injector well on
    %taking month value
    realmonth = rem(monthcount,12);
    realyear = year+floor(monthcount/12);        
    if realmonth==0
        realmonth = 12;
        realyear = realyear-1;
    end
    realmonth = months(1,realmonth);

    %generate dates
    y={'DATES'};
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y=append('1 ', realmonth, ' ', num2str(realyear), ' /');
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y={'/'};
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    
    %injection constraints
    y={'WCONINJE'};
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y=append('INJECT1 GAS OPEN RATE ', num2str(injrate), ' 1* 300 /');
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y=append('INJECT2 GAS OPEN RATE ', num2str(injrate), ' 1* 300 /');
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y=append('INJECT3 GAS OPEN RATE ', num2str(injrate), ' 1* 300 /');
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y=append('INJECT4 GAS OPEN RATE ', num2str(injrate), ' 1* 300 /');
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y={'/'};
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    
    %injection fluid
    y={'WELLSTRE'};
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y=append('INJFLUID ', InjFluid, ' /');
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y={'/'};
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');

    %delegate injection fluid to well
    y={'WINJGAS'};
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y={'INJECT1 STREAM INJFLUID /'};
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y={'INJECT2 STREAM INJFLUID /'};
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y={'INJECT3 STREAM INJFLUID /'};
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y={'INJECT4 STREAM INJFLUID /'};
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    y={'/'};
    dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
    
    monthcount = monthcount+1;

    %flooding
    for floodcount=2:ceil(PVinj(i,1)*10^7/(qinj(i,1)*10^6)/30*50) %assume Bg 50
        %taking month value
        realmonth = rem(monthcount,12);
        realyear = year+floor(monthcount/12);        
        if realmonth==0
            realmonth = 12;
            realyear = realyear-1;
        end
        realmonth = months(1,realmonth);
        
        %generate dates
        y={'DATES'};
        dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
        y=append('1 ', realmonth, ' ', num2str(realyear), ' /');
        dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
        y={'/'};
        dlmwrite('SCHEDULE.INC',y,'-append','delimiter','');
        
        monthcount = monthcount+1;
    end
      
%     !eclrun.exe -v 2019.4 e300 D:\SProjectRun\CASE.DATA
    runecl('D:\SProjectRun\CASE.DATA')
    clc
    temp = dlmread('CASE.RSM','\t',6, 1);
    dlmwrite('results_blind.RSM',z,'-append','delimiter','\t');

    time = [time;temp(:,2)];dlmwrite('time_blind.txt',time,'delimiter','\t');
    fopr = [fopr;temp(:,3)];dlmwrite('foprvSV_blind.txt',fopr,'delimiter','\t');
    fpr = [fpr;temp(:,4)];dlmwrite('fprvSV_blind.txt',fpr,'delimiter','\t');
       
    %For later in WAG
%     temp2=dlmread('CASE_E300.RSM','\t');%,[374 1 577 7]);
%     zz=[temp temp2];
%     fgir=[fgir;temp(:,3)];dlmwrite('fgirvSV.txt',fgir,'delimiter','\t');cwx=ya1(:,4);
%     fgit=[fgit cwx];dlmwrite('fgivSV.txt',fgit,'delimiter','\t');
%     fgor=[fgor;temp(:,5)];dlmwrite('fgorvSV.txt',fgor,'delimiter','\t');
%     fgpr=[fgpr;temp(:,6)];dlmwrite('fgprvSV.txt',fgpr,'delimiter','\t');
%     fwct=[fwct;temp(:,3)];dlmwrite('fwctvSV.txt',fwct,'delimiter','\t');
%     fwir=[fwir;temp(:,4)];dlmwrite('fwirvSV.txt',fwir,'delimiter','\t');cvb=ya2(:,5);
%     fwit=[fwit cvb];dlmwrite('fwitvSV.txt',fwit,'delimiter','\t');
%     fwpr=[fwpr;temp(:,6)];dlmwrite('fwprSV.txt',fwpr,'delimiter','\t');

    z=z+1;
end

function run = runecl(filename)
% Call Eclipse to run a data-file in Matlab
    cmd=['!C:\ecl\macros\eclrun.exe e300 ' filename];
    eval(cmd);
end