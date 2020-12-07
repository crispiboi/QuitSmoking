require('NPCs/MainCreationMethods');

local function initQuitSmoking(_player)
    local player = _player;
    player:getModData().chancetoquit = 0;
    player:getModData().incremental = 1;
    player:getModData().formersmoker = false;
end

local function checkQuitSmoking()
    --add this patch so it can be enabled on existing games.
    local player = getPlayer();
    if  player:hasModData() 
        and player:getModData().chancetoquit ~= nil
        then return
        else  
        player:getModData().chancetoquit = 0;
        player:getModData().incremental = 1;
        player:getModData().formersmoker = false;
    end 

end 

local function quitChanceUpdate(_player, _playerdata)
    --run every hour
    local player = getPlayer();
    local playerdata = player:getModData();
    local newchance = 0;
     if 
        player:HasTrait("Smoker") 
        and playerdata.chancetoquit <=1
    then
        if player:HasTrait("Lucky") then
            player.incremental = player.incremental + 0.01;
            newchance = ZombRand(player.incremental,100)/33600 ;
        end
        if player:HasTrait("Unlucky") then
            player.incremental = player.incremental + 0.002;
            newchance = ZombRand(player.incremental,100)/134400 ;
        else 
            player.incremental = player.incremental + 0.005;
            newchance =ZombRand(player.incremental,100)/67200;
        end
        print("incremental value:");
        print(player.incremental);
        print("chance to quit:");
        print(playerdata.chancetoquit);
        print("new chance:" .. newchance);
        playerdata.chancetoquit = playerdata.chancetoquit +  newchance;
    end

    if player:getTimeSinceLastSmoke() <= 2
    then  playerdata.chancetoquit = 0 ;
    end

end

local function smokerUpdate()
    local player = getPlayer();
    local playerdata = player:getModData();
    selection = 100 -  math.floor(playerdata.chancetoquit * 100);
    magicnumber = ZombRand(0,selection);
    print("selection:" .. selection .. " magic number:" ..magicnumber);
    -- add trait check to resolve bug where player can obtain smoker trait after this function running
    if player:HasTrait("Smoker") 
    and magicnumber == 0
        then player:getTraits():remove("Smoker");
        print("smoking ceased");
        --insert a delay, or find a good sound to indicate this happens
        
        --player:Say("I have quit smoking.")
        playerdata.formersmoker = true;
        player:getStats():setStressFromCigarettes(0);
        player:playSound("GainExperienceLevel");
    end 

    --reset all values if the player smokes
    if playerdata.formersmoker == true
    and player:getTimeSinceLastSmoke() <=24 
        then playerdata.chancetoquit = 0;
        playerdata.incremental = 1;
        playerdata.formersmoker = false;
        player:getTraits():add("Smoker");  
        player:Say("I'm hooked on smokes again.")
    end 




   
end


Events.OnNewGame.Add(initQuitSmoking);
Events.EveryHours.Add(quitChanceUpdate);
Events.EveryDays.Add(smokerUpdate);
Events.OnGameStart.Add(checkQuitSmoking);
