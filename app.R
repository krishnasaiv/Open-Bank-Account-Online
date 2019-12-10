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
setwd("C:/Users/vootl/OneDrive/Documents/Me/Employee Onboarding")
InProgress <- read.csv(file = "./files/InProgress.csv", stringsAsFactors = F)
mcc <- read.csv(file = "./files/mcc_codes.csv", stringsAsFactors = F)
summ_table <- read.csv(file = "./files/summary.csv", stringsAsFactors = F)
colnames(summ_table) <- c("_", "in_Dollars", "in_Percentage", "Per_Tran")
# summ_table1 <-  read_excel("summary.xlsx")
# summ_table1 <- cbind( summ_table1, Type_ =  c("1", "1", "1", "2", "3", "1"))
# summ_table1$`NET REVENUE %` <- summ_table1$`NET REVENUE %` * 100
user_base <- read.csv(file = "./files/users.csv", header = T, stringsAsFactors = F)
user_base$Password_HASH <- sapply( user_base$Password, sodium::password_store) 
bundled_pricing_options <- read.csv("./files/bundled_pricing_option.csv", stringsAsFactors = F)


con <- dbConnect(RSQLite::SQLite(), ":memory:")
if(dbExistsTable(con, "InProgress")){dbRemoveTable(con, "InProgress")}; dbWriteTable(con, "InProgress", InProgress)
if(dbExistsTable(con, "mcc")){dbRemoveTable(con, "mcc")}; dbWriteTable(con, "mcc", mcc)
if(dbExistsTable(con, "summ_table")){dbRemoveTable(con, "summ_table")}; dbWriteTable(con, "summ_table", summ_table)
# if(dbExistsTable(con, "summ_table1")){dbRemoveTable(con, "summ_table1")}; dbWriteTable(con, "summ_table1", summ_table1)
if(dbExistsTable(con, "user_base")){dbRemoveTable(con, "user_base")}; dbWriteTable(con, "user_base", user_base)

if(dbExistsTable(con, "bundled_pricing_options")){dbRemoveTable(con, "bundled_pricing_options")}; dbWriteTable(con, "bundled_pricing_options", bundled_pricing_options)
rm(InProgress, mcc, summ_table, user_base, bundled_pricing_options)


