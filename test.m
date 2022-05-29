clear all

n = 5; % 

% Setting initial times
clipLength = zeros(1,n);
initialTime = zeros(1,n);
tic
% for i = 1:n
%     toRead = strcat('songDatabase/', num2str(i),'.mat');
%     load(toRead, '-mat');   
%     clipLength(i) = length(y)/Fs;
%     initialTime(i) = randi(round(clipLength(i)-10));
% end
toc
% Testing algorithms with varying times
songID = zeros(1,n);
for i = 1:n
    id = num2str(i);
    timeTaken(i) = 0;
    
    while songID(i) == 0
        timeTaken(i) = timeTaken(i) + 1;
        toRead = strcat('songDatabase/', num2str(i),'.mat');
        load(toRead, '-mat');
        clipLength(i) = length(y)/Fs;
        initialTime(i) = randi(round(clipLength(i)-10));
        load(toRead, '-mat');  
        if timeTaken(i) >  10
            timeTaken(i) = timeTaken(i) - 1
            break
        end
        yInput = y((initialTime(i)*Fs:initialTime(i)*Fs +  timeTaken(i)*Fs), :);
        songID(i) = mainabc123(yInput, Fs); % Your code will be used here instead of abc123
    end
end

% Results
accuracy = sum(songID == [1:n])/n
averageTimeTaken = sum(timeTaken)/length(songID)
points = 3*sum(songID == [1:n]) - nnz(songID);
score = points/averageTimeTaken