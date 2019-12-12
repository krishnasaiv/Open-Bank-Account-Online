rm(list=ls())
print("............ Running App ............")
if (!require("DT")) install.packages('DT')
if (!require("shiny")) install.packages('shiny')
if (!require("shinydashboard")) install.packages('shinydashboard')
if (!require("shinythemes")) install.packages("shinythemes")
# if (!require("reactlog")) install.packages("reactlog")
if (!require("shinyjs")) install.packages("shinyjs")
if (!require("shinyWidgets")) install.packages("shinyWidgets")
if (!require("formattable")) install.packages("formattable")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("readxl")) install.packages("readxl")
if (!require("dplyr")) install.packages("dplyr")
if (!require("DBI")) install.packages("DBI")
if (!require("devtools")) install.packages('devtools')
if (!require("sodium")) install.packages('sodium')
if (!require("shinyauthr")) devtools::install_github("paulc91/shinyauthr")
options(shiny.reactlog = TRUE)

##################################### Pre-Run #####################################
setwd("C:/Users/vootl/OneDrive/Documents/GitHub/Open-Bank-Account-Online/")
##################################### Shiny #####################################

ui <- dashboardPage(
  dashboardHeader(
    title = "Create account online",
    titleWidth = 280,
    tags$li(
      class = "dropdown", style = "padding: 8px;",
      # shinyauthr::logoutUI(id = "logout", label = "Logout", icon = icon("poweroff"))
    )
  ),
  dashboardSidebar(width = 280,
                   sidebarMenu(
                     # menuItem("Architecture", tabName = "architecture", icon = icon("sitemap")),
                     # menuItem("Home", tabName = "home", icon = icon("home")),
                     menuItem("Open Account", tabName = "new", icon = icon("dollar-sign")),
                     # menuItem("Search Models", tabName = "search", icon = icon("search")),
                     menuItem("About", tabName = "about", icon = icon("book"))
                   )
  ),
  dashboardBody(width = 100, height = 100,
                useShinyjs(),
                tags$div(id = "calculator_content",
                         tabItems( 
                           tabItem(tabName = "about"
                                   
                           ),
                           # ================== New Pricing ==================
                           tabItem(tabName = "new",
                                   navbarPage(title = "", id = "new",
                                              # ----------- Screen 1 
                                              tabPanel("User Info", value = "main",
                                                       box(width =12, 
                                                           collapsible = F,  solidHeader = T, title = "Demographics", status = "primary",
                                                           fluidRow(
                                                             column(2,selectInput(inputId = "salutation", label = "Salutation:", choices = c("Mr.", "Ms.", "Mrs."), selected = "Mr.", multiple = F) ),
                                                             column(3,textInput(inputId = "merchant_name", label = "Name:",placeholder = "Name" )),
                                                             column(2, tags$p(tags$strong("Business Account:"))),
                                                             column(1, switchInput( inputId = "Bsns_acnt", onStatus = "success", offStatus = 'danger', onLabel = "Yes", offLabel = "No", size = 'mini' , value = F))
                                                           ),
                                                           fluidRow(
                                                             column(3, selectInput(inputId = "gender", label = "Gender:", choices = c("M","F","Others","Choose not to say"))),
                                                             column(3, dateInput(inputId = "dob", label = "DOB:",autoclose = T,weekstart = 1))
                                                           ),
                                                           fluidRow(
                                                             column(3, textInput(inputId = "email",label = "Email ID:", placeholder = "user@domain.com")),
                                                             column(3, textInput(inputId = "phno",label = "Mobile Num:", placeholder = "+CC XXXX-XXXX-XX"))
                                                           ),
                                                           fluidRow(
                                                             column(3, selectInput(inputId = "idtype",label = "ID Type :", choices = c("SSN", "Driver's Licence", "Voter ID", "Others"))),
                                                             column(3, textInput(inputId = "idnum",label = "Id Num:", placeholder = "XXXX XXXX XXXX")),
                                                             column(3, fileInput(inputId = "idfile", label = "Upload Scanned ID:"))
                                                           )
                                                       ),
                                                       box(width =12,
                                                           collapsible = F,  solidHeader = T, title = "Merchant Pricing Selection", status = "primary",
                                                           fluidRow(
                                                             column(5,prettyRadioButtons(shape = "round",  animation = 'jelly',inputId = "pricing_strategy", label = "Pricing Strategy:", choices = c("Standard", "Custom"), selected = "Standard", inline = T)),
                                                             column(5,prettyRadioButtons(shape = "round",  animation = 'jelly',inputId = "type_of_acnt", label = "Account Type:", choices = c("Savings" ,"Salary", "Current", "Credit", "Pension", "Demat Only"), selected = "Savings", inline = T))
                                                           ),
                                                           fluidRow(
                                                             column(10, 
                                                                    tags$strong(tags$u(tags$p("Note:"))),
                                                                    tags$p("* To choose a default avialable account type, select 'Standard' option."),
                                                                    tags$p("* To tailor your banking experience to suit your needs, select the 'Custom' option."))
                                                           )
                                                       ),
                                                       fluidRow(column(11), column(1, actionButton(inputId = "nxt_main", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "Standard pricing", value = "standard_main",
                                                       box(width=12,
                                                           collapsible = F, solidHeader = T, title = "Merchant Demographics", status = "primary",
                                                           fluidRow(
                                                             column(3, textInput(inputId = "std_name_on_card", label = "Name on the Card:", placeholder = "Name to Display"))
                                                           ),
                                                           fluidRow(
                                                             column(3, numericInput(inputId = "std_salary", label = "Annual Income:", value = 50000,min = 25000, step = 1000))
                                                           ),
                                                           fluidRow(
                                                             column(6, checkboxGroupInput(inputId = "std_category", label = "Category", inline = T, choices = c("Premium cards", "Featured Cards", "Co Branded Cards", "Other Cards"))),
                                                             column(6, checkboxGroupInput(inputId = "std_reward_type", label = "Rewards Type", inline = T, choices = c("Travel", "Movie", "Fuel", "Shopping")))
                                                           ),
                                                           
                                                           fluidRow(
                                                             column(12, 
                                                                    radioGroupButtons(inputId = "std_card_type", label = "Choose a card:", 
                                                                                      choices = c("Standard", "Rewards","League Platinum", "Royal signature", "Corporate Platinum", "Corporate Signature", "Elite Club", "Elite Planitum", "Elite Signature"),
                                                                                      selected = "Standard", individual = T, status = "primary", checkIcon = list(yes = icon("ok", lib = "glyphicon"))
                                                                    )
                                                             )
                                                           )
                                                       ),
                                                       fluidRow(column(1, actionButton(inputId = "prev_standard_main", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_standard_main", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "Custom Pricing", value = "cstm_main",
                                                       
                                                       box(width = 12,
                                                           collapsible = F,  solidHeader = T, title = "Methods of Operation", status = "primary", #collapsed = F, 
                                                           prettyCheckboxGroup(status = 'primary', inputId = "mop", label = NULL, 
                                                                               choices = c("Credit", "Debit", "Electronic Check (ECP)", "UPI", "Demat", "Forex"), inline = T)
                                                       ),
                                                       box(width = 12,
                                                           collapsible = F,  solidHeader = T, title = "Additional Products & Capabilities", status = "primary", #collapsed = F, 
                                                           prettyCheckboxGroup(status = 'primary',inputId = "processing_options", label = "Processing Options:", 
                                                                               choices = c(
                                                                                 'Smart Insights' = 'si', 'Fraud Filter' = 'ff', 'Fraud Insurance' = 'fi',
                                                                                 'Auto Scale Limit' = 'asl', 'Pinless Credit Payment' = 'pcp', 'Lounge Access' = 'la', 
                                                                                 'Pinless Debit Payment' = 'pdp', 'Photo Debit Card' = 'pdc', 'EMI on Debit' = 'eod',
                                                                                 'ECP Verification' = 'ecp',
                                                                                 'Portfolio Assistant' = 'pa', 'Instant Payment to World Markets' = 'ipwm',
                                                                                 'Multi-Currency Acceptance' = 'mc'  
                                                                               ),  selected = character(0), inline = T),
                                                       ),
                                                       fluidRow(column(1, actionButton(inputId = "prev_cstm_main", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_cstm_main", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "Credit", value = "credit",
                                                       box(id = "credit_debit", width = 12,
                                                           collapsible = T, collapsed = F,  solidHeader = T, title = "Credit Card Information", status = "primary",
                                                           fluidRow(
                                                             column(2, tags$p(tags$strong("Already have an acoount with us ?"))),
                                                             column(1, switchInput( inputId = "has_accnt", onStatus = "success", offStatus = 'danger', onLabel = "Yes", offLabel = "No", size = 'mini' , value = F)),
                                                             column(3, textInput(inputId = "accnt_num", label = "Account Number:", placeholder = "XXXX XXXX XXXX"))
                                                             
                                                           ),
                                                           fluidRow(
                                                             column(3, textInput(inputId = "cre_name_on_card", label = "Name on the Card:", placeholder = "Name to Display"))
                                                           ),
                                                           fluidRow(
                                                             column(3, numericInput(inputId = "salary", label = "Annual Income:", value = 50000,min = 25000, step = 1000))
                                                           ),
                                                           fluidRow(
                                                             column(6, checkboxGroupInput(inputId = "cre_category", label = "Category", inline = T, choices = c("Premium cards", "Featured Cards", "Co Branded Cards", "Other Cards"))),
                                                             column(6, checkboxGroupInput(inputId = "cre_reward_type", label = "Rewards Type", inline = T, choices = c("Travel", "Movie", "Fuel", "Shopping")))
                                                           ),
                                                           
                                                           fluidRow(
                                                             column(12, 
                                                                    radioGroupButtons(inputId = "cre_card_type", label = "Choose a card:", 
                                                                                      choices = c("Standard", "Rewards","League Platinum", "Royal signature", "Corporate Platinum", "Corporate Signature", "Elite Club", "Elite Planitum", "Elite Signature"),
                                                                                      selected = "Standard", individual = T, status = "primary", checkIcon = list(yes = icon("ok", lib = "glyphicon"))
                                                                    )
                                                             )
                                                           )
                                                       ),
                                                       
                                                       tags$div(id = "credit_ap", 
                                                                box( width = 12,
                                                                     collapsible = T, collapsed = F,  solidHeader = T, title = "Credit Card Additional Products Info", status = "primary", 
                                                                     fluidRow(column(3, selectInput(inputId = "ap_cre_auto_scale", label = "Auto Scale Limit:", choices = c("x1", "x2", "x3", "x4", "x5"), selected = "x1"))),
                                                                     fluidRow(column(3, numericInput(inputId = "ap_cre_pinless_credit", label = "Pinless Credit Limit:",value = 5000, min = 2000, step = 1000))),
                                                                     fluidRow(column(3, selectInput(inputId = "ap_cre_lounge_access", label = "Lounge Access:", choices = c("Standard", "Premium", "Business"), selected = "x1"))),
                                                                     
                                                                )
                                                       ),
                                                       
                                                       
                                                       fluidRow(column(1, actionButton(inputId = "prev_credit", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_credit", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "Debit", value = "debit", 
                                                       box( width = 12,
                                                            collapsible = T, collapsed = F,  solidHeader = T, title = "Debit Card Info", status = "primary",
                                                            fluidRow(
                                                              column(3, textInput(inputId = "de_name_on_card", label = "Name on the Card:", placeholder = "Name to Display"))
                                                            ),
                                                            fluidRow(
                                                              column(6, checkboxGroupInput(inputId = "dre_category", label = "Category", inline = T, choices = c("Premium cards", "Featured Cards", "Co Branded Cards", "Other Cards"))),
                                                              column(6, checkboxGroupInput(inputId = "dre_reward_type", label = "Rewards Type", inline = T, choices = c("Travel", "Movie", "Fuel", "Shopping")))
                                                            ),
                                                            
                                                            fluidRow(
                                                              column(12, 
                                                                     radioGroupButtons(inputId = "dre_card_type", label = "Choose a card:", 
                                                                                       choices = c("Standard", "Rewards","League Platinum", "Royal signature", "Corporate Platinum", "Corporate Signature", "Elite Club", "Elite Planitum", "Elite Signature"),
                                                                                       selected = "Standard", individual = T, status = "primary", checkIcon = list(yes = icon("ok", lib = "glyphicon"))
                                                                     )
                                                              )
                                                            )
                                                       ),
                                                       
                                                       tags$div(id = "debit_ap", 
                                                                box( width = 12,
                                                                     collapsible = T, collapsed = F,  solidHeader = T, title = "Debit Card Additional Products Info", status = "primary",
                                                                     fluidRow(column(3, numericInput(inputId = "ap_de_pinless", label = "Pinless Debit Limit:",value = 5000, min = 2000, step = 1000))),
                                                                     fluidRow(column(3, fileInput(inputId = "ap_de_photo", label = "Photo on Debit Card:"))),
                                                                     fluidRow(column(3, numericInput(inputId = "ap_de_emi_debit", label = "EMI on Debit:",value = 5000, min = 2000, step = 1000))),
                                                                     
                                                                )
                                                       ),
                                                       fluidRow(column(1, actionButton(inputId = "next_debit", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_cstm_cre_deb_pri", label = "Next", icon = icon("arrow-right"))))
                                              ), 
                                              tabPanel(title = "Others", value = "others",
                                                       
                                                       tags$div(id="ecp",
                                                                box(width = 12,
                                                                    collapsible = T, collapsed = F,  solidHeader = T, title = "Check processing", status = "primary",
                                                                    fluidRow(
                                                                      column(2, tags$p(tags$strong("Send funds by Electronic Checks ?"))),
                                                                      column(1, switchInput( inputId = "ec_send", onStatus = "success", offStatus = 'danger', onLabel = "Yes", offLabel = "No", size = 'mini' , value = F))
                                                                    ),
                                                                    fluidRow(
                                                                      column(2, tags$p(tags$strong("Receive funds by Electronic Checks ?"))),
                                                                      column(1, switchInput( inputId = "ec_receive", onStatus = "success", offStatus = 'danger', onLabel = "Yes", offLabel = "No", size = 'mini' , value = F))
                                                                    )
                                                                )
                                                       ),
                                                       
                                                       tags$div(id="forex", 
                                                                box( width = 12,
                                                                     collapsible = T, collapsed = F,  solidHeader = T, title = "Foreign Exchange Information", status = "primary",
                                                                     fluidRow(column(12, radioGroupButtons(inputId = "", label = "Select Currencies", choices = c("USD", "Euro", "Pound Sterling", "SGD", "UAE Dirham", "CAD", "Hong Kong Dollar", "Japan - Yen", "China - Yuan"), selected = "USD", status = 'primary', individual = T))),
                                                                     fluidRow(column(3, tags$p(tags$strong("Want to exchange in other currencies ?"))),
                                                                              column(1, switchInput( inputId = "forex_others", onStatus = "success", offStatus = 'danger', onLabel = "Yes", offLabel = "No", size = 'mini' , value = F)),
                                                                              column(6, tags$p("We will get in touch with you about exclusive pricing."))
                                                                     ),
                                                                     
                                                                     
                                                                )
                                                       ),
                                                       tags$div(id = "others_ap", 
                                                                box( width = 12,
                                                                     collapsible = T, collapsed = F,  solidHeader = T, title = "Other Additional Products Info", status = "primary",
                                                                     fluidRow(column(3, tags$div(id= "ecp_ap", tags$strong(tags$u(tags$p("ECP:")))))),
                                                                     fluidRow(
                                                                       column(3, tags$div(id = "ec_receive_flag_head", tags$p(tags$strong("Enable EC Validation for incoming checks ?")))),
                                                                       column(1,  tags$div(id = "ec_receive_flag_switch", switchInput( inputId = "ec_receive_flag_switch_", onStatus = "success", offStatus = 'danger', onLabel = "Yes", offLabel = "No", size = 'mini' , value = F)))
                                                                     ),
                                                                     fluidRow(column(3, tags$div(id= "demat_ap", tags$strong(tags$u(tags$p("Demat:")))))),
                                                                     fluidRow(
                                                                       column(2, tags$div(id = "portfoli_smart_summary_head", tags$p(tags$strong("Portfolio Summary ?")))),
                                                                       column(1,  tags$div(id = "portfoli_smart_summary_switch", switchInput( inputId = "portfoli_smart_summary_switch_", onStatus = "success", offStatus = 'danger', onLabel = "Yes", offLabel = "No", size = 'mini' , value = F))),
                                                                       column(2, tags$div(id = "portfoli_forecast_head", tags$p(tags$strong("Portfolio Forecast ?")))),
                                                                       column(1,  tags$div(id = "portfoli_forecast_switch", switchInput( inputId = "portfoli_forecast_switch_", onStatus = "success", offStatus = 'danger', onLabel = "Yes", offLabel = "No", size = 'mini' , value = F)))
                                                                       
                                                                     ),
                                                                     fluidRow(column(3, tags$div(id= "forex_ap", tags$strong(tags$u(tags$p("Forex:")))))),
                                                                     fluidRow(
                                                                       column(2, tags$div(id = "instant_wire_head", tags$p(tags$strong("Instant Wire Transfer ?")))),
                                                                       column(1,  tags$div(id = "instant_wire_switch", switchInput( inputId = "instant_wire_switch_", onStatus = "success", offStatus = 'danger', onLabel = "Yes", offLabel = "No", size = 'mini' , value = F)))
                                                                     )
                                                                )
                                                       ),
                                                       fluidRow(column(1, actionButton(inputId = "prev_ecp_upi", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_ecp_upi", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "Summary", value = "summary",
                                                       fluidPage(align="center",column(8, tags$h1("Congratulations! You have succesfully completed filling the form."))),
                                                       tags$br(), tags$br(), tags$br(), tags$br(),
                                                       fluidPage(align="center",
                                                                 fluidRow(tags$u(tags$strong("What's next:"))),
                                                                 fluidRow(tags$p("We have received your preferences, we will verify your details & notify you when the account is succesfully opened.")),
                                                                 fluidRow(column(1, actionButton(inputId = "prev_summary", label = "Prev", icon = icon("arrow-left")))
                                                                 )
                                                       )
                                              )
                                   )
                           )
                         )
                )
  )
  
)
server <- function(input, output, session) {
  # ==========================================================================================
  #                                       Login
  #==========================================================================================
  
  # credentials <- callModule(shinyauthr::login, 
  #                           "login", 
  #                           data = user_base,
  #                           user_col = UserName,
  #                           pwd_col = Password_HASH,
  #                           sodium_hashed = TRUE,
  #                           log_out = reactive(logout_init())
  # )
  # 
  # logout_init <- callModule(shinyauthr::logout, "logout", reactive(credentials()$user_auth))
  # 
  # observe({
  #   if(credentials()$user_auth) {
  #     shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
  #   } else {
  #     shinyjs::addClass(selector = "body", class = "sidebar-collapse")
  #   }
  # }, priority = 10)
  # 
  # user_info <- reactive({credentials()$info})
  # 
  # user_data <- reactive({
  #   req(credentials()$user_auth)
  #   
  #   if (user_info()$Permissions == "admin") {
  #     dplyr::starwars[,1:10]
  #   } else if (user_info()$Permissions == "standard") {
  #     dplyr::storms[,1:11]
  #   }
  #   
  # })
  # 
  # output$welcome <- renderText({
  #   req(credentials()$user_auth)
  #   
  #   glue("{user_info()$Name}")
  # })
  # 
  # observe({
  #   if(credentials()$user_auth) {
  #     shinyjs::showElement(id = "calculator_content")
  #   } else {
  #     shinyjs::hideElement(id = "calculator_content")
  #   }
  # }, priority = 9)
  
  
  #==========================================================================================
  #                                       Debugging
  #==========================================================================================
  output$value <- renderPrint({ input$equipment_type })
  observeEvent({input$status}, {
    print("------- Status Report -------")
    print(bundled_pricing_options())
  })
  #==========================================================================================
  #                                       Session Global Variables
  #==========================================================================================
  load_pages <- function(lst, en){
    for(i in 1:length(en)){
      sel = paste0("#new li a[data-value='",lst[i], "']")
      if(en[i]){shinyjs::showElement(selector = sel, anim = T, animType = "slide")}
      else{shinyjs::hideElement(selector = sel, anim = T, animType = 'slide', time = 0.01 )}
    }
  }
  update_products <- function(l, e, s, sess){
    s <- e & (l %in% s)
    for(i in 1:length(l)){
      sel = paste0("#processing_options input[value='",l[i], "']")
      # print(sel)
      if(e[i]){shinyjs::enable(selector = sel)}
      else{shinyjs::disable(selector = sel)}
    }
    updatePrettyCheckboxGroup(session = sess, inputId = "processing_options", inline = T, 
                              # prettyOptions = list( status = 'primary'), 
                              selected = l[s])
  }
  tabs_list <- c("main", "standard_main","cstm_main", "credit" , "debit", "others", "summary")
  tabs_enabled <-  c(T,F,F,F,F,F,F)
  products_list <- c('si','ff','fi','asl','pcp', 'la', 'pdp','pdc','eod', 'ecp', 'pa', 'ipwm', 'mc')
  products_enabled <- c(T,T,T,F,F,F,F,F,F,F,F,F,F)
  products_selected <- c(F,F,F,F,F,F,F,F,F,F,F,F,F)
  
  #==========================================================================================
  #                                       Run on Startup
  #==========================================================================================
  
  cur_page <- reactive(input$new)
  load_pages(tabs_list, tabs_enabled)
  update_products(products_list, products_enabled, NULL, session)
  
  #==========================================================================================
  #                                       Page Navigation
  #==========================================================================================
  observeEvent( {
    input$next_credit | input$next_cstm_cre_deb_pri | input$next_ecp_upi | input$next_standard_main
  },
  {
    curpos <-  which(tabs_list == cur_page())
    enabled_page_indices <- which(tabs_enabled)[which(tabs_enabled) > curpos]
    if(length(enabled_page_indices) != 0){
      target_ind <- enabled_page_indices[1]
      target_page <- tabs_list[target_ind]
      # print(paste("Target Page Name:",target_page))
      updateTabsetPanel(session, "new", selected = target_page)
    }
  }
  )
  observeEvent( { 
    input$prev_credit | input$next_debit | input$prev_ecp_upi | input$prev_cstm_main | input$prev_standard_main |  input$prev_summary}, 
    {
      curpos <-  which(tabs_list == cur_page())
      enabled_page_indices <- which(tabs_enabled)[which(tabs_enabled) < curpos]
      if(length(enabled_page_indices) != 0){
        target_ind <- enabled_page_indices[length(enabled_page_indices)]
        target_page <- tabs_list[target_ind]
        # print(paste("Target Page Name:",target_page))
        updateTabsetPanel(session, "new", selected = target_page)
      }
    }
  )
  #==========================================================================================
  #                                       Reactives - Main Page
  #==========================================================================================
  observeEvent(input$pricing_strategy, {
    if(input$pricing_strategy == "Standard"){shinyjs::showElement(id = "type_of_acnt")}
    else{shinyjs::hideElement(id = "type_of_acnt")}
  })
  
  observeEvent(input$nxt_main, {
    # print("============ Status Report From Main ============")
    # print(tabs_enabled)
    if(input$pricing_strategy == "Standard"){
      tabs_enabled[-c(1,2)] <<- tabs_enabled[-c(1,2)] & F
      tabs_enabled[tabs_list == "standard_main"] <<- T
      tabs_enabled[tabs_list == "summary"] <<- T
      load_pages(tabs_list, tabs_enabled)
      updateTabsetPanel(session, "new", selected = "standard_main")
    }
    else{
      tabs_enabled[tabs_list == "standard_main"] <<- F
      tabs_enabled[tabs_list == "summary"] <<- F
      tabs_enabled[tabs_list == "cstm_main"] <<- T
      load_pages(tabs_list, tabs_enabled)
      shinyjs::disable(id = "next_cstm_main")
      updateTabsetPanel(session, "new", selected = "cstm_main")
    }
  })
  
  #==========================================================================================
  #                                       Reactives - Custom Main
  #==========================================================================================
  
  observeEvent(input$next_cstm_main, {
    ##### show all relevant elements & hide the rest
    tabs_enabled[-c(1,2,3)] <<- tabs_enabled[-c(1,2,3)] & F
    if("Credit" %in% input$mop ){
      tabs_enabled[tabs_list == "credit"] <<- T
    }
    if("Debit" %in% input$mop){
      tabs_enabled[tabs_list == "debit"] <<- T
    }
    if("Electronic Check (ECP)" %in% input$mop | "Demat" %in% input$mop | "Forex" %in% input$mop){
      tabs_enabled[tabs_list == "others"] <<- T
      
      if("Electronic Check (ECP)" %in% input$mop ){shinyjs::showElement(id = 'ecp')}
      else{shinyjs::hideElement(id = 'ecp')}
      
      if("Demat" %in% input$mop ){shinyjs::showElement(id = 'demat')}
      else{shinyjs::hideElement(id = 'demat')}
      
      if("Forex" %in% input$mop ){shinyjs::showElement(id = 'forex')}
      else{shinyjs::hideElement(id = 'forex')}
    }
    
    tabs_enabled[tabs_list == "summary"] <<- T
    
    # print(tabs_enabled)
    load_pages(tabs_list, tabs_enabled)
    #### Swith to the next tab
    curpos <-  which(tabs_list == cur_page())
    enabled_page_indices <- which(tabs_enabled)[which(tabs_enabled) > curpos]
    # print(paste("CurPos:",curpos, "; Enabled Pages", tabs_list[enabled_page_indices]))
    if(length(enabled_page_indices) != 0){
      target_ind <- enabled_page_indices[1]
      target_page <- tabs_list[target_ind]
      # print(paste("Target Page Name:",target_page))
      updateTabsetPanel(session, "new", selected = target_page)
    }
    
    ########### Additional Products - Box Elements
    if('asl' %in% input$processing_options | 'pcp' %in% input$processing_options | 'la' %in% input$processing_options){shinyjs::showElement(id = "credit_ap")}
    else{shinyjs::hideElement(id = "credit_ap")}
    
    if('pdp' %in% input$processing_options | 'pdc' %in% input$processing_options | 'eod' %in% input$processing_options){shinyjs::showElement(id = "debit_ap")}
    else{shinyjs::hideElement(id = "debit_ap")}
    
    if('pa' %in% input$processing_options | 'ipwm' %in% input$processing_options | 'mc' %in% input$processing_options | 'ecp' %in% input$processing_options){
      shinyjs::showElement(id = "others_ap")
      if('pa' %in% input$processing_options | 'ipwm' %in% input$processing_options){shinyjs::showElement(id = "demat_ap")}
      else{shinyjs::hideElement(id = "demat_ap")}
      
      if('mc' %in% input$processing_options){shinyjs::showElement(id = "forex_ap")}
      else{shinyjs::hideElement(id = "forex_ap")}
      
      if('ecp' %in% input$processing_options){shinyjs::showElement(id = "ecp_ap")}
      else{shinyjs::hideElement(id = "ecp_ap")}
      
    }
    else{
      shinyjs::hideElement(id = "others_ap")
    }
    
    
    ########### Additional Products - Individual Elements
    ### Credit
    if('asl' %in% input$processing_options){shinyjs::showElement(id = "ap_cre_auto_scale")}
    else{shinyjs::hideElement(id = "ap_cre_auto_scale")}
    
    if('pcp' %in% input$processing_options){shinyjs::showElement(id = "ap_cre_pinless_credit")}
    else{shinyjs::hideElement(id = "ap_cre_pinless_credit")}
    
    if('la' %in% input$processing_options){shinyjs::showElement(id = "ap_cre_lounge_access")}
    else{shinyjs::hideElement(id = "ap_cre_lounge_access")}
    
    
    ### Debit
    if('pdp' %in% input$processing_options){shinyjs::showElement(id = "ap_de_pinless")}
    else{shinyjs::hideElement(id = "ap_de_pinless")}
    
    if('pdc' %in% input$processing_options){shinyjs::showElement(id = "ap_de_photo")}
    else{shinyjs::hideElement(id = "ap_de_photo")}
    
    if('eod' %in% input$processing_options){shinyjs::showElement(id = "ap_de_emi_debit")}
    else{shinyjs::hideElement(id = "ap_de_emi_debit")}
    
    
    ### Others
    if('ecp' %in% input$processing_options){
      shinyjs::showElement(id = "ec_receive_flag_head")
      shinyjs::showElement(id = "ec_receive_flag_switch")
    }
    else{
      shinyjs::hideElement(id = "ec_receive_flag_head")
      shinyjs::hideElement(id = "ec_receive_flag_switch")
    }
    
    if('pa' %in% input$processing_options){
      shinyjs::showElement(id = "portfoli_smart_summary_head")
      shinyjs::showElement(id = "portfoli_smart_summary_switch")
      shinyjs::showElement(id = "portfoli_forecast_head")
      shinyjs::showElement(id = "portfoli_forecast_switch")
    }
    else{
      shinyjs::hideElement(id = "portfoli_smart_summary_head")
      shinyjs::hideElement(id = "portfoli_smart_summary_switch")
      shinyjs::hideElement(id = "portfoli_forecast_head")
      shinyjs::hideElement(id = "portfoli_forecast_switch")
    }
    
    
    if('ipwm' %in% input$processing_options | 'mc' %in% input$processing_options ){
      shinyjs::showElement(id = "instant_wire_head")
      shinyjs::showElement(id = "instant_wire_switch")
    }
    else{
      shinyjs::hideElement(id = "instant_wire_head")
      shinyjs::hideElement(id = "instant_wire_switch")
    }
    
    
    
    
  })
  
  ########### Enable/Disable Additional Products in products page
  
  observeEvent({input$mop}, {
    if( length(input$mop) == 0){shinyjs::disable(id = 'next_cstm_main')}
    else{shinyjs::enable(id = 'next_cstm_main')}
    
    if("Credit" %in% input$mop){
      products_enabled[products_list %in% c('asl', 'pcp', 'la')]  <<- T
    }else{
      products_enabled[products_list %in% c('asl', 'pcp', 'la')]  <<- F
    }
    if("Debit" %in% input$mop ){products_enabled[products_list  %in% c('pdp', 'pdc', 'eod')]  <<- T}
    else{products_enabled[products_list  %in% c('pdp', 'pdc', 'eod')]  <<- F}
    
    if("Electronic Check (ECP)" %in% input$mop){products_enabled[products_list  == 'ecp']  <<- T}
    else{products_enabled[products_list  == 'ecp']  <<- F}
    
    if("Demat" %in% input$mop ){products_enabled[products_list %in% c('pa', 'ipwm')]  <<- T}
    else{products_enabled[products_list %in% c('pa', 'ipwm')]  <<- F}
    
    if("Forex" %in% input$mop ){products_enabled[products_list %in% c('mc')]  <<- T}
    else{products_enabled[products_list %in% c('mc')]  <<- F}
    
    update_products(l = products_list, e = products_enabled, s = input$processing_options, sess = session)
    
  }, ignoreNULL = FALSE)
  
  observeEvent(input$has_accnt, {
    if(input$has_accnt){shinyjs::showElement(id = 'accnt_num', anim = T,  animType = 'slide')}
    else{shinyjs::hideElement(id = 'accnt_num', anim = T,  animType = 'slide')}
    
  })
  
  
}
shinyApp(ui = ui, server = server)
