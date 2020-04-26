// Flywrench autosplitter by Hamb
// tested for version 1.0.0.2 on windows + steam

state("FlywrenchStudio")
{
    // in-game total time and time trial timers are stored in 1/60-th of seconds (frames) for some reason ...
    // most values are stored as double by the game

    // room as in the gamemaker concept
    uint roomNumber : "FlywrenchStudio.exe", 0x513370;

    // in-game time that is displayed (rounded) in the menu and after beating sun
    double totalTime : "FlywrenchStudio.exe", 0x310fa4, 0x0, 0x3e0, 0xc, 0xac, 0x8, 0xc8, 0xd0, 0x8;

    // time trial timer
    double timeTrialTime : "FlywrenchStudio.exe", 0x310fa4, 0x0, 0x3e0, 0xc, 0xac, 0x8, 0xc8, 0xe0, 0x8;

    // 1 = new game/continue, 3 = time trial
    double mode : "FlywrenchStudio.exe", 0x310fa4, 0x0, 0x3e0, 0xc, 0xac, 0x8, 0xc8, 0x7c, 0x0, 0x8;

    // cumulated number of beaten levels on all planets
    // uint beatenLevels : "FlywrenchStudio.exe", 0x51ef34, 0x2c, 0x4;

    // number of locked themes
    // uint lockedThemes : "FlywrenchStudio.exe", 0x51ef34, 0x48, 0x4;

    string25 currentLevel : "FlywrenchStudio.exe", 0x310fa4, 0x0, 0x3e0, 0xc, 0xac, 0x8, 0xc8, 0x68, 0x8, 0x0;
}

startup
{
    refreshRate = 30;

       settings.Add("levelsplits", false, "Auto-split after each level in story mode.");

       vars.lastLevels = new HashSet<string>() { "DK_REDUXSLAMMER", "NXT_BSS", "GUM_FLIM", "WTG2_REDACTED", "WND_TREETOPS", "MM_CLIMB", "EMLW_CANNONBALL", "HY_ROCKET", "MCY2_IMPACT", "INIT_ICARUS" };
}

init
{
    // time span from 1/60-th of seconds
    vars.toTimeSpan = (Func<double, TimeSpan>) (t => 
    {
        var ticks = (long) (t / 60 * 10000000);
        return new TimeSpan(ticks);
    });

    // trick to avoid false weird momentary changes in variables (probably due to gamemaker shenanigans)
    vars.currentLevelStabilizer = 4;
    vars.timeTrialTimeStabilizer = 4;
}

update
{
    if (old.currentLevel != current.currentLevel)
    {
        vars.currentLevelStabilizer = 0;
    }
    else if (vars.currentLevelStabilizer < 3)
    {
        vars.currentLevelStabilizer += 1;
    }
    else if (vars.currentLevelStabilizer == 3)
    {
        vars.currentLevelStabilizer += 1;
        vars.currentLevel = current.currentLevel;
    }

    if ((int) current.mode == 3)
    {
        vars.timeTrialTimeReset = false;
        if (current.timeTrialTime < old.timeTrialTime) 
        {
            vars.timeTrialTimeStabilizer = 0;
        }
        else if (current.timeTrialTime < 20)
        {
            if (vars.timeTrialTimeStabilizer < 3)
            {
                vars.timeTrialTimeStabilizer += 1;
            }
            else if (vars.timeTrialTimeStabilizer == 3)
            {
                vars.timeTrialTimeStabilizer += 1;
                vars.timeTrialTimeReset = true;
            }
        }
        else
        {
            vars.timeTrialTimeStabilizer = 4;
        }
    }
}

gameTime
{    
    if ((int) current.mode == 3)
    {
        return vars.toTimeSpan(current.timeTrialTime);
    }
    else
    {
        return vars.toTimeSpan(current.totalTime);
    }
}

start
{
    if ((int) current.mode == 3)
    {
        return old.timeTrialTime <= 0 && current.timeTrialTime > 0;
    }
    else
    {
        return current.roomNumber == 30;
    }
}

reset
{
    if ((int) current.mode == 3)
    {
        return vars.timeTrialTimeReset;  // time trial time only resets when starting a new time trial.
    }
    else
    {
        return old.roomNumber == 6 && current.roomNumber == 2 && current.totalTime == 0;
        // bool timerReset = old.totalTime > 0 && current.totalTime <= 0;
        // bool inMenu = current.roomNumber == 2 || current.roomNumber == 6;  // main menu or erase progress, just to make sure
        // return timerReset && inMenu;
    }
}

split
{
    bool levelCompleted = old.roomNumber == 29 && current.roomNumber == 3;

    if ((int) current.mode == 3)
    {
        return levelCompleted;
    }
    else
    {
        return levelCompleted && (settings["levelsplits"] || vars.lastLevels.Contains(vars.currentLevel));
    }
}

isLoading
{
    return true;
}
