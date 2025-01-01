require('NPCs/MainCreationMethods');

local function initQuitSmoking(_player)
    local player = _player;
    player:getModData().chancetoquit = 0;
    player:getModData().incremental = 1.0;
    player:getModData().formersmoker = false;
    player:getModData().version = 1.1;
end

local function checkQuitSmoking()
    --add this patch so it can be enabled on existing games.
    local player = getPlayer();
    if  player:hasModData() 
        and player:getModData().chancetoquit ~= nil
        or player:getModData().incremental ~= nil
        then return
        else  
        player:getModData().chancetoquit = 0;
        player:getModData().incremental = 1.0;
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
            newchance = ZombRand(1,100)/33600 ;
            playerdata.incremental = playerdata.incremental + 0.01 ;
        end
        if player:HasTrait("Unlucky") then
            newchance = ZombRand(1,100)/134400 ;
            playerdata.incremental = playerdata.incremental + 0.002 ;
        else newchance =ZombRand(1,100)/67200;
            playerdata.incremental = playerdata.incremental + 0.005 ;
        end

        print("incremental:" .. playerdata.incremental );
        print("chance to quit:" .. playerdata.chancetoquit );
        print("new chance:" .. newchance);

       playerdata.chancetoquit = playerdata.chancetoquit +  newchance;
    end

    --reset values if player has smoked
    if player:getTimeSinceLastSmoke() <= 1
    then  playerdata.chancetoquit = 0 ;
        playerdata.incremental = 1;
    end

end

local function smokerUpdate()
    local player = getPlayer();
    local playerdata = player:getModData();
    selection = math.max(((100 -  math.floor(playerdata.chancetoquit * 100)) - math.floor(playerdata.incremental)),0);
    magicnumber = ZombRand(0,selection);
    print("selection:" .. selection .. " magic number:" ..magicnumber);
    -- add trait check to resolve bug where player can obtain smoker trait after this function running
    if player:HasTrait("Smoker") 
    and magicnumber == 0
        then 
        player:getTraits():remove("Smoker");
        print("smoking ceased");
        --insert a delay, or find a good sound to indicate this happens
        playerdata.formersmoker = true;
        --changed this from 0 to .00001 after recomendation from zerogab on steam to resolve infinite stress
        player:getStats():setStressFromCigarettes(0.0001);
        player:playSound("GainExperienceLevel");
    end 

    if playerdata.formersmoker == true
    and player:getTimeSinceLastSmoke() <=9 
        then playerdata.chancetoquit = 0;
        playerdata.formersmoker = false;
        player:getTraits():add("Smoker");  
        player:Say("I'm hooked on smokes again.")
    end 


   
end


Events.OnNewGame.Add(initQuitSmoking);
Events.EveryHours.Add(quitChanceUpdate);
Events.EveryDays.Add(smokerUpdate);
Events.OnGameStart.Add(checkQuitSmoking);
