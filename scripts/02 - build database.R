# ----------------------------------
# Build database
# ----------------------------------

# ONLY RUN ONCE: create a monetdb executable (.bat) file for the SJV travel data
batfile <-
	monetdb.server.setup(
		
		# set the path to the directory where the initialization batch file and all data will be stored
		database.directory = paste0( getwd() , "/MonetDB" ) ,
		# must be empty or not exist
		
		# find the main path to the monetdb installation program
		monetdb.program.path = "C:/Program Files/MonetDB/MonetDB5" ,
		
		# choose a database name
		dbname = "traveldata" ,
		
		# choose a database port
		# this port should not conflict with other monetdb databases
		# on your local computer.  two databases with the same port number
		# cannot be accessed at the same time
		dbport = 62000
	)

# ---------------------------------------------------
# Connect to database
# ---------------------------------------------------

# Your batfile is here
batfile

# In the future set a more precise path
# batfile <- "E:/github repos/travel-data-analysis/data/MonetDB/traveldata.bat"

pid <- monetdb.server.start(batfile)
dbname <- "traveldata"
dbport <- 62000
drv <- dbDriver("MonetDB")
monet.url <- paste0( "monetdb://localhost:" , dbport , "/" , dbname )
db <- dbConnect( drv , monet.url , "monetdb" , "monetdb" )

# ---------------------------------------------------
# Disconnect from database (store for future use)
# ---------------------------------------------------

# dbDisconnect(db)
# monetdb.server.stop(pid)

# ---------------------------------------------------
# Build the database
# ---------------------------------------------------

# set working directory to the location where you've downloaded the data files
# https://github.com/aakarner/travel-model-analyses/tree/master/data

monet.read.csv(db, "sample_trip table.csv", "trip_table", 5000, locked = TRUE)
monet.read.csv(db, "dist_skims_am.csv", "skims_am", 50^2, locked = TRUE)
monet.read.csv(db, "dist_skims_pm.csv", "skims_pm", 50^2, locked = TRUE)

# create a primary key on the trip table
dbSendUpdate(db, "alter table trip_table add column idkey int auto_increment")
dbSendUpdate(db, "alter table trip_table add primary key (idkey)")

# see a listing of all tables in the database
dbListTables(db)

# ---------------------------------------------------
# Match trips to skims
# ---------------------------------------------------

# create a table that will contain matched skims for all modes
dbSendUpdate(db, paste0(
	"create table matched_skims as
	select idkey, t1.orig, t1.dest, time, mode, sov, hov2, hov3, walk, bike 
	from trip_table t1
	inner join skims_am t2
	on t1.orig = t2.orig
	and t1.dest = t2.dest
	with no data"))


	
# insert skims into the 'matched' table dpeending on time period
for(i in c("am", "pm")) {
	
	times <- ifelse(i == "am", 1, 5)
	
	dbSendUpdate(db, paste0(
		"insert into matched_skims
		select idkey, t1.orig, t1.dest, time, mode, sov, hov2, hov3, walk, bike 
		from trip_table t1
		inner join skims_", i, " t2
		on t1.orig = t2.orig
		and t1.dest = t2.dest
		where time = ", times))
	
}

# create columns in the matched skim tables and trip tables to store the skim results
dbSendUpdate(db, paste0("alter table matched_skims add column matched float"))

dbSendUpdate(db, paste0("update matched_skims set matched = sov where mode = 'SOV'"))
dbSendUpdate(db, paste0("update matched_skims set matched = hov2 where mode = 'HOV2'"))
dbSendUpdate(db, paste0("update matched_skims set matched = hov3 where mode = 'HOV3'"))
dbSendUpdate(db, paste0("update matched_skims set matched = walk where mode = 'Walk'"))
dbSendUpdate(db, paste0("update matched_skims set matched = bike where mode = 'Bike'"))
	
# update trip table to contain a column representing the trip distance
dbSendUpdate(db, paste0("alter table trip_table add column dist float"))
	
dbSendUpdate(db, paste0(
	"update trip_table set dist = 
	(select matched_skims.matched
	from matched_skims
	where trip_table.idkey = matched_skims.idkey)"))

		
		

