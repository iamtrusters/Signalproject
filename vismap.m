function songID = vismap(y, songID_test, Fs) % It is a sample code
    min_gs = 5; max_gs = 20; n_seg=4; deltaTL = 1; deltaTU = 3; deltaF  = 30;
    load('hashTable_52_segd13_35.mat', 'hashTable');
    
%     cutoff_frequency = 3000;
%     Wp = cutoff_frequency/Fs*2;
%     [b1,a1] = butter(6,Wp,'low');
    y = y(:,1);
%     y = filter(b1,a1,y);
    new_Fs = 8000;
    resampledSong = resample(y,new_Fs,Fs);


    window = new_Fs * 52*10^-3;
    noverlap = new_Fs * 32*10^-3;
    nfft = window;
    [S,F,T] = spectrogram(resampledSong,window,noverlap,nfft,new_Fs);
    log_S = log10(abs(S)+1);
    spec_map = figure();
    set(spec_map, "Visible", "off");
    imagesc(T,F,20*log10(abs(S)));
    axis xy;
    xlabel('Time (s)')
    ylabel('Frequency (kHz)')
    title('Spectrogram')
    colormap jet
    c=colorbar;
    set(c);
    ylabel(c,'Power (dB)','FontSize',14);
    saveas(spec_map, strcat("error_analysis/2Adaptive-spectrogram_id", num2str(songID_test), "_52NoiseNoFilter.png"));

    length_freq = floor(size(log_S,1)/n_seg);
    localPeakLocation = ones(size(log_S));
    ind = 1;
    for gs = linspace(min_gs,max_gs,n_seg)
        array = -floor(gs/2):floor(gs/2);
        for i = 1:gs
            for j = 1:gs
                slice1 = (ind-1)*length_freq+1;
                slice2 = min(ind*length_freq, size(log_S,1));
%                 disp(slice1);
%                 disp(slice2);
                if (array(i) == 0 && array(j) == 0)
                    localPeakLocation(slice1:slice2,:) = localPeakLocation(slice1:slice2,:);
                else
                    
                    CA = circshift(log_S(slice1:slice2,:),[array(i),array(j)]);
                    localPeakLocation(slice1:slice2,:) = (log_S(slice1:slice2,:)-CA > 0) .* localPeakLocation(slice1:slice2,:);
                end
            end
        end
        ind = ind + 1;
    end

    localPeakValues = log_S .* localPeakLocation;
    desiredNumPeaks = ceil(T(end)) * 35;% time(second) * 30 peaks/second
    sortedLocalPeak = sort(localPeakValues(:),'descend');
    peaks = sortedLocalPeak(1:desiredNumPeaks);
    threshold = (peaks(end));
    localPeakLocation = (localPeakValues >= threshold);
 
    [freqLocation,timeLocation] = find(localPeakLocation);% Find non-zero peaks % <-- but this is not values tho...
 
    cs_map = figure();
    set(cs_map, 'Visible', 'off');
    axis xy;
    xlabel("Time (bin)")
    ylabel("Frequency (bin)");
    title("Constellation Map");
    hold on;
%     tz = min(300,length(timeLocation));
%     fz = min(300,length(freqLocation));
    scatter(timeLocation, freqLocation, "black", "x");
    hold off;
    saveas(cs_map, strcat('error_analysis/2AdaptiveConstellation_id',num2str(songID_test), '_52Noise.png'));
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