library(quanteda)
library(dplyr)
library(stringr)
library(tm)
library(data.table)

break_text <- function(text){
   text <- text %>% tolower() %>% stripWhitespace() %>% removePunctuation()
   n <- str_count(text, "\\w+")
   
   if(n > 3){
      five <- text %>% word(., n-3, n, sep = " ") %>% paste0("^", ., "$") 
   }else(five = NA)
   if(n > 2){
      four <- text %>% word(., n-2, n, sep = " ") %>% paste0("^", . , "$")
   }else(four = NA)
   if(n > 1){
      three <- text %>% word(., n-1, n, sep = " ") %>% paste0("^", ., "$")
   }else(three = NA)
   two <- text %>% word(., n, n, sep = " ") %>% paste0("^", ., "$")
   
   result <- list(five, four, three, two)
   return(result)
}

guess <- function(text, howMany = 3){
   n <- str_count(text, "\\w+")
   
   result <- break_text(text)
   five <- result[[1]]
   four <- result[[2]]
   three <- result[[3]]
   two <- result[[4]]
   
   recom <- data.table()
   
   if(!is.na(five) & n > 3){
      ind <- like(pattern = five, fivegram$history)
      matchSum <- sum(fivegram$freq[ind])
      recom <- rbind(recom, data.table(word = fivegram$word[ind], 
                          score = (fivegram$freq[ind]/matchSum)))
      
   }
   
   if(!is.na(four) & n > 2){
      ind <- like(pattern = four, fourgram$history)
      matchSum <- sum(fourgram$freq[ind])
      recom <- rbind(recom, data.table(word = fourgram$word[ind], 
                          score = (0.4 * fourgram$freq[ind]/matchSum)))
      
   }
   
   if(!is.na(three) & n > 1 ){
      ind <- like(pattern = three, trigram$history)
      matchSum <- sum(trigram$freq[ind])
      recom <- rbind(recom, data.table(word = trigram$word[ind], 
                          score = (0.4* 0.4 * trigram$freq[ind]/matchSum)))
      
   }
   
   if(exists("two")){
      ind <- like(pattern = two, bigram$history)
      matchSum <- sum(bigram$freq[ind])
      recom <- rbind(recom, data.table(word = bigram$word[ind], 
                          score = (0.4 * 0.4 * 0.4 * bigram$freq[ind]/matchSum)))
      
   }
   if(is.na(recom[1,1])){
     stop("No Match")
   }
   recom = recom %>% group_by(word) %>% 
      summarise(score = max(score), .groups = "drop") %>% 
      arrange(desc(score)) %>% as.data.frame(stringsAsFactors = FALSE)
   
   x = min(howMany, nrow(recom))
   print(recom[1:x, ])
   
}

generate_ngram_Freq <- function(data){
   
bigram <- data %>% tokens(what= "word") %>%
   tokens_ngrams(n = 2, concatenator = " ") %>% 
   unlist %>% table() %>% sort(decreasing = T) %>% 
   as.data.table() %>% setNames(., c("word","freq")) %>% 
   .[freq > 4] %>% mutate(., history = word_History(., 2), word = word_Final(., 2))
print("25% complete")

trigram<- data %>% tokens(what= "word") %>%
   tokens_ngrams(n = 3, concatenator = " ") %>% 
   unlist %>% table() %>% sort(decreasing = T) %>% 
   as.data.table() %>% setNames(., c("word","freq")) %>% 
   .[freq > 4] %>% mutate(., history = word_History(., 3), word = word_Final(., 3))
print("50% complete")

fourgram <- data %>% tokens(what= "word") %>%
   tokens_ngrams(n = 4, concatenator = " ") %>% 
   unlist %>% table() %>% sort(decreasing = T) %>% 
   as.data.table() %>% setNames(., c("word","freq")) %>% 
   .[freq > 1] %>% mutate(., history = word_History(., 4), word = word_Final(., 4))
print("75% complete")

fivegram <- data %>% tokens(what= "word") %>%
   tokens_ngrams(n = 5, concatenator = " ") %>% 
   unlist %>% table() %>% sort(decreasing = T) %>% 
   as.data.table() %>% setNames(., c("word","freq")) %>% 
   .[freq > 1] %>% mutate(., history = word_History(., 5), word = word_Final(., 5))
print("completed")

result <- list(
   bigram, trigram, fourgram, fivegram
)
return(result)
}

word_Final <- function(data, ng){
   fin <- as.character()
   for(i in 1:nrow(data)){
      fin <- c(fin, word(data[i,1], ng, ng, sep = " "))
   }
   return(fin)
}

word_History <- function(data, ng){
   his <- as.character()
   for (i in 1: nrow(data)) {
      his <- c(his, word(data[i,1], 1, ng-1, sep = " "))
   }
   return(his)
}


cleanUp_Profan <- function(){
bigram <- result[[1]]
trigram <- result[[2]] 
fourgram <- result[[3]]
fivegram <- result[[4]]

bigram = bigram[!bigram$word %in% profan, ]
bigram = bigram[!bigram$history %in% profan, ]
trigram = trigram[!trigram$word %in% profan, ]
trigram = trigram[!trigram$history %in% profan, ]
fourgram = fourgram[!fourgram$word %in% profan, ]
fourgram = fourgram[!fourgram$history %in% profan, ]
fivegram = fivegram[!fivegram$word %in% profan, ]
fivegram = fivegram[!fivegram$history %in% profan, ]
}

