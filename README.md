# SPM-Field-CO2Flood
Field Based Smart Proxy Model - Optimization for CO2 Flooding Case
CO2 injection is one of the most common EOR methods employed in mature fields. When
injecting CO2 into the reservoir, it will reduce the oil viscosity, add an acidic effect on
carbonate and shaley rock, swells oil, and reduces IFT between oil and water-based on
the miscibility condition. When planning a CO2 injection project, usually it needs to go
through a conceptual design study. Several stages and design variables need to be passed
before the project gets approved. One of them is a reservoir engineering design study.
When coming to the design, optimization needs to be performed to find the optimum
flow design. Doing this takes a lot of time, as conventional reservoir simulation takes
many times to generate one case, not to forget that the optimization problem is a complex
problem.
Employing Smart Proxy Model (SPM) to substitutes our reservoir model and coupling
with an optimization algorithm helps to tackle this problem. An optimization study to
maximize the total oil produced on CO2 flooding synthetic case was performed in this
study. The SPM that we built using Artificial Neural Network (ANN) reduces the run time
from 4.5 minutes to less than 10 seconds for running one case. Genetic Algorithm (GA)
then coupled with our SPM to solve the optimization problem. The optimum condition
that reached with the optimization algorithm then tested in Eclipse. It shows that our SPM
has a relative error of 1.63% when compared with the Eclipse run result.

This is a case studied during the 3rd semester at NTNU as a fulfillment for TPG4560 Course.
Details and the study result are reported in the project report.

Matlab Codes
1. Eclipse_Multiple_Run : Code to do multiple Eclipse run based on data
   sampling generated from LHS
2. FOPT : Function of FOPT for optimization problem formulation
3. LHS_Aqnan : Modified LHS for the project
4. NN_Creation : Code to generate NN for learning the extracted data

TXT files
1. blindtest : Blind test cases (for Eclipse run)
2. exp : Training cases (for Eclipse run)
3. foprSV : FOPR extracted from Eclipse run results of defined training cases
4. foprSV_blind : FOPR extracted from Eclipse run results of defined blind test cases
5. time : timesteps extracted from Eclipse run results of defined training cases
6. time_blind : timesteps extracted from Eclipse run results of defined blind test cases
