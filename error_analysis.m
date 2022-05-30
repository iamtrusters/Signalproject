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

load 'hashTable_52_seg.mat'
disp('Done')


load('clipInfo.mat');
%     load('1clipNoiseInfo.mat')


songID_test = 43;


%     toRead = strcat('../../songDatabase/', num2str(i),'.mat');
toRead = strcat(SONGDIR, num2str(songID_test),EXT);
load(toRead, '-mat');
timeTaken = 0;
songID=0;
while songID == 0
        timeTaken = timeTaken + 1;
        
        if timeTaken >  10
            timeTaken = timeTaken - 1;
            break
        end
        yInput = y((initialTime(songID_test)*Fs:initialTime(songID_test)*Fs +  timeTaken*Fs), :);
        songID = vismap(yInput, songID_test, Fs);
        % Your code will be used here instead of abc123
        %         songID(i) = i;
end
disp(timeTaken);
