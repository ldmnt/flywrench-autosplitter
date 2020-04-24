Livesplit auto-splitting script for Flywrench 1.0.0.2 (Windows & Steam version).

### Current features
- In-game timer for full game runs, planet time trials and individual level time trials.
- Auto-start on the first level of pluto for full game runs and when starting a time trial.
- Auto-reset when clearing the save or when restarting time trials.
- Auto-splitting between planets and time. Based on the total amount of levels completed, so only works if the levels are completed in order.
- Auto-splitting between time trials. Not ideal yet.
	- splits only at the start of new levels
	- will split when browsing through the levels in the menu without having reset the timer

### To do
- Better auto-splitting for time trials.
	- split directly on level completion
	- do not split when browsing the menu
- Better auto-splitting for full game runs (based on individual level completion data for instance).


### Notes
- In-game timer is precise up to milliseconds even during full game runs.
- Time trial time is not affected by the bug where the in-game timer displays :0X times incorrectly.