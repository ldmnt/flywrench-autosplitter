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
}

gameTime
{
    if ((int) current.mode == 3)
    {
        print("timeTrialTime: " + current.timeTrialTime.ToString());
        return vars.toTimeSpan(current.timeTrialTime);
    }
    else
    {
        print("totalTime: " + current.totalTime.ToString());
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
        return old.totalTime <= 0 && current.totalTime > 0;
    }
}

reset
{
    if ((int) current.mode == 3)
    {
        return current.timeTrialTime < old.timeTrialTime;  // time trial time only resets when starting a new time trial
    }
    else
    {
        return old.totalTime > 0 && current.totalTime <= 0;
    }
}

isLoading
{
    return true;
}
