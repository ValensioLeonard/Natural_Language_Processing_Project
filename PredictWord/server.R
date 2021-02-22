library(shiny)
library(dplyr)
library(stringr)
library(tm)
library(data.table)
library(DT)

result <- readRDS("./result.rds")

bigram <- result[[1]]
trigram <- result[[2]] 
fourgram <- result[[3]]
fivegram <- result[[4]]

rm(result)

url <- a("Final Report Data Science Capstone Leonard", href= "https://rpubs.com/valLeonard/649435")
url2 <- a("Presentation for Word Predict R by Leonard", href ="https://rpubs.com/valLeonard/649232")

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

guess <- function(text, howMany = 5){
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
            opt <- options(show.error.messages = FALSE)
            on.exit(options(opt))
            stop()
        }
        recom = recom %>% group_by(word) %>% 
                summarise(score = max(score), .groups = "drop") %>% 
                arrange(desc(score)) %>% as.data.frame(stringsAsFactors = FALSE)
        
        x = min(howMany, nrow(recom))
        print(recom[1:x, ])
        
}

shinyServer(function(input, output) {
   
   nx <- reactive({
        str_count(input$text, "\\w+")
   })
    
   rsl <- reactive({
       if(nx() == 0){
           print("Please enter a word or a sentence !") 
       }
       else {
           print(input$text)
       }
   })
   
   output$resul <- renderText({
       print(rsl())
       })
   
    output$recom <- DT::renderDataTable({
        if(nx() == 0){
           dt = data.table(word = c("the", "a", "in"), score = c("0,0,0"))
        }else{
            dt = guess(input$text, input$numb)
        }
        dt %>%
            datatable(., 
            options = list(
                pageLength = input$numb,
                dom = "t") 
            )%>%
            formatRound(., columns= "score", digits=3)
    })
    
    output$rep <- renderUI({
        tagList(url)
    })
    
    output$pres <- renderUI({
        tagList(url2)
    })
    
})
