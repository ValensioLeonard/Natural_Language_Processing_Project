library(shiny)
library(shinythemes)
library(DT)
library(base64enc)

img <- base64enc::dataURI(file="./formul.PNG",mime="image/png")

ui <- fluidPage(
    theme = shinytheme("flatly"),
navbarPage(
    "Predict Word R",
    tabPanel(
        "Application",
        titlePanel("Word Predict Using Backoff Model"),
        h3("Word Predict R is an application that guesses what you will write based on your previous writing."),
        h4("Try it out by writing a word or a sentence !"),
        br(),
        sidebarLayout(
            sidebarPanel(
                h3("What do you have in mind ?"),
                textInput("text","Input Text Here.", placeholder = "Hint: I am going"),
                sliderInput("numb", "How Many Predictions?", value = 5, min = 2, max = 15)
            ),
            mainPanel(
                h3("Your Sentence: "),
                textOutput("resul"),
                br(),
                h4("Recommendations:"),
                DT::dataTableOutput("recom")
            )
        )
    ),
    tabPanel(
        "About",
        verticalLayout(
            h3("Note of Explanation"),
            h4("The model I used in this application for predicting 
               the next word is called Backoff using 
               relative frequencies (Stupid Backkoff, Brants et al. 2007)."),
            img(src=img),
            h4("I used this model based on our task background given the large corpus 
               and diverse word to predict,
               and due to the simplicity of this model, which produced a result that
               is fairly accurate."),
            br(),
            br(),
            h4("Find more on my final report in this link below."),
            uiOutput("rep"),
            h4("You can also see the presentation of the overall project in this link below."),
            uiOutput("pres")
        )
        )
)
)