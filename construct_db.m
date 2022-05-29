function hashTable = construct_db()
    Fs = 44100;
    table = [];
    for i = 1:50
        id = num2str(i);
        toRead = strcat('songDatabase/', num2str(i),'.mat');
        load(toRead, '-mat');
        y = y(:,1);
        tempTable = make_table(y, Fs);
        songID = i.*(ones(length(tempTable),1));% For songID
        table = [table; tempTable, songID];
    end
    hashTable = hash(table); %make database
    save hashTable_2.mat
end