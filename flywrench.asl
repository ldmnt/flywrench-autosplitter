// Flywrench autosplitter by Hamb
// tested for version 1.0.0.2 on windows + steam

state("FlywrenchStudio")
{
    // in-game total time and time trial timers are stored in 1/60-th of seconds (frames) for some reason ...
    // all values are stored as double by the game

    // in-game time that is displayed (rounded) in the menu and after beating sun
    double totalTime : "FlywrenchStudio.exe", 0x310fa4, 0x0, 0x3e0, 0xc, 0xac, 0x8, 0xc8, 0xd0, 0x8;

    // time trial timer
    double timeTrialTime : "FlywrenchStudio.exe", 0x310fa4, 0x0, 0x3e0, 0xc, 0xac, 0x8, 0xc8, 0xe0, 0x8;

    // 1 = new game/continue, 3 = time trial
    double mode : "FlywrenchStudio.exe", 0x310fa4, 0x0, 0x3e0, 0xc, 0xac, 0x8, 0xc8, 0x7c, 0x0, 0x8;

    // cumulated number of beaten levels on all planets
    uint beatenLevels : "FlywrenchStudio.exe", 0x51ef34, 0x2c, 0x4;

    // number of locked themes
    // uint lockedThemes : "FlywrenchStudio.exe", 0x51ef34, 0x48, 0x4;

    string25 currentLevel : "FlywrenchStudio.exe", 0x310fa4, 0x0, 0x3e0, 0xc, 0xac, 0x8, 0xc8, 0x68, 0x8, 0x0;
}

startup
{
    refreshRate = 30;
}

init
{
    // time span from 1/60-th of seconds
    vars.toTimeSpan = (Func<double, TimeSpan>) (t => 
    {
        var ticks = (long) (t / 60 * 10000000);
        return new TimeSpan(ticks);
    });

    vars.thresholds = new uint[] { 21, 42, 67, 85, 105, 123, 142, 165, 186, 187 };

    vars.updateLevelCountForNextSplit = (Func<uint, uint>) (beaten =>
    {
        foreach (uint t in vars.thresholds)
        {
            if (beaten < t) { return t; }
        }
        return 188;
    });
    vars.levelCountForNextSplit = vars.updateLevelCountForNextSplit(current.beatenLevels);

    // trick to avoid false positives on changes : use flags that switch only after 3 stable frames
    vars.currentLevelStabilizer = 4;
    vars.timeTrialTimeStabilizer = 4;
}

update
{
	vars.currentLevelChanged = false;
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
		vars.currentLevelChanged = true;
	}

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
        if (old.totalTime <= 0 && current.totalTime > 0)
        {
            vars.levelCountForNextSplit = vars.updateLevelCountForNextSplit(current.beatenLevels);
            return true;
        }
        else 
        {
            return false;
        }
    }
}

reset
{
    if ((int) current.mode == 3)
    {
        return vars.timeTrialTimeReset;  // time trial time only resets when starting a new time trial
    }
    else
    {
        if (old.totalTime > 0 && current.totalTime <= 0 && (old.beatenLevels < current.beatenLevels || current.beatenLevels == 0))
        {
            vars.levelCountForNextSplit = vars.updateLevelCountForNextSplit(0);
            return true;
        }
        else
        {
            return false;
        }
    }
}

split
{
    if ((int) current.mode == 3)
    {
        return vars.currentLevelChanged;
    }
    else
    {
        if (current.beatenLevels > old.beatenLevels && current.beatenLevels == vars.levelCountForNextSplit)
        {
            vars.levelCountForNextSplit = vars.updateLevelCountForNextSplit(current.beatenLevels);
            return true;
        }
        else
        {
            return false;
        }
    }
}

isLoading
{
    return true;
}
