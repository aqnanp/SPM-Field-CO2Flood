function TotalProd = FOPT(x)
    Inj_Rate = x(1);
    PV_Inj = x(2);
    start_time_ID = x(3);
    CO2_comp = x(4);
    C1_comp = x(5);
    C2_comp = x(6);
    
    start_time_data = [0.5 3.75 5];
    start_time = start_time_data(start_time_ID);
    timebank = importdata('timebank.txt');
    temp = [Inj_Rate PV_Inj start_time CO2_comp C1_comp C2_comp];
    
    time = start_time + (PV_Inj*10^7*50/(Inj_Rate*10^6))/365.25;
    
    %Result=[];
    TotalProd=0;
    for i=1:ceil(time*12)
        if i==1
            input_proxy = [timebank(i,2) temp 0];
        else
            input_proxy = [timebank(i,2) temp FOPR_gen];
        end
        FOPR_gen = GeneratedANN(input_proxy');
        TotalProd = TotalProd+FOPR_gen*timebank(i,1);
        %Result = [Result; timebank(i,1) FOPR_gen TotalProd];
    end
    TotalProd = -1*TotalProd;