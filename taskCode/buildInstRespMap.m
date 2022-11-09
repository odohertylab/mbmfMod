function [backKeys, nextKeys] = buildInstRespMap(ioStruct, numInstructions)
    % define forward/back keys for each screne (default to arrow keys)
    backKeys = repmat({[KbName('2'), KbName('2@'), KbName('leftarrow')]}, numInstructions, 1);
    nextKeys = repmat({[KbName('3'), KbName('3#'), KbName('rightarrow')]}, numInstructions, 1);
    
    % define response keys the move them forward
    nextKeys{4} = [KbName('F')];
    nextKeys{11} = [KbName('space')];
    nextKeys{16} = [KbName('K')];
    nextKeys{18} = [KbName('F')];
    nextKeys{20} = [KbName('F')];
    nextKeys{23} = [KbName('J')];
    nextKeys{26} = [KbName('D')];
    nextKeys{28} = [KbName('F')];
    nextKeys{30} = [KbName('J')];
    nextKeys{end} = [KbName('1'), KbName('1!') KbName('space')];
end