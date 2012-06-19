# An R script to generate graphs for Apache accesses. Histograms are drawn
# for the number per second, per 5 seconds, per 60 seconds, and per hour.

# R --no-save --args may31.csv 50 < rps_daygraph.r

args <- commandArgs(trailingOnly = TRUE);

# Set this to the path to your CSV generated by apache_rps.sh if you don't
# want to use the command line.
csv <- args[1]

# Set this to whatever your Apache MaxClients setting is set to. This just
# draws a line indicating where your server might be overloaded.
max_clients <- args[2];

# Return a moving average based off of the last n items.
ma <- function(x, n=5) {
  filter(x,rep(1/n,n), sides=1);
}

# Read in the CSV.
rps <- read.csv(file=csv, head=TRUE, sep=",");

# Generate a PNG image.
png(filename=paste(csv, ".png", sep=""), width=800, height=600, units="px", pointsize = 12);

# Initialize the plot.
plot(rps$requests_per_second, col="darkblue", xlab="Time", ylab="Requests", xaxt="n", type="h");

# Add a line for the 5 second average.
a <- ma(rps$requests_per_second, 5);
lines(a, col="green", type="h");

# Add a line for the 60 second average.
a <- ma(rps$requests_per_second, 60);
lines(a, col="red", type="h");

# Add a line for the 1 hour average.
a <- ma(rps$requests_per_second, 3600);
lines(a, col="yellow", type="h");

# Add a legend to clarify each line.
legend("topleft", c("Per second", "Per 5 seconds", "Per minute", "Per hour"), col=c("darkblue", "green", "red", "yellow"), lty=1, lwd=2);

# Determine our X axis ticks.
hours <- rps$date[seq(1, length(rps$date), 3600)];
axis(1, at=seq(0, 3600*23, 3600), hours);

# Draw a horizontal line showing where our maximum simulataneous capacity is.
abline(max_clients, 0);
dev.off();

