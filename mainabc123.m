function songID = mainabc123(y, Fs) % It is a sample code
    load('hashTable_2.mat', 'hashTable')
    table = make_table(y, Fs);

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