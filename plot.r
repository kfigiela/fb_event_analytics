#!/usr/bin/env Rscript
library(ggplot2)
library(reshape2)

setClass('myDate')
setAs("character","myDate", function(from) as.Date(from, format="%Y-%m-%d") )

args <- commandArgs(TRUE)
data <- read.delim(args, colClasses=c("myDate", "numeric", "numeric", "numeric", "factor", "factor"))

data$Total <- data$Attending + data$Maybe

df <- melt(data, id.vars=c("Date"),measure.vars =c("Attending", "Total"))

p <- ggplot(df, aes(x=df$Date, y=df$value)) 
p <- p + geom_point(aes(color=df$variable), size=3) 
p <- p + scale_x_date(name="") 
p <- p + scale_y_continuous(name="") 
p <- p + stat_smooth(method=loess, aes(group=df$variable, color=df$variable), se=FALSE, size=1) 
p <- p + theme(legend.title=element_blank()) 
p <- p + scale_colour_discrete( name="Experimental\nCondition", breaks=c("Attending", "Total"), labels=c("Attending", "Attending + Maybe")) 
p <- p + theme(legend.position="bottom")

ggsave(filename=paste(args,'.pdf',sep=""), plot=p)
# print(p)

