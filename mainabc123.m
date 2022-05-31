function songID = mainabc123(y, Fs, t) % It is a sample code
    min_gs = 7; max_gs=21;n_seg=3; deltaTL = 1; deltaTU = 3; deltaF  = 30;
    load('hashTable_52_segd13_gs7x3_35.mat', 'hashTable')
    table = make_table(y, min_gs,max_gs, n_seg, deltaTL, deltaTU, deltaF, Fs);

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
%         confidenceThreshold = 1/(7+10*t);
        minimumFrequencies = 100;
        if confidence > confidenceThreshold & frequency(2)>minimumFrequencies
            songID = mode(matchMatrix(find(matchMatrix(:,1) == modeValue(1)),2))
        else
            songID = 0;
        end
    end

end