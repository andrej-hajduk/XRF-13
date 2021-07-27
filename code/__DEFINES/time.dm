#define MIDNIGHT_ROLLOVER 864000	//number of deciseconds in a day

#define JANUARY 1
#define FEBRUARY 2
#define MARCH 3
#define APRIL 4
#define MAY 5
#define JUNE 6
#define JULY 7
#define AUGUST 8
#define SEPTEMBER 9
#define OCTOBER 10
#define NOVEMBER 11
#define DECEMBER 12

//Select holiday names -- If you test for a holiday in the code, make the holiday's name a define and test for that instead
#define NEW_YEAR "New Year"
#define VALENTINES "Valentine's Day"
#define APRIL_FOOLS "April Fool's Day"
#define EASTER "Easter"
#define HALLOWEEN "Halloween"
#define CHRISTMAS "Christmas"
#define FESTIVE_SEASON "Festive Season"

/*

Days of the week to make it easier to reference them.

When using time2text(), please use "DDD" to find the weekday. Refrain from using "Day"

*/

#define MONDAY "Mon"
#define TUESDAY "Tue"
#define WEDNESDAY "Wed"
#define THURSDAY "Thu"
#define FRIDAY "Fri"
#define SATURDAY "Sat"
#define SUNDAY "Sun"

#define SECONDS *10

#define MINUTES SECONDS*60

#define HOURS MINUTES*60

#define DAYS HOURS*24

#define TICKS *world.tick_lag

#define MILLISECONDS * 0.10

#define DS2TICKS(DS) ((DS)/world.tick_lag)

#define TICKS2DS(T) ((T) TICKS)

#define MS2DS(T) ((T) MILLISECONDS)

#define DS2MS(T) ((T) * 100)

// SKYRAT EDIT ADDITION - EPOCH
#define EPOCH_DAY 86400
#define EPOCH_MONTH 2629743
#define EPOCH_YEAR 31556926

/proc/convert_from_epoch(epoch, epoch_relative = FALSE)
	var/years = epoch / EPOCH_YEAR
	years = round(years)
	epoch -= years * EPOCH_YEAR
	var/months = epoch / EPOCH_MONTH
	months = round(months)
	epoch -= months * EPOCH_MONTH
	var/days = epoch / EPOCH_DAY
	if(epoch_relative)
		return list(days, months, years)
	return list(days + 1, months + 1, years + 1970)

/proc/convert_to_epoch(day, month, year, epoch_relative = FALSE)
	if(!epoch_relative)
		year -= 1970
		month -= 1
		day -= 1
	year *= EPOCH_YEAR
	month *= EPOCH_MONTH
	day *= EPOCH_DAY
	return year + month + day
// SKYRAT ADDITION END
