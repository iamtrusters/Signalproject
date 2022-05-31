function table = make_table(y,min_gs, max_gs, n_seg, deltaTL, deltaTU, deltaF, Fs)
    
    cutoff_frequency = 3000;
    Wp = cutoff_frequency/Fs*2;
    [b1,a1] = butter(10,Wp,'low');
    y = y(:,1);
    y = filter(b1,a1,y);
    new_Fs = 8000;
    resampledSong = resample(y,new_Fs,Fs);
    


    window = new_Fs * 52*10^-3;
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

%     array = -floor(gs/2):floor(gs/2);
%     localPeakLocation = ones(size(log_S));
% 
%     for i = 1:gs
%         for j = 1:gs
%             if (array(i) == 0 && array(j) == 0)
%                 localPeakLocation = localPeakLocation;
%             else
%                 CA = circshift(log_S,[array(i),array(j)]);
%                 localPeakLocation = (log_S-CA > 0) .* localPeakLocation;
%             end
%         end
%     end
    
    %Frequency-adaptive local maximum
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
 
%     figure()
%     axis xy;
%     xlabel("Time (bin)")
%     ylabel("Frequency (bin)");
%     title("Constellation Map");
%     hold on;
%     tz = min(300,length(timeLocation));
%     fz = min(300,length(freqLocation));
%     scatter(timeLocation(1:tz), freqLocation(1:fz), "black", "x");
%     hold off;
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
end
