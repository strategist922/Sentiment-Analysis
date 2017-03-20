library(twitteR)
library(curl)
library(tm)
library(ggplot2)

dict <- read.csv("F:/R/senti_analysis/superdic.csv",stringsAsFactors = F)


consumer_key <- "EJfvJef43wxK5SytXH9ugB1MP"
consumer_secret <- "2KxcMOsl6LEWD9H4tXSN3csWL9ndKKK39ibJiYol3BCOKodUWm"
access_token <- "807488357806678016-9gIqjHwDSsoNTwqDG9WN8UvoUTdgtaP"
access_secret <- "E3PcW7hmyvlNmRwk3ZaC4rE2R09YLaM1kw0AVZs9oP6R2"

setup_twitter_oauth(consumer_key,consumer_secret,access_token,access_secret)




sentiment <- function(word,tweets_num=500) {
  
  string <- paste0(word,"-filter:retweets")
  tweets <- searchTwitter(string,n=tweets_num, lang="en",resultType = "recent")
  tweetsdf <- twListToDF(tweets)
  tweetsdf <- data.frame(text=tweetsdf$text)
  
  tweetsdf$text <- gsub("@[[:alnum:]]+ *","",tweetsdf$text)
  tweetsdf$text <- gsub("http[[:alnum:][:punct:]]+ *","",tweetsdf$text)
  tweetsdf$text <- gsub("[^[:alpha:][:space:]]*","",tweetsdf$text)
  tweetsdf$text <- gsub("[[:punct:]]","",tweetsdf$text)
  tweetsdf$text <- gsub("\n","",tweetsdf$text)
  
  tweetsdf$text <- tolower(tweetsdf$text)
  
  
  sentiscores <- unlist(lapply(tweetsdf$text,function(x){
    
    
    sum(as.numeric(dict$Score[match(unlist(strsplit(x," ")),dict$Word)]),na.rm=T)
    
    }))
  
  
  sentiscores[is.na(sentiscores)] <- as.numeric(0)
  
  
  sentiscoresdf <- data.frame(Scores=sentiscores)
  sentiscoresdf$color <- ifelse(sentiscoresdf$Scores > 0,"positive",ifelse(sentiscoresdf$Scores == 0,"neutral","negative"))
  
  list(write.csv(cbind(tweetsdf,Scores=sentiscores),paste0("./Scores/",word,"scores.csv"),row.names = F),
            ggplot(data=sentiscoresdf,aes(x=Scores))+geom_bar(aes(fill=color))+
         ylab("No. Of Tweets")+xlab("Sentiment Score")+theme_minimal()+geom_text(stat="count",aes(label=..count..),vjust=-.5)
          +scale_x_continuous(breaks=c(-7:7))+scale_fill_manual(values = c(positive="steelblue",negative="firebrick1",neutral="yellowgreen")))
  
  
  
  
}