# dbListTables(con)
InProgress <- dbReadTable(con, "InProgress")
mcc <- dbReadTable(con, "mcc")
summ_table <- dbReadTable(con, "summ_table")
# summ_table1 <- dbReadTable(con, "summ_table1")
user_base <- dbReadTable(con, "user_base")
bundled_pricing_options <- dbReadTable(con, "bundled_pricing_options")
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
                # fixedPage(width = 200, height = 300,
                useShinyjs(),
                # titlePanel("",windowTitle = "Universal Pricing Calculator"),
                # shinythemes::themeSelector(),
                # shinyauthr::loginUI("login"),
                tags$div(id = "calculator_content",
                         tabItems( 
                           tabItem(tabName = "about",
                                   fluidRow(
                                     column(12, tags$h3("Universal Calculator End to End Architecture"))),
                                   
                                   box(width = 12, height = 800, tags$ul(
                                     tags$li(tags$p("Create centralized, single-platform pricing tools, aligned against standard pricing. State of art User Interface (API) to enable quick processing of deals")),
                                     tags$li(tags$p("Improve Deal Economics - Hurdle rates by industrial vertical; establish price floors at product level and subsidy considerations based on total firmwide relationship")),
                                     tags$li(tags$p("Establish tracking of price performance for both net-new and existing clients against expected value. Ensuring pricing adherence and price realization"))
                                   ),
                                   plotOutput(outputId =  "architecture_image")
                                   )
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
                                                             column(3,textInput(inputId = "merchant_name", label = "Name:",placeholder = "Name" ))
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
                                                                    # tags$br(),
                                                                    tags$p("* To tailor your banking experience to suit your needs, select the 'Custom' option."))
                                                           )
                                                       ),
                                                       
                                                       fluidRow(column(11), column(1, actionButton(inputId = "nxt_main", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "Standard pricing", value = "standard_main",
                                                       box(width=12,
                                                           collapsible = F, solidHeader = T, title = "Merchant Demographics", status = "primary",
                                                           prettyRadioButtons(shape = "round",  animation = 'jelly',inputId = "primary_cust_type", label = "Primary Customer Type:", choices = c( "Consumers", "Other Businesses"),inline = T),
                                                           prettyRadioButtons(shape = "round",  animation = 'jelly',inputId = "foreign_issued_txns",   label = "Foreign Issued Transactions:", choices = c( "Few", "Many"),inline = T),
                                                           prettyRadioButtons(shape = "round",  animation = 'jelly',inputId = "equipment_type", label = "Equipment/POS Type:", choices = c( "Chase Mobile Checkout", "Chase Blue Terminal", "Virtual Terminal", "Authorize.Net"), 
                                                                              selected ="Chase Mobile Checkout",
                                                                              inline = T)
                                                           
                                                       ),
                                                       box(width=12, 
                                                           collapsible = F, solidHeader = T, title = "Standard Pricing Options", status = "primary",
                                                           radioGroupButtons(inputId = "bundled_pricing_options", label = "Bundled Pricing Options:", choices = c( "Swiped: 2.60% + $0.10,<br/>Keyed: 3.50% + $0.10", "2.90% +<br/> $0.25", "3.50% +<br/> $0.10"),
                                                                             status = "primary", checkIcon = list(yes = icon("ok", lib = "glyphicon"))),
                                                           radioGroupButtons(inputId = "interchange_pass_thru_pricing_options",label = "Interchange Pass Thru Pricing Options:",choices = c("0.35% + $0.10,<br/>$9.95 Monthly Fee", "0.55% + $0.10,<br/>$0 Monthly Fee"),
                                                                             status = "primary", checkIcon = list(yes = icon("ok", lib = "glyphicon")), selected = character(0))
                                                       ),
                                                       fluidRow(column(1, actionButton(inputId = "prev_standard_main", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_standard_main", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "Custom Pricing", value = "cstm_main",
                                                       
                                                       box(width = 12,
                                                           collapsible = F,  solidHeader = T, title = "Methods of Payment", status = "primary", #collapsed = F, 
                                                           prettyCheckboxGroup(status = 'primary', inputId = "mop", label = NULL, 
                                                                               choices = c("Credit", "PIN-Based Debit", "PINless Debit", "Electronic Check (ECP)", "ChaseNet/ ChasePay"), inline = T)
                                                       ),
                                                       box(width = 12,
                                                           collapsible = F,  solidHeader = T, title = "Additional Products & Capabilities", status = "primary", #collapsed = F, 
                                                           prettyCheckboxGroup(status = 'primary',inputId = "processing_options", label = "Processing Options:", 
                                                                               choices = c('Account Updater' = 'au', 'ChaseNet/Chase Pay' = 'cncp', 'Purchasing Card Lvl 3' = 'pcl3',
                                                                                           'Fraud Filter' = 'ff', 'PINless Bin Management' = 'plbm', 'Dynamic Debit Routing' = 'ddr', 
                                                                                           'ECP Advanced Verification' = 'ecp', 'Multi-Currency' = 'mc'),  selected = character(0), inline = T),
                                                           prettyCheckboxGroup(status = 'primary', inputId = "connectivity_products", label = "Connectivity Products:", 
                                                                               choices = c('NetConnect', 'Orbital Gateway',  'Frame Relay'),  inline = T),
                                                           prettyCheckboxGroup(status = 'primary', inputId = "security_products", label = "Security Products:", 
                                                                               choices = c('Safetech Encryption', 'Safetech Tokenization',  'Safetech Fraud'),inline = T),
                                                           hidden(prettyCheckboxGroup(status = 'primary', inputId = "analytics_products", label = "Analytical Products:", 
                                                                                      choices = c("Fraud Advice Reporting"), inline = T))
                                                       ),
                                                       fluidRow(column(1, actionButton(inputId = "prev_cstm_main", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_cstm_main", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              # navbarMenu(title = "Credit & Debit", value = "cre_and_deb", 
                                              tabPanel(title = "Processing Information", value = "cstm_cre_deb_inf",
                                                       
                                                       box(id = "credit_debit", width = 12,
                                                           collapsible = T, collapsed = F,  solidHeader = T, title = "Credit & Debit Processing Information", status = "primary",
                                                           fluidRow(column(3, numericInput(inputId = "annual_gross_sales_vol", label = "Annual Gross Card Sales Volume ($)", value = 1000,min = 0, max = 1000000000000, step = 1000)),
                                                                    column(3, numericInput(inputId = "annual_gross_txns", label = "Annual Gross Card Sales Txns", value = 10000, min = 0, max = 1000000000, step = 1000))
                                                           ), br(), br(),
                                                           fluidRow(id = "amex", column(3,numericInput(inputId = "amex_percent", label = "AMEX % of Volume", value = 5,min = 0, max = 100, step = 1)),
                                                                    column(3,selectInput(inputId = "amex_processing_type", label = "AMEX Processing Type", choices = c("Conveyed"), selected = "Conveyed")),
                                                                    column(3, tags$strong("Amex Volume Share"),   textOutput(outputId = "amex_percent_vol") ) 
                                                           ),
                                                           fluidRow(id = "discover", column(3,numericInput(inputId = "discover_percent", label = "Discover % of Volume", value = 5,min = 0, max = 100, step = 1)),
                                                                    column(3,selectInput(inputId = "discover_processing_type", label = "Discover Processing Type", choices = c("Conveyed", "Settled"), selected = "Settled")),
                                                                    column(3,  tags$strong("Discover Volume Share"),textOutput(outputId = "discover_percent_vol"))
                                                           ),
                                                           fluidRow(id = "pin", column(3,numericInput(inputId = "pin_percent", label = "PIN-based Debit % of Volume", value = 5,min = 0, max = 100, step = 1)),
                                                                    column(3, tags$strong("PIN-based Debit Volume Share"), textOutput(outputId = "pin_percent_vol"))
                                                           ),
                                                           fluidRow(id = "pinless",column(3,numericInput(inputId = "pinless_percent", label = "PINless Debit % of Volume", value = 5,min = 0, max = 100, step = 1)),
                                                                    column(3,tags$strong("PINless Debit Volume Share"), textOutput(outputId = "pinless_percent_vol"))
                                                           ),
                                                           br(), br(),
                                                           fluidRow(column(3, selectInput(inputId = "dual_auth_network", label = "Dial Authorization Network", choices = c("None", "PNS", "FDR", "Vital - TSYS", "BuyPass"), selected = "None")),
                                                                    column(3, numericInput(inputId = "percent_dial_auth", label = "% Dial Authorizations", value = 0, min = 0, max = 100, step = 1))),
                                                           br(), br(),
                                                           fluidRow(column(3,numericInput(inputId = "auth2tran_ratio", label = "Auth-to-Tran Ratio (%)", value = 120, min = 100, max = 1000, step = 5)),
                                                                    column(3,numericInput(inputId = "return_ratio", label = "Return Ratio (%)", value = 2, min = 0, max = 100, step = 1)),
                                                                    column(3,numericInput(inputId = "chargeback_ratio", label = "Chargeback Ratio (%)", value = 0.05, min = 0, max = 100, step = 1)),
                                                                    column(3,numericInput(inputId = "voice_auth_ratio", label = "Voice Authorization Ratio (%)", value = 0.0005, min = 0, max = 100, step = 1)))
                                                       ),
                                                       fluidRow(column(1, actionButton(inputId = "prev_cstm_cre_deb_inf", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_cstm_cre_deb_inf", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "Processing Pricing", value = "cstm_cre_deb_pri", 
                                                       box( width = 12,
                                                            collapsible = T, collapsed = F,  solidHeader = T, title = "Credit & Debit Processing Pricing", status = "primary",
                                                            fluidRow( column(12, tags$a("Authorization & Deposit Pricing"))),
                                                            fluidRow(
                                                              column(3, disabled(numericInput(inputId = "auths", label = "Authorizations", value = 1000, min = 0, max = 1000000, step = 1000)),
                                                                     disabled(numericInput(inputId = "txns", label = "Transactions (S+R)", value = 1000, min = 0, max = 1000000, step = 1000)), 
                                                                     disabled(numericInput(inputId = "sales", label = "Net Sales $ (S-R)", value = 1000, min = 0, max = 1000000, step = 1000))), 
                                                              column(3, numericInput(inputId = "auth_fee", label = "Authorization Fee", value = 0.0425, min = 0, max = 1000000, step = 1000), 
                                                                     numericInput(inputId = "txn_fee", label = "Transaction Fee", value = 0.0550, min = 0, max = 1000000, step = 1000),
                                                                     numericInput(inputId = "discount_rate", label = "Discount Rate", value = 0, min = 0, max = 1000000, step = 1000))
                                                            ),
                                                            fluidRow( column(12, tags$a("Chargeback Pricing"))),
                                                            fluidRow(
                                                              column(3, disabled(numericInput(inputId = "chargebacks", label = "Chargebacks", value = 1000, min = 0, max = 1000000, step = 1000))), 
                                                              column(3, numericInput(inputId = "cback_fee", label = "Chargeback/Representment Fee", value = 2.5, min = 0, max = 1000000, step = 1000)), 
                                                              column(3, numericInput(inputId = "comp_fee", label = "Collection/Pre-Arb/Compliance Fee", value = 10, min = 0, max = 1000000, step = 1000)))
                                                            ,
                                                            fluidRow(id = "voice_auth_section", column(12, tags$a("Voice Authorization Pricing")),
                                                                     column(3, disabled(numericInput(inputId = "voice_authorizations", label = "Voice Authorizations", value = 1000, min = 0, max = 1000000, step = 1000))), 
                                                                     column(3, numericInput(inputId = "voice_auth_rev_fee", label = "Voice Authorization & Reversal Fee", value = 0.65, min = 0, max = 1000000, step = 1000), 
                                                                            numericInput(inputId = "voice_op_assist_fee", label = "Voice Operator Assist Fee", value = 1.75, min = 0, max = 1000000, step = 1000)), 
                                                                     column(3, numericInput(inputId = "voice_avs_fee", label = "Voice AVS Request Fee", value = 0.65, min = 0, max = 1000000, step = 1000), 
                                                                            numericInput(inputId = "aru_auth_fee", label = "ARU Authorization Fee", value = 0.5, min = 0, max = 1000000, step = 1000)),
                                                                     column(3, numericInput(inputId = "voice_avs_auth_fee", label = "Voice AVS Authorization Fee", value = 1.75, min = 0, max = 1000000, step = 1000))
                                                            ),
                                                            fluidRow( column(12, tags$a("Other Pricing Options"))),
                                                            fluidRow(
                                                              column(3, disabled(numericInput(inputId = "paper_reporting_fee", label = "Paper Reporting Fee", value = 50, min = 0, max = 1000000, step = 1000))), 
                                                              column(3, numericInput(inputId = "application_fee", label = "Application Fee", value = 0, min = 0, max = 1000000, step = 1000)), 
                                                              column(3, numericInput(inputId = "monthly_maintainence_fee", label = "Monthly Maintenance Fee", value = 0, min = 0, max = 1000000, step = 1000)),
                                                              column(3, numericInput(inputId = "sign_on_bonus", label = "Sign-On Bonus", value = 0, min = 0, max = 1000000, step = 1000))
                                                            )
                                                       ),
                                                       fluidRow(column(1, actionButton(inputId = "prev_cstm_cre_deb_pri", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_cstm_cre_deb_pri", label = "Next", icon = icon("arrow-right"))))
                                              ), 
                                              tabPanel(title = "Optional credit Products", value = "cstm_cre_opt",
                                                       
                                                       tags$div(id = 'optional_purchasing_card_level3', box(width = 12, collapsible = T, collapsed = F,  solidHeader = T, title = "Optional Credit Product Pricing: Purchasing Card Level 3", status = "primary",
                                                                                                            fluidRow(column(3,numericInput(inputId = "purchasing_card_level3_txns", label = "Purchasing Card Level 3 Txns:", value = 100)),
                                                                                                                     # column(3),
                                                                                                                     column(3,numericInput(inputId = "purchasing_card_level3_fee", label = "Purchasing Card Level 3 Fee:", value = 100)))
                                                       )),
                                                       tags$div(id = 'optional_account_updater', box(width = 12, collapsible = T, collapsed = F,  solidHeader = T, title = "Optional Credit Product Pricing: Account Updater", status = "primary",
                                                                                                     prettyCheckboxGroup(status = 'primary',inline = T, inputId = "visa_account_updater_type", label = "Visa Account Updater Type", choices = c("Batch", "Real Time")),
                                                                                                     fluidRow(
                                                                                                       column(3, numericInput(inputId = "accnt_updater_matches", label = "Account Updater Matches (V/MC)", value = 0)),
                                                                                                       # column(3),
                                                                                                       column(3, numericInput(inputId = "accnt_updater_match_fee", label = "Account Updater Match Fee", value = 0)),
                                                                                                       column(3, numericInput(inputId = "accnt_updater_montly_fee", label = "Account Updater Monthly Fee", value = 0))
                                                                                                     )
                                                       )),
                                                       tags$div(id = 'optional_fraud', box(width = 12, collapsible = T, collapsed = F,  solidHeader = T, title = "Optional Credit Product Pricing: Fraud Advice Reporting", status = "primary",
                                                                                           fluidRow(
                                                                                             column(3, numericInput(inputId = "num_visa_records", label = "# of Visa Records", value = 0),
                                                                                                    numericInput(inputId = "num_mc_records", label = "# of MasterCard Records", value = 0)),
                                                                                             # column(3),
                                                                                             column(3, disabled(numericInput(inputId = "visa_fraud_fee", label = "Visa Fraud Subscription Fee", value = 0)), 
                                                                                                    numericInput(inputId = "mc_fraud_fee", label = "MasterCard  Fraud Subscription Fee", value = 0))
                                                                                           )
                                                       )),
                                                       tags$div(id = 'optional_pinless', box(width = 12, collapsible = T, collapsed = F,  solidHeader = T, title = "Optional Debit Product Pricing: PINless Bin Management", status = "primary",
                                                                                             fluidRow(
                                                                                               column(3, numericInput(inputId = "pinless_bin_management_txns", label = "PINless Bin Management Txns", value = 0)),
                                                                                               # column(3),
                                                                                               column(3, numericInput(inputId = "pinless_bin_management_txn_fee", label = "PINless Bin Mgmt Txn Fee", value = 0.0200)), 
                                                                                               column(3, numericInput(inputId = "pinless_bin_management_montly_fee", label = "PINless Bin Mgmt Monthly Fee", value = 500))
                                                                                               
                                                                                             )
                                                       )),
                                                       tags$div(id = 'optional_multicurrency', box(width = 12, collapsible = T, collapsed = F,  solidHeader = T, title = "Optional Product Pricing: Multi-Currency", status = "primary", 
                                                                                                   prettyRadioButtons(shape = "round",  animation = 'jelly',inputId = "multicurrency_pricing_type", label = "PINless Bin Management Txns",choices = c("Multi-Currency", "AccessFX"), inline = T),
                                                                                                   fluidRow(column(3, numericInput(inputId = "non_usd_presentment_percent_vol", label = "Non-USD Presentment % of Volume", value = 0, min = 0, max = 100)),
                                                                                                            # column(3),
                                                                                                            column(3, 
                                                                                                                   numericInput(inputId = "fx_markup", label = "FX Markup", value = 0))
                                                                                                   )
                                                       )),
                                                       fluidRow(column(1, actionButton(inputId = "prev_cstm_cre_opt", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_cstm_cre_opt", label = "Next", icon = icon("arrow-right"))))
                                              )
                                              # )
                                              ,
                                              tabPanel(title = "ECP Information", value = "cstm_ecp_info",
                                                       
                                                       box( width = 12,
                                                            collapsible = T, collapsed = F,  solidHeader = T, title = "Electronic Check Processing (ECP) Information", status = "primary",
                                                            fluidRow(column(3, 
                                                                            selectInput(inputId = "type_of_service", label = "Type of service", choices = c("AUTH & DEPOSIT", "AUTH ONLY")),
                                                                            selectInput(inputId = "check_conversion", label = "Check Conversion", choices = c("None", "ARC Only", "POP Only", "Both"),  selected = "None"),
                                                                            br(),
                                                                            numericInput(inputId = "ecp_validate_only_txns", label = "ECP Validate Only Transactions", value = 0), 
                                                                            br(),
                                                                            numericInput(inputId = "ecp_debit_txns", label = "ECP Deposit Transactions", value = 0), 
                                                                            numericInput(inputId = "ecp_avg_tckt", label = "ECP Average Ticket", value = 0), 
                                                                            selectInput(inputId = "mop_organization", label = "Method of Payment Origination", choices = c("None", "Best Possible"), selected = "Best Possible"))),
                                                            fluidRow(column(3, numericInput(inputId = "paper_draft_percent_deposit_txns", label = "Paper Draft % of Deposit Txns", value = 0, min = 0, max = 100) ),
                                                                     column(3, br(), 500)),br(),
                                                            fluidRow(column(3, numericInput(inputId = "ecp_refund_ratio", label = "ECP Refund Ratio", value = 0)), 
                                                                     column(3, numericInput(inputId = "ecp_return_ratio", label = "ECP Return Ratio", value = 0)
                                                                     ))
                                                       ),
                                                       fluidRow(column(1, actionButton(inputId = "prev_cstm_ecp_info", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_cstm_ecp_info", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "ECP Pricing", value = "cstm_ecp_pri",
                                                       
                                                       box( width = 12,
                                                            collapsible = T, collapsed = F,  solidHeader = T, title = "Electronic Check Processing (ECP) Pricing", status = "primary", 
                                                            fluidRow(column(3, tags$a("ECP Validate(Auth Only Pricing"))),
                                                            fluidRow(column(3, numericInput(inputId = "ecp_val_only_txns", label = "ECP Validate Only Transactions", value = 0)), 
                                                                     column(3, numericInput(inputId = "echeck_val_fee", label = "eCheck Validation Fee", value = 0))),
                                                            fluidRow(column(3, tags$a("ECP Deposit Pricing"))),
                                                            fluidRow(column(3, numericInput(inputId = "echeck_ach_deposits", label = "eCheck ACH Deposits", value = 0)), 
                                                                     column(3, numericInput(inputId = "echeck_ach_deposit_fee", label = "eCheck ACH Deposit Fee", value = 0)),
                                                                     column(3, numericInput(inputId = "returns_ach_fee", label = "Return ACH Fee", value = 0))
                                                            ),
                                                            
                                                            fluidRow(column(3, numericInput(inputId = "echeck_paper_draft_deposits", label = "eCheck Paper Draft Deposits", value = 0)), 
                                                                     column(3, numericInput(inputId = "echeck_paper_draft_deposit_fee", label = "eCheck Paper Draft Deposit Fee", value = 0),
                                                                            numericInput(inputId = "deposit_matching_repair_fee", label = "Deposit Matching/Repair Fee", value = 0)
                                                                     ),
                                                                     column(3, numericInput(inputId = "returns_paper_draft_fee", label = "Returns Paper Draft Fee", value = 0),
                                                                            numericInput(inputId = "echeck_notification_of_change_fee", label = "eCheck Notification of Change Fee", value = 0)
                                                                     )
                                                            )
                                                            
                                                       ),
                                                       box( width = 12,
                                                            collapsible = T, collapsed = F,  solidHeader = T, title = "Optional ECP Product Pricing: Advanced Verification", status = "primary",
                                                            fluidRow(column(3, numericInput(inputId = "accnt_status_ver_txns", label = "Account Status Verification Txns", value = 0)), 
                                                                     column(3, numericInput(inputId = "accnt_owner_auth_txns", label = "Account Owner Authentication Txns", value = 0))),
                                                            fluidRow(column(3, numericInput(inputId = "accnt_status_ver_fee", label = "Account Status Verification Fee", value = 0)), 
                                                                     column(3, numericInput(inputId = "accnt_owner_auth_fee", label = "Account Owner Authentication Fee", value = 0)))), 
                                                       
                                                       
                                                       fluidRow(column(1, actionButton(inputId = "prev_cstm_ecp_pri", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_cstm_ecp_pri", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "Fund Transfer & Connectivity", value = "transfer_connectivity",
                                                       box( width = 12,
                                                            collapsible = T, collapsed = F,  solidHeader = T, title = "Funds Transfer Pricing", status = "primary",
                                                            fluidRow(column(3, numericInput(inputId = "annual_ach_funds_transfers", label = "Annual ACH Funds Transfers", value = 0), 
                                                                            numericInput(inputId = "annual_wire_funds_transfers", label = "Annual Wire Funds Transfers", value = 0)),
                                                                     column(3, numericInput(inputId = "ach_fund_transfer_fee", label = "ACH Funds Transfer Fee", value = 2.5), 
                                                                            numericInput(inputId = "wire_funds_transfer_fee", label = "Wire Funds Transfer Fee", value = 10)))
                                                       ),
                                                       tags$div(id = "connectivity_netconnect", box( width = 12,
                                                                                                     collapsible = T, collapsed = F,  solidHeader = T, title = "Connectivity Product Pricing: NetConnect", status = "primary",
                                                                                                     fluidRow(column(3, numericInput(inputId = "netconnect_txns", label = "NetConnect Transactions", value = 0)),
                                                                                                              column(3, numericInput(inputId = "netconnect_txn_fee", label = "NetConnect Transaction Fee", value = 0)), 
                                                                                                              column(3, numericInput(inputId = "netconnect_batch_monthly_fee", label = "NetConnect Batch Monthly Fee", value = 0))))),
                                                       tags$div(id = "connectivity_orbitalgateway", box( width = 12,
                                                                                                         collapsible = T, collapsed = F,  solidHeader = T, title = "Connectivity Product Pricing: Orbital Gateway", status = "primary",
                                                                                                         fluidRow(column(3, numericInput(inputId = "orbital_gateway_txns", label = "Orbital Gateway Transactions", value = 0), 
                                                                                                                         numericInput(inputId = "outlets_with_orbital_gateway_monthly_fee", label = "Outlets w/ Gateway Monthly Fee", value = 0)),
                                                                                                                  column(3, numericInput(inputId = "orbital_gateway_per_item_transport_fee", label = "Gateway Per Item Transport Fee", value = 0), 
                                                                                                                         numericInput(inputId = "orbital_gateway_per_outlet_monthly_fee", label = "Gateway Monthly Fee (per Outlet)", value = 0))))),
                                                       tags$div(id = "connectivity_hostedpay", box( width = 12,
                                                                                                    collapsible = T, collapsed = F,  solidHeader = T, title = "Connectivity Product Pricing: Hosted Pay Page", status = "primary",
                                                                                                    fluidRow(column(3, numericInput(inputId = "hostedpaypage_txns", label = "Hosted Pay Page Transactions", value = 0)),
                                                                                                             column(3, numericInput(inputId = "hostedpaypage_txn_fee", label = "Hosted Pay Page Transaction Fee", value = 0))))),
                                                       tags$div(id = "connectivity_framerelay", box( width = 12,
                                                                                                     collapsible = T, collapsed = F,  solidHeader = T, title = "Connectivity Product Pricing: Frame Relay", status = "primary",
                                                                                                     fluidRow(column(3, numericInput(inputId = "num_frame_relay_circuits", label = "Number of Frame Relay Circuits", value = 0)),
                                                                                                              column(3, numericInput(inputId = "network_admin_fee", label = "Network Administration Fee", value = 0))))),
                                                       fluidRow(column(1, actionButton(inputId = "prev_transfer_connectivity", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_transfer_connectivity", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "Security Product Pricing", value = "security",
                                                       tags$div(id = "security_encryption", box( width = 12,
                                                                                                 collapsible = T, collapsed = F,  solidHeader = T, title = "Safetech Encryption ", status = "primary",
                                                                                                 fluidRow(column(3, numericInput(inputId = "safetech_encryption_items", label = "Safetech Encryption Items", value = 0)),
                                                                                                          column(3, numericInput(inputId = "safetech_encryption_per_item_fee", label = "Safetech Encryption Per Item Fee", value = 0)), 
                                                                                                          column(3, numericInput(inputId = "safetech_encryption_monthly_fee", label = "Safetech Encryption Monthly Fee", value = 0))),
                                                                                                 fluidRow(column(12, 
                                                                                                                 prettyCheckboxGroup(inputId = "terminal_type",label = "Terminal Type",choices = c("Verifone", "Magtek", "Ingenico"), selected = character(0),inline = TRUE,  status = "primary"))
                                                                                                 ),
                                                                                                 fluidRow(column(3, numericInput(inputId = "ingenico_percent_encyption_items", label = "Ingenico % of Encryption Items", value = 0, min = 0, max = 100)))
                                                       )),
                                                       tags$div(id = "security_tokenization", box( width = 12,
                                                                                                   collapsible = T, collapsed = F,  solidHeader = T, title = "Safetech Tokenization", status = "primary",
                                                                                                   fluidRow(column(3, numericInput(inputId = "safetech_tokenization_items", label = "Safetech Tokenization Items", value = 0)),
                                                                                                            column(3, numericInput(inputId = "safetech_tokenization_per_item_fee", label = "Safetech Tokenization Per Item Fee", value = 0)), 
                                                                                                            column(3, numericInput(inputId = "safetech_tokenization_monthly_fee", label = "Safetech Tokenization Monthly Fee", value = 0))))),
                                                       tags$div(id = "security_page_encryption", box( width = 12,
                                                                                                      collapsible = T, collapsed = F,  solidHeader = T, title = "Safetech Page Encryption", status = "primary",
                                                                                                      fluidRow(column(3, numericInput(inputId = "safetech_page_encryption_items", label = "Safetech Page Encryption Items", value = 0)),
                                                                                                               column(3, numericInput(inputId = "safetech_page_encryption_per_item_fee", label = "Safetech Page Encryption Per Item Fee", value = 0)), 
                                                                                                               column(3, numericInput(inputId = "safetech_page_encryption_monthly_fee", label = "Safetech Page Encryption Monthly Fee", value = 0)))
                                                       )),
                                                       tags$div(id = "security_fraud", box( width = 12,
                                                                                            collapsible = T, collapsed = F,  solidHeader = T, title = "Safetech Fraud", status = "primary",
                                                                                            fluidRow(column(3, numericInput(inputId = "safetech_fraud_items", label = "Safetech Fraud Items", value = 0)),
                                                                                                     column(3, numericInput(inputId = "safetech_fraud_per_item_fee", label = "Safetech Fraud Per Item Fee", value = 0))
                                                                                            ),
                                                                                            fluidRow(column(2, tags$p(tags$strong("Elect Target & LexisNexis?"))),
                                                                                                     column(1, switchInput( inputId = "", onStatus = "success",  onLabel = "Yes", offLabel = "No", size = 'mini' , value = F)))
                                                       )),
                                                       fluidRow(column(1, actionButton(inputId = "prev_security", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_security", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "ChaseNet/ChasePay", value = "cstm_chnet_chpay",
                                                       box( width = 12,
                                                            collapsible = T, collapsed = F,  solidHeader = T, title = "Credit & Debit Processing Pricing", status = "primary",
                                                            fluidRow(column(3, tags$p("___")), column(2, tags$a("Cents per Transaction")), column(2, tags$a("%  on Sales"))),
                                                            fluidRow(column(3,tags$p("ChaseNet/Chase Pay Credit/Sig Debit Markup")), column(2, numericInput(inputId = "",label = "", value = 0)), column(2,  numericInput(inputId = "", label = "", value = 0, min = 0, max = 100))),
                                                            fluidRow(column(3,tags$p("ChaseNet PIN Debit Markup")), column(2, numericInput(inputId = "",label = "", value = 0)), column(2, numericInput(inputId = "", label = "", value = 0))),
                                                            br(), br(), 
                                                            fluidRow(column(3, tags$p("ChaseNet/Chase Pay Credit MDR")), column(2, disabled(numericInput(inputId = "", label = "", value = 0))), column(2, disabled(numericInput(inputId = "", label = "",value = 0, min = 0, max = 100)) )),
                                                            fluidRow(column(3,tags$p("ChaseNet/Chase Pay Sig Debit MDR")), column(2, disabled(numericInput(inputId = "", label = "",value = 0))), column(2, disabled(numericInput(inputId = "", label = "",value = 0, min = 0, max = 100)))),
                                                            fluidRow(column(3,tags$p("ChaseNet PIN Debit MDR")), column(2, disabled(numericInput(inputId = "", label = "",value = 0))), column(2,disabled(numericInput(inputId = "", label = "",value = 0, min = 0, max = 100)) ))
                                                       ),
                                                       fluidRow(column(1, actionButton(inputId = "prev_cstm_chnet_chpay", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_cstm_chnet_chpay", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "Referral Partner", value = "cstm_ref_part",
                                                       box( width = 12,
                                                            collapsible = T, collapsed = F,  solidHeader = T, title = "Credit & Debit Processing Pricing", status = "primary", 
                                                            fluidRow(column(3, numericInput(inputId = "", label = "Rev Share % to Referral Partner", value = 0, min = 0, max = 100), 
                                                                            numericInput(inputId = "", label = "Rev Share Per Item Expense", value = 0.05), 
                                                                            numericInput(inputId = "", label = "Rev Share Setup Expense", value = 0), 
                                                                            numericInput(inputId = "", label = "Rev Share Monthly Expense", value = 5)),
                                                                     column(3, numericInput(inputId = "rebate_percent_on_net_volume", label = "Rebate % on Net Volume", value = 0, min = 0, max = 100), 
                                                                            numericInput(inputId = "rebate_dollar_per_tran", label = "Rebate $ per Transaction", value = 0),
                                                                            numericInput(inputId = "rebate_setup", label = "Rebate - Setup", value = 0), 
                                                                            numericInput(inputId = "rebate_monthly", label = "Rebate - Monthly", value = 0)))
                                                       ),
                                                       fluidRow(column(1, actionButton(inputId = "prev_cstm_ref_part", label = "Prev", icon = icon("arrow-left"))),
                                                                column(10),
                                                                column(1, actionButton(inputId = "next_cstm_ref_part", label = "Next", icon = icon("arrow-right"))))
                                              ),
                                              tabPanel(title = "Summary", value = "summary",
                                                       
                                                       box( width = 6,
                                                            collapsible = T, collapsed = F,  solidHeader = T, title = "Merchant P&A", status = "primary", 
                                                            tableOutput(outputId = "summ_table")
                                                       ),
                                                       box( width = 6,
                                                            collapsible = T, collapsed = F,  solidHeader = T, title = "Comparison", status = "primary",
                                                            tableOutput(outputId = "summ_table1")
                                                       ),
                                                       box(width =12, collapsible = T, collapsed = F,  solidHeader = T, title = "Comparison Plot", status = "primary",
                                                           plotOutput(outputId = "plt")),
                                                       box(width =12, collapsible = T, collapsed = F,  solidHeader = T, title = "Schedule", status = "primary",
                                                           downloadButton("downloadData", label = "Download Schedule")),
                                                       fluidRow(column(1, actionButton(inputId = "prev_summary", label = "Prev", icon = icon("arrow-left"))))
                                              )
                                   )
                           )#,
                           # ================== Search Models ==================
                           # tabItem(tabName = "search")#,
                           # # ================== Guide ==================
                           # tabItem(tabName = "guide")
                         ))
  )
  # )
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
    # print("................ Staus report ................")
    # print(lst)
    # print(en)
    # print("..............................................")
    for(i in 1:length(en)){
      sel = paste0("#new li a[data-value='",lst[i], "']")
      # print(sel)
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
  tabs_list <- c("main", "standard_main","cstm_main", 
                 # "cre_and_deb",
                 "cstm_cre_deb_inf" , "cstm_cre_deb_pri", "cstm_cre_opt" , "cstm_ecp_info", "cstm_ecp_pri", "transfer_connectivity", "security", "cstm_chnet_chpay", "cstm_ref_part", "summary")
  tabs_enabled <-  c(T,F,F,F,
                     # F,
                     F,F,F,F,F,F,F,F,F)
  products_list <- c('au','cncp','pcl3','ff','plbm','ddr','ecp','mc')
  products_enabled <- c(F,F,F,F,F,F,F,F)
  products_selected <- c(F,F,F,F,F,F,F,F)
  equipment_list <- c( "Chase Mobile Checkout", "Chase Blue Terminal", "Virtual Terminal", "Authorize.Net")
  bundled_pricing_options_list <- c("Swiped: 2.60% + $0.10,<br/>Keyed: 3.50% + $0.10",
                                    "2.90% +<br/> $0.25", 
                                    "3.50% +<br/> $0.10",
                                    "Credit: 2.21% <br/> Debit: 1.64%  + 0.2 $",
                                    "Credit: 2.23% <br/> Debit: 1.67%  + 0.2 $",
                                    "Credit: 2.50% <br/> Debit: 1.30%  + 0.2 $",
                                    "Credit: 2.99% <br/> Debit: 2.99%  + 0.25 $")
  #==========================================================================================
  #                                       Run on Startup
  #==========================================================================================
  
  output$architecture_image <- renderImage({
    filename <- normalizePath(file.path('./arch.PNG'))
    list(src = filename, width =1250, height = 675)
  }, deleteFile = FALSE)
  output$i <- renderDataTable(expr = {InProgress}, options = list(pageLength = 10, lengthMenu = list(c(10, 20, -1), c('10', '20', 'All')), searchHighlight = TRUE))
  output$c <- renderDataTable(expr = {}, options = list(pageLength = 10, lengthMenu = list(c(10, 20, -1), c('10', '20', 'All')), searchHighlight = TRUE))
  output$e <- renderDataTable(expr = {}, options = list(pageLength = 10, lengthMenu = list(c(10, 20, -1), c('10', '20', 'All')), searchHighlight = TRUE))
  output$summ_table <- renderTable(expr = {formattable(summ_table)}, striped = T, bordered = T, spacing = "s")
  output$summ_table1 <- renderTable(expr = {formattable(summ_table1 %>% select(-Type_))}, striped = T, bordered = T, spacing = "s")
  output$plt <- renderPlot( 
    ggplot(data = summ_table1, aes(x = VOLUME.., y = NET.REVENUE.. , color = Type_)) + 
      geom_point() + 
      labs(x = "Processing Volume", y = "Net Revenue") + 
      geom_text(aes(label=TYPE),hjust=0, vjust=0) + 
      ggtitle("Net Revenue Comparison")
  )
  cur_page <- reactive(input$new)
  load_pages(tabs_list, tabs_enabled)
  # output$mcc_desc <- renderText(expr = {mcc[mcc$mcc_code == input$mcc, 2]})
  update_products(products_list, products_enabled, NULL, session)
  
  #==========================================================================================
  #                                       Page Navigation
  #==========================================================================================
  observeEvent( {
    input$next_cstm_cre_deb_inf | input$next_cstm_cre_deb_pri | input$next_cstm_cre_opt | input$next_cstm_ecp_info | input$next_cstm_ecp_pri  | input$next_cstm_chnet_chpay | input$next_cstm_ref_part | input$next_transfer_connectivity | input$next_security | input$next_standard_main
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
    input$prev_cstm_cre_deb_inf | input$prev_cstm_cre_deb_pri | input$prev_cstm_cre_opt | input$prev_cstm_ecp_info | input$prev_cstm_ecp_pri  | input$prev_cstm_chnet_chpay | input$prev_cstm_ref_part | input$prev_transfer_connectivity | input$prev_security  | input$prev_cstm_main | input$prev_standard_main |  input$prev_summary}, 
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
      updateTabsetPanel(session, "new", selected = "cstm_main")
    }
    # print(tabs_enabled)
  })
  # observeEvent({input$client_segment}, {
  #   if(input$client_segment=="Small (<$5MM)"){
  #     updatePrettyRadioButtons(session = session, inputId = "pricing_strategy", selected = "Standard", choices = c("Standard"), inline = T, prettyOptions = list(shape = 'round'))
  #     updateNumericInput(session = session, inputId = "monthly_maintainence_fee", value = 10, min = 0, max = 1000000, step = 1000)}
  #   else{
  #     updatePrettyRadioButtons(session = session, inputId = "pricing_strategy", selected = input$pricing_strategy, choices = c("Standard", "Custom")  , inline = T, prettyOptions = list(shape = 'round'))
  #     updateNumericInput(session = session, inputId = "monthly_maintainence_fee", value = 0, min = 0, max = 1000000, step = 1000)}
  # })
  # observeEvent({input$region}, {
  #   if("EMEA" %in% input$region | "APAC" %in% input$region){updatePrettyRadioButtons(session = session, inputId = "platform", selected = "Global", choices = c("Global"), inline = T, prettyOptions = list(shape = 'round'))}
  #   else{updatePrettyRadioButtons(session = session, inputId = "platform", selected = input$platform, choices = c("Global", "NAP"), inline = T, prettyOptions = list(shape = 'round'))}
  # }, ignoreNULL = FALSE)
  #==========================================================================================
  #                                       Reactives - Standard Main
  #==========================================================================================
  
  # nonprofit_partner_flag <- eventReactive(c(input$referal_partner_flag, input$referral_partner_name),{
  #   if(input$referral_partner_name == "Non Profit Organization"){T}
  #   else{F}
  # })
  # 
  # bundled_pricing_options_reac <- eventReactive(
  #   c(input$payment_acceptance_type, input$avg_tckt_std, input$foreign_issued_txns, input$equipment_type, input$merchant_txns_std,
  #     input$primary_cust_type, input$referal_partner_flag ,nonprofit_partner_flag(), input$merchant_sales_std), 
  #   {
  #     x = bundled_pricing_options %>% 
  #       filter(
  #         (alwaysShow == "Y") | 
  #           (ifelse(input$referal_partner_flag, "Y", "N") == partner_flag &
  #              ifelse(input$referal_partner_flag, input$referral_partner_name, "") == partner_name & 
  #              input$avg_tckt_std >= avgTcktMin &  input$avg_tckt_std <= avgTcktMax &
  #              input$merchant_sales_std >= volGrossAmtMin & input$merchant_sales_std <= volGrossAmtMax &
  #              input$merchant_txns_std >= volGrossCntMin & input$merchant_txns_std <= volGrossCntMax &
  #              grepl(input$primary_cust_type, primary_cust_type) &
  #              grepl(input$foreign_issued_txns, foreign_issued_txns) &
  #              grepl(input$payment_acceptance_type, paymentAcceptanceType) &
  #              grepl(input$equipment_type, equipment_type) 
  #           )
  #       ) %>% 
  #       pull(pricing_option) 
  #     print("----------------------------------------------")
  #     print(x)
  #     
  #     x
  #   }, ignoreNULL = F)
  # 
  # observeEvent(bundled_pricing_options_reac(), {
  #   updateRadioGroupButtons(session = session, inputId = "bundled_pricing_options", selected = input$bundled_pricing_options,
  #                           choices = bundled_pricing_options_reac(), status = "primary", checkIcon = list(yes = icon("ok", lib = "glyphicon")))
  #   
  # }, ignoreNULL = F, ignoreInit = F)
  # 
  # 
  # observeEvent(
  #   {
  #     input$payment_acceptance_type}, {
  #       if(input$payment_acceptance_type == 'In Person'){
  #         print("Payment Acceptance Type = In Person")
  #         x <- equipment_list[( equipment_list  %in% input$equipment_type ) & c(T,T,F,F)]
  #         shinyjs::disable(selector = "#equipment_type input[value='Virtual Terminal']")
  #         shinyjs::disable(selector = "#equipment_type input[value='Authorize.Net']")
  #         if(input$equipment_type %in% c('Virtual Terminal', 'Authorize.Net')){
  #           updatePrettyRadioButtons(session = session, inputId = "equipment_type", inline = T, 
  #                                    # choices = equipment_list,
  #                                    selected = "Chase Mobile Checkout", prettyOptions = list(shape = 'round'))
  #         }
  #       }
  #       else{
  #         print("Payment Acceptance Type != In Person")
  #         shinyjs::enable(selector = "#equipment_type input[value='Virtual Terminal']")
  #         shinyjs::enable(selector = "#equipment_type input[value='Authorize.Net']")
  #       }
  #     }
  # )
  # observeEvent( c(input$bundled_pricing_options, input$referal_partner_flag), {
  #   if(! input$referal_partner_flag ) {
  #     # print("Enabling Bundled Pricing. Disabling Interchange Pricing")
  #     updateRadioGroupButtons(session = session, inputId = "interchange_pass_thru_pricing_options", selected = character(0),
  #                             choices = c("0.35% + $0.10,<br/>$9.95 Monthly Fee", "0.55% + $0.10,<br/>$0 Monthly Fee"), status = "primary", checkIcon = list(yes = icon("ok", lib = "glyphicon")))}
  # }, ignoreNULL = F)
  # 
  # observeEvent(c(input$interchange_pass_thru_pricing_options, input$referal_partner_flag), {
  #   if(! input$referal_partner_flag ) {
  #     # print("Enabling Interchange Pricing. Disabling Bundled Pricing")
  #     updateRadioGroupButtons(session = session, inputId = "bundled_pricing_options", selected = character(0),
  #                             choices = bundled_pricing_options_reac(), status = "primary", checkIcon = list(yes = icon("ok", lib = "glyphicon")))
  #   }
  # }, ignoreNULL = F)
  # 
  # observeEvent(input$referal_partner_flag, {
  #   if(!input$referal_partner_flag){
  #     shinyjs::hideElement(id = "referral_partner_name", anim = T, animType = "slide")
  #     # shinyjs::hideElement(id = "non_profit_text", anim = T, animType = "slide")
  #     
  #     
  #   }
  #   else{
  #     shinyjs::showElement(id = "referral_partner_name", anim = T, animType = "slide")
  #     # shinyjs::showElement(id = "non_profit_text", anim = T, animType = "slide")
  #   }
  # })
  # 
  # output$downloadData <- downloadHandler(
  #   filename <- function() {
  #     paste("schedule", "docx", sep=".")
  #   },
  #   
  #   content <- function(file) {
  #     s <- ""
  #     if(input$referal_partner_flag & (!nonprofit_partner_flag())){
  #       if (input$referral_partner_name == "Mohawk Bundled"){
  #         if(!is.na(input$merchant_sales_std)){
  #           if(input$merchant_sales_std < 1000000){ s <- "Mohawk_greater_than_1M.docx" }
  #           else{ s <- "Mohawk_less_than_1M.docx"}
  #         }
  #       }
  #       else{
  #         s <- "ADA.docx"
  #       }
  #       
  #     }
  #     if(input$referal_partner_flag & nonprofit_partner_flag()){
  #       s <- "Non_profit1.docx"
  #     } 
  #     
  #     file.copy(s, file)
  #   }
  #   , contentType = "application/msword" #NA
  # )
  # 
  # observeEvent(input$downloadData, {
  #   if(input$referal_partner_flag){shinyjs::hideElement(id = "downloadData")}
  #   else{shinyjs::showElement(id = "downloadData")}
  # })
  #==========================================================================================
  #                                       Reactives - Custom Main
  #==========================================================================================
  observeEvent(input$next_cstm_main, {
    ##### show all relevant elements & hide the rest
    # print("============ Status Report From Custom Main ============")
    # print(tabs_enabled)
    tabs_enabled[-c(1,2,3)] <<- tabs_enabled[-c(1,2,3)] & F
    if("Credit" %in% input$mop | "PIN-Based Debit" %in% input$mop | "PINless Debit" %in% input$mop){
      tabs_enabled[tabs_list == "cstm_cre_deb_inf"] <<- T
      tabs_enabled[tabs_list == "cstm_cre_deb_pri"] <<- T
    }
    if("Credit" %in% input$mop){
      tabs_enabled[tabs_list == "cre_and_deb"] <<- T
    }
    if("pcl3" %in% input$processing_options | "au" %in% input$processing_options | "plbm" %in% input$processing_options | "mc" %in% input$processing_options | "Fraud Advice Reporting" %in% input$analytics_products){
      tabs_enabled[tabs_list == "cstm_cre_opt"] <<- T
      tabs_enabled[tabs_list == "cre_and_deb"] <<- T
    }
    if("Electronic Check (ECP)" %in% input$mop ){
      tabs_enabled[tabs_list == "cstm_ecp_info"] <<- T
      tabs_enabled[tabs_list == "cstm_ecp_pri"] <<- T
    }
    if("ChaseNet/ ChasePay" %in% input$mop ){
      tabs_enabled[tabs_list == "cstm_chnet_chpay"] <<- T
    }
    if(input$referal_partner_flag){
      tabs_enabled[tabs_list == "cstm_ref_part"] <<- T
    }
    if(length(input$security_products) > 0) {
      tabs_enabled[tabs_list == "security"] <<-T
    }
    tabs_enabled[tabs_list == "transfer_connectivity"] <<- T
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
  })
  ### MCC update placed in startup segment
  observeEvent({input$mop}, {
    if("Credit" %in% input$mop){
      shinyjs::showElement(id = "amex")
      shinyjs::showElement(id = "discover")
      shinyjs::showElement(id = "voice_auth_ratio")
      shinyjs::showElement(id = 'analytics_products')
      shinyjs::showElement(id = "voice_auth_section")
      products_enabled[products_list %in% c('au', 'cncp', 'pcl3', 'ff', 'mc')]  <<- T
    }else{
      shinyjs::hideElement(id = "amex")
      shinyjs::hideElement(id = "discover")
      shinyjs::hideElement(id = "voice_auth_ratio")
      shinyjs::hideElement(id = 'analytics_products')
      shinyjs::hideElement(id = "voice_auth_section")
      products_enabled[products_list %in% c('au', 'cncp', 'pcl3', 'ff', 'mc')]  <<- F
    }
    if("PIN-Based Debit" %in% input$mop | "PINless Debit" %in% input$mop){products_enabled[products_list  == 'ddr']  <<- T}
    else{products_enabled[products_list  == 'ddr']  <<- F}
    if("PINless Debit" %in% input$mop){products_enabled[products_list  == 'plbm']  <<- T;  shinyjs::showElement(id = "pinless")}
    else{products_enabled[products_list  == 'plbm']  <<- F;  shinyjs::hideElement(id = "pinless")}
    if("PIN-Based Debit" %in% input$mop){shinyjs::showElement(id = "pin")}
    else{shinyjs::hideElement(id = "pin")}
    if("Electronic Check (ECP)" %in% input$mop ){products_enabled[products_list  == 'ecp']  <<- T}
    else{products_enabled[products_list  == 'ecp']  <<- F}
    # print(products_list)
    # print(products_enabled)
    # print(input$processing_options)
    update_products(l = products_list, e = products_enabled, s = input$processing_options, sess = session)
  }, ignoreNULL = FALSE)
  
  observe({
    if('Orbital Gateway' %in% input$connectivity_products){
      updatePrettyCheckboxGroup(session = session,
                                inputId = "connectivity_products",
                                choices = c('NetConnect', 'Orbital Gateway', 'Hosted Pay Page', 'Frame Relay'),
                                inline = T, selected = input$connectivity_products)
    }
    else{
      updatePrettyCheckboxGroup(session = session,
                                inputId = "connectivity_products",
                                choices = c('NetConnect', 'Orbital Gateway', 'Frame Relay'),
                                inline = T, selected = input$connectivity_products)
    }
  })
  observe({
    if('Safetech Tokenization' %in% input$security_products){
      updatePrettyCheckboxGroup(session = session,
                                inputId = "security_products",
                                choices =  c('Safetech Encryption', 'Safetech Tokenization','Safetech Page Encryption', 'Safetech Fraud'),
                                inline = T, selected = input$security_products)
    }
    else{
      updatePrettyCheckboxGroup(session = session,
                                inputId = "security_products",
                                choices =  c('Safetech Encryption', 'Safetech Tokenization',  'Safetech Fraud'),
                                inline = T, selected = input$security_products)
    }
  })
  #==========================================================================================
  #                                       Reactives - Credit & Debit Processing Information
  #==========================================================================================
  amex_percent_vol_reac <- reactive({ifelse(is.na(input$amex_percent) | is.na(input$annual_gross_sales_vol), 0 , input$amex_percent * input$annual_gross_sales_vol / 100)})
  discover_percent_vol_reac <- reactive({ifelse(is.na(input$discover_percent) | is.na(input$annual_gross_sales_vol), 0 , input$discover_percent * input$annual_gross_sales_vol / 100) })
  pin_percent_vol_reac <- reactive({ifelse(is.na(input$pin_percent) | is.na(input$annual_gross_sales_vol), 0 , input$pin_percent * input$annual_gross_sales_vol / 100) })
  pinless_percent_vol_reac <- reactive({ifelse(is.na(input$pinless_percent) | is.na(input$annual_gross_sales_vol), 0 , input$pinless_percent * input$annual_gross_sales_vol / 100) })
  output$amex_percent_vol <- renderText(expr = { paste0("$ ", prettyNum(x = amex_percent_vol_reac(), big.mark = ",", scientific=F) ) })
  output$discover_percent_vol <- renderText(expr = {paste0("$ ", prettyNum(x = discover_percent_vol_reac(), big.mark = ",", scientific=F) ) })
  output$pin_percent_vol <- renderText(expr = { paste0("$ ", prettyNum(x = pin_percent_vol_reac(), big.mark = ",", scientific=F) ) })
  output$pinless_percent_vol <- renderText(expr = { paste0("$ ", prettyNum(x = pinless_percent_vol_reac(), big.mark = ",", scientific=F) ) })
  observe({
    if(amex_percent_vol_reac() < 1000000){
      updateSelectInput(session = session, inputId = "amex_processing_type", choices = c("Conveyed", "Settled"), selected = input$amex_processing_type)
    }else{
      updateSelectInput(session = session, inputId = "amex_processing_type", choices = c("Conveyed"), selected = "Conveyed")
    }
  })
  
  observeEvent({input$dual_auth_network}, {
    if(input$dual_auth_network  == 'None'){
      shinyjs::disable(id = "percent_dial_auth")
      updateNumericInput(session = session, inputId = "percent_dial_auth", value = 0)
    }else{
      shinyjs::enable(id = "percent_dial_auth")
      updateNumericInput(session = session, inputId = "percent_dial_auth", value = 3)
    }
  })
  #==========================================================================================
  #                                       Reactives - Credit & Debit Processing Pricing
  #==========================================================================================
  observeEvent(c(input$annual_gross_txns, input$return_ratio), {a <- input$annual_gross_txns * (100 + input$return_ratio) / 100; updateNumericInput(inputId = "txns", session = session, value = a)}, ignoreNULL = F)
  observeEvent(c(input$txns, input$auth2tran_ratio), { updateNumericInput(inputId = "auths", session = session, value = input$txns *  input$auth2tran_ratio/100)}, ignoreNULL = F)
  observeEvent(c(input$annual_gross_sales_vol, input$return_ratio), { updateNumericInput(inputId = "sales", session = session, value = input$annual_gross_sales_vol * (100 - input$return_ratio)/100)}, ignoreNULL = F)
  observeEvent(c(input$txns, input$chargeback_ratio), { updateNumericInput(inputId = "chargebacks", session = session, value = input$txns * input$chargeback_ratio /100)}, ignoreNULL = F)
  observeEvent(c(input$auths, input$voice_auth_ratio), { updateNumericInput(inputId = "voice_authorizations", session = session, value = input$voice_auth_ratio *  input$auths / 100)}, ignoreNULL = F)
  observeEvent(c(input$auths, input$voice_auth_ratio), { updateNumericInput(inputId = "paper_reporting_fee", session = session, value = input$voice_auth_ratio *  input$auths / 100)}, ignoreNULL = F)
  #==========================================================================================
  #                                       Reactives - Optional Credit products
  #==========================================================================================
  observeEvent(c(input$analytics_products, input$processing_options), {
    if("pcl3" %in% input$processing_options){ shinyjs::show(id = "optional_purchasing_card_level3") }
    else{ shinyjs::hide(id = "optional_purchasing_card_level3") }
    
    if("au" %in% input$processing_options){ shinyjs::show(id = "optional_account_updater") }
    else{ shinyjs::hide(id = "optional_account_updater") }
    
    if("Fraud Advice Reporting" %in% input$analytics_products){ shinyjs::show(id = "optional_fraud") }
    else{ shinyjs::hide(id = "optional_fraud") }
    
    if("plbm" %in% input$processing_options){ shinyjs::show(id = "optional_pinless") }
    else{ shinyjs::hide(id = "optional_pinless") }
    
    if("mc" %in% input$processing_options){ shinyjs::show(id = "optional_multicurrency") }
    else{ shinyjs::hide(id = "optional_multicurrency") }
  }, ignoreNULL = FALSE)
  #==========================================================================================
  #                                       Reactives - Fund Transfer & Connectivity Products
  #==========================================================================================
  observeEvent(input$connectivity_products, {
    if("NetConnect" %in% input$connectivity_products){ shinyjs::show(id = "connectivity_netconnect") }
    else{ shinyjs::hide(id = "connectivity_netconnect") }
    
    if("Orbital Gateway" %in% input$connectivity_products){ shinyjs::show(id = "connectivity_orbitalgateway") }
    else{ shinyjs::hide(id = "connectivity_orbitalgateway") }
    
    if("Hosted Pay Page" %in% input$connectivity_products){ shinyjs::show(id = "connectivity_hostedpay") }
    else{ shinyjs::hide(id = "connectivity_hostedpay") }
    
    if("Frame Relay" %in% input$connectivity_products){ shinyjs::show(id = "connectivity_framerelay") }
    else{ shinyjs::hide(id = "connectivity_framerelay") }
  }, ignoreNULL = FALSE)
  #==========================================================================================
  #                                       Reactives - Security Product Pricing
  #==========================================================================================
  observeEvent(input$security_products, {
    if("Safetech Encryption" %in% input$security_products){ shinyjs::show(id = "security_encryption") }
    else{ shinyjs::hide(id = "security_encryption") }
    
    if("Safetech Tokenization" %in% input$security_products){ shinyjs::show(id = "security_tokenization") }
    else{ shinyjs::hide(id = "security_tokenization") }
    
    if("Safetech Page Encryption" %in% input$security_products){ shinyjs::show(id = "security_page_encryption") }
    else{ shinyjs::hide(id = "security_page_encryption") }
    
    if("Safetech Fraud" %in% input$security_products){ shinyjs::show(id = "security_fraud") }
    else{ shinyjs::hide(id = "security_fraud") }
  }, ignoreNULL = FALSE)
  observeEvent(input$terminal_type, {
    if('Ingenico' %in% input$terminal_type){shinyjs::showElement(id = 'ingenico_percent_encyption_items', anim = T, animType = 'slide')}
    else{shinyjs::hideElement(id = 'ingenico_percent_encyption_items', anim = T, animType = 'slide')}
  }, ignoreNULL = FALSE)
  #==========================================================================================
  #                                       Reactives - ECP Information
  #==========================================================================================
  
  observeEvent(input$type_of_service, {
    if(input$type_of_service == "AUTH ONLY"){
      updateSelectInput(session = session, inputId = "check_conversion", selected = "None")
      shinyjs::disable(id = "check_conversion")
      
      updateNumericInput(session = session, inputId = "ecp_debit_txns", value = 0)
      shinyjs::disable(id = "ecp_debit_txns")
    }
    else{
      shinyjs::enable(id = "check_conversion")
      shinyjs::enable(id = "ecp_debit_txns")
    }
    
    if(input$type_of_service == "AUTH & DEPOSIT"){
      updateSelectInput(session = session, inputId = "check_conversion", selected = "None")
      shinyjs::disable(id = "check_conversion")
    }
    else{
      shinyjs::enable(id = "check_conversion")
      shinyjs::enable(id = "ecp_debit_txns")
    }
    
  }, ignoreNULL = F)
  
  #==========================================================================================
  #                                       Calculations
  #==========================================================================================
  
  ach_fund_tansfer_rev <- eventReactive(c(input$ach_fund_transfer_fee, input$annual_ach_funds_transfers), 
                                        {ifelse(is.na(input$ach_fund_transfer_fee * input$annual_ach_funds_transfers),0,input$ach_fund_transfer_fee * input$annual_ach_funds_transfers) })
  wire_funds_transfer_rev <- eventReactive(c(input$wire_funds_transfer_fee, input$annual_wire_funds_transfers), 
                                           {ifelse(is.na(input$wire_funds_transfer_fee * input$annual_wire_funds_transfers),0,input$wire_funds_transfer_fee * input$annual_wire_funds_transfers)})
  rebate_net_sales_rev <- eventReactive(c(input$rebate_percent_on_net_volume, input$sales), 
                                        {ifelse(is.na(input$rebate_percent_on_net_volume* input$sales),0,(input$rebate_percent_on_net_volume* input$sales))})
  rebate_setup_rev <- eventReactive(c(input$rebate_setup),
                                    {ifelse(is.na(input$rebate_setup),0,(input$rebate_setup))})
  rebate_monthly_rev <- eventReactive(c(input$rebate_monthly), {ifelse(is.na(input$rebate_monthly),0, (input$rebate_monthly * 12))})
  rebate_per_capture_rev   <- eventReactive(c(input$rebate_dollar_per_tran, input$txns), {ifelse(is.na(input$rebate_dollar_per_tran* input$txns),0,(input$rebate_dollar_per_tran* input$txns))})
  
  
  other_rev <- reactive({sum(ach_fund_tansfer_rev() , wire_funds_transfer_rev() , rebate_net_sales_rev() , rebate_setup_rev() , rebate_monthly_rev() , rebate_per_capture_rev(), na.rm = T)})
  
  
  #---------- Credit
  auth_fee_rev <- reactive({ifelse( 'Credit' %in% input$mop & !is.na(input$auths * input$auth_fee),(input$auths * input$auth_fee),0)})
  txn_fee_rev <- eventReactive(c(input$txn_fee, input$txns, input$mop),
                               {ifelse( 'Credit' %in% input$mop & !is.na(input$txn_fee * input$txns),(input$txn_fee * input$txns),0)}
  )
  discount_rate_rev <- eventReactive(c(input$sales, input$discount_rate, input$mop), {ifelse( 'Credit' %in% input$mop & !is.na(input$sales * input$discount_rate),(input$sales * input$discount_rate),0)} )
  
  chargeback_fee_rev <- eventReactive(c(input$chargebacks, input$cback_fee, input$mop),
                                      {ifelse( 'Credit' %in% input$mop & !is.na(input$chargebacks * input$cback_fee),(input$chargebacks * input$cback_fee),0)}
  )
  collection_fee_rev <- eventReactive(c(input$chargebacks, input$comp_fee, input$mop), 
                                      {ifelse( 'Credit' %in% input$mop & !is.na(input$chargebacks * input$comp_fee),(input$chargebacks * input$comp_fee),0)}
  )
  voice_auth_rev <- eventReactive(c(input$voice_authorizations, input$voice_auth_rev_fee, input$mop), 
                                  {ifelse( 'Credit' %in% input$mop & !is.na(input$voice_authorizations * input$voice_auth_rev_fee),(input$voice_authorizations * input$voice_auth_rev_fee),0)}
  )
  
  paper_reporting_rev <- eventReactive(c(input$paper_reporting_fee, input$mop), 
                                       {ifelse( 'Credit' %in% input$mop & !is.na(input$paper_reporting_fee ),(input$paper_reporting_fee * 12),0)}
  )
  monthly_maintainence_fee_rev <- eventReactive(c(input$monthly_maintainence_fee, input$mop),
                                                {ifelse( 'Credit' %in% input$mop & !is.na(input$monthly_maintainence_fee ),(input$monthly_maintainence_fee * 12),0)}
  )
  application_fee_rev <- eventReactive(c(input$application_fee, input$mop), 
                                       {ifelse( 'Credit' %in% input$mop & !is.na(input$application_fee),(input$application_fee),0)}
  )
  
  credit_rev <- reactive({sum(auth_fee_rev() , txn_fee_rev() , discount_rate_rev() ,       chargeback_fee_rev() , collection_fee_rev() , voice_auth_rev() , paper_reporting_rev() , monthly_maintainence_fee_rev() , application_fee_rev(), na.rm = T)})
  
  observeEvent(credit_rev(), {
    summ_table[summ_table$X_ == 'Credit Net Revenue', 'in_Dollars'] <<- credit_rev()
    output$summ_table <- renderTable(expr = {formattable(summ_table)}, striped = T, bordered = T, spacing = "s")
  })
  
  #---------- VAP
  purchasing_card_level3_rev <- eventReactive(c(input$purchasing_card_level3_fee, input$purchasing_card_level3_txns, input$processing_options),
                                              {ifelse('pcl3' %in% input$processing_options, input$purchasing_card_level3_fee * input$purchasing_card_level3_txns, 0)}
  )
  accnt_updater_match_rev <- eventReactive(c(input$accnt_updater_match_fee, input$accnt_updater_matches, input$processing_options), 
                                           {ifelse('au' %in% input$processing_options, (input$accnt_updater_match_fee * input$accnt_updater_matches), 0)}
  )
  accnt_updater_montly_rev <- eventReactive(c(input$accnt_updater_montly_fee, input$processing_options), 
                                            {ifelse('au' %in% input$processing_options, (input$accnt_updater_montly_fee * 12), 0)}
  )
  
  visa_fraud_rev <- eventReactive(c(input$visa_fraud_fee, input$num_visa_records, input$processing_options, input$analytics_products), 
                                  {ifelse('Credit' %in% input$mop & 'Fraud Advice Reporting' %in% input$analytics_products, (input$visa_fraud_fee * input$num_visa_records), 0)}
  )
  mc_fraud_rev <- eventReactive(c(input$mc_fraud_fee, input$num_mc_records, input$processing_options, input$analytics_products),
                                {ifelse('Credit' %in% input$mop & 'Fraud Advice Reporting' %in% input$analytics_products, (input$mc_fraud_fee * input$num_mc_records), 0)}
  )
  pinless_bin_management_fee_rev <- eventReactive(c(input$pinless_bin_management_txn_fee, input$pinless_bin_management_txns, input$processing_options),
                                                  {ifelse( 'plbm' %in% input$processing_options, (input$pinless_bin_management_txn_fee * input$pinless_bin_management_txns), 0)}
  )
  pinless_bin_management_montly_fee_rev <- eventReactive(c(input$pinless_bin_management_montly_fee, input$processing_options),
                                                         {ifelse( 'plbm' %in% input$processing_options, (input$pinless_bin_management_montly_fee * 12), 0)}
  )
  multicurrency_rev <- eventReactive(c(input$fx_markup, input$non_usd_presentment_percent_vol, input$annual_gross_sales_vol, input$processing_options), 
                                     {ifelse( 'mc' %in% input$processing_options, (input$fx_markup * input$non_usd_presentment_percent_vol * input$annual_gross_sales_vol), 0)}
  )
  
  # Connectivity
  netconnect_txn_rev <- eventReactive(c(input$netconnect_txn_fee, input$netconnect_txns, input$connectivity_products), 
                                      {ifelse( 'NetConnect' %in% input$connectivity_products, (input$netconnect_txn_fee* input$netconnect_txns), 0)}
  )
  netconnect_batch_monthly_fee_rev <- eventReactive(c(input$netconnect_batch_monthly_fee, input$connectivity_products), 
                                                    {ifelse( 'NetConnect' %in% input$connectivity_products, (input$netconnect_batch_monthly_fee * 12), 0)}
  )
  
  orbital_gateway_per_item_transport_fee_rev <- eventReactive(c(input$orbital_gateway_per_item_transport_fee, input$orbital_gateway_txns, input$connectivity_products), 
                                                              {ifelse( 'Orbital Gateway' %in% input$connectivity_products, (input$orbital_gateway_per_item_transport_fee* input$orbital_gateway_txns), 0)}
  )
  orbital_gateway_per_outlet_monthly_fee_rev <- eventReactive(c(input$orbital_gateway_per_outlet_monthly_fee, input$outlets_with_orbital_gateway_monthly_fee, input$connectivity_products), 
                                                              {ifelse( 'Orbital Gateway' %in% input$connectivity_products, (input$orbital_gateway_per_outlet_monthly_fee* input$outlets_with_orbital_gateway_monthly_fee), 0)}
  )
  hostedpaypage_txn_rev <- eventReactive(c(input$hostedpaypage_txns, input$hostedpaypage_txn_fee, input$connectivity_products), 
                                         {ifelse( 'Hosted Pay Page' %in% input$connectivity_products, (input$hostedpaypage_txns * input$hostedpaypage_txn_fee), 0)}
  )
  frame_relay_rev <- eventReactive(c(input$num_frame_relay_circuits, input$network_admin_fee, input$connectivity_products), 
                                   {ifelse( 'Frame Relay' %in% input$connectivity_products, (input$num_frame_relay_circuits* input$network_admin_fee), 0)}
  )
  
  # Security
  safetech_encryption_per_item_fee_rev <- eventReactive(c(input$safetech_encryption_per_item_fee, input$safetech_encryption_items, input$security_products), 
                                                        {ifelse( 'Safetech Encryption' %in% input$security_products, (input$safetech_encryption_per_item_fee * input$safetech_encryption_items), 0)}
  )
  safetech_encryption_ingenico_rev <- eventReactive(c(input$safetech_encryption_items, input$ingenico_percent_encyption_items, input$security_products), 
                                                    {ifelse( 'Safetech Encryption' %in% input$security_products, (-0.005 * input$safetech_encryption_items * (1 - input$ingenico_percent_encyption_items) ), 0)}
  )
  safetech_encryption_monthly_fee_rev <- eventReactive(c(input$safetech_encryption_monthly_fee, input$security_products),
                                                       {ifelse( 'Safetech Encryption' %in% input$security_products, (input$safetech_encryption_monthly_fee * 12), 0)}
  )
  
  safetech_tokenization_monthly_fee_rev <- eventReactive(c(input$safetech_tokenization_monthly_fee, input$security_products), 
                                                         {ifelse( 'Safetech Tokenization' %in% input$security_products, (input$safetech_tokenization_monthly_fee * 12), 0)}
  )
  safetech_tokenization_per_item_fee_rev <- eventReactive(c(input$safetech_tokenization_per_item_fee, input$safetech_tokenization_items, input$security_products), 
                                                          {ifelse( 'Safetech Tokenization' %in% input$security_products, input$safetech_encryption_per_item_fee * input$safetech_tokenization_items, 0)}
  )
  
  safetech_page_encryption_per_item_fee_rev <- eventReactive(c(input$safetech_page_encryption_per_item_fee, input$safetech_page_encryption_items, input$security_products),
                                                             {ifelse( 'Safetech Page Encryption' %in% input$security_products, (input$safetech_page_encryption_per_item_fee * input$safetech_page_encryption_items), 0)}
  )
  safetech_page_encryption_per_item_contra_rev <- eventReactive(c(input$safetech_page_encryption_items, input$security_products), 
                                                                {ifelse( 'Safetech Page Encryption' %in% input$security_products, (input$safetech_page_encryption_items * (-0.0013)), 0)}
  )
  
  safetech_page_encryption_monthly_fee_rev <- eventReactive(c(input$safetech_page_encryption_monthly_fee, input$security_products), 
                                                            {ifelse( 'Safetech Fraud' %in% input$security_products, (input$safetech_page_encryption_monthly_fee * 12), 0)}
  )
  safetech_fraud_per_item_fee_rev <- eventReactive(c(input$safetech_fraud_per_item_fee, input$safetech_fraud_items, input$security_products), 
                                                   {ifelse( 'Safetech Fraud' %in% input$security_products, (input$safetech_fraud_per_item_fee * input$safetech_fraud_items), 0)}
  )
  safetech_fraud_per_item_contra_rev  <- eventReactive(c(input$safetech_fraud_items, input$safetech_fraud_per_item_fee, input$processing_options), 
                                                       {ifelse( 'Safetech Fraud' %in% input$security_products, (
                                                         if(input$safetech_fraud_per_item_fee < 0.07){0.5 * input$safetech_fraud_per_item_fee < 0.07}
                                                         else if(input$safetech_fraud_items < 1000000){0.02*(0.3*(input$safetech_fraud_per_item_fee - 0.02))}
                                                         else{-0.015 * 0.3*(input$safetech_fraud_per_item_fee - 0.02)}
                                                       ), 0)}
  )
  
  vap_rev <- reactive({sum(purchasing_card_level3_rev() , accnt_updater_match_rev() , accnt_updater_montly_rev() , 
                           visa_fraud_rev() , mc_fraud_rev() , pinless_bin_management_fee_rev() , pinless_bin_management_montly_fee_rev() , multicurrency_rev() , netconnect_txn_rev() , 
                           netconnect_batch_monthly_fee_rev() , orbital_gateway_per_item_transport_fee_rev() , orbital_gateway_per_outlet_monthly_fee_rev() , hostedpaypage_txn_rev() ,
                           frame_relay_rev() , safetech_encryption_per_item_fee_rev() , safetech_encryption_ingenico_rev() , safetech_encryption_ingenico_rev() , safetech_encryption_monthly_fee_rev() ,
                           safetech_tokenization_monthly_fee_rev() , safetech_tokenization_monthly_fee_rev() , safetech_tokenization_per_item_fee_rev() , safetech_page_encryption_per_item_fee_rev() , 
                           safetech_page_encryption_per_item_contra_rev() , safetech_page_encryption_monthly_fee_rev() , safetech_fraud_per_item_fee_rev(), na.rm = T)})
  
  observeEvent(vap_rev(), {
    summ_table[summ_table$X_ == 'VAP Net Revenue', 'in_Dollars'] <<- vap_rev()
    output$summ_table <- renderTable(expr = {formattable(summ_table)}, striped = T, bordered = T, spacing = "s")
  })
  #---------- ECP
  echeck_realtime_val_rev <- eventReactive(c(input$echeck_val_fee, input$ecp_val_only_txns, input$mop), 
                                           {ifelse( 'Electronic Check (ECP)' %in% input$mop, (input$echeck_val_fee* input$ecp_val_only_txns), 0)}
  )
  echeck_ach_deposit_rev <- eventReactive(c(input$echeck_ach_deposit_fee, input$echeck_ach_deposits, input$mop), 
                                          {ifelse( 'Electronic Check (ECP)' %in% input$mop, (input$echeck_ach_deposit_fee* input$echeck_ach_deposits), 0)}
  )
  echeck_ach_redeposit_rev <- eventReactive(c(input$echeck_ach_deposit_fee, input$ecp_debit_txns, input$ecp_validate_only_txns, input$mop), 
                                            {ifelse( 'Electronic Check (ECP)' %in% input$mop, (input$echeck_ach_deposit_fee* (input$ecp_debit_txns + input$ecp_validate_only_txns) * 0.0013), 0)}
  )
  echeck_paper_draft_deposit_rev <- eventReactive(c(input$echeck_paper_draft_deposits, input$echeck_paper_draft_deposit_fee, input$mop),
                                                  {ifelse( 'Electronic Check (ECP)' %in% input$mop, (input$echeck_paper_draft_deposits* input$echeck_paper_draft_deposit_fee), 0)}
  )
  echeck_paper_draft_redeposit_rev <- eventReactive(c(input$echeck_paper_draft_deposits, input$echeck_paper_draft_deposit_fee, input$mop), 
                                                    {ifelse( 'Electronic Check (ECP)' %in% input$mop, (input$echeck_paper_draft_deposits* input$echeck_paper_draft_deposit_fee * 0.00008), 0)}
  )
  
  ecp_returns_ach_rev <- eventReactive(c(input$returns_ach_fee, input$ecp_debit_txns, input$paper_draft_percent_deposit_txns, input$ecp_return_ratio, input$mop), 
                                       {ifelse( 'Electronic Check (ECP)' %in% input$mop, (input$returns_ach_fee* (1 - input$paper_draft_percent_deposit_txns) * input$ecp_return_ratio), 0)}
  )
  
  ecp_returns_paperdraft_rev <- eventReactive(c(input$returns_paper_draft_fee, input$ecp_debit_txns, input$paper_draft_percent_deposit_txns, input$ecp_return_ratio, input$mop), 
                                              {ifelse( 'Electronic Check (ECP)' %in% input$mop, (input$returns_paper_draft_fee* (input$paper_draft_percent_deposit_txns) * input$ecp_return_ratio), 0)}
  )
  
  repair_rev <- eventReactive(c(input$deposit_matching_repair_fee, input$ecp_debit_txns, input$ecp_val_only_txns, input$mop), 
                              {ifelse( 'Electronic Check (ECP)' %in% input$mop, (input$deposit_matching_repair_fee* (input$ecp_debit_txns + input$ecp_val_only_txns) * 0.0056), 0)}
  )
  ecp_notification_of_revview_rev <- eventReactive(c(input$echeck_notification_of_change_fee, input$ecp_debit_txns, input$ecp_val_only_txns, input$mop), 
                                                   {ifelse( 'Electronic Check (ECP)' %in% input$mop, (input$echeck_notification_of_change_fee* (input$ecp_debit_txns + input$ecp_val_only_txns) * 0.00008), 0)}
  )  
  ecp_rejects_rev <- eventReactive(c(input$echeck_ach_deposit_fee, input$ecp_debit_txns, input$ecp_val_only_txns, input$mop),
                                   {ifelse( 'Electronic Check (ECP)' %in% input$mop, (input$echeck_ach_deposit_fee* (input$ecp_debit_txns + input$ecp_val_only_txns) * 0.0013), 0)}
  )
  ecp_account_status_verification_rev <- eventReactive(c(input$ach_fund_transfer_fee, input$accnt_status_ver_txns, input$mop), 
                                                       {ifelse( 'Electronic Check (ECP)' %in% input$mop, (input$accnt_status_ver_fee * input$accnt_status_ver_txns), 0)}
  )
  ecp_account_owner_authentication_rev <- eventReactive(c(input$accnt_owner_auth_txns, input$accnt_owner_auth_fee, input$mop), 
                                                        {ifelse( 'Electronic Check (ECP)' %in% input$mop, (input$accnt_owner_auth_txns * input$accnt_owner_auth_fee), 0)}
  )
  
  ecp_rev <- reactive({
    sum(echeck_realtime_val_rev() , echeck_ach_deposit_rev() , echeck_ach_redeposit_rev() , 
        echeck_paper_draft_deposit_rev() , echeck_paper_draft_redeposit_rev() , ecp_returns_ach_rev() , 
        ecp_returns_paperdraft_rev() , repair_rev() , ecp_notification_of_revview_rev() , 
        ecp_rejects_rev() , ecp_account_status_verification_rev() , ecp_account_owner_authentication_rev(), na.rm = T)
  })
  
  observeEvent(ecp_rev(), {
    summ_table[summ_table$X_ == 'ECP Net Revenue', 'in_Dollars'] <<- ecp_rev()
    output$summ_table <- renderTable(expr = {formattable(summ_table)}, striped = T, bordered = T, spacing = "s")
  })
  
  total_rev <- eventReactive(c(other_rev(), credit_rev(), vap_rev(), ecp_rev()), {sum(other_rev(), credit_rev(), vap_rev(), ecp_rev(), na.rm = T)})  
  
  observeEvent(total_rev(), {
    summ_table[summ_table$X_ == 'Total Net Revenue', 'in_Dollars'] <<-   paste("$",format(round(as.numeric(total_rev()), 1), nsmall=1, big.mark=",") )
    summ_table[summ_table$X_ == 'Total Net Revenue', 'in_Percentage'] <<- paste(format(round(as.numeric(total_rev() / ( input$sales * 0.0001)), 1), nsmall=1, big.mark=","), "BPS")
    summ_table[summ_table$X_ == 'Total Net Revenue', 'Per_Tran'] <<- paste("$",format(round(as.numeric(total_rev() / input$txns), 1), nsmall=1, big.mark=",") ) 
    
    summ_table[summ_table$X_ == 'Credit Net Revenue', 'in_Dollars'] <<- paste("$",format(round(as.numeric(credit_rev()), 1), nsmall=1, big.mark=",") )
    summ_table[summ_table$X_ == 'Credit Net Revenue', 'in_Percentage'] <<- paste(format(round(as.numeric(credit_rev() / ( input$sales * 0.0001)), 1), nsmall=1, big.mark=","), "BPS")
    summ_table[summ_table$X_ == 'Credit Net Revenue', 'Per_Tran'] <<- paste("$",format(round(as.numeric(credit_rev() / input$txns), 1), nsmall=1, big.mark=",") ) 
    
    summ_table[summ_table$X_ == 'ECP Net Revenue', 'in_Dollars'] <<- paste("$",format(round(as.numeric(ecp_rev()), 1), nsmall=1, big.mark=",") )
    summ_table[summ_table$X_ == 'ECP Net Revenue', 'in_Percentage'] <<- paste(format(round(as.numeric(ecp_rev() / ( input$sales * 0.0001)), 1), nsmall=1, big.mark=","), "BPS")
    summ_table[summ_table$X_ == 'ECP Net Revenue', 'Per_Tran'] <<- paste("$",format(round(as.numeric(ecp_rev() / input$txns), 1), nsmall=1, big.mark=",") ) 
    
    summ_table[summ_table$X_ == 'VAP Net Revenue', 'in_Dollars'] <<- paste("$",format(round(as.numeric(vap_rev()), 1), nsmall=1, big.mark=",") )
    summ_table[summ_table$X_ == 'VAP Net Revenue', 'in_Percentage'] <<- paste(format(round(as.numeric(vap_rev() / ( input$sales * 0.0001)), 1), nsmall=1, big.mark=","), "BPS")
    summ_table[summ_table$X_ == 'VAP Net Revenue', 'Per_Tran'] <<- paste("$",format(round(as.numeric(vap_rev() / input$txns), 1), nsmall=1, big.mark=",") ) 
    
    output$summ_table <- renderTable(expr = {formattable(summ_table)}, striped = T, bordered = T, spacing = "s")
  })
  # shinyAppDir(".")
  
}
shinyApp(ui = ui, server = server)
