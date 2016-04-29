library(RMySQL)
library(ggplot2)
library(data.table)
library(repmis)

##############################################################
##query pitchfx database, more info at baseballheatmaps.com ##
#############################################################

con<-dbConnect(MySQL(), user='root', password='', dbname='PitchFX', host='localhost')

#batting data query, this will get us the x,y coordinate which I adjust to center it around homeplate
batting_data<-dbGetQuery(con, 
"select 
game.date,ab.ab_id, ab.game_id, ab.inning, ab.num, ab.ball, ab.strike, ab.outs, ab.batter, ab.pitcher, ab.stand, (ab.hit_x-125) as hitx ,(ab.hit_y-200) as hity,ab.hit_type,
p.end_speed, p.start_speed, p.px, p.pz, p.pitch_type, p.type, p.des, concat(pl.first,' ', pl.last) as pitcher_name, concat(bl.first,' ', bl.last) as batter_name,
case when p.type in ('X','S') then 1 else 0 end as swung
from atbats ab
join pitches p on ab.ab_id = p.ab_id
join players bl on bl.eliasid = ab.batter
join players pl on pl.eliasid = ab.pitcher
join games game on game.game_id = ab.game_id
where p.type = 'X'
group by ab_id, game_id, inning, num, ball, strike, outs, batter, pitcher, stand, hit_x, hit_y, hit_type, end_speed, start_speed, px, pz, pitch_type
order by ab_id")

#data tables access data quicker
batting_data<- as.data.table(batting_data)
#create a column call count, which will give us the total AB by batter
batting_data[ , count := .N, by = list(batter_name)]
batting_data$hitx<-batting_data$hitx
#flip the x axis
batting_data$hity<-batting_data$hity*-1
#convert teh date to a date format in our table
batting_data$date<-as.Date(batting_data$date, "%Y-%m-%d")
bases<-data.frame(x=c(0,45/sqrt(2),0, -45/sqrt(2),0), y=c(0,45/sqrt(2),2*45/sqrt(2),45/sqrt(2),0))

#plot by pitch type (example for Miguel Cabrera)
p0<-ggplot(data=batting_data[batter_name %in% 'Miguel Cabrera'], aes(hitx,hity))
p1<-p0+geom_point(aes(colour=hit_type))
p1<-p0+geom_point(aes(color=hit_type))
p2<-p1+coord_equal()
p3<-p2+geom_path(aes(x=x,y=y), data=bases)
p4<-p3+guides(col=guide_legend(ncol=2))
p4+geom_segment(x=0,xend=300,y=0,yend=300)+geom_segment(x=0,xend=-300,y=0,yend=300)

#get AB where batters had more then 100 AB
batting_data_over_100 = batting_data[count > 100]
batting_data_over_100$date<-as.Date(batting_data$date, "%Y-%m-%d")
kmeans(batting_data_over_100)
#plot by pitch type
p0<-ggplot(data=batting_data_over_100[batter_name %in% 'Miguel Cabrera'], aes(hitx,hity))
p1<-p0+geom_point(aes(colour=hit_type))
#p1<-p0+geom_point(aes(shape=hit_type, colour=pitch_type,size=end_speed))
p1<-p0+geom_point(aes(color=hit_type))
p2<-p1+coord_equal()
p3<-p2+geom_path(aes(x=x,y=y), data=bases)
p4<-p3+guides(col=guide_legend(ncol=2))
p4+geom_segment(x=0,xend=300,y=0,yend=300)+geom_segment(x=0,xend=-300,y=0,yend=300)

#save our data locally as a csv
write.table(batting_data_over_100, file = paste("/Users/atroiano/desktop/SABR/Baseball_Data/", 'baseball.csv'), append = FALSE, quote = TRUE, sep = ",",
            eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = TRUE, qmethod = c("escape", "double"),
            fileEncoding = "")
#save the r data
saveRDS(batting_data_over_100,file="/Users/atroiano/desktop/SABR/Baseball_Data/batting_data_over_100")

#kmeans analysis
km_df<-data.table(na.omit(batting_data_over_100[batter_name %in% 'Miguel Cabrera']))
m<-as.matrix(cbind(km_df$hitx,mg_df$hity), ncol=2)
kmeans_baseball<-kmeans(m, 7)

#check out some cool data about your clusters
kmeans_baseball$withinss
kmeans_baseball$size

km_df[,cluster:=kmeans_baseball$cluster]
centers<-as.data.table(kmeans_baseball$centers)


#combine the clustered data to a main df adn plot it
p0<-ggplot(data=km_df, aes(hitx,hity))
p1<-p0+geom_point(aes(colour=cluster))+geom_point(data=centers, aes(x=as.numeric(V1),y=as.numeric(V2)))+geom_point(data=centers, aes(x=V1,y=V2), size=65, alpha=.3)
#p1<-p0+geom_point(aes(color=hit_type))
p2<-p1+coord_equal()
p3<-p2+geom_path(aes(x=x,y=y), data=bases)
p4<-p3+guides(col=guide_legend(ncol=2))
p4+geom_segment(x=0,xend=300,y=0,yend=300)+geom_segment(x=0,xend=-300,y=0,yend=300)