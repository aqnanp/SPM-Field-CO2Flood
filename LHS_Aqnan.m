n = 1;    %number of samples generated
var = 3;   %number of parameter
minparameter = [1 1 1];  %lower value for each parameter
maxparameter = [2 2 15]; %upper value for each parameter
points = [6 6 15]; %number of level for each parameter

%generate for 3 timestep

Sampling1 = denoLHS(n,var,minparameter,maxparameter,points);
Sampling2 = denoLHS(n,var,minparameter,maxparameter,points);
Sampling3 = denoLHS(n,var,minparameter,maxparameter,points);

%Turn them on to see the distribution
% figure
% plot3(Sampling1(:,1),Sampling1(:,2),Sampling1(:,3),'*')
% title('LHS Sampling')
% xlabel('Injection Rate')
% ylabel('PV Injected')
% zlabel('Injection Fluid ID')
% grid on

%For inserting start time
stime1=zeros(n,1);
stime2=zeros(n,1);
stime3=zeros(n,1);
stime1(:,1)=0.5;
stime2(:,1)=3.75;
stime3(:,1)=5;

SamplingOutput1=[Sampling1(:,1:3) stime1];
SamplingOutput2=[Sampling2(:,1:3) stime2];
SamplingOutput3=[Sampling3(:,1:3) stime3];

fileID = fopen('blindtest.txt','w');
%fprintf(fileID,'%6s %6s %6s\n','Qinj','PVinj','Inj Fluid ID', 'tstart');
fprintf(fileID,'%6.2f %6.2f %6.2i %6.2f\n',SamplingOutput1.');
fprintf(fileID,'%6.2f %6.2f %6.2i %6.2f\n',SamplingOutput2.');
fprintf(fileID,'%6.2f %6.2f %6.2i %6.2f\n',SamplingOutput3.');
fclose(fileID);

function denormalize=denoLHS(n,var,minparameter,maxparameter,points)
    design=lhsdesign(n,var,'smooth','off');

    steplength = zeros(1,var);
    steplength(1,:) = (maxparameter(:)-minparameter(:))./(points(:)-1);
    
    denormalize=zeros(n,var);
    for i=1:var
        % assuming all variable uniform discrete
        denormalize(:,i)=(unidinv(design(:,i),points(i))-1).*steplength(1,i)+minparameter(i);
    end
end