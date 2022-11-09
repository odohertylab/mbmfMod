function trialSpec = showTrial(ioStruct, trialSpec)
    % only allow relevant keys
    RestrictKeysForKbCheck( [ioStruct.respKey_1, ioStruct.respKey_2] );
    
    % task stimulus placeholders
    Screen('TextSize', ioStruct.wPtr, 60); Screen('TextColor', ioStruct.wPtr, ioStruct.textColor);  
    % show fixation
    DrawFormattedText(ioStruct.wPtr, '+', 'center', 'center');
    
                %Screen('AddFrameToMovie', ioStruct.wPtr, [],[],[], trialSpec.jitterITI*30);
    
    [~, trialSpec.tStart] = Screen(ioStruct.wPtr, 'Flip');
    
    % show ship options after ITI has expired
    Screen('DrawTexture', ioStruct.wPtr, ioStruct.spaceShip(1), [], ioStruct.rectShip(trialSpec.shipPos(1),:));
    Screen('DrawTexture', ioStruct.wPtr, ioStruct.spaceShip(2), [], ioStruct.rectShip(trialSpec.shipPos(2),:));
    [~, trialSpec.tState1On] = Screen(ioStruct.wPtr, 'Flip', trialSpec.tStart + trialSpec.jitterITI, 1);
    
    % wait for response and store RT
    [trialSpec.tResp1, keyCode] = KbWait(ioStruct.devID, 2, trialSpec.tState1On + ioStruct.MAX_RT);
    trialSpec.RT1 = trialSpec.tResp1 - trialSpec.tState1On;
    pressedKey = find(keyCode);
    
                %Screen('AddFrameToMovie', ioStruct.wPtr, [],[],[], round(trialSpec.RT1*30));
           
    % was a valid response captured
    if isempty(pressedKey)
        % no valid response - show too slow error
        trialSpec = showTooSlowChoice(ioStruct, trialSpec);
        return;
    end
    
    % store response
    if ismember(pressedKey(end), ioStruct.respKey_1)
        trialSpec.resp1 = trialSpec.shipPos(1);
        respSide = ioStruct.LEFT;
    elseif ismember(pressedKey(end), ioStruct.respKey_2)
        trialSpec.resp1 = trialSpec.shipPos(2);
        respSide = ioStruct.RIGHT;
    end
    % track state transitioned into for the given action
    trialSpec.outcome1 = trialSpec.state3(trialSpec.resp1);
    
    % move the selected ship toward the center, and dim the rejected option
    flipPause = 0.02;
    flipTimes = [0:flipPause:(trialSpec.jitterResp1)-0.5] + GetSecs();
    % track the current ship location
    selectedLocation = ioStruct.rectShip(respSide,:);
    rejectedLocation = ioStruct.rectShip(respSide ~= [ioStruct.LEFT, ioStruct.RIGHT],:);
    % step through widths and heights for shrinking ship
    shipWidth = selectedLocation(3) - selectedLocation(1);
    shipHeight = selectedLocation(4) - selectedLocation(2);
    % adjustement to the ship size at each step
    stepWidth = linspace(0, 0.25*shipWidth, length(flipTimes));
    stepHeight = linspace(0, 0.25*shipHeight, length(flipTimes));
    % step through [x,y] corrdinates for moving the ship
    stepX = linspace(0, ioStruct.centerX - round(shipWidth/2) - selectedLocation(1), length(flipTimes));
    stepY = linspace(0, 50, length(flipTimes));
    
    alphaDimSel = logspace(0, log10(255), length(flipTimes));
    alphaDimRej = 255 - logspace(log10(255), 0, length(flipTimes));
    % dim the rejected ship to visualize the jitter
    for fI = 1 : length(flipTimes)
        % dim the rejected ship
        Screen('FillRect', ioStruct.wPtr, [ioStruct.bgColor alphaDimRej(fI)], rejectedLocation);
        % cover the chosen ship
        % show the selected ship as taking off
        Screen('FillRect', ioStruct.wPtr, ioStruct.bgColor, selectedLocation);
        % draw ship in new location
        sizeAdjust = [stepWidth(fI), stepHeight(fI), -stepWidth(fI), -stepHeight(fI)];
        locAdjust = [stepX(fI), -stepY(fI), stepX(fI), -stepY(fI)];
        newLocation = selectedLocation + sizeAdjust + locAdjust;
        Screen('DrawTexture', ioStruct.wPtr, ioStruct.spaceShipSelect(trialSpec.resp1), [], newLocation);  
        Screen('FillRect', ioStruct.wPtr, [ioStruct.bgColor alphaDimSel(fI)], newLocation);
        Screen(ioStruct.wPtr, 'Flip', flipTimes(fI), 0);
        
                            %Screen('AddFrameToMovie', ioStruct.wPtr, [],[],[], 1);
    end
    % clear the screen before showing the station
    Screen(ioStruct.wPtr, 'Flip');

    
    % show the station
    if ismember(trialSpec.outcome1, [1 2])
        stationImg = ioStruct.imgStation(1);
    else
        stationImg = ioStruct.imgStation(2);
    end
    Screen('DrawTexture', ioStruct.wPtr, stationImg, [], ioStruct.rectState);
    [~, trialSpec.tState2On] = Screen(ioStruct.wPtr, 'Flip');
    
    %check if any key presses are made too soon, before the planet is shown
    RestrictKeysForKbCheck( [ioStruct.respKey_3] );
    [~, keyCode] = KbWait(ioStruct.devID, 2, trialSpec.tState2On + trialSpec.jitterState2);
    
    pressedKey = find(keyCode);
    if ~isempty(pressedKey)   %if there is a premature key press
        trialSpec = showTooSoon(ioStruct, trialSpec);
        return;
    end     
    
    % start detecting early presses
    ListenChar(0); 
    KbQueueCreate(ioStruct.devID);
    KbQueueStart(ioStruct.devID);
    
                            %Screen('AddFrameToMovie', ioStruct.wPtr, [],[],[], round(trialSpec.jitterState2*30));
    

    % progressively dim, move, and shrink the station
    flipPause = 0.02;
    flipTimes = [0:flipPause:trialSpec.jitterTrans] + GetSecs();    
    % step through widths and heights for shrinking station
    stationWidth = ioStruct.rectState(3) - ioStruct.rectState(1);
    stationHeight = ioStruct.rectState(4) - ioStruct.rectState(2);   
    % adjustment to the ship size at each step
    stepWidth = linspace(0, 0.25*stationWidth, length(flipTimes));
    stepHeight = linspace(0, 0.25*stationHeight, length(flipTimes));    
    % adjustment to [x,y] corrdinates for moving the ship
    stepY = linspace(0, stationHeight, length(flipTimes));  
    % step through dimming
    dimAlpha = linspace(0, 150, length(flipTimes));
    
    for fI = 1 : length(flipTimes)
        sizeAdjust = [stepWidth(fI), stepHeight(fI), -stepWidth(fI), -stepHeight(fI)];
        locAdjust = [0, stepY(fI), 0, stepY(fI)];
        newLocation = ioStruct.rectState + sizeAdjust + locAdjust;
        Screen('DrawTexture', ioStruct.wPtr, stationImg, [], newLocation);
        Screen('fillRect', ioStruct.wPtr, [ioStruct.bgColor dimAlpha(fI)], newLocation);
        Screen(ioStruct.wPtr, 'Flip', flipTimes(fI), 0);
        
                            %Screen('AddFrameToMovie', ioStruct.wPtr, [],[],[], 1);
    end
    
    % detect any early input during the animation
    KbQueueStop(ioStruct.devID);
    [pressed] = KbQueueCheck(ioStruct.devID);
    if pressed      %if there is a premature key press
        trialSpec = showTooSoon(ioStruct, trialSpec);
        KbQueueFlush(ioStruct.devID);
        ListenChar(2);
        return;
    end
    KbQueueFlush(ioStruct.devID);
    ListenChar(2);
    
    Screen('DrawTexture', ioStruct.wPtr, stationImg, [], newLocation);
    Screen('fillRect', ioStruct.wPtr, [ioStruct.bgColor dimAlpha(fI)], newLocation);
    % show planet (terminal state)
    Screen('DrawTexture', ioStruct.wPtr, ioStruct.imgState(trialSpec.state3(trialSpec.resp1)), [], ioStruct.rectState);
    [~, trialSpec.tState3On] = Screen(ioStruct.wPtr, 'Flip', trialSpec.tState2On + trialSpec.jitterTrans, 1);
    
                            %Screen('AddFrameToMovie', ioStruct.wPtr, [],[],[], round(trialSpec.jitterTrans * 30));
    
    % compute outcome according to reward contingency mapping (state)
    trialSpec.outcomeBin = trialSpec.rewBinary(trialSpec.outcome1);
    trialSpec.outcomeMag = round(trialSpec.rewBinary(trialSpec.outcome1) * trialSpec.rewMagnitude * 100);

    % structure reward output images
    if trialSpec.outcomeBin == 1
        rewardString = sprintf('%+2d', trialSpec.outcomeMag);
    else
        rewardString = '0';
    end
    
    % wait for response and store RT
    RestrictKeysForKbCheck( [ioStruct.respKey_3] );
    [trialSpec.tResp2, keyCode] = KbWait(ioStruct.devID, 2, trialSpec.tState3On + ioStruct.MAX_RT2);
    trialSpec.RT2 = trialSpec.tResp2 - trialSpec.tState3On;
    pressedKey = find(keyCode);
    
                            %Screen('AddFrameToMovie', ioStruct.wPtr, [],[],[], round(trialSpec.RT2 * 30));  
           
    % was a valid response captured
    if isempty(pressedKey)
        % no valid response - show too slow error
        trialSpec = showTooSlowOutcome(ioStruct, trialSpec);
        return;
    end
    
    % show the outcome (win/loss) and reward magnitude 
    Screen('TextSize', ioStruct.wPtr, 60); Screen('TextColor', ioStruct.wPtr, [255 255 255]);
    %Screen('DrawTexture', ioStruct.wPtr, rewImage, [], ioStruct.rectReward);
    Screen('FillOval', ioStruct.wPtr, [0 0 0 100], ioStruct.rectReward);
    DrawFormattedText(ioStruct.wPtr, rewardString, 'center', 'center', [], [], [], [], [], [], ioStruct.rectReward);
    [~, trialSpec.tFbOn] = Screen(ioStruct.wPtr, 'Flip', trialSpec.tState3On + trialSpec.jitterFb, 1);
    
                            %Screen('AddFrameToMovie', ioStruct.wPtr, [],[],[], round(trialSpec.jitterFb * 30));

    % clear the screen
    Screen(ioStruct.wPtr, 'Flip', trialSpec.tFbOn + ioStruct.REW_DURATION);
