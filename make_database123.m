function hashTable = make_database123(min_gs,max_gs, n_seg, deltaTL,deltaTU,deltaF, numOfSongs)
    table = [];
    
    for i = 1:numOfSongs
        id = num2str(i);
        toRead = strcat('songDatabase/', num2str(i),'.mat');
        load(toRead, '-mat');
        y = y(:,1);
        tempTable = make_table(y, min_gs, max_gs, n_seg, deltaTL, deltaTU, deltaF, Fs);
        songID = i.*(ones(length(tempTable),1));% For songID
        table = [table; tempTable, songID];
    end
    hashTable = hash(table); %make database
end