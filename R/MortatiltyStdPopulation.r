#!/usr/bin/env Rscript
#
#
# Script:  MortalityStdPopulation.r
#
# Stand: 2021-01-29
#
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

options(OutDec=',')

MyScriptName <- "MortalityStdPopulation"

require(data.table)
library(REST)
library(grid)
library(gridExtra)
library(gtable)
library(lubridate)
library(ggplot2)
library(viridis)
library(hrbrthemes)

setwd("~/git/R/RKI-Dashboard/R/")

source("lib/copyright.r")
source("lib/sql.r")

today <- Sys.Date()
heute <- format(today, "%Y%m%d")


data <- RunSQL('call MortalityBundeslandStdBev();')

data[,3] <- round(data[,3],2)

print(data)

png( paste( 
      "output/"
    ,  heute
    , "Mortality-1.png"
    , sep = ""
)
, width = 1920
, height = 1080
)

vp <- viewport(
      x = 0.5
    , y = 0.5
    , width = 14
    , height = 10
    )

tt <- ttheme_default(
  base_size = 32
  , padding = unit(c(12,12), "mm")
  , core=list(
    fg_params=list( 
        hjust = 1
      , x = 0.99
    )
  )
)

table <- tableGrob(
  data
  , theme = tt
  , cols = c("Rang", "Bundesland", "Tote pro 100k" )
  , vp = vp
)

title <- textGrob('Totesfälle pro 100.000 Einwohner',gp=gpar(fontsize=50))
footnote <- textGrob(paste('Stand:', heute), x=0, hjust=0,
                     gp=gpar( fontface="italic"))

padding <- unit(0.5,"line")

table <- gtable_add_rows(table, 
                         heights = grobHeight(title) + padding,
                         pos = 0)
table <- gtable_add_rows(table, 
                         heights = grobHeight(footnote)+ padding)
table <- gtable_add_grob(table, list(title,footnote),
                         t=c(1, nrow(table)), l=c(1,2), 
                         r=ncol(table))

grid.draw(table)

dev.off()

p <- ggplot(data, aes(fill=Bundesland, y=Mortality, x=Bundesland)) +
  geom_bar(position="dodge", stat="identity") +
  geom_text(aes(label=paste(Mortality, ' (', Rang, ')', sep='')), size=2, position=position_dodge(width=0.9), vjust=-0.25) +
  scale_fill_viridis(discrete = T) +
  ggtitle("Corona: Standardisierte Todesfälle pro 100.000 Einwohner") +
  theme_ipsum() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  xlab("Bundesländer") +
  ylab("Insgesamt gemeldete Todesfälle pro 100.000")

gg <- grid.arrange(p, ncol=1)

plot(gg)

ggsave( plot = gg, 
        file = paste( 
          "output/"
          ,  heute
          , "Mortality-2.png"
          , sep = ""
        )
       , type = "cairo-png",  bg = "white"
       , width = 29.7, height = 21, units = "cm", dpi = 150)
