clear all

numOfSongs = 50; %

withNoise = 0;

if withNoise
    SONGDIR = 'songHighNoise1/';
    EXT = 'Noise.mat';
else
    SONGDIR = 'songDatabase/';
    EXT = '.mat';
end

try
    load 'hashTable_52_seg.mat'
catch
    disp('Updating hashTable ...')
    min_gs = 5; max_gs=20; n_seg=4; deltaTL = 3; deltaTU = 6; deltaF  = 9;
    hashTable = make_database123(min_gs,max_gs, n_seg ,deltaTL,deltaTU,deltaF, numOfSongs);
    save('hashTable_52_seg.mat', 'hashTable')
    disp('Done')
end

% Setting initial times

try
    load('1clipInfo.mat')
    %     load('1clipNoiseInfo.mat')
catch
    rng(0,'v5uniform')
    clipLength = zeros(1,numOfSongs);
    initialTime = zeros(1,numOfSongs);
    for i = 1:numOfSongs
        toRead = strcat(SONGDIR, num2str(i),EXT);
        
        load(toRead, '-mat');
        clipLength(i) = length(y)/Fs;
        initialTime(i) = randi(round(clipLength(i)-10));
    end
    save('clipInfo.mat', 'clipLength', 'initialTime')
    %     save('clipNoiseInfo.mat', 'clipLength', 'initialTime')
end

% Testing algorithms with varying times
songID = zeros(1,numOfSongs);
for i = 1:numOfSongs
    id = num2str(i);
    timeTaken(i) = 0;
    
    %     toRead = strcat('../../songDatabase/', num2str(i),'.mat');
    toRead = strcat(SONGDIR, num2str(i),EXT);
    load(toRead, '-mat');
    
    while songID(i) == 0
        timeTaken(i) = timeTaken(i) + 1;
        
        if timeTaken(i) >  10
            timeTaken(i) = timeTaken(i) - 1;
            break
        end
        yInput = y((initialTime(i)*Fs:initialTime(i)*Fs +  timeTaken(i)*Fs), :);
        songID(i) = mainabc123(yInput, Fs); 
        % Your code will be used here instead of abc123
        %         songID(i) = i;
    end
    disp([i, songID(i), i==songID(i)])
end

[songID; timeTaken];
% Results
accuracy = sum(songID == [1:numOfSongs])/numOfSongs
averageTimeTaken = max(sum(timeTaken)/length(songID) - 1, 1)
points = 3*sum(songID == [1:numOfSongs]) - nnz(songID);
score1 = points/averageTimeTaken;
score2 = points * 0.8 + 0.2 * score1;
finalScore = max(score1, score2)
MaxScore = 2*numOfSongs