end


function trialSpec = showTooSlowChoice(ioStruct, trialSpec)
    % clear the screen
    Screen(ioStruct.wPtr, 'Flip');
    % show error text
    slowText = ['Too Slow!\n\n Please make your choice within ' num2str(ioStruct.MAX_RT) ' seconds'];
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 0 0]); Screen('TextFont', ioStruct.wPtr, 'Helvetica');
    DrawFormattedText(ioStruct.wPtr, slowText, 'center', 'center');
    % show feedback for prescribed time, then clear screen
    Screen(ioStruct.wPtr, 'Flip');
    WaitSecs(trialSpec.jitterResp1 + trialSpec.jitterState2 + trialSpec.jitterTrans + trialSpec.jitterFb + ioStruct.REW_DURATION);
    Screen(ioStruct.wPtr, 'Flip');
end

function trialSpec = showTooSlowOutcome(ioStruct, trialSpec)
    % clear the screen
    Screen(ioStruct.wPtr, 'Flip');
    % show error text
    slowText = ['Too Slow!\n\n Please collect your outcome within ' num2str(ioStruct.MAX_RT2) ' second'];
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 0 0]); Screen('TextFont', ioStruct.wPtr, 'Helvetica');
    DrawFormattedText(ioStruct.wPtr, slowText, 'center', 'center');
    % show feedback for prescribed time, then clear screen
    Screen(ioStruct.wPtr, 'Flip');
    WaitSecs(trialSpec.jitterFb + ioStruct.REW_DURATION);
    Screen(ioStruct.wPtr, 'Flip');
end

function trialSpec = showTooSoon(ioStruct, trialSpec)
    % clear the screen
    Screen(ioStruct.wPtr, 'Flip');
    % show error text
    soonText = ['Too soon!\n\n Please wait until you see the planet to hit the spacebar'];
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 0 0]); Screen('TextFont', ioStruct.wPtr, 'Helvetica');
    DrawFormattedText(ioStruct.wPtr, soonText, 'center', 'center');
    % show feedback for prescribed time, then clear screen
    Screen(ioStruct.wPtr, 'Flip');
    WaitSecs(trialSpec.jitterFb + ioStruct.REW_DURATION);
    Screen(ioStruct.wPtr, 'Flip');
end