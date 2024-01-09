% This function applies a non-linear filter to the input data.
% The filter is based on forward and backward moving averages and a weighting function.
% The function sets the first N and last N data points to zero.

function Denoised_Data = Apply_NLF (data,N,M,p)

% Get the length of the data
datalength = length(data);
% Define the start and finish indices for the main part of the data
start = N + 1;
finish = datalength - N;

% If is the forward signal
% Initialize with zeros
If = zeros(datalength,1);

% Ib is the backward signal
% Initialize with zeros
Ib = zeros(datalength,1);

% Calculate the forward and backward moving averages
for i = start:finish
    If(i) = mean(data(i-N:i-1));  % Forward moving average
    Ib(i) = mean(data(i+1:i+N));  % Backward moving average
end

% Initialize the forward and backward weights with ones
forward = ones(datalength, 1);
backward = ones(datalength, 1);

% Initialize the summation variables for the weight calculation
summF = 0;
summB = 0;

% Calculate the weights based on the difference between the data and the moving averages
for i = start:finish
    for j = 0 : M-1
        % Accumulate the squared differences for the forward and backward weights
        summF = summF + ( data(i-j) - If(i-j) )^2 ;
        summB = summB + ( data(i-j) - Ib(i-j) )^2 ;
    end
    
    % Calculate the forward and backward weights
    forward(i) = 1/(1+ (summF/summB)^p );
    backward(i) = 1/(1+ (summB/summF)^p );
end

% Combine the forward and backward signals using the weights to get the final denoised data
Denoised_Data =  forward.* If + backward.* Ib;

end