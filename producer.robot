*** Settings ***
Library           Collections
Library           RPA.Robocorp.WorkItems
Library           RPA.Excel.Files
Library           RPA.Tables
Library           RPA.Dialogs
Library    RPA.Robocorp.Vault
*** Variables ***
${ORDER_FILE_NAME}=    orders.csv


*** Keywords ***


*** Tasks ***
Split orders file
    [Documentation]    Reads orders file from input item and creates workeritems
    ...    Asks user if they want to continue with orders.
    Get Work Item File    ${ORDER_FILE_NAME}
    ${table}=    Read table from CSV    ${ORDER_FILE_NAME}    header=True
    ${groups}=    Group Table By Column    ${table}    Order number

    ##reads user from vault:
    ${secret}=    Get Secret    robotsparebin
    Log    ${secret}[username]

    #asks user if we proceed?
    Add icon      Warning
    Add heading   ${secret}[username] do you want to proceed with orders?
    Add text    ${table}
    Add submit buttons    buttons=No,Yes    default=Yes
    ${result}=    Run dialog
    IF   $result.submit == "Yes"
        #Open Workbook    ${ORDER_FILE_NAME}

        
        FOR    ${products}    IN    @{groups}
            ${rows}=    Export Table    ${products}
            @{items}=    Create List
            FOR    ${row}    IN    @{rows}
                Create Output Work Item    variables=${row}    save=True
            END
            #${variables}=    Create Dictionary
            #...    Name= ${rows}[0][Order number]
            #...    Zip=  ${rows}[0][Head]
            #...    Items=${rows}[0][Body]
            
        END       
    END

