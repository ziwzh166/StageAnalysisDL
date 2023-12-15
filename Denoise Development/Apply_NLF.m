%% 2023-10-09 Mohammad: Apply non-linear filter
%       Used in Find_Steps
%       MATLAB 2023a
% data is a vector contains the output of a single electrode
% based on what Zinaida-Cecilia wrote
% This function set N first and N last datapoints to zero, that data will be lost

function Denoised_Data = Apply_NLF (data,N,M,p)

datalength = length(data);
start = N + 1;
finish = datalength - N;

If = zeros(datalength,1);
Ib = zeros(datalength,1);
    
%points intensities
for i = start:finish
    If(i) = mean(data(i-N:i-1));
    Ib(i) = mean(data(i+1:i+N));  
end

forward = ones(datalength, 1);
backward = ones(datalength, 1);

summF = 0;
summB = 0;

%weight functions
for i = start:finish

    for j = 0 : M-1
        summF = summF + ( data(i-j) - If(i-j) )^2 ;
        summB = summB + ( data(i-j) - Ib(i-j) )^2 ;
    end
    
    forward(i) = 1/(1+ (summF/summB)^p );
    backward(i) = 1/(1+ (summB/summF)^p );
    
end

%final signals
Denoised_Data =  forward.* If + backward.* Ib;

end

