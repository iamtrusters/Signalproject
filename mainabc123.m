function songID = mainabc123(y, Fs) % It is a sample code
    load('hashTable.mat')
    gs = 9;
    deltaTL = 3;
    deltaTU = 6;
    deltaF  = 9;

    y = y(:,1);
    new_Fs = 8000;
    resampledSong = resample(y,new_Fs,Fs);


    window = new_Fs * 64*10^-3;
    noverlap = new_Fs * 32*10^-3;
    nfft = window;
    [S,F,T] = spectrogram(resampledSong,window,noverlap,nfft,new_Fs);
    log_S = log10(abs(S)+1);
%     
%     figure()
%     imagesc(T,F,20*log10(abs(S)))
%     axis xy;
%     xlabel('Time (s)')
%     ylabel('Frequency (kHz)')
%     title('Spectrogram')
%     colormap jet
%     c= colorbar;
%     set(c);
%     ylabel(c,'Power (dB)','FontSize',14);

    array = -floor(gs/2):floor(gs/2);
    localPeakLocation = ones(size(log_S));

    for i = 1:gs
        for j = 1:gs
            if (array(i) == 0 && array(j) == 0)
                localPeakLocation = localPeakLocation;
            else
                CA = circshift(log_S,[array(i),array(j)]);
                localPeakLocation = (log_S-CA > 0) .* localPeakLocation;
            end
        end
    end

    localPeakValues = log_S .* localPeakLocation;
    desiredNumPeaks = ceil(T(end)) * 30;% time(second) * 30 peaks/second
    sortedLocalPeak = sort(localPeakValues(:),'descend');
    peaks = sortedLocalPeak(1:desiredNumPeaks);
    threshold = (peaks(end));
    localPeakLocation = (localPeakValues >= threshold);

    [freqLocation,timeLocation] = find(localPeakLocation);% Find non-zero peaks % <-- but this is not values tho...
    fanOut = 3;
    table = [];

    for i = 1:length(timeLocation)
        freqLocation_1 = freqLocation(i);
        timeLocation_1 = timeLocation(i);
        freqLower = max(1,freqLocation_1 - deltaF);
        freqUpper = min(length(F),freqLocation_1 + deltaF);
        timeLower = (timeLocation_1 + deltaTL);
        timeUpper = min(length(T), timeLocation_1 + deltaTU);
        subArray = localPeakLocation(freqLower:freqUpper,timeLower:timeUpper);

        [subArrayRow, subArrayCol] = find(subArray,fanOut);% Find at most 3 non-zeros

        if (~isempty(subArrayRow) && ~isempty(subArrayCol))
            freqLocation_2 = (subArrayRow+(freqLocation_1-deltaF)) - 1;
            timeLocation_2 = (subArrayCol+(timeLocation_1+deltaTL)) - 1;

            for index =1:length(freqLocation_2)
                table = [table ; freqLocation_1 freqLocation_2(index) timeLocation_1 (timeLocation_2(index)-timeLocation_1)];
            end
        end
    end

    clipHash = hash(table);
    matchMatrix = [];% [t_0 songID]
    for i2 = 1:size(clipHash,1)
        index = find(hashTable(:,1) == clipHash(i2,1));%
        matchMatrix = [matchMatrix; hashTable(index,2)-clipHash(i2,2), hashTable(index,3)]; %%record all the t_o and song ID end
    end
    [modeValue, frequency] = mode(matchMatrix);
    if length(frequency) <2
        songID = 0;
    else
        confidence = frequency(2)/length(matchMatrix);
        confidenceThreshold = 1/20;
        minimumFrequencies = 100;
        if confidence > confidenceThreshold & frequency(2)>minimumFrequencies
            songID = mode(matchMatrix(find(matchMatrix(:,1) == modeValue(1)),2))
        else
            songID = 0;
        end
    end

end